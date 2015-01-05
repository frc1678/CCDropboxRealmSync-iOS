CCDropboxRealmSync-iOS
======================

Framework to handle lightweight syncing of Realm databases via Dropbox

## Using Client API:

1 In your `AppDelegate.h` make sure to have `#import "CCDropboxLinkingAppDelegate.h"` as well as `@interface AppDelegate : CCDropboxLinkingAppDelegate`

2 In your view controller .m file you must include the folowing:
```objectivec
#import "ViewController.h"
#import <CCDropboxRealmSync-iOS/CCDropboxLinkingAppDelegate.h>
#import "CCRealmSync.h"
```
3 In `viewDidLoad` make sure to include:
```objectivec
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseUpdated:) name:CC_NEW_REALM_NOTIFICATION object:nil]; // Sign up for notifications for the Realm Database
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(putDataInTableViewFromRealm) name:CC_DROPBOX_LINK_NOTIFICATION object:nil];
[CCRealmSync setRealmDropboxPath:[self dropboxFilePath]];
```

4 In `viewDidAppear` include `[CC_DROPBOX_APP_DELEGATE possiblyLinkFromController:self];`.

## Using Server API:

1 In your `AppDelegate.h` make sure to have `#import "CCDropboxLinkingAppDelegate.h"` as well as `@interface AppDelegate : CCDropboxLinkingAppDelegate`.

2 In `AppDelegate.h` make sure to import `<Dropbox/Dropbox.h>`.

3 In your view controller .m file you must include the following:
```objectivec
#import "CCDropboxLinkingAppDelegate.h"
#import "CCDropboxSync.h"
#import <Realm/Realm.h>
#import <RealmModels.h>
#import "CCRealmSync.h"
```

4 In `viewDidLoad` make sure to include:
```objectivec
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLinked:) name:CC_DROPBOX_LINK_NOTIFICATION object:nil];
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startDatabaseOperations) name:CC_REALM_SETUP_NOTIFICATION object:nil];
[CCRealmSync setupDefaultRealmForDropboxPath:[self databaseDBPath]];
```

5 In `viewDidAppear` include `[CC_DROPBOX_APP_DELEGATE possiblyLinkFromController:self];`.

