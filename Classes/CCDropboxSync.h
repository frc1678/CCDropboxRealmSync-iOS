//
//  CCDropboxSync.h
//  DropboxRealmClientTest
//
//  Created by Donald Pinckney on 12/21/14.
//  Copyright (c) 2014 citruscircuits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dropbox.h"

typedef id (^CCDropboxCallbackDataResult)();
typedef id (^CCDropboxFileCallbackDataResult)(DBFile *file);
typedef void (^CCDropboxFileCallback)(DBFile *file);


@interface CCDropboxSync : NSObject

+ (instancetype)sharedSync;

- (BOOL)writeString:(NSString *)string toPath:(DBPath *)path;
- (BOOL)writeData:(NSData *)data toPath:(DBPath *)path;


- (void)path:(DBPath *)path addSetupListener:(CCDropboxFileCallback)setup updateListener:(CCDropboxFileCallback)update;
- (id)initialReadFromPath:(DBPath *)path
    readingFromPathCallback:(CCDropboxFileCallbackDataResult)callback
          noFileYetCallback:(CCDropboxCallbackDataResult)callback;

@end
