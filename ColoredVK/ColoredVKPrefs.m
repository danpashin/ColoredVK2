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
#import "NSDate+DateTools.h"
#import "UIImage+ResizeMagick.h"

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
    if ([NSStringFromClass([UIApplication.sharedApplication.keyWindow.rootViewController class]) isEqualToString:@"DeckController"]) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (id)specifiers
{
    self.prefsPath = CVK_PREFS_PATH;
    self.cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    self.cvkFolder = CVK_FOLDER_PATH;
    
    
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
            for (NSString *key in specifier.titleDictionary.allKeys) {
                [tempDict setValue:NSLocalizedStringFromTableInBundle([specifier.titleDictionary objectForKey:key], @"ColoredVK", self.cvkBunlde, nil) forKey:key];
            }
            specifier.titleDictionary = [tempDict copy];
        }
    }
    
    if (specifiersArray.count == 0) {
        specifiersArray = [NSMutableArray new];
        [specifiersArray addObject:[self errorMessage]];
    }
    if ([self.specifier.properties[@"shouldAddFooter"] boolValue]) [specifiersArray addObject:[self footer]];
    
    _specifiers = [specifiersArray copy];
    
    return _specifiers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (UIView *view in self.view.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"UITableView"]) {
            UITableView *tableView = (UITableView *)view;
            tableView.separatorColor = [UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1];
            break;
        }
    }
}

- (id) readPreferenceValue:(PSSpecifier*)specifier
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
    
    if (!prefs[specifier.properties[@"key"]]) return specifier.properties[@"default"];
    return prefs[specifier.properties[@"key"]];
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{    
    [self setPrefsValue:value forKey:specifier.properties[@"key"]];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
    
    NSArray *identificsToReloadMenu = @[@"menuSelectionStyle", @"hideMenuSeparators", @"enabledBlackTheme", @"changeSwitchColor"];
    if ([identificsToReloadMenu containsObject:specifier.identifier]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
    }
    
    if ([specifier.identifier isEqualToString:@"enabledBlackTheme"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.black.theme"), NULL, NULL, YES);
//        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.messages"), NULL, NULL, YES);
    }
}


- (void)setPrefsValue:(id)value forKey:(NSString *)key
{
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:self.prefsPath];
    if (value) [prefs setValue:value forKey:key];
    else [prefs removeObjectForKey:key];
    [prefs writeToFile:self.prefsPath atomically:YES];
}


- (PSSpecifier *)footer
{
    NSString *footerText = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"TWEAK_FOOTER_TEXT", nil, self.cvkBunlde, nil), [self getTweakVersion], [self getVKVersion] ];
    
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



- (NSString *)getTweakVersion
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
    return [prefs[@"cvkVersion"] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
}

- (NSString *)getVKVersion
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
    return prefs[@"vkVersion"];
}

- (void)resetSettings
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"WARNING", nil, self.cvkBunlde, nil)
                                                                             message:NSLocalizedStringFromTableInBundle(@"RESET_SETTINGS_QUESTION", nil, self.cvkBunlde, nil) 
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[NSLocalizedStringFromTableInBundle(@"RESET_SETTINGS", @"ColoredVK", self.cvkBunlde, nil) componentsSeparatedByString:@" "][0] 
                                                        style:UIAlertActionStyleDestructive 
                                                      handler:^(UIAlertAction *action) {
                                                          NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:self.prefsPath];
                                                          NSArray *keysToExclude = @[@"cvkVersion", @"vkVersion", @"lastCheckForUpdates"];
                                                          for (NSString *key in prefs.allKeys) {
                                                              if (![keysToExclude containsObject:key]) [prefs removeObjectForKey:key];
                                                          }
                                                          [prefs writeToFile:self.prefsPath atomically:YES];
                                                          
                                                          NSFileManager *manager = [NSFileManager defaultManager];
                                                          NSArray *imageNames = [manager contentsOfDirectoryAtPath:CVK_FOLDER_PATH error:nil];
                                                          for (NSString *name in imageNames) {
                                                              if ([name.pathExtension.lowercaseString isEqualToString:@"png"]) [manager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", self.cvkFolder, name] error:nil];
                                                          }
                                                          
                                                          [self reloadSpecifiers];
                                                          for (id viewController in self.parentViewController.childViewControllers) {
                                                              if ([viewController respondsToSelector:@selector(reloadSpecifiers)]) { [viewController performSelector:@selector(reloadSpecifiers)]; break; }
                                                          }
                                                          CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
                                                          CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
                                                          CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.messages"), NULL, NULL, YES);
                                                          CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.black.theme"), NULL, NULL, YES);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}



- (void)showColorPicker:(PSSpecifier*)specifier
{
    ColoredVKColorPicker *picker = [[ColoredVKColorPicker alloc] initWithIdentifier:specifier.identifier];
    picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.definesPresentationContext = NO;
    picker.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    picker.view.backgroundColor = [UIColor clearColor];
    
    UIViewController *controller = [UIViewController new];
    picker.pickerWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    picker.pickerWindow.rootViewController = controller;
    picker.pickerWindow.windowLevel = UIWindowLevelNormal;
    picker.pickerWindow.backgroundColor = [UIColor clearColor];
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
            
            UIImage *recisedImage = [[UIImage imageWithContentsOfFile:imagePath] resizedImageByMagick: [NSString stringWithFormat:@"%fx%f#", [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height]];
            [UIImagePNGRepresentation(recisedImage) writeToFile:imagePath options:NSDataWritingAtomic error:&error];
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

- (NSString *)getLastCheckForUpdates:(PSSpecifier *)specifier
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    
    return prefs[@"lastCheckForUpdates"]?[dateFormatter dateFromString:prefs[@"lastCheckForUpdates"]].timeAgoSinceNow : NSLocalizedStringFromTableInBundle(@"NEVER", nil, self.cvkBunlde, nil);
}

- (void)checkForUpdates:(id)sender
{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *stringURL = [NSString stringWithFormat:@"http://danpashin.ru/api/v1.1/checkUpdates.php?userVers=%@&product=com.daniilpashin.coloredvk2", kColoredVKVersion];
#ifndef COMPILE_FOR_JAIL
        stringURL = [stringURL stringByAppendingString:@"&getIPA=1"];
#endif
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest 
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                                   if (!connectionError) {
                                       NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:self.prefsPath];
                                       NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                       if (!responseDict[@"error"]) {
                                           NSString *skip = NSLocalizedStringFromTableInBundle(@"SKIP_THIS_VERSION_BUTTON_TITLE", nil, self.cvkBunlde, nil);
                                           NSString *remindLater = NSLocalizedStringFromTableInBundle(@"REMIND_LATER_BUTTON_TITLE", nil, self.cvkBunlde, nil);
                                           NSString *updateNow = NSLocalizedStringFromTableInBundle(@"UPADTE_BUTTON_TITLE", nil, self.cvkBunlde, nil);
                                           
                                           alertController.message = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"YOUR_COPY_OF_TWEAK_NEEDS_TO_BE_UPGRADED_ALERT_MESSAGE", nil, self.cvkBunlde, nil), responseDict[@"version"]];
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
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
                                       });
                                       
                                       NSDateFormatter *dateFormatter = [NSDateFormatter new];
                                       dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
                                       [prefs setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:@"lastCheckForUpdates"];
                                       [prefs writeToFile:self.prefsPath atomically:YES];
                                       [self reloadSpecifiers];
                                   }
                               }];
//    });
    
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
@end
