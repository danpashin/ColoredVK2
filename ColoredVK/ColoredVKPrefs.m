//
//  ColoredVKPrefs.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKPrefs.h"
#import "ColoredVKColorPickerViewController.h"
#import "UIImage+ResizeMagick.h"
#import "PrefixHeader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ColoredVKHUD.h"
#import "NSDate+DateTools.h"
#import "UIImage+ResizeMagick.h"
#import "SSZipArchive.h"

OBJC_EXPORT Class objc_getClass(const char *name) OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0);

@interface ColoredVKPrefs () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) NSString *prefsPath;
@property (strong, nonatomic) NSBundle *cvkBunlde;
@property (strong, nonatomic) NSString *cvkFolder;
@property (strong, nonatomic) NSString *imageID;
@end

@implementation ColoredVKPrefs

- (UIStatusBarStyle) preferredStatusBarStyle
{
    if ([[NSBundle mainBundle].executablePath.lastPathComponent isEqualToString:@"vkclient"]) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSString *plistName = [@"plists/" stringByAppendingString:self.specifier.properties[@"plistToLoad"]];
        
        NSMutableArray *specifiersArray = [NSMutableArray new];
        if ([self respondsToSelector:@selector(setBundle:)] && [self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:)]) {
            self.bundle = self.cvkBunlde;
            specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self] mutableCopy];
        } else if ([self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:bundle:)]) {
            specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self bundle:self.cvkBunlde] mutableCopy];
        } 
        else if ([self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:)]) {
            specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self] mutableCopy];
        }
        
        for (PSSpecifier *specifier in specifiersArray) {
            specifier.name = NSLocalizedStringFromTableInBundle(specifier.name, @"ColoredVK", self.cvkBunlde, nil);
            
            if (specifier.properties[@"footerText"]) [specifier setProperty:NSLocalizedStringFromTableInBundle(specifier.properties[@"footerText"], @"ColoredVK", self.cvkBunlde, nil) forKey:@"footerText"];
            if (specifier.properties[@"label"]) [specifier setProperty:NSLocalizedStringFromTableInBundle(specifier.properties[@"label"], @"ColoredVK", self.cvkBunlde, nil) forKey:@"label"];
            if (specifier.properties[@"validTitles"]) {            
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
                for (NSString *key in specifier.titleDictionary.allKeys) [tempDict setValue:NSLocalizedStringFromTableInBundle(specifier.titleDictionary[key], @"ColoredVK", self.cvkBunlde, nil) forKey:key];
                specifier.titleDictionary = [tempDict copy];
            }
            
            if ([specifier.identifier isEqualToString:@"checkUpdates"] && [kColoredVKVersion containsString:@"beta"]) [specifier setProperty:@NO forKey:@"enabled"];
        }
        
        if (specifiersArray.count == 0) {
            specifiersArray = [NSMutableArray new];
            [specifiersArray addObject:[self errorMessage]];
        }
        if ([self.specifier.properties[@"shouldAddFooter"] boolValue]) [specifiersArray addObject:[self footer]];
        
        _specifiers = [specifiersArray copy];
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
            break;
        }
    }
}

- (id)readPreferenceValue:(PSSpecifier*)specifier
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];    
    if (!prefs[specifier.properties[@"key"]]) return specifier.properties[@"default"];
    return prefs[specifier.properties[@"key"]];
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:self.prefsPath];
    if (value) [prefs setValue:value forKey:specifier.properties[@"key"]];
    else [prefs removeObjectForKey:specifier.properties[@"key"]];
    [prefs writeToFile:self.prefsPath atomically:YES];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, NULL, YES);
    
    NSArray *identificsToReloadMenu = @[@"menuSelectionStyle", @"hideMenuSeparators", @"changeSwitchColor", @"useMenuParallax", @"changeMenuTextColor"];
    if ([identificsToReloadMenu containsObject:specifier.identifier])
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
}



- (PSSpecifier *)footer
{
    NSString *footerText = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"TWEAK_FOOTER_TEXT", nil, self.cvkBunlde, nil), self.tweakVersion, self.vkAppVersion ];
    PSSpecifier *footer = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [footer setProperty:[footerText stringByAppendingString:@"\n\n© Daniil Pashin 2015"] forKey:@"footerText"];
    [footer setProperty:@"1" forKey:@"footerAlignment"];
    return footer;
}

- (PSSpecifier *)errorMessage
{
    PSSpecifier *errorMessage = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [errorMessage setProperty:[NSLocalizedStringFromTableInBundle(@"LOADING_TWEAK_FILES_ERROR_MESSAGE", nil, self.cvkBunlde, nil) stringByAppendingString:@"\n\nhttps://vk.com/danpashin"] forKey:@"footerText"];
    [errorMessage setProperty:@"1" forKey:@"footerAlignment"];
    return errorMessage;
}

- (NSString *)tweakVersion
{
    return [kColoredVKVersion stringByReplacingOccurrencesOfString:@"-" withString:@" "];
}

- (NSString *)vkAppVersion
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
    return prefs[@"vkVersion"];
}

- (NSBundle *)cvkBunlde
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


- (void)showColorPicker:(PSSpecifier*)specifier
{
    ColoredVKColorPickerViewController *picker = [[ColoredVKColorPickerViewController alloc] initWithIdentifier:specifier.identifier];
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.definesPresentationContext = NO;
    picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    picker.view.backgroundColor = [UIColor clearColor];
    
    UIViewController *controller = [UIViewController new];
    picker.pickerWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    picker.pickerWindow.rootViewController = controller;
    [picker.pickerWindow makeKeyAndVisible];
    [controller presentViewController:picker animated:YES completion:nil];

}

- (void)chooseImage:(PSSpecifier*)specifier
{
    self.imageID = specifier.identifier;
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;    
    if (IS_IPAD) {
        picker.modalPresentationStyle = UIModalPresentationPopover;
        picker.popoverPresentationController.permittedArrowDirections = 0;
        picker.popoverPresentationController.sourceView = self.view;
        picker.popoverPresentationController.sourceRect = self.view.bounds;
    }
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    ColoredVKHUD *hud = [ColoredVKHUD showAddedToView:picker.view];
    hud.backgroundView.blurStyle = LHBlurEffectStyleDark;
    hud.centerBackgroundView.blurStyle = LHBlurEffectStyleNone;
    hud.centerBackgroundView.backgroundColor = [UIColor clearColor];
    hud.didHiddenBlock = ^{ [picker dismissViewControllerAnimated:YES completion:nil]; };
    
    hud.executionBlock = ^(ColoredVKHUD *parentHud) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (![[NSFileManager defaultManager] fileExistsAtPath:self.cvkFolder]) [[NSFileManager defaultManager] createDirectoryAtPath:self.cvkFolder withIntermediateDirectories:NO attributes:nil error:nil];
            NSString *imagePath = [self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", self.imageID]];
            NSString *prevImagePath = [self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", self.imageID]];
            
            NSError *error = nil;
            [UIImagePNGRepresentation(image) writeToFile:imagePath options:NSDataWritingAtomic error:&error];
            if (!error) {
                UIGraphicsBeginImageContext(CGSizeMake(40, 40));
                UIImage *preview = image;
                [preview drawInRect:CGRectMake(0, 0, 40, 40)];
                preview = UIGraphicsGetImageFromCurrentImageContext();
                [UIImagePNGRepresentation(preview) writeToFile:prevImagePath options:NSDataWritingAtomic error:&error];
                UIGraphicsEndImageContext();
                
                CGSize screenSize = UIScreen.mainScreen.bounds.size;
                UIImage *recisedImage = [[UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]] resizedImageByMagick: [NSString stringWithFormat:@"%fx%f#", screenSize.width, screenSize.height]];
                [UIImagePNGRepresentation(recisedImage) writeToFile:imagePath options:NSDataWritingAtomic error:&error];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.image.update" object:nil userInfo:@{ @"identifier" : self.imageID }];
                if ([self.imageID isEqualToString:@"menuBackgroundImage"]) {
                    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
                } else if ([self.imageID isEqualToString:@"messagesBackgroundImage"]) {
                    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.messages"), NULL, NULL, YES);
                }
                error?[parentHud showFailureWithStatus:error.localizedDescription]:[parentHud showSuccess];
            });
        });
    };
    
    hud.executionBlock(hud);
}


- (NSString *)getLastCheckForUpdates:(PSSpecifier *)specifier
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    
    return prefs[@"lastCheckForUpdates"]?[dateFormatter dateFromString:prefs[@"lastCheckForUpdates"]].timeAgoSinceNow : NSLocalizedStringFromTableInBundle(@"NEVER", nil, self.cvkBunlde, nil);
}

- (void)checkForUpdates:(id)sender
{
    NSString *stringURL = [NSString stringWithFormat:@"http://danpashin.ru/api/v%@/checkUpdates.php?userVers=%@&product=com.daniilpashin.coloredvk2", API_VERSION, kColoredVKVersion];
#ifndef COMPILE_FOR_JAIL
    stringURL = [stringURL stringByAppendingString:@"&getIPA=1"];
#endif
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK 2" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        if (!connectionError) {
            NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:self.prefsPath];
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (!responseDict[@"error"]) {
                NSString *skip = NSLocalizedStringFromTableInBundle(@"SKIP_THIS_VERSION_BUTTON_TITLE", nil, self.cvkBunlde, nil);
                NSString *remindLater = NSLocalizedStringFromTableInBundle(@"REMIND_LATER_BUTTON_TITLE", nil, self.cvkBunlde, nil);
                NSString *updateNow = NSLocalizedStringFromTableInBundle(@"UPADTE_BUTTON_TITLE", nil, self.cvkBunlde, nil);
                
                alertController.message = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"UPGRADE_IS_AVAILABLE_ALERT_MESSAGE", nil, self.cvkBunlde, nil),
                                           responseDict[@"version"], responseDict[@"changelog"]];
                [alertController addAction:[UIAlertAction actionWithTitle:skip style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [prefs setValue:responseDict[@"version"] forKey:@"skippedVersion"];
                    [prefs writeToFile:self.prefsPath atomically:YES];
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:remindLater style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
                [alertController addAction:[UIAlertAction actionWithTitle:updateNow style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    NSURL *url = [NSURL URLWithString:responseDict[@"url"]];
                    if ([[UIApplication sharedApplication] canOpenURL:url]) [[UIApplication sharedApplication] openURL:url];
                    
                }]];
            } else {
                alertController.message = NSLocalizedStringFromTableInBundle(@"NO_UPDATES_FOUND_BUTTON_TITLE", nil, self.cvkBunlde, nil);
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{ [self presentViewController:alertController animated:YES completion:nil]; });
            
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
            [prefs setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:@"lastCheckForUpdates"];
            [prefs writeToFile:self.prefsPath atomically:YES];
            [self reloadSpecifiers];
        }
    }];
}

- (void)openProfie
{
    NSURL *appURL = [NSURL URLWithString:@"vk://vk.com/danpashin"];
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:appURL]) [self openURL:appURL];
    else [self openURL:[NSURL URLWithString:@"https://vk.com/danpashin"]];
}

- (void)openURL:(NSURL *)url
{
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) [application openURL:url options:@{} completionHandler:^(BOOL success) {}];
    else [application openURL:url];
}

- (void)clearCoversCache
{
    ColoredVKHUD *hud = [ColoredVKHUD showHUD];
    hud.operation = [NSBlockOperation blockOperationWithBlock:^{
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:CVK_CACHE_PATH error:&error];
        if (success && !error) [hud showSuccess];
        else [hud showFailureWithStatus:[NSString stringWithFormat:@"%@\n%@", error.localizedDescription, error.localizedFailureReason] animated:YES];
    }];
}

- (void)resetSettings
{
    void (^resetSettingsBlock)() = ^{
        if ([[NSBundle mainBundle].executablePath.lastPathComponent isEqualToString:@"vkclient"]) 
            self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:60/255.0f green:112/255.0f blue:169/255.0f alpha:1];
        
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
            error?[hud showFailure]:[hud showSuccess];
        }];  
    };
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"WARNING", nil, self.cvkBunlde, nil)
                                                                             message:NSLocalizedStringFromTableInBundle(@"RESET_SETTINGS_QUESTION", nil, self.cvkBunlde, nil) 
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *resetTitle = [NSLocalizedStringFromTableInBundle(@"RESET_SETTINGS", @"ColoredVK", self.cvkBunlde, nil) componentsSeparatedByString:@" "].firstObject;    
    [alertController addAction:[UIAlertAction actionWithTitle:resetTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { resetSettingsBlock(); }]];
    [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)backupSettings
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

- (void)restoreSettings
{    
    NSMutableArray *files = [NSMutableArray array];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];    
    for (NSString *filename in [filemanager contentsOfDirectoryAtPath:CVK_BACKUP_PATH error:nil]) {
        if ([filename containsString:@"com.daniilpashin.coloredvk2"]) [files addObject:filename];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedStringFromTableInBundle(@"CHOOSE_BACKUP", @"ColoredVK", self.cvkBunlde, nil) 
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (files.count > 0) {
        [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
        for (NSString *filename in files) {
            UIAlertAction *alertAction = [UIAlertAction actionWithTitle:filename style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self restoreSettingsFromFile:filename];
            }];
            [alertController addAction:alertAction];
        }
    } else {
        alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK 2" message:NSLocalizedStringFromTableInBundle(@"NO_FILES_TO_RESTORE", @"ColoredVK", self.cvkBunlde, nil) 
                                                       preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    }
    
    if (IS_IPAD) {
        alertController.popoverPresentationController.permittedArrowDirections = 0;
        alertController.popoverPresentationController.sourceView = self.view;
        alertController.popoverPresentationController.sourceRect = self.view.bounds;
    }
    [self presentViewController:alertController animated:YES completion:nil];
    
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
@end
