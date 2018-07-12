//
//  ColoredVKBackupsModel.m
//  ColoredVK2
//
//  Created by Даниил on 23.03.18.
//

#import "ColoredVKBackupsModel.h"

#import "ColoredVKNewInstaller.h"
#import "ColoredVKHUD.h"
#import "ColoredVKAlertController.h"
#import "SSZipArchive.h"

@interface ColoredVKBackupsModel ()
@property (strong, nonatomic) NSBundle *cvkBundle;
@property (strong, nonatomic) dispatch_queue_t backgroundQueue;
@end

@implementation ColoredVKBackupsModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _availableBackups = @[];
        self.backgroundQueue = dispatch_queue_create("ru.danpashin.coloredvk2.backups.queue", DISPATCH_QUEUE_CONCURRENT);
        self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        
        [self updateBackups];
    }
    return self;
}

- (void)resetSettings
{
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:CVKLocalizedStringInBundle(@"WARNING", self.cvkBundle)
                                                                                           message:CVKLocalizedStringInBundle(@"RESET_SETTINGS_QUESTION", self.cvkBundle)];
    
    NSString *resetTitle = [CVKLocalizedStringFromTableInBundle(@"RESET_SETTINGS", @"ColoredVK", self.cvkBundle) componentsSeparatedByString:@" "].firstObject;    
    [alertController addAction:[UIAlertAction actionWithTitle:resetTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        ColoredVKHUD *hud = [ColoredVKHUD showHUD];
        
        dispatch_async(self.backgroundQueue, ^{
            NSError *error = nil;
            cvk_removeItem(CVK_PREFS_PATH, &error);
            cvk_removeItem(CVK_FOLDER_PATH, &error);
            [[ColoredVKNewInstaller sharedInstaller] createFolders];
            
            error ? [hud showFailure] : [hud showSuccess];
            
            POST_CORE_NOTIFICATION(kPackageNotificationReloadMenu);
        });
    }]];
    [alertController present];
    [alertController addCancelActionWithTitle:UIKitLocalizedString(@"No")];
}

- (void)createBackup
{
    ColoredVKHUD *hud = [ColoredVKHUD showHUD];
    
    dispatch_async(self.backgroundQueue, ^{
        NSMutableArray *files = @[CVK_PREFS_PATH].mutableCopy;
        
        for (NSString *fileName in cvk_folderContents(CVK_FOLDER_PATH, nil)) {
            if (![fileName containsString:@"Cache"])
                [files addObject:[NSString stringWithFormat:@"%@/%@", CVK_FOLDER_PATH, fileName]];
        }
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd_HH-mm";
        NSString *backupName = [NSString stringWithFormat:@"com.daniilpashin.coloredvk2_%@.cvkb", [dateFormatter stringFromDate:[NSDate date]]];
        NSString *tmpBackupPath = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), backupName];
        
        BOOL success = [SSZipArchive createZipFileAtPath:tmpBackupPath withFilesAtPaths:files];
        if (success) {
            NSString *backupPath = [NSString stringWithFormat:@"%@/%@", CVK_BACKUP_PATH, backupName];
            success = cvk_moveItem(tmpBackupPath, backupPath, nil);
        }
        
        success ? [hud showSuccess] : [hud showFailure];
    });
}

- (void)restoreSettingsFromFile:(NSString *)file
{
    ColoredVKHUD *hud = [ColoredVKHUD showHUD];
    
    dispatch_async(self.backgroundQueue, ^{
        NSString *backupPath = [NSString stringWithFormat:@"%@/%@", CVK_BACKUP_PATH, file];
        NSString *backupTempPath = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), file];
        cvk_copyItem(backupPath, backupTempPath, nil);
        
        NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingString:@"coloredvk2"];
        [SSZipArchive unzipFileAtPath:backupTempPath toDestination:tmpPath progressHandler:nil completionHandler:^(NSString *path, BOOL succeeded, NSError *error) {
            dispatch_async(self.backgroundQueue, ^{
                if (!succeeded || error) {
                    [hud showFailureWithStatus:error.localizedDescription];
                    return;
                }
                
                cvk_removeItem(CVK_PREFS_PATH, nil);
                cvk_removeItem(CVK_FOLDER_PATH, nil);
                cvk_createFolder(CVK_FOLDER_PATH, nil);
                
                NSError *movingError = nil;
                for (NSString *filename in cvk_folderContents(tmpPath, nil)) {
                    NSString *filePath = [NSString stringWithFormat:@"%@/%@", tmpPath, filename];
                    if ([filename containsString:@"Image"]) {
                        NSString *newPath = [NSString stringWithFormat:@"%@/%@", CVK_FOLDER_PATH, filename];
                        cvk_moveItem(filePath, newPath, &movingError);
                    } else if ([filename containsString:@"plist"]) {
                        cvk_moveItem(filePath, CVK_PREFS_PATH, &movingError);
                        
                    }
                    if (movingError)
                        break;
                }
                cvk_removeItem(tmpPath, nil);
                cvk_removeItem(backupTempPath, nil);
                
                movingError ? [hud showFailureWithStatus:movingError.localizedDescription] : [hud showSuccess];
                
                POST_CORE_NOTIFICATION(kPackageNotificationReloadMenu);
                
                if ([self.delegate respondsToSelector:@selector(backupsModel:didEndRestoringBackup:)])
                    [self.delegate backupsModel:self didEndRestoringBackup:file];
            });
        }];
    });
    
}

- (void)updateBackups
{
    dispatch_async(self.backgroundQueue, ^{
        NSMutableArray *availableBackups = [NSMutableArray array];
        
        for (NSString *filename in cvk_folderContents(CVK_BACKUP_PATH, nil)) {
            NSArray <NSString *> *extensions = @[@"zip", @"cvkb"];
            if ([filename containsString:@"com.daniilpashin.coloredvk2"] && [extensions containsObject:filename.pathExtension]) {
                [availableBackups addObject:filename];
            }
        }
        
        self->_availableBackups = availableBackups;
        
        if ([self.delegate respondsToSelector:@selector(backupsModel:didEndUpdatingBackups:)])
            [self.delegate backupsModel:self didEndUpdatingBackups:self.availableBackups];
    });
}

- (NSString *)readableNameForBackup:(NSString *)backup
{
    @autoreleasepool {
        NSMutableArray *components = [backup componentsSeparatedByString:@"_"].mutableCopy;
        [components removeObjectAtIndex:0];
        
        NSMutableString *readableName = [NSMutableString string];
        for (NSString *str in components) {
            [readableName appendFormat:@"%@_", str];
        }
        [readableName deleteCharactersInRange:NSMakeRange(readableName.length-1, 1)];
        
        NSString *path = [NSString stringWithFormat:@"%@/%@", CVK_BACKUP_PATH, backup];
        float fileSize = cvk_itemAttributes(path, nil).fileSize;
        fileSize = fileSize / 1024.0f / 1024.0f;
        
        [readableName appendFormat:@" (%.1f MB)", fileSize];
        
        return readableName;
    }
}

@end
