//
//  HandlerMain.m
//  ColoredVKPrefsHandler
//
//  Created by Даниил on 11.07.18.
//  Copyright (c) 2018 Daniil Pashin. All rights reserved.
//

#import "MessagingCenter.h"
#import <dlfcn.h>

extern CPDistributedMessagingCenter *cvk_notifyCenter(void);


@interface ColoredVKFSHandler : NSObject
@end
@implementation ColoredVKFSHandler

+ (NSDictionary *)handleMessageNamed:(NSString *)name userInfo:(NSDictionary *)userInfo
{
    NSArray *folderContents = nil;
    NSDictionary *itemAttributes = nil;
    NSError *error = nil;
    
   if ([name isEqualToString:kPackageNotificationWriteData]) {
        error = [self writeData:userInfo];
    } else if ([name isEqualToString:kPackageNotificationRemoveFile]) {
        error = [self removeFile:userInfo];
    } else if ([name isEqualToString:kPackageNotificationCreateFolder]) {
        error = [self createFolder:userInfo];
    } else if ([name isEqualToString:kPackageNotificationMoveFile]) {
        error = [self moveFile:userInfo];
    } else if ([name isEqualToString:kPackageNotificationFolderContents]) {
        folderContents = [self folderContents:userInfo error:&error];
    } else if ([name isEqualToString:kPackageNotificationItemAttributes]) {
        itemAttributes = [self itemAttributes:userInfo error:&error];
    } else if ([name isEqualToString:kPackageNotificationCopyFile]) {
        error = [self copyFile:userInfo];
    }
    
    NSMutableDictionary *reply = [NSMutableDictionary dictionary];
    reply[@"success"] = @((error == nil));
    
    if (error)
        reply[@"error"] = error;
    
    if (folderContents)
        reply[@"folderContents"] = folderContents;
    
    if (itemAttributes)
        reply[@"itemAttributes"] = itemAttributes;
    
    return reply;
}

+ (NSError *)writeData:(NSDictionary *)notifyUserInfo
{
    NSData *data = notifyUserInfo[@"data"];
    NSString *path = notifyUserInfo[@"path"];
    
    NSError *error = nil;
    [data writeToFile:path options:NSDataWritingAtomic error:&error];
    
    return error;
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

+ (NSError *)moveFile:(NSDictionary *)notifyUserInfo
{
    NSString *oldPath = notifyUserInfo[@"oldPath"];
    NSString *newPath = notifyUserInfo[@"newPath"];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
    
    return error;
}

+ (NSError *)copyFile:(NSDictionary *)notifyUserInfo
{
    NSString *path = notifyUserInfo[@"path"];
    NSString *copyPath = notifyUserInfo[@"copyPath"];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtPath:path toPath:copyPath error:&error];
    
    return error;
}

+ (NSArray *)folderContents:(NSDictionary *)notifyUserInfo error:(NSError * __autoreleasing *)error
{
    NSString *folderPath = notifyUserInfo[@"path"];
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:error];
}

+ (NSDictionary *)itemAttributes:(NSDictionary *)notifyUserInfo error:(NSError * __autoreleasing *)error
{
    NSString *itemPath = notifyUserInfo[@"path"];
    return [[NSFileManager defaultManager] attributesOfItemAtPath:itemPath error:error];
}


@end

CVK_CONSTRUCTOR
{
	@autoreleasepool {
        CPDistributedMessagingCenter *center = cvk_notifyCenter();
        
        Class targetClass = [ColoredVKFSHandler class];
        SEL targetSelector = @selector(handleMessageNamed:userInfo:);
        
        [center registerForMessageName:kPackageNotificationWriteData    target:targetClass selector:targetSelector];
        
        [center registerForMessageName:kPackageNotificationRemoveFile   target:targetClass selector:targetSelector];
        [center registerForMessageName:kPackageNotificationMoveFile     target:targetClass selector:targetSelector];
        [center registerForMessageName:kPackageNotificationCopyFile     target:targetClass selector:targetSelector];
        
        [center registerForMessageName:kPackageNotificationCreateFolder     target:targetClass selector:targetSelector];
        [center registerForMessageName:kPackageNotificationFolderContents   target:targetClass selector:targetSelector];
        
        [center registerForMessageName:kPackageNotificationItemAttributes   target:targetClass selector:targetSelector];
        
        [center runServerOnCurrentThread];
	}
}
