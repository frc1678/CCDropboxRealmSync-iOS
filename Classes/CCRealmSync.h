//
//  CCRealmSync.h
//  Pods
//
//  Created by Donald Pinckney on 12/22/14.
//
//

#import <Foundation/Foundation.h>
#import "Realm.h"
#import "Dropbox.h"

#warning THIS IS BLACK MAJJJJJJJJJIKKKKKKK

typedef void (^CCRealmCallback)(RLMRealm *realm);

// Subscribe to notificaitons from this constant to get database refreshes
#define CC_NEW_REALM_NOTIFICATION @"CC_NEW_REALM_NOTIFICATION"

@interface CCRealmSync : NSObject

+ (void)setRealmDropboxPath:(DBPath *)path;
+ (void)defaultReadonlyDropboxRealm:(CCRealmCallback) callback;


@end