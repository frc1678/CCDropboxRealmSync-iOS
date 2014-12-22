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
@property (nonatomic, strong) NSMutableDictionary *pathsToArraysOfSetupListeners;
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

- (NSMutableDictionary *)pathsToArraysOfSetupListeners
{
    if (!_pathsToArraysOfSetupListeners) {
        _pathsToArraysOfSetupListeners = [[NSMutableDictionary alloc] init];
    }
    return _pathsToArraysOfSetupListeners;
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

- (void)path:(DBPath *)path addSetupListener:(CCDropboxCallback)setup updateListener:(CCDropboxCallback)update {
    if (!self.pathsToArraysOfSetupListeners[path.stringValue]) {
        self.pathsToArraysOfSetupListeners[path.stringValue] = [[NSMutableArray alloc] init];
    }
    if (!self.pathsToArraysOfUpdateListeners[path.stringValue]) {
        self.pathsToArraysOfUpdateListeners[path.stringValue] = [[NSMutableArray alloc] init];
    }
    
    if (![self.pathsToArraysOfSetupListeners[path.stringValue] containsObject:setup]) {
        [self.pathsToArraysOfSetupListeners[path.stringValue] addObject:setup];
    }
    
    if (![self.pathsToArraysOfUpdateListeners[path.stringValue] containsObject:update]) {
        [self.pathsToArraysOfUpdateListeners[path.stringValue] addObject:update];
    }
    
    if (!self.pathsToDBFiles[path.stringValue]) {
        DBFileInfo *info = [[DBFilesystem sharedFilesystem] fileInfoForPath:path error:nil];
        DBFile *file;
        if(info) {
            file = [[DBFilesystem sharedFilesystem] openFile:path error:nil];
        } else {
            file = [[DBFilesystem sharedFilesystem] createFile:path error:nil];
        }
        
        setup(file);
        
//        self.pathsToDBFiles[path.stringValue] = file;
        
        [[DBFilesystem sharedFilesystem] addObserver:self forPath:path block:^{
            NSLog(@"Path: %@ has been updated", path);
            [self loadFileFromDropbox:file];
        }];
    }
    
}





- (void)callUpdateMethods:(DBFile *)file {
    NSArray *updateArray = self.pathsToArraysOfUpdateListeners[file.info.path.stringValue];
    for(CCDropboxCallback callback in updateArray) {
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

@end
