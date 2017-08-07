//
//  ColoredVKSettingsController.m
//  ColoredVK
//
//  Created by Даниил on 12/02/2017.
//
//

#import "ColoredVKSettingsController.h"
#import "PrefixHeader.h"
#import "PSSpecifier.h"
#import "ColoredVKHUD.h"
#import "ColoredVKPrefs.h"
#import "SSZipArchive.h"
#import "ColoredVKAlertController.h"

@implementation ColoredVKSettingsController

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSMutableArray *specifiers = [NSMutableArray array];
    
        NSFileManager *filemanager = [NSFileManager defaultManager];    
        for (NSString *filename in [filemanager contentsOfDirectoryAtPath:CVK_BACKUP_PATH error:nil]) {
            if ([filename containsString:@"com.daniilpashin.coloredvk2"] && [filename containsString:@".zip"]) {
                NSMutableArray *components = [filename componentsSeparatedByString:@"_"].mutableCopy;
                [components removeObjectAtIndex:0];
                NSString *name = @"";
                for (NSString *str in components) {
                    name = [name stringByAppendingString:[NSString stringWithFormat:@"%@_", str]];
                }
                name = [name substringToIndex:name.length-1];
                
                
                CGFloat fileSize = [filemanager attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", CVK_BACKUP_PATH, filename] error:nil].fileSize;
                fileSize = fileSize / 1024.0f / 1024.0f;
                
                name = [NSString stringWithFormat:@"%@  (%.1f MB)", name, fileSize];
                
                PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:name target:self set:nil get:nil detail:nil cell:PSTitleValueCell edit:nil];
                (specifier.properties)[@"filename"] = filename;
                [specifiers addObject:specifier];
            }
        }
        
        _specifiers = [specifiers copy];
    }
    
    return _specifiers;
}

- (void)loadView
{
    [super loadView];
    self.prefsTableView.allowsMultipleSelectionDuringEditing = NO;
}


#pragma mark -
#pragma mark DZNEmptyDataSetSource
#pragma mark -

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSMutableAttributedString *string = [[super titleForEmptyDataSet:scrollView] mutableCopy];
    string.mutableString.string = NSLocalizedStringFromTableInBundle(@"NO_FILES_TO_RESTORE", @"ColoredVK", self.cvkBundle, nil);
    
    return string;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"TabsIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
}


#pragma mark -
#pragma mark UITableViewDelegate, UITableViewDataSource
#pragma mark -

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PSSpecifier *specifier = nil;
        if ([self respondsToSelector:@selector(specifierAtIndexPath:)]) {
            specifier = [self specifierAtIndexPath:indexPath];
        } else {
            NSInteger index = [self indexForRow:indexPath.row inGroup:indexPath.section];
            specifier = [self specifierAtIndex:index];
        }
        
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", CVK_BACKUP_PATH, specifier.properties[@"filename"]] error:&error];
        if (!error && success) [self removeSpecifier:specifier animated:YES];
    }    
}

- (PSTableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [shareButton addTarget:self action:@selector(actionShare:) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setImage:[UIImage imageNamed:@"ShareIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    shareButton.accessibilityValue = cell.specifier.properties[@"filename"];
    cell.accessoryView = shareButton;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSSpecifier *specifier = nil;
    if ([self respondsToSelector:@selector(specifierAtIndexPath:)]) {
        specifier = [self specifierAtIndexPath:indexPath];
    } else {
        NSInteger index = [self indexForRow:indexPath.row inGroup:indexPath.section];
        specifier = [self specifierAtIndex:index];
    }
    
    NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"RESTORE_BACKUP_QUESTION", nil, self.cvkBundle, nil), specifier.properties[@"filename"]];
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:@"ColoredVK 2" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"No") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"YES_I_AM_SURE", nil, self.cvkBundle, nil) style:UIAlertActionStyleDefault 
                                                      handler:^(UIAlertAction *action) {
                                                          [self restoreSettingsFromFile:specifier.properties[@"filename"]];
                                                      }]];
    [alertController present];
}


#pragma mark - Actions

- (void)actionShare:(UIButton *)button
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", CVK_BACKUP_PATH, button.accessibilityValue];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:path isDirectory:NO]] applicationActivities:nil];
    [self presentPopover:activityVC];
}

- (void)actionBackup
{
    ColoredVKHUD *hud = [ColoredVKHUD showHUD];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableArray *files = @[self.prefsPath].mutableCopy;
        
        NSFileManager *filemaneger = [NSFileManager defaultManager];
        if (![filemaneger fileExistsAtPath:CVK_BACKUP_PATH]) [filemaneger createDirectoryAtPath:CVK_BACKUP_PATH withIntermediateDirectories:NO attributes:nil error:nil];
        
        for (NSString *fileName in [filemaneger contentsOfDirectoryAtPath:self.cvkFolder error:nil]) {
            if (![fileName containsString:@"Cache"]) [files addObject:[NSString stringWithFormat:@"%@/%@", self.cvkFolder, fileName]];
        }
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd_HH:mm";
        NSString *backupName = [@"com.daniilpashin.coloredvk2_" stringByAppendingString:[dateFormatter stringFromDate:[NSDate date]]];
        NSString *backupPath = [NSString stringWithFormat:@"%@/%@.zip", CVK_BACKUP_PATH, backupName];
        
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
        
        [SSZipArchive unzipFileAtPath:backupPath toDestination:tmpPath progressHandler:^(NSString *entry, unz_file_info zipInfo, long entryNumber, long total){} 
                    completionHandler:^(NSString *path, BOOL succeeded, NSError *error) {
                        if (succeeded && !error) {
                            NSFileManager *filemanager = [NSFileManager defaultManager];
                            
                            [filemanager removeItemAtPath:self.prefsPath error:nil];
                            [filemanager removeItemAtPath:self.cvkFolder error:nil];
                            [filemanager createDirectoryAtPath:self.cvkFolder withIntermediateDirectories:NO attributes:nil error:nil];
                            
                            NSError *movingError = nil;
                            for (NSString *filename in [filemanager contentsOfDirectoryAtPath:tmpPath error:nil]) {
                                NSString *filePath = [NSString stringWithFormat:@"%@/%@", tmpPath, filename];
                                if ([filename containsString:@"Image"]) {
                                    [filemanager copyItemAtPath:filePath toPath:[NSString stringWithFormat:@"%@/%@", self.cvkFolder, filename] error:&error];
                                } else if ([filename containsString:@"plist"]) {
                                    [filemanager copyItemAtPath:filePath toPath:self.prefsPath error:&error];
                                }                                
                                if (movingError) break;
                            }
                            [filemanager removeItemAtPath:tmpPath error:nil];
                            
                            movingError ? [hud showFailureWithStatus:movingError.localizedDescription] : [hud showSuccess];
                            
                            [self sendNotifications];
                        } else
                            [hud showFailureWithStatus:error.localizedDescription];
                    }];
    });
    
}

- (void)actionReset
{
    void (^resetSettingsBlock)() = ^{
        
        ColoredVKHUD *hud = [ColoredVKHUD showHUD];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSError *error = nil;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:self.prefsPath error:&error];
            [fileManager removeItemAtPath:self.cvkFolder error:&error];
            
            error ? [hud showFailure] : [hud showSuccess];
            
            [self sendNotifications];
        });  
    };
    
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"WARNING", nil, self.cvkBundle, nil)
                                                                             message:NSLocalizedStringFromTableInBundle(@"RESET_SETTINGS_QUESTION", nil, self.cvkBundle, nil) 
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *resetTitle = [NSLocalizedStringFromTableInBundle(@"RESET_SETTINGS", @"ColoredVK", self.cvkBundle, nil) componentsSeparatedByString:@" "].firstObject;    
    [alertController addAction:[UIAlertAction actionWithTitle:resetTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { resetSettingsBlock(); }]];
    [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"No") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [alertController present];
}

- (void)sendNotifications
{
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, NULL, YES);
    CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.reload.menu"),   NULL, NULL, YES);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadSpecifiers];
        
        UINavigationBar *navBar = self.navigationController.navigationBar;
        navBar.barTintColor = navBar.barTintColor;
        navBar.tintColor = navBar.tintColor;
    });
}
@end
