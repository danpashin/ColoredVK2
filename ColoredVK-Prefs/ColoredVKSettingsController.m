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

@implementation ColoredVKSettingsController

- (UIStatusBarStyle) preferredStatusBarStyle
{
    if ([[NSBundle mainBundle].executablePath.lastPathComponent isEqualToString:@"vkclient"]) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

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
                [specifier.properties setValue:filename forKey:@"filename"];
                [specifiers addObject:specifier];
            }
        }
        if (specifiers.count == 0) [specifiers addObject:self.errorMessage];
        
        _specifiers = [specifiers copy];
    }
    
    return _specifiers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)view;
            tableView.separatorColor = [UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1];
            tableView.allowsMultipleSelectionDuringEditing = NO;
            break;
        }
    }
}

- (NSBundle *)cvkBundle
{
    return [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
}

- (NSString *)cvkFolder
{
    return CVK_FOLDER_PATH;
}

- (NSString *)prefsPath
{
    return CVK_PREFS_PATH;
}

- (PSSpecifier *)errorMessage
{
    PSSpecifier *errorMessage = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [errorMessage setProperty:CVKLocalizedStringFromTable(@"NO_FILES_TO_RESTORE", @"ColoredVK") forKey:@"footerText"];
    [errorMessage setProperty:@"1" forKey:@"footerAlignment"];
    return errorMessage;
}




#pragma mark UITableView delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];   
        
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", CVK_BACKUP_PATH, specifier.properties[@"filename"]] error:&error];
        if (!error && success) [self removeSpecifier:specifier animated:YES];
    }    
}

- (PSTableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    CGFloat buttonWidth = 30.0;
    if (![cell.contentView.subviews containsObject:[cell.contentView viewWithTag:2]]) {
        UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width-1.5*buttonWidth, 0, buttonWidth, buttonWidth)];
        [shareButton addTarget:self action:@selector(actionShare:) forControlEvents:UIControlEventTouchUpInside];
        [shareButton setImage:[UIImage imageNamed:@"ShareIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        shareButton.accessibilityValue = cell.specifier.properties[@"filename"];
        shareButton.tag = 2;
        [cell.contentView addSubview:shareButton];
        
        shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[shareButton]-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil views:NSDictionaryOfVariableBindings(shareButton)]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[shareButton(width)]-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:@{@"width":@(buttonWidth)} views:NSDictionaryOfVariableBindings(shareButton)]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
    
    NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"RESTORE_BACKUP_QUESTION", nil, self.cvkBundle, nil), specifier.properties[@"filename"]];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK 2" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"No") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"YES_I_AM_SURE", nil, self.cvkBundle, nil) style:UIAlertActionStyleDefault 
                                                      handler:^(UIAlertAction *action) {
                                                          [self restoreSettingsFromFile:specifier.properties[@"filename"]];
                                                      }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];

}



#pragma mark Actions

- (void)actionShare:(UIButton *)button
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", CVK_BACKUP_PATH, button.accessibilityValue];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:path isDirectory:NO]] applicationActivities:nil];
    [self presentPopover:activityVC];
}

- (void)actionBackup
{
    ColoredVKHUD *hud = [ColoredVKHUD showHUD];
    hud.operation = [NSBlockOperation blockOperationWithBlock:^{
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
        
        [SSZipArchive createZipFileAtPath:backupPath withFilesAtPaths:files];
        [hud showSuccess];
    }];
}

- (void)restoreSettingsFromFile:(NSString *)file
{
    ColoredVKHUD *hud = [ColoredVKHUD showHUD];
    hud.executionBlock = ^(ColoredVKHUD *parentHud){
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
                            
                            movingError?[parentHud showFailureWithStatus:movingError.localizedDescription]:[parentHud showSuccess];
                            
                            [self reloadSpecifiers];
                            CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
                            CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, NULL, YES);
                            CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.reload.menu"),   NULL, NULL, YES);
                            
                        } else [parentHud showFailureWithStatus:error.localizedDescription];
                    }];
    };
    hud.executionBlock(hud);
    
}

- (void)actionReset
{
    void (^resetSettingsBlock)() = ^{
        
        ColoredVKHUD *hud = [ColoredVKHUD showHUD];
        hud.operation = [NSBlockOperation blockOperationWithBlock:^{
            NSError *error = nil;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:self.prefsPath error:&error];
            [fileManager removeItemAtPath:self.cvkFolder error:&error];
            [self reloadSpecifiers];
            CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
            CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, NULL, YES);
            CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.reload.menu"),   NULL, NULL, YES);
            
            if ([[NSBundle mainBundle].executablePath.lastPathComponent isEqualToString:@"vkclient"]) 
                self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:60/255.0f green:112/255.0f blue:169/255.0f alpha:1];
            
            error?[hud showFailure]:[hud showSuccess];
        }];  
    };
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"WARNING", nil, self.cvkBundle, nil)
                                                                             message:NSLocalizedStringFromTableInBundle(@"RESET_SETTINGS_QUESTION", nil, self.cvkBundle, nil) 
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *resetTitle = [NSLocalizedStringFromTableInBundle(@"RESET_SETTINGS", @"ColoredVK", self.cvkBundle, nil) componentsSeparatedByString:@" "].firstObject;    
    [alertController addAction:[UIAlertAction actionWithTitle:resetTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { resetSettingsBlock(); }]];
    [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"No") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}


- (void)presentPopover:(UIViewController *)controller
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *viewCotroller = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (IS_IPAD) {
            controller.modalPresentationStyle = UIModalPresentationPopover;
            controller.popoverPresentationController.permittedArrowDirections = 0;
            controller.popoverPresentationController.sourceView = viewCotroller.view;
            controller.popoverPresentationController.sourceRect = viewCotroller.view.bounds;
        }
        [viewCotroller presentViewController:controller animated:YES completion:nil];
    });
}
@end
