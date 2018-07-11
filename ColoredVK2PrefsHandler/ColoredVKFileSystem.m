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
    return [center sendMessageAndReceiveReplyName:name userInfo:userInfo];
}
#endif


BOOL cvk_writePrefs(NSDictionary *prefs, NSString *notificationName)
{
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
    if (!success && localError) {
        NSDictionary *reply = cvk_sendNotification(kPackageNotificationWriteData, @{@"data":data, @"path":path});
        success = [reply[@"success"] boolValue];
        localError = reply[@"error"];
    }
#endif
    
    if (error)
        *error = localError;
    
    return success;
}

BOOL cvk_removeFile(NSString *path, NSError *__autoreleasing *error)
{
    NSError *localError = nil;
    BOOL success = YES;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        success = [[NSFileManager defaultManager] removeItemAtPath:path error:&localError];
    
#ifdef COMPILE_FOR_JAIL
    if (!success && localError) {
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
    if (!success && localError) {
        NSDictionary *reply = cvk_sendNotification(kPackageNotificationCreateFolder, @{@"path":path});
        success = [reply[@"success"] boolValue];
        localError = reply[@"error"];
    }
#endif
    
    if (error)
        *error = localError;
    
    return success;
}
