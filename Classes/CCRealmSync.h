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
// For CLIENT apps:
#define CC_NEW_REALM_NOTIFICATION @"CC_NEW_REALM_NOTIFICATION"

// For SERVER apps:
#define CC_REALM_SETUP_NOTIFICATION @"CC_REALM_SETUP_NOTIFICATION"


@interface CCRealmSync : NSObject


// Methods for CLIENT apps to use:
+ (void)setRealmDropboxPath:(DBPath *)path;
+ (void)defaultReadonlyDropboxRealm:(CCRealmCallback) callback;

// Methods for SERVER apps to use:
+ (void)setupDefaultRealmForDropboxPath:(DBPath *)path;

@end
