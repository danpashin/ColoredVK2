//
//  ColoredVKFileSystem.m
//  ColoredVK2
//
//  Created by Даниил on 11.07.18.
//

#import "MessagingCenter.h"

BOOL cvk_writePrefs(NSDictionary *prefs, NSString *notificationName)
{
    if (!notificationName)
        notificationName = @"";
    
    if ([prefs writeToFile:CVK_PREFS_PATH atomically:YES]) {
        if (notificationName.length > 0)
            POST_CORE_NOTIFICATION(notificationName);
        
        return YES;
    } else {
#ifdef COMPILE_FOR_JAIL
        CPDistributedMessagingCenter *center = cvk_notifyCenter();
        NSDictionary *reply = [center sendMessageAndReceiveReplyName:kPackageNotificationWritePrefs 
                                                            userInfo:@{@"prefs":prefs, @"notifyName":notificationName}];
        return [reply[@"success"] boolValue];
#endif
    }
}

BOOL cvk_writeData(NSData *data, NSString *path, NSError *__autoreleasing *error)
{
    NSError *localError = nil;
    BOOL success = [data writeToFile:path options:NSDataWritingAtomic error:&localError];
    
#ifdef COMPILE_FOR_JAIL
    if (!success && localError) {
        CPDistributedMessagingCenter *center = cvk_notifyCenter();
        NSDictionary *reply = [center sendMessageAndReceiveReplyName:kPackageNotificationWriteData
                                                            userInfo:@{@"data":data, @"path":path}];
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
        CPDistributedMessagingCenter *center = cvk_notifyCenter();
        NSDictionary *reply = [center sendMessageAndReceiveReplyName:kPackageNotificationRemoveFile
                                                            userInfo:@{@"path":path}];
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
        CPDistributedMessagingCenter *center = cvk_notifyCenter();
        NSDictionary *reply = [center sendMessageAndReceiveReplyName:kPackageNotificationCreateFolder
                                                            userInfo:@{@"path":path}];
        success = [reply[@"success"] boolValue];
        localError = reply[@"error"];
    }
#endif
    
    if (error)
        *error = localError;
    
    return success;
}




