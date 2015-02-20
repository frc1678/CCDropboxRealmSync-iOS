//
//  AppDelegate.m
//  DropboxRealmClientTest
//
//  Created by Donald Pinckney on 12/21/14.
//  Copyright (c) 2014 citruscircuits. All rights reserved.
//

#import "CCDropboxLinkingAppDelegate.h"
#import "Dropbox.h"
#import "CCRealmSync.h"

@interface CCDropboxLinkingAppDelegate ()

@end

@implementation CCDropboxLinkingAppDelegate

+ (CCDropboxLinkingAppDelegate *) getCCDropboxAppDelegate {
    return ((CCDropboxLinkingAppDelegate *)[[UIApplication sharedApplication] delegate]);
}

- (void)setupDBFilesystemForAccount:(DBAccount *)account {
    DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:account];
    [DBFilesystem setSharedFilesystem:filesystem];
    NSLog(@"Shared filesystem object created");
}

//Link app to dropbox if it's not already linked.
- (void) possiblyLinkFromController:(UIViewController *)controller {
    if ([DBAccountManager sharedManager].linkedAccount == nil) {
        [[DBAccountManager sharedManager] linkFromController:controller];
    } else {
        NSLog(@"App already linked");
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Dropbox initialization: See https://www.dropbox.com/developers/sync/start/ios
    //Its probably not great code to have the app key and the secret hardcoded here. Maybe use #define?
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:@"fu1drprr1bha4zl"
                                                                         secret:@"x8f4ehb2qyk30r4"]; 
    [DBAccountManager setSharedManager:accountManager];
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account) {
        [self setupDBFilesystemForAccount:account];
    }
    
    return YES;
}

// Handles result of linking from Dropbox login, https://www.dropbox.com/developers/sync/start/ios
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
  sourceApplication:(NSString *)source
         annotation:(id)annotation {
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        NSLog(@"App linked successfully!");
        
        [self setupDBFilesystemForAccount:account];
        
        // Update Realm database a few seconds after it is done linking, to give Dropbox time to finish syncing.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:CC_DROPBOX_LINK_NOTIFICATION object:[DBFilesystem sharedFilesystem]];
        });
        
        
        return YES;
    }
    return NO;
}





- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
