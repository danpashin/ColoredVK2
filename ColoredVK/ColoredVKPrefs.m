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

@interface ColoredVKPrefs () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) NSString *prefsPath;
@property (strong, nonatomic) NSBundle *cvkBunlde;
@property (strong, nonatomic) NSString *cvkFolder;
@property (strong, nonatomic) NSString *imageID;
@end

@implementation ColoredVKPrefs

- (UIStatusBarStyle) preferredStatusBarStyle
{
    if ([NSStringFromClass([[UIApplication sharedApplication].keyWindow.rootViewController class]) isEqualToString:@"DeckController"]) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (id)specifiers
{
    self.prefsPath = CVK_PREFS_PATH;
    self.cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    self.cvkFolder = CVK_FOLDER_PATH;
    
    
    NSString *plistName = @"ColoredVK";
    
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
        [UISegmentedControl appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed:90/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1.0];
    });
    
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
    
    if ((specifier.properties[@"iconImage"] == nil) && specifier.properties[@"icon"]) {
        [specifier setProperty:[UIImage imageNamed:[specifier.properties[@"icon"] stringByDeletingPathExtension] inBundle:self.self.cvkBunlde compatibleWithTraitCollection:nil] forKey:@""];
        [self reloadSpecifier:specifier];
    }
    
    if (!prefs[specifier.properties[@"key"]]) return specifier.properties[@"default"];
    return prefs[specifier.properties[@"key"]];
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{    
    [self setPrefsValue:value forKey:specifier.properties[@"key"]];
    
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


- (void)openProfie
{    
    NSURL *appURL = [NSURL URLWithString:@"vk://vk.com/danpashin"];
    if ([[UIApplication sharedApplication] canOpenURL:appURL]) [[UIApplication sharedApplication] openURL:appURL];
    else [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://vk.com/danpashin"]];
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
        
        UIImage *crImage = [image imageScaledToWidth:[UIScreen mainScreen].bounds.size.width height:[UIScreen mainScreen].bounds.size.height];
        
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
@end
