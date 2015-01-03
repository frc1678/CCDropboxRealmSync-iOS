//
//  CCDropboxSync.m
//  DropboxRealmClientTest
//
//  Created by Donald Pinckney on 12/21/14.
//  Copyright (c) 2014 citruscircuits. All rights reserved.
//

#import "CCDropboxSync.h"
@interface CCDropboxSync()
@property (nonatomic, strong) NSMutableDictionary *pathsToDBFiles;
@property (nonatomic, strong) NSMutableDictionary *pathsToArraysOfUpdateListeners;
@end

@implementation CCDropboxSync

- (NSMutableDictionary *)pathsToDBFiles
{
    if (!_pathsToDBFiles) {
        _pathsToDBFiles = [[NSMutableDictionary alloc] init];
    }
    return _pathsToDBFiles;
}


- (NSMutableDictionary *)pathsToArraysOfUpdateListeners
{
    if (!_pathsToArraysOfUpdateListeners) {
        _pathsToArraysOfUpdateListeners = [[NSMutableDictionary alloc] init];
    }
    return _pathsToArraysOfUpdateListeners;
}

+ (instancetype)sharedSync {
    static CCDropboxSync *sharedSync = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSync = [[self alloc] init];
    });
    return sharedSync;
}

- (void)path:(DBPath *)path addSetupListener:(CCDropboxFileCallback)setup updateListener:(CCDropboxFileCallback)update {
    if (!self.pathsToArraysOfUpdateListeners[path.stringValue]) {
        self.pathsToArraysOfUpdateListeners[path.stringValue] = [[NSMutableArray alloc] init];
    }

    
    if (![self.pathsToArraysOfUpdateListeners[path.stringValue] containsObject:update]) {
        [self.pathsToArraysOfUpdateListeners[path.stringValue] addObject:update];
    }
    
    if (!self.pathsToDBFiles[path.stringValue]) {
        NSError *error = nil;
        DBFileInfo *info = [[DBFilesystem sharedFilesystem] fileInfoForPath:path error:&error];
        if(error) {
            NSLog(@"Error getting file info: %@", error);
            return;
        }
        
        DBFile *file;
        if(info) {
            file = [[DBFilesystem sharedFilesystem] openFile:path error:nil];
        } else {
            file = [[DBFilesystem sharedFilesystem] createFile:path error:nil];
        }
        
        if(file == nil) {
            NSLog(@"Dropbox probably not linked yet... :(");
            return;
        }
        
        if(file.status.state == DBFileStateIdle) {
            setup(file);
        } else {
            __weak DBFile *weakFile = file;
            __weak CCDropboxSync *weakSelf = self;
            [file addObserver:self block:^{
                if(weakFile.status.state == DBFileStateIdle && weakFile.newerStatus == nil) {
                    NSLog(@"New data loaded for first time setup");
                    [weakFile update:nil];
                    
                    setup(weakFile);
                    
                    [weakFile removeObserver:weakSelf];
                    
                }
            }];
        }
        
        self.pathsToDBFiles[path.stringValue] = file;
        
        [[DBFilesystem sharedFilesystem] addObserver:self forPath:path block:^{
            NSLog(@"Path: %@ has been updated", path);
            [self loadFileFromDropbox:file];
        }];
    }
    
}





- (void)callUpdateMethods:(DBFile *)file {
    NSArray *updateArray = self.pathsToArraysOfUpdateListeners[file.info.path.stringValue];
    for(CCDropboxFileCallback callback in updateArray) {
        callback(file);
    }
}

- (void) loadFileFromDropbox:(DBFile *)file {
    [file update:nil];
    
    if(file.newerStatus == nil || file.newerStatus.state == DBFileStateIdle) {
        NSLog(@"Loading new data!");
        
        [self callUpdateMethods:file];
        
    } else {
        __weak DBFile *weakFile = file;
        __weak CCDropboxSync *weakSelf = self;
        [file addObserver:self block:^{
            if(weakFile.newerStatus.state == DBFileStateIdle) {
                NSLog(@"Loading new data!");
                [weakFile update:nil];
                
                [self callUpdateMethods:weakFile];
                
                [weakFile removeObserver:weakSelf];
                
            }
        }];
    }
    
}




- (id)initialReadFromPath:(DBPath *)path readingFromPathCallback:(CCDropboxFileCallbackDataResult)callback noFileYetCallback:(CCDropboxCallbackDataResult)noFileCallback
{
    if([DBFilesystem sharedFilesystem] == nil) {
        return nil;
    }
    
    DBFile *file = self.pathsToDBFiles[path.stringValue];
    BOOL createdNewFile = NO;
    if (!file) {
        // From http://stackoverflow.com/questions/16663000/ios-check-if-file-exists-dropbox-sync-api-ios-sdk
        DBFileInfo *info = [[DBFilesystem sharedFilesystem] fileInfoForPath:path error:nil];
        if(info) {
            file = [[DBFilesystem sharedFilesystem] openFile:path error:nil];
        } else {
            NSError *error;
            file = [[DBFilesystem sharedFilesystem] createFile:path error:&error];
            createdNewFile = YES;
        }
        self.pathsToDBFiles[path.stringValue] = file;
    }
    
    if(createdNewFile) {
        return noFileCallback();
    } else {
        return callback(file);
    }
}


- (BOOL)writeString:(NSString *)string toPath:(DBPath *)path {
    return [self writeData:[string dataUsingEncoding:NSUTF8StringEncoding] toPath:path];
}

- (BOOL)writeData:(NSData *)data toPath:(DBPath *)path {
    DBFile *file = self.pathsToDBFiles[path.stringValue];
    if(!file) {
        file = [CCDropboxSync createFileFromPath:path];
    }
    
    return [file writeData:data error:nil];
}



+ (DBFile *)createFileFromPath:(DBPath *)path {
    DBFile *file;
    
    // From http://stackoverflow.com/questions/16663000/ios-check-if-file-exists-dropbox-sync-api-ios-sdk
    DBFileInfo *info = [[DBFilesystem sharedFilesystem] fileInfoForPath:path error:nil];
    if(info) {
        file = [[DBFilesystem sharedFilesystem] openFile:path error:nil];
    } else {
        file = [[DBFilesystem sharedFilesystem] createFile:path error:nil];
    }

    return file;
}

@end
