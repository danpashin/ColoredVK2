    //
    //  ColoredVKPrefs.m
    //  ColoredVK
    //
    //  Created by Даниил on 23.04.16.
    //  Copyright (c) 2016 Daniil Pashin. All rights reserved.
    //


#import "ColoredVKPrefs.h"
#import "ColoredVKColorPicker.h"
#import "ColoredVKJailCheck.h"
#import "UIImage+ResizeMagick.h"
#import "PrefixHeader.h"


@implementation ColoredVKPrefs
- (id)specifiers
{
    cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    prefsPath = CVK_PREFS_PATH;
    cvkFolder = CVK_FOLDER_PATH;
    
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed:235.0/255.0f green:235.0/255.0f blue:235.0/255.0f alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = [UIColor colorWithRed:90/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1.0];
    [UITableView appearanceWhenContainedIn:self.class, nil].separatorColor = [UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1];
    
    NSMutableArray *specifiersArray = [[self loadSpecifiersFromPlistName:@"ColoredVK" target:self] mutableCopy];
    
    if (specifiersArray.count == 0) {
        [specifiersArray addObject:[self errorMessage]];
        [specifiersArray addObject:[self footer]];
    }  else {
        if ([ColoredVKJailCheck isExecutable]) {
            for (PSSpecifier *spec in specifiersArray) {
                
                if ([spec.identifier isEqualToString:@"developerLink"]) {
                    [specifiersArray removeObject:spec];
                    [specifiersArray addObject:[self footer]];
                }
            }
        } else {
            [specifiersArray insertObject:[self footer] atIndex:[specifiersArray indexOfObject:specifiersArray.lastObject]];
        }
        
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
        
        if ([prefs[@"enabledBlackTheme"] boolValue]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (PSSpecifier *spec in specifiersArray) {                    
                    if ([spec.identifier isEqualToString:@"enabledBlackTheme"]) {
                        [spec setProperty:@YES forKey:@"enabled"];
                    } else if ([spec.identifier isEqualToString:@"developerLink"]) {
                        [spec setProperty:@YES forKey:@"enabled"];
                    } else {
                        [spec setProperty:@NO forKey:@"enabled"];
                    }
                }
            });
        }
    }
    
    _specifiers = [specifiersArray copy];
    
        
    
    return _specifiers;
}


- (id) readPreferenceValue:(PSSpecifier*)specifier
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    if (![prefs[@"enabledBlackTheme"] boolValue]) {
        if ([specifier.identifier isEqualToString:@"useBlur"] ) {
            if ( [UIDevice currentDevice].systemVersion.floatValue >= 8.0 ) {
                [specifier setProperty:@YES forKey:@"enabled"];
            } else {
                [specifier setProperty:@NO forKey:@"enabled"];
            }
        } 
    }
    
    if (!prefs[specifier.properties[@"key"]]) {
        return specifier.properties[@"default"];
    }
    return prefs[specifier.properties[@"key"]];
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] init];
    [prefs addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:prefsPath]];
    [prefs setValue:value forKey:specifier.properties[@"key"]];
    [prefs writeToFile:prefsPath atomically:YES];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
    
    if ([specifier.identifier isEqualToString:@"useBlur"] || [specifier.identifier isEqualToString:@"hideSeparators"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
    }
    
    if ([specifier.identifier isEqualToString:@"enabledBlackTheme"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.black.theme"), NULL, NULL, YES);
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.messages"), NULL, NULL, YES);
        
        [self reloadSpecifiers];
    }
}


- (PSSpecifier *)footer
{
    NSString *footerText = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"TWEAK_FOOTER_TEXT", nil, cvkBunlde, nil), [self getTweakVersion], [self getVKVersion] ];
    
    PSSpecifier *footer = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [footer setProperty:[footerText stringByAppendingString:[NSString stringWithFormat:@"\n\n© Daniil Pashin %@", [self dynamicYear]]] forKey:@"footerText"];
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


- (NSString *)dynamicYear
{
    NSString *dynamicYear = @"2015";
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy";
    
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    if (![dynamicYear isEqual:dateString]) { dynamicYear = [NSString stringWithFormat:@"%@ - %@", dynamicYear, dateString]; }
    return dynamicYear;
}



- (void)openProfie
{    
    NSURL *appURL = [NSURL URLWithString:@"vk://vk.com/danpashin"];
    NSURL *safariURL = [NSURL URLWithString:@"https://vk.com/danpashin"];
    if ( [[UIApplication sharedApplication] canOpenURL:appURL] ) {
        [[UIApplication sharedApplication] openURL:appURL];
    } else {
        [[UIApplication sharedApplication] openURL:safariURL];
    }
}



- (void)showColorPicker:(PSSpecifier*)specifier
{
    ColoredVKColorPicker *picker = [ColoredVKColorPicker new];
    picker.cellIdentifier = specifier.identifier;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)chooseImage:(PSSpecifier*)specifier
{
    self.imageID = specifier.identifier;
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    NSString *imagePath = [cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", self.imageID]];
    NSString *prevImagePath = [cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", self.imageID]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cvkFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cvkFolder withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    
    UIImage *newImage = image;
    newImage = [newImage resizedImageByMagick: [NSString stringWithFormat:@"%fx%f#", [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height]];
    
    BOOL success = [UIImagePNGRepresentation(newImage) writeToFile:imagePath atomically:YES];
    if (success) {
        UIGraphicsBeginImageContext(CGSizeMake(40, 40));
        UIImage *preview = image;
        [preview drawInRect:CGRectMake(0, 0, 40, 40)];
        preview = UIGraphicsGetImageFromCurrentImageContext();
        [UIImagePNGRepresentation(preview) writeToFile:prevImagePath atomically:YES];
        UIGraphicsEndImageContext();
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"ERROR", nil, cvkBunlde, nil)
                                                        message:NSLocalizedStringFromTableInBundle(@"CAN_NOT_SAVE_IMAGE_TRY_AGAIN", nil, cvkBunlde, nil)
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk.image.update" object:nil userInfo:@{@"identifier" : self.imageID}];
    
    if ([self.imageID isEqualToString:@"menuBackgroundImage"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
    }
    
    if ([self.imageID isEqualToString:@"messagesBackgroundImage"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.messages"), NULL, NULL, YES);
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    
}
@end
