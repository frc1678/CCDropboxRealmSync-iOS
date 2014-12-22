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

#define REALM_PATH_A [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"a.realm"]
#define REALM_PATH_B [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"b.realm"]

NSString *currentReadonlyRealmPath = nil;

+ (void)defaultReadonlyDropboxRealm:(CCRealmCallback) callback {
    if(currentReadonlyRealmPath == nil) {
        currentReadonlyRealmPath = REALM_PATH_A;
        
        // Setup dropbox stuff
        // Once done syncing, callback()
        [[CCDropboxSync sharedSync] path:realmDropboxPath addSetupListener:^(DBFile *file) {
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
    NSData *realmData = [file readData:nil];
    NSString *newPath = [currentReadonlyRealmPath isEqualToString:REALM_PATH_A] ? REALM_PATH_B : REALM_PATH_A;
    currentReadonlyRealmPath = newPath;
    [realmData writeToFile:newPath atomically:YES];
}








@end
