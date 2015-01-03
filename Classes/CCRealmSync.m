//
//  CCRealmSync.m
//  Pods
//
//  Created by Donald Pinckney on 12/22/14.
//
//

#import "CCRealmSync.h"
#import "CCDropboxSync.h"

@implementation CCRealmSync


DBPath *realmDropboxPath = nil;
+ (void)setRealmDropboxPath:(DBPath *)path {
    realmDropboxPath = path;
}

#define REALM_PATH_A [[[RLMRealm defaultRealmPath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"a.realm"]
#define REALM_PATH_B [[[RLMRealm defaultRealmPath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"b.realm"]

NSString *currentReadonlyRealmPath = nil;

+ (void)defaultReadonlyDropboxRealm:(CCRealmCallback) callback {
    if(currentReadonlyRealmPath == nil) {
        
        
    
        // Setup dropbox stuff
        // Once done syncing, callback()
        //Add listeners to Dropbox
        [[CCDropboxSync sharedSync] path:realmDropboxPath addSetupListener:^(DBFile *file) {
            currentReadonlyRealmPath = REALM_PATH_A;
            [self downloadFromDropboxFileToNonActiveRealmPath:file];
            callback([RLMRealm realmWithPath:currentReadonlyRealmPath readOnly:YES error:nil]);
        } updateListener:^(DBFile *file) {
            [self downloadFromDropboxFileToNonActiveRealmPath:file];
            
            // Do mechanism to tell the world about new Realm
            RLMRealm *realm = [RLMRealm realmWithPath:currentReadonlyRealmPath readOnly:YES error:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:CC_NEW_REALM_NOTIFICATION object:realm];
        }];
        
    } else {
        callback([RLMRealm realmWithPath:currentReadonlyRealmPath readOnly:YES error:nil]);
    }
}

+ (void)downloadFromDropboxFileToNonActiveRealmPath:(DBFile *)file {
    [file update:nil];
    NSData *realmData = [file readData:nil];
    NSString *newPath = [currentReadonlyRealmPath isEqualToString:REALM_PATH_A] ? REALM_PATH_B : REALM_PATH_A;
    currentReadonlyRealmPath = newPath;
    [realmData writeToFile:newPath atomically:YES];
}



RLMNotificationToken *token;
+ (void)setupDefaultRealmForDropboxPath:(DBPath *)dbPath {
    // Note to self: abstract this
    [[CCDropboxSync sharedSync] initialReadFromPath:dbPath readingFromPathCallback:^id(DBFile *file) {
        NSData *data = [file readData:nil];
        if([data length] > 0) {
            NSString *path = [RLMRealm defaultRealmPath];
            [data writeToFile:path atomically:YES];
            [[RLMRealm defaultRealm] refresh];
            
            token = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString *notification, RLMRealm *realm) {
                [self copyRealmToDropbox:dbPath];
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:CC_REALM_SETUP_NOTIFICATION object:[RLMRealm defaultRealm]];
        }
        NSLog(@"Downloaded realm data from dropbox");
        return nil;
    } noFileYetCallback:^id{
        NSLog(@"No data Yet");
        token = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString *notification, RLMRealm *realm) {
            [self copyRealmToDropbox:dbPath];
        }];
        [[NSNotificationCenter defaultCenter] postNotificationName:CC_REALM_SETUP_NOTIFICATION object:[RLMRealm defaultRealm]];
        return nil;
    }];

}


// Note to self: abstract this
// The path of the file to write the default realm to before uploading to Dropbox
#define REALM_LOCAL_PATH [[[RLMRealm defaultRealmPath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"1678_LOCAL.realm"]
+ (void)copyRealmToDropbox:(DBPath *)path {
    [[NSFileManager defaultManager] removeItemAtPath:REALM_LOCAL_PATH error:nil];
    [[RLMRealm defaultRealm] writeCopyToPath:REALM_LOCAL_PATH error:nil];
    [self writeLocalFileToDropbox:path];
}


+ (void)writeLocalFileToDropbox:(DBPath *)path {
    NSData *realmData = [NSData dataWithContentsOfFile:REALM_LOCAL_PATH];
    [[CCDropboxSync sharedSync] writeData:realmData toPath:path];
}


@end
