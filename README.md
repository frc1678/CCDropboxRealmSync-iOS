CCDropboxRealmSync-iOS
======================

Framework to handle lightweight syncing of Realm databases via Dropbox


Using Client API:

1 In your `AppDelegate.h` make sure to have `#import "CCDropboxLinkingAppDelegate.h"` as well as `@interface AppDelegate : CCDropboxLinkingAppDelegate`

2 In your view controller .m file you must include the folowing:
```objectivec
#import <Dropbox.h>
#import "CCDropboxSync.h"
#import <CCDropboxRealmSync-iOS/CCDropboxLinkingAppDelegate.h>
#import "CCRealmSync.h"
#import <RealmModels.h>
```
3 In `viewDidLoad` make sure to include `[CCRealmSync setRealmDropboxPath:[self dropboxFilePath]];`

4 In `viewDidAppear` include `[CC_DROPBOX_APP_DELEGATE possiblyLinkFromController:self];`

Using Server API:
