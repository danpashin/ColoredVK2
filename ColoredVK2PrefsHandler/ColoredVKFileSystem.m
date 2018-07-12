//
//  ColoredVKFileSystem.m
//  ColoredVK2
//
//  Created by Даниил on 11.07.18.
//

#import "MessagingCenter.h"

#ifdef COMPILE_FOR_JAIL
NSDictionary *cvk_sendNotification(NSString *name, NSDictionary *userInfo)
{
    CPDistributedMessagingCenter *center = cvk_notifyCenter();
    if (center.doesServerExist)
        return [center sendMessageAndReceiveReplyName:name userInfo:userInfo];
    
    return @{};
}
#endif


BOOL cvk_writePrefs(NSDictionary *prefs, NSString *notificationName)
{
    if (!prefs)
        return NO;
    
    BOOL success = [prefs writeToFile:CVK_PREFS_PATH atomically:YES];
    
#ifdef COMPILE_FOR_JAIL
    if (!success) {
        NSDictionary *reply = cvk_sendNotification(kPackageNotificationWritePrefs, @{@"prefs":prefs});
        success = [reply[@"success"] boolValue];
    }
#endif
    
    if (notificationName)
        POST_CORE_NOTIFICATION(notificationName);
    
    return success;
}

BOOL cvk_writeData(NSData *data, NSString *path, NSError *__autoreleasing *error)
{
    NSError *localError = nil;
    BOOL success = [data writeToFile:path options:NSDataWritingAtomic error:&localError];
    
#ifdef COMPILE_FOR_JAIL
    if (!success || localError) {
        NSDictionary *reply = cvk_sendNotification(kPackageNotificationWriteData, @{@"data":data, @"path":path});
        success = [reply[@"success"] boolValue];
        localError = reply[@"error"];
    }
#endif
    
    if (error)
        *error = localError;
    
    return success;
}

BOOL cvk_removeItem(NSString *path, NSError *__autoreleasing *error)
{
    NSError *localError = nil;
    BOOL success = YES;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        success = [[NSFileManager defaultManager] removeItemAtPath:path error:&localError];
    
#ifdef COMPILE_FOR_JAIL
    if (!success || localError) {
        NSDictionary *reply = cvk_sendNotification(kPackageNotificationRemoveFile, @{@"path":path});
        success = [reply[@"success"] boolValue];
        localError = reply[@"error"];
    }
#endif
    
    if (error)
        *error = localError;
    
    return success;
}

BOOL cvk_createFolder(NSString *path, NSError *__autoreleasing *error)
{
    NSError *localError = nil;
    BOOL success = YES;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        success = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&localError];
    
#ifdef COMPILE_FOR_JAIL
    if (!success || localError) {
        NSDictionary *reply = cvk_sendNotification(kPackageNotificationCreateFolder, @{@"path":path});
        success = [reply[@"success"] boolValue];
        localError = reply[@"error"];
    }
#endif
    
    if (error)
        *error = localError;
    
    return success;
}


BOOL cvk_moveItem(NSString *oldPath, NSString *newPath, NSError *__autoreleasing *error)
{
    NSError *localError = nil;
    BOOL success = [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&localError];
    
#ifdef COMPILE_FOR_JAIL
    if (!success || localError) {
        NSDictionary *reply = cvk_sendNotification(kPackageNotificationMoveFile, @{@"oldPath":oldPath, @"newPath":newPath});
        success = [reply[@"success"] boolValue];
        localError = reply[@"error"];
    }
#endif
    
    if (error)
        *error = localError;
    
    return success;
}

BOOL cvk_copyItem(NSString *path, NSString *copyPath, NSError *__autoreleasing *error)
{
    NSError *localError = nil;
    BOOL success = [[NSFileManager defaultManager] copyItemAtPath:path toPath:copyPath error:&localError];
    
#ifdef COMPILE_FOR_JAIL
    if (!success || localError) {
        NSDictionary *reply = cvk_sendNotification(kPackageNotificationCopyFile, @{@"path":path, @"copyPath":copyPath});
        success = [reply[@"success"] boolValue];
        localError = reply[@"error"];
    }
#endif
    
    if (error)
        *error = localError;
    
    return success;
}

NSArray <NSString *>* cvk_folderContents(NSString *path, NSError *__autoreleasing *error)
{
    NSError *localError = nil;
    NSArray <NSString *>* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&localError];
    
#ifdef COMPILE_FOR_JAIL
    if (!contents || localError) {
        NSDictionary *reply = cvk_sendNotification(kPackageNotificationFolderContents, @{@"path":path});
        contents = reply[@"folderContents"];
        localError = reply[@"error"];
    }
#endif
    
    if (error)
        *error = localError;
    
    return contents;
}

NSDictionary <NSString *, id> *cvk_itemAttributes(NSString *path, NSError *__autoreleasing *error)
{
    NSError *localError = nil;
    NSDictionary <NSString *, id> *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&localError];
    
#ifdef COMPILE_FOR_JAIL
    if (!attrs || localError) {
        NSDictionary *reply = cvk_sendNotification(kPackageNotificationItemAttributes, @{@"path":path});
        attrs = reply[@"itemAttributes"];
        localError = reply[@"error"];
    }
#endif
    
    if (error)
        *error = localError;
    
    return attrs;
}
