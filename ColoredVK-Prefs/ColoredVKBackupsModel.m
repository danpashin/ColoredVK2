//
//  ColoredVKBackupsModel.m
//  ColoredVK2
//
//  Created by Даниил on 23.03.18.
//

#import "ColoredVKBackupsModel.h"

#import "PrefixHeader.h"
#import "ColoredVKNewInstaller.h"
#import "ColoredVKHUD.h"
#import "ColoredVKAlertController.h"
#import "SSZipArchive.h"

@interface ColoredVKBackupsModel ()
@property (strong, nonatomic) NSBundle *cvkBundle;
@end

@implementation ColoredVKBackupsModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _availableBackups = @[];
        self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        [self updateBackups];
    }
    return self;
}

- (void)resetSettings
{
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:CVKLocalizedStringInBundle(@"WARNING", self.cvkBundle)
                                                                                           message:CVKLocalizedStringInBundle(@"RESET_SETTINGS_QUESTION", self.cvkBundle) 
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *resetTitle = [CVKLocalizedStringFromTableInBundle(@"RESET_SETTINGS", @"ColoredVK", self.cvkBundle) componentsSeparatedByString:@" "].firstObject;    
    [alertController addAction:[UIAlertAction actionWithTitle:resetTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        ColoredVKHUD *hud = [ColoredVKHUD showHUD];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSError *error = nil;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:CVK_PREFS_PATH error:&error];
            [fileManager removeItemAtPath:CVK_FOLDER_PATH error:&error];
            [[ColoredVKNewInstaller sharedInstaller] createFolders];
            
            error ? [hud showFailure] : [hud showSuccess];
            
            POST_CORE_NOTIFICATION(kPackageNotificationReloadPrefs);
            POST_CORE_NOTIFICATION(kPackageNotificationReloadMenu);
        });
    }]];
    [alertController present];
    [alertController addCancelActionWithTitle:UIKitLocalizedString(@"No")];
}

- (void)createBackup
{
    ColoredVKHUD *hud = [ColoredVKHUD showHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableArray *files = @[CVK_PREFS_PATH].mutableCopy;
        
        NSFileManager *filemaneger = [NSFileManager defaultManager];
        if (![filemaneger fileExistsAtPath:CVK_BACKUP_PATH])
            [filemaneger createDirectoryAtPath:CVK_BACKUP_PATH withIntermediateDirectories:NO attributes:nil error:nil];
        
        for (NSString *fileName in [filemaneger contentsOfDirectoryAtPath:CVK_FOLDER_PATH error:nil]) {
            if (![fileName containsString:@"Cache"])
                [files addObject:[NSString stringWithFormat:@"%@/%@", CVK_FOLDER_PATH, fileName]];
        }
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd_HH-mm";
        NSString *backupPath = [NSString stringWithFormat:@"%@/com.daniilpashin.coloredvk2_%@.cvkb", 
                                CVK_BACKUP_PATH, [dateFormatter stringFromDate:[NSDate date]]];
        
        BOOL success = [SSZipArchive createZipFileAtPath:backupPath withFilesAtPaths:files];
        success ? [hud showSuccess] : [hud showFailure];
    });
}

- (void)restoreSettingsFromFile:(NSString *)file
{
    ColoredVKHUD *hud = [ColoredVKHUD showHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSString *backupPath = [NSString stringWithFormat:@"%@/%@", CVK_BACKUP_PATH, file];
        NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingString:@"coloredvk2"];
        
        [SSZipArchive unzipFileAtPath:backupPath toDestination:tmpPath progressHandler:nil completionHandler:^(NSString *path, BOOL succeeded, NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                if (!succeeded || error) {
                    [hud showFailureWithStatus:error.localizedDescription];
                    return;
                }
                NSFileManager *filemanager = [NSFileManager defaultManager];
                
                [filemanager removeItemAtPath:CVK_PREFS_PATH error:nil];
                [filemanager removeItemAtPath:CVK_FOLDER_PATH error:nil];
                [filemanager createDirectoryAtPath:CVK_FOLDER_PATH withIntermediateDirectories:NO attributes:nil error:nil];
                
                NSError *movingError = nil;
                for (NSString *filename in [filemanager contentsOfDirectoryAtPath:tmpPath error:nil]) {
                    NSString *filePath = [NSString stringWithFormat:@"%@/%@", tmpPath, filename];
                    if ([filename containsString:@"Image"]) {
                        NSString *newPath = [NSString stringWithFormat:@"%@/%@", CVK_FOLDER_PATH, filename];
                        [filemanager copyItemAtPath:filePath toPath:newPath error:&movingError];
                    } else if ([filename containsString:@"plist"]) {
                        [filemanager copyItemAtPath:filePath toPath:CVK_PREFS_PATH error:&movingError];
                    }
                    if (movingError)
                        break;
                }
                [filemanager removeItemAtPath:tmpPath error:nil];
                
                movingError ? [hud showFailureWithStatus:movingError.localizedDescription] : [hud showSuccess];
                
                POST_CORE_NOTIFICATION(kPackageNotificationReloadPrefs);
                POST_CORE_NOTIFICATION(kPackageNotificationReloadMenu);
                
                if ([self.delegate respondsToSelector:@selector(backupsModel:didEndRestoringBackup:)])
                    [self.delegate backupsModel:self didEndRestoringBackup:file];
            });
        }];
    });
    
}

- (void)updateBackups
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableArray *availableBackups = [NSMutableArray array];
        
        for (NSString *filename in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:CVK_BACKUP_PATH error:nil]) {
            NSArray <NSString *> *extensions = @[@"zip", @"cvkb"];
            if ([filename containsString:@"com.daniilpashin.coloredvk2"] && [extensions containsObject:filename.pathExtension]) {
                [availableBackups addObject:filename];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            _availableBackups = availableBackups;
            
            if ([self.delegate respondsToSelector:@selector(backupsModel:didEndUpdatingBackups:)])
                [self.delegate backupsModel:self didEndUpdatingBackups:self.availableBackups];
        });
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
        float fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil].fileSize;
        fileSize = fileSize / 1024.0f / 1024.0f;
        
        [readableName appendFormat:@" (%.1f MB)", fileSize];
        
        return readableName;
    }
}

@end
