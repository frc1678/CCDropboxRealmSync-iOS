//
//  AppDelegate.h
//  DropboxRealmClientTest
//
//  Created by Donald Pinckney on 12/21/14.
//  Copyright (c) 2014 citruscircuits. All rights reserved.
//  small change

#import <UIKit/UIKit.h>

#define CC_DROPBOX_APP_DELEGATE ((CCDropboxLinkingAppDelegate *)[[UIApplication sharedApplication] delegate])
#define CC_DROPBOX_LINK_NOTIFICATION @"CC_DROPBOX_LINK_NOTIFICATION"

@interface CCDropboxLinkingAppDelegate : UIResponder <UIApplicationDelegate>

+ (CCDropboxLinkingAppDelegate *) getCCDropboxAppDelegate;

@property (strong, nonatomic) UIWindow *window;

- (void)possiblyLinkFromController:(UIViewController *)controller;

@end

