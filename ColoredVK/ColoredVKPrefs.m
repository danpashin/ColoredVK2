    //
    //  ColoredVKPrefs.m
    //  ColoredVK
    //
    //  Created by Даниил on 23.04.16.
    //  Copyright (c) 2016 Daniil Pashin. All rights reserved.
    //


#import "ColoredVKPrefs.h"
#import "ColoredVKColorPicker.h"
#import "UIImage+ResizeMagick.h"
#import "PrefixHeader.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "LHProgressHUD.h"

OBJC_EXPORT Class objc_getClass(const char *name) OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0);

@implementation ColoredVKPrefs

- (UIStatusBarStyle) preferredStatusBarStyle
{
    if ([NSStringFromClass([[UIApplication sharedApplication].keyWindow.rootViewController class]) isEqualToString:@"DeckController"]) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (id)specifiers
{
    prefsPath = CVK_PREFS_PATH;
    cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    cvkFolder = CVK_FOLDER_PATH;
    
    
    NSString *plistName = @"ColoredVK";
    
    NSMutableArray *specifiersArray = [NSMutableArray new];
    if ([self respondsToSelector:@selector(setBundle:)] && [self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:)]) {
        self.bundle = cvkBunlde;
        specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self] mutableCopy];
    } else if ([self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:bundle:)]) {
        specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self bundle:cvkBunlde] mutableCopy];
    } 
    else if ([self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:)]) {
        specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self] mutableCopy];
    }
    
    if (specifiersArray.count == 0) {
        specifiersArray = [NSMutableArray new];
        [specifiersArray addObject:[self errorMessage]];
    }
    [specifiersArray addObject:[self footer]];
    
    _specifiers = [specifiersArray copy];
    
    dispatch_async(dispatch_queue_create("com.daniilpashin.coloredvk2.prefs", nil), ^{
        [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed:235.0/255.0f green:235.0/255.0f blue:235.0/255.0f alpha:1.0];
        [UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = [UIColor colorWithRed:90/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1.0];
        [UISwitch appearanceWhenContainedIn:self.class, nil].tag = 404;
        [UITableView appearanceWhenContainedIn:self.class, nil].separatorColor = [UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1];
        [UISegmentedControl appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed:90/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1.0];
    });
    
    return _specifiers;
}

- (id) readPreferenceValue:(PSSpecifier*)specifier
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    
    if (!prefs[specifier.properties[@"key"]]) return specifier.properties[@"default"];
    return prefs[specifier.properties[@"key"]];
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *prefs = [NSMutableDictionary new];
    [prefs addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:prefsPath]];
    [prefs setValue:value forKey:specifier.properties[@"key"]];
    [prefs writeToFile:prefsPath atomically:YES];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
    
    
    NSArray *identificsToReloadMenu = @[@"menuSelectionStyle", @"hideSeparators", @"enabledBlackTheme", @"changeSwitchColor"];
    if ([identificsToReloadMenu containsObject:specifier.identifier]) {
         CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
    }
    
    if ([specifier.identifier isEqualToString:@"enabledBlackTheme"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.black.theme"), NULL, NULL, YES);
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.messages"), NULL, NULL, YES);
    }
}


- (PSSpecifier *)footer
{
    NSString *footerText = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"TWEAK_FOOTER_TEXT", nil, cvkBunlde, nil), [self getTweakVersion], [self getVKVersion] ];
    
    PSSpecifier *footer = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [footer setProperty:[footerText stringByAppendingString:@"\n\n© Daniil Pashin 2015"] forKey:@"footerText"];
    [footer setProperty:@"1" forKey:@"footerAlignment"];
    
    return footer;
}

- (PSSpecifier *)errorMessage
{
    PSSpecifier *errorMessage = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [errorMessage setProperty:[NSLocalizedStringFromTableInBundle(@"LOADING_TWEAK_FILES_ERROR_MESSAGE", nil, cvkBunlde, nil) stringByAppendingString:@"\n\nhttps://vk.com/danpashin"] forKey:@"footerText"];
    [errorMessage setProperty:@"1" forKey:@"footerAlignment"];
    return errorMessage;
}



- (NSString *)getTweakVersion
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    return [prefs[@"cvkVersion"] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
}

- (NSString *)getVKVersion
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    return prefs[@"vkVersion"];
}


- (void)openProfie
{    
    NSURL *appURL = [NSURL URLWithString:@"vk://vk.com/danpashin"];
    if ([[UIApplication sharedApplication] canOpenURL:appURL]) [[UIApplication sharedApplication] openURL:appURL];
    else [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://vk.com/danpashin"]];
}



- (void)showColorPicker:(PSSpecifier*)specifier
{
    ColoredVKColorPicker *picker = [[ColoredVKColorPicker alloc] initWithIdentifier:specifier.identifier];    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    if (IS_IPAD) nav.preferredContentSize = CGSizeMake(self.view.frame.size.width - 100, self.view.frame.size.height / 1.5);
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)chooseImage:(PSSpecifier*)specifier
{
    self.imageID = specifier.identifier;
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    if (IS_IPAD) {
        picker.modalPresentationStyle = UIModalPresentationPopover;
        picker.popoverPresentationController.sourceView = self.view;
        picker.popoverPresentationController.sourceRect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.width/2, 1, 1);
        
        PSTableCell *cell = [self cachedCellForSpecifier:specifier];
        if ([cell.subviews containsObject:[cell viewWithTag:20]]) {
            picker.popoverPresentationController.sourceView = cell;
            picker.popoverPresentationController.sourceRect = CGRectMake([cell viewWithTag:20].frame.origin.x, [cell viewWithTag:20].frame.origin.y, 1, 1);
        }
    } 
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    LHProgressHUD *hud = [LHProgressHUD showAddedToView:picker.view];
    hud.backgroundView.blurStyle = LHBlurEffectStyleDark;
    hud.centerBackgroundView.blurStyle = LHBlurEffectStyleNone;
    hud.centerBackgroundView.backgroundColor = [UIColor clearColor];
    [self saveImage:image completionBlock:^(BOOL success, NSString *message) {
        success?[hud showSuccessWithStatus:@"" animated:YES]:[hud showFailureWithStatus:message animated:YES];
        [hud hideAfterDelay:1.5 hiddenBlock:^{ [picker dismissViewControllerAnimated:YES completion:nil]; }];
    }];
   
}


- (void)saveImage:(UIImage *)image completionBlock:( void(^)(BOOL success, NSString *message) )block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![[NSFileManager defaultManager] fileExistsAtPath:cvkFolder]) [[NSFileManager defaultManager] createDirectoryAtPath:cvkFolder withIntermediateDirectories:NO attributes:nil error:nil];
        NSString *imagePath = [cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", self.imageID]];
        NSString *prevImagePath = [cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", self.imageID]];
        
        UIImage *crImage = [image imageScaledToWidth:[UIScreen mainScreen].bounds.size.width height:[UIScreen mainScreen].bounds.size.height];
            //    crImage = [[UIImage imageWithData:UIImagePNGRepresentation(image)] resizedImageByMagick: [NSString stringWithFormat:@"%fx%f#", [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height]];
        
        NSError *error = nil;
        [UIImagePNGRepresentation(crImage) writeToFile:imagePath options:NSDataWritingAtomic error:&error];
        if (!error) {
            UIGraphicsBeginImageContext(CGSizeMake(40, 40));
            UIImage *preview = image;
            [preview drawInRect:CGRectMake(0, 0, 40, 40)];
            preview = UIGraphicsGetImageFromCurrentImageContext();
            [UIImagePNGRepresentation(preview) writeToFile:prevImagePath options:NSDataWritingAtomic error:&error];
            UIGraphicsEndImageContext();
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk.image.update" object:nil userInfo:@{ @"identifier" : self.imageID }];
            if ([self.imageID isEqualToString:@"menuBackgroundImage"]) {
                CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
            } else if ([self.imageID isEqualToString:@"messagesBackgroundImage"]) {
                CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.messages"), NULL, NULL, YES);
            }    
            if (block) block(error?NO:YES, error?error.localizedDescription:nil); 
        });
    });
}


- (NSArray *)menuValuesDataSource
{
    NSMutableArray *values = [NSMutableArray arrayWithObjects:@"0", @"1", nil];
    if ( [UIDevice currentDevice].systemVersion.floatValue >= 8.0 ) [values addObject:@"2"];
    return [values copy];
}

- (NSArray *)menuTitlesDataSource
{
    NSMutableArray *titles = [NSMutableArray arrayWithObjects:
                              NSLocalizedStringFromTableInBundle(@"NONE", @"ColoredVK", cvkBunlde, nil), 
                              NSLocalizedStringFromTableInBundle(@"TRANSPARENT", @"ColoredVK", cvkBunlde, nil), 
                              nil];
    if ( [UIDevice currentDevice].systemVersion.floatValue >= 8.0 ) [titles addObject:NSLocalizedStringFromTableInBundle(@"BLURRED", @"ColoredVK", cvkBunlde, nil)];
    return [titles copy];
}
@end
