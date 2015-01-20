CCDropboxRealmSync-iOS
======================

Framework to handle lightweight syncing of Realm databases via Dropbox

## Using Client API:

0 Go to Project Settings, then the Info tab, and expand the URL Types section. Add a new URL Type with the scheme db-fu1drprr1bha4zl.

1 In your `AppDelegate.h` make sure to have `#import "CCDropboxLinkingAppDelegate.h"` as well as `@interface AppDelegate : CCDropboxLinkingAppDelegate`, <b>AND</b> remove all method definitions from your `AppDelegate.m`.

2 In your view controller .m file you must include the folowing:
```objectivec
#import <CCDropboxRealmSync-iOS/CCDropboxLinkingAppDelegate.h>
#import "CCRealmSync.h"
```
3 In `viewDidLoad` make sure to include:
```objectivec
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseUpdated:) name:CC_NEW_REALM_NOTIFICATION object:nil]; // Sign up for notifications for the Realm Database
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUIBecauseDropboxIsLinkedNow) name:CC_DROPBOX_LINK_NOTIFICATION object:nil];
[CCRealmSync setRealmDropboxPath:MY_DBX_PATH];
```
where `MY_DBX_PATH` is the `DBPath` to the Realm database on Dropbox

4 In `viewDidAppear` include `[CC_DROPBOX_APP_DELEGATE possiblyLinkFromController:self];`.

5 When implementing `databaseUpdated:`, the object attached to the `NSNotification` is the `RLMRealm` object that you should use for all reading operations. Example:
```objectivec
- (void)databaseUpdated:(NSNotification *)note {
  RLMRealm *realm = note.object; 
  // Do stuff with realm object
}
```

6 Any other time you want to read from the Realm database _AS THE CLIENT_, the **_only_** way you should access it is via: `CCRealmSync +defaultReadonlyDropboxRealm:` Example:
```objectivec
[CCRealmSync defaultReadonlyDropboxRealm:^(RLMRealm *realm) {
  // Do stuff with realm object
}];
```
## Using Server API:

0 Go to Project Settings, then the Info tab, and expand the URL Types section. Add a new URL Type with the scheme db-fu1drprr1bha4zl.

1 In your `AppDelegate.h` make sure to have `#import "CCDropboxLinkingAppDelegate.h"` as well as `@interface AppDelegate : CCDropboxLinkingAppDelegate`, <b>AND</b> remove all method definitions from your `AppDelegate.m`.

2 In your view controller .m file you must include the following:
```objectivec
#import "CCDropboxLinkingAppDelegate.h"
#import "CCRealmSync.h"
```

3 In `viewDidLoad` make sure to include:
```objectivec
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLinked:) name:CC_DROPBOX_LINK_NOTIFICATION object:nil];
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDatabaseOperations) name:CC_REALM_SETUP_NOTIFICATION object:nil];
[CCRealmSync setupDefaultRealmForDropboxPath:MY_DBX_PATH];
```
where `MY_DBX_PATH` is the `DBPath` to the Realm database on Dropbox

4 In `viewDidAppear` include `[CC_DROPBOX_APP_DELEGATE possiblyLinkFromController:self];`.

5 Implement `dropboxLinked:` (for the above `NSNotification`) exactly like this:
```objectivec
- (void)dropboxLinked:(NSNotification *)note {
  [CCRealmSync setupDefaultRealmForDropboxPath:MY_DBX_PATH];
}
```
where `MY_DBX_PATH` is the `DBPath` to the Realm database on Dropbox

6 **_ONLY_** start database operations once the `CC_REALM_SETUP_NOTIFICATION` has been triggered.

7 **_Always_** use the default Realm for all database operations _AS THE SERVER_: `[RLMRealm defaultRealm]`
