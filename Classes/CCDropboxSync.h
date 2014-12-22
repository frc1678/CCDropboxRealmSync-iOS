//
//  CCDropboxSync.h
//  DropboxRealmClientTest
//
//  Created by Donald Pinckney on 12/21/14.
//  Copyright (c) 2014 citruscircuits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dropbox.h"

typedef void (^CCDropboxCallback)(DBFile *file);


@interface CCDropboxSync : NSObject

+ (instancetype)sharedSync;

- (void)path:(DBPath *)path addSetupListener:(CCDropboxCallback)setup updateListener:(CCDropboxCallback)update;


@end
