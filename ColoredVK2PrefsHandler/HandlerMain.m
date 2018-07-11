//
//  HandlerMain.m
//  ColoredVKPrefsHandler
//
//  Created by Даниил on 11.07.18.
//  Copyright (c) 2018 Daniil Pashin. All rights reserved.
//

#import "MessagingCenter.h"
#import <CPDistributedMessagingCenter.h>
#import <dlfcn.h>

CPDistributedMessagingCenter *cvk_notifyCenter(void);


@interface ColoredVKSBHandler : NSObject
@end
@implementation ColoredVKSBHandler

+ (NSDictionary *)handleMessageNamed:(NSString *)name userInfo:(NSDictionary *)userInfo
{
    NSError *error = nil;
    BOOL success = NO;
    if ([name isEqualToString:kPackageNotificationWritePrefs]) {
        success = [self writePrefs:userInfo];
    } else if ([name isEqualToString:kPackageNotificationWriteData]) {
        error = [self writeData:userInfo];
    } else if ([name isEqualToString:kPackageNotificationRemoveFile]) {
        error = [self removeFile:userInfo];
    } else if ([name isEqualToString:kPackageNotificationCreateFolder]) {
        error = [self createFolder:userInfo];
    }
    
    success = (error == nil);
    
    if (error)
        return @{@"success":@(success), @"error":error};
    
    return @{@"success":@(success)};
}

+ (BOOL)writePrefs:(NSDictionary *)notifyUserInfo
{
    if ([notifyUserInfo[@"prefs"] isKindOfClass:[NSDictionary class]]) {
        BOOL success = [notifyUserInfo[@"prefs"] writeToFile:CVK_PREFS_PATH atomically:YES];
        
        if ([notifyUserInfo[@"notifyName"] length] > 0)
            POST_CORE_NOTIFICATION(notifyUserInfo[@"notifyName"]);
        
        return success;
    }
    
    return NO;
}

+ (NSError *)writeData:(NSDictionary *)notifyUserInfo
{
    if ([notifyUserInfo[@"data"] isKindOfClass:[NSData class]]) {
        NSData *data = notifyUserInfo[@"data"];
        NSString *path = notifyUserInfo[@"path"];
        
        NSError *error = nil;
        [data writeToFile:path options:NSDataWritingAtomic error:&error];
        
        if ([notifyUserInfo[@"notifyName"] length] > 0)
            POST_CORE_NOTIFICATION(notifyUserInfo[@"notifyName"]);
        
        return error;
    }
    
    return nil;
}

+ (NSError *)removeFile:(NSDictionary *)notifyUserInfo
{
    NSString *filePath = notifyUserInfo[@"path"];
    NSError *error = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    
    return error;
}

+ (NSError *)createFolder:(NSDictionary *)notifyUserInfo
{
    NSString *filePath = notifyUserInfo[@"path"];
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error];
    
    return error;
}

@end

CVK_CONSTRUCTOR
{
	@autoreleasepool {
        dlopen("/System/Library/PrivateFrameworks/AppSupport.framework/AppSupport", RTLD_NOW);
        
        CPDistributedMessagingCenter *center = cvk_notifyCenter();
        [center registerForMessageName:kPackageNotificationWritePrefs target:[ColoredVKSBHandler class] selector:@selector(handleMessageNamed:userInfo:)];
        [center registerForMessageName:kPackageNotificationWriteData target:[ColoredVKSBHandler class] selector:@selector(handleMessageNamed:userInfo:)];
        [center registerForMessageName:kPackageNotificationRemoveFile target:[ColoredVKSBHandler class] selector:@selector(handleMessageNamed:userInfo:)];
        [center registerForMessageName:kPackageNotificationCreateFolder target:[ColoredVKSBHandler class] selector:@selector(handleMessageNamed:userInfo:)];
        [center runServerOnCurrentThread];
	}
}
