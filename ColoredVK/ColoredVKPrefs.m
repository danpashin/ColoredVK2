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
#import "ColoredVKSettingsController.h"
//#import "YMSPhotoPickerViewController.h"

@interface ColoredVKPrefs () <UIImagePickerControllerDelegate, UINavigationControllerDelegate> // YMSPhotoPickerViewControllerDelegate
@property (strong, nonatomic, readonly) NSString *prefsPath;
@property (strong, nonatomic, readonly) NSBundle *cvkBundle;
@property (strong, nonatomic, readonly) NSString *cvkFolder;
@property (strong, nonatomic) NSString *lastImageIdentifier;
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
            self.bundle = self.cvkBundle;
            specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self] mutableCopy];
        } else if ([self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:bundle:)]) {
            specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self bundle:self.cvkBundle] mutableCopy];
        } 
        else if ([self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:)]) {
            specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self] mutableCopy];
        }
        
        for (PSSpecifier *specifier in specifiersArray) {
            specifier.name = NSLocalizedStringFromTableInBundle(specifier.name, @"ColoredVK", self.cvkBundle, nil);
            
            if (specifier.properties[@"footerText"]) [specifier setProperty:NSLocalizedStringFromTableInBundle(specifier.properties[@"footerText"], @"ColoredVK", self.cvkBundle, nil) forKey:@"footerText"];
            if (specifier.properties[@"label"]) [specifier setProperty:NSLocalizedStringFromTableInBundle(specifier.properties[@"label"], @"ColoredVK", self.cvkBundle, nil) forKey:@"label"];
            if (specifier.properties[@"validTitles"]) {            
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
                for (NSString *key in specifier.titleDictionary.allKeys) [tempDict setValue:NSLocalizedStringFromTableInBundle(specifier.titleDictionary[key], @"ColoredVK", self.cvkBundle, nil) forKey:key];
                specifier.titleDictionary = [tempDict copy];
            }
            
            if ([specifier.identifier isEqualToString:@"checkUpdates"] && [kColoredVKVersion containsString:@"beta"]) [specifier setProperty:@NO forKey:@"enabled"];
        }
        
        if (specifiersArray.count == 0) {
            specifiersArray = [NSMutableArray new];
            [specifiersArray addObject:self.errorMessage];
        }
        if ([self.specifier.properties[@"shouldAddFooter"] boolValue]) [specifiersArray addObject:self.footer];
        
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

- (id)readPreferenceValue:(PSSpecifier *)specifier
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
    NSString *footerText = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"TWEAK_FOOTER_TEXT", nil, self.cvkBundle, nil), self.tweakVersion, self.vkAppVersion ];
    PSSpecifier *footer = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [footer setProperty:[footerText stringByAppendingString:@"\n\n© Daniil Pashin 2015"] forKey:@"footerText"];
    [footer setProperty:@"1" forKey:@"footerAlignment"];
    return footer;
}

- (PSSpecifier *)errorMessage
{
    PSSpecifier *errorMessage = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [errorMessage setProperty:[NSLocalizedStringFromTableInBundle(@"LOADING_TWEAK_FILES_ERROR_MESSAGE", nil, self.cvkBundle, nil) stringByAppendingString:@"\n\nhttps://vk.com/danpashin"] forKey:@"footerText"];
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
    self.lastImageIdentifier = specifier.identifier;
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentPopover:picker];
}

//- (void)chooseImageWithNewPicker:(PSSpecifier*)specifier
//{
//    self.lastImageIdentifier = specifier.identifier;
//    YMSPhotoPickerViewController *picker = [YMSPhotoPickerViewController new];
//    picker.delegate = self;
//    [self presentViewController:picker];
//}
//
//- (void)photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:(YMSPhotoPickerViewController *)picker
//{
//    NSString *message = [NSString stringWithFormat:@"ColoredVK 2 doesn't have rights to your album.\n%@", UIKitLocalizedString(@"You can enable access in Privacy Settings.")];
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK 2" message:message preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) { }]];
//    [self presentViewController:alertController];
//}
//
//- (void)photoPickerViewController:(YMSPhotoPickerViewController *)picker didFinishPickingImage:(UIImage *)image
//{
//    [self saveImage:image fromPickerViewController:picker];
//}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self saveImage:image fromPickerViewController:picker]; 
}


- (void)saveImage:(UIImage *)image fromPickerViewController:(UIViewController *)picker
{
    ColoredVKHUD *hud = [ColoredVKHUD showAddedToView:picker.view];
    hud.backgroundView.blurStyle = LHBlurEffectStyleDark;
    hud.centerBackgroundView.blurStyle = LHBlurEffectStyleNone;
    hud.centerBackgroundView.backgroundColor = [UIColor clearColor];
    hud.didHiddenBlock = ^{ [picker dismissViewControllerAnimated:YES completion:nil]; };
    
    hud.executionBlock = ^(ColoredVKHUD *parentHud) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (![[NSFileManager defaultManager] fileExistsAtPath:self.cvkFolder]) [[NSFileManager defaultManager] createDirectoryAtPath:self.cvkFolder withIntermediateDirectories:NO attributes:nil error:nil];
            NSString *imagePath = [self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", self.lastImageIdentifier]];
            NSString *prevImagePath = [self.cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", self.lastImageIdentifier]];
            
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
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.image.update" object:nil userInfo:@{ @"identifier" : self.lastImageIdentifier }];
                if ([self.lastImageIdentifier isEqualToString:@"menuBackgroundImage"]) {
                    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
                } else if ([self.lastImageIdentifier isEqualToString:@"messagesBackgroundImage"]) {
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
    
    return prefs[@"lastCheckForUpdates"]?[dateFormatter dateFromString:prefs[@"lastCheckForUpdates"]].timeAgoSinceNow : NSLocalizedStringFromTableInBundle(@"NEVER", nil, self.cvkBundle, nil);
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
                NSString *skip = NSLocalizedStringFromTableInBundle(@"SKIP_THIS_VERSION_BUTTON_TITLE", nil, self.cvkBundle, nil);
                NSString *remindLater = NSLocalizedStringFromTableInBundle(@"REMIND_LATER_BUTTON_TITLE", nil, self.cvkBundle, nil);
                NSString *updateNow = NSLocalizedStringFromTableInBundle(@"UPADTE_BUTTON_TITLE", nil, self.cvkBundle, nil);
                
                alertController.message = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"UPGRADE_IS_AVAILABLE_ALERT_MESSAGE", nil, self.cvkBundle, nil),
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
                alertController.message = NSLocalizedStringFromTableInBundle(@"NO_UPDATES_FOUND_BUTTON_TITLE", nil, self.cvkBundle, nil);
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
            }
            [self presentViewController:alertController animated:YES completion:nil];
            
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

- (void)openTesterPage:(PSSpecifier *)specifier
{
    NSURL *appURL = [NSURL URLWithString:[NSString stringWithFormat:@"vk://vk.com/%@", specifier.properties[@"url"]]];
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:appURL]) [self openURL:appURL];
    else [self openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/%@", specifier.properties[@"url"]]]];
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
        else [hud showFailureWithStatus:[NSString stringWithFormat:@"%@\n%@", error.localizedDescription, error.localizedFailureReason]];
    }];
}

- (void)resetSettings
{
    [[ColoredVKSettingsController alloc] actionReset];
}

- (void)backupSettings
{
    [[ColoredVKSettingsController alloc] actionBackup];
}

- (void)presentPopover:(UIViewController *)controller
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (IS_IPAD) {
            controller.modalPresentationStyle = UIModalPresentationPopover;
            controller.popoverPresentationController.permittedArrowDirections = 0;
            controller.popoverPresentationController.sourceView = self.view;
            controller.popoverPresentationController.sourceRect = self.view.bounds;
        }
        [self.navigationController presentViewController:controller animated:YES completion:nil];
    });
}
@end
