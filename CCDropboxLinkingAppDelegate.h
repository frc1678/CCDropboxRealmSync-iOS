//
//  AppDelegate.h
//  DropboxRealmClientTest
//
//  Created by Donald Pinckney on 12/21/14.
//  Copyright (c) 2014 citruscircuits. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CC_DROPBOX_APP_DELEGATE ((CCDropboxLinkingAppDelegate *)[[UIApplication sharedApplication] delegate])

@interface CCDropboxLinkingAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)possiblyLinkFromController:(UIViewController *)controller;

@end

