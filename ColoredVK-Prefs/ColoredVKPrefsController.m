//
//  ColoredVKPrefsController.m
//  ColoredVK
//
//  Created by Даниил on 19.07.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKPrefsController.h"
#import "PrefixHeader.h"
#import "ColoredVKHeaderView.h"
#import "ColoredVKInstaller.h"
#import "ColoredVKPrefs.h"
#import "LHProgressHUD.h"

@interface ColoredVKPrefsController ()
@property (strong, nonatomic) NSString *prefsPath;
@property (strong, nonatomic) NSBundle *cvkBunlde;
@property (strong, nonatomic) NSString *cvkFolder;
@end

@implementation ColoredVKPrefsController

- (UIStatusBarStyle) preferredStatusBarStyle
{
    if ([NSStringFromClass(UIApplication.sharedApplication.keyWindow.rootViewController.class) isEqualToString:@"DeckController"]) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (id)specifiers
{
    self.prefsPath = CVK_PREFS_PATH;
    self.cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    self.cvkFolder = CVK_FOLDER_PATH;
    
    NSString *plistName = @"Main";
    
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
    
    return _specifiers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[ColoredVKInstaller alloc] startWithCompletionBlock:^(BOOL disableTweak) {}];
    for (UIView *view in self.view.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"UITableView"]) {
            UITableView *tableView = (UITableView *)view;
            tableView.tableHeaderView = [ColoredVKHeaderView headerForView:self.view];
            tableView.separatorColor = [UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1];
            break;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *navbar = self.navigationController.navigationBar;
    if ([navbar.subviews containsObject:[navbar viewWithTag:10]]) {
        [[navbar viewWithTag:10] removeFromSuperview];        
        [navbar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    }
}

- (id) readPreferenceValue:(PSSpecifier*)specifier
{    
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
    if (prefs == nil) { prefs = [NSMutableDictionary new]; [prefs writeToFile:self.prefsPath atomically:YES]; }
    
    if (!prefs[specifier.properties[@"key"]]) return specifier.properties[@"default"];
    return prefs[specifier.properties[@"key"]];
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:self.prefsPath];
    [prefs setValue:value forKey:specifier.properties[@"key"]];
    [prefs writeToFile:self.prefsPath atomically:YES];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
    if ([specifier.identifier isEqualToString:@"enabled"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.black.theme"), NULL, NULL, YES);
    }
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
    return [kColoredVKVersion stringByReplacingOccurrencesOfString:@"-" withString:@" "];
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
    [alertController addAction:[UIAlertAction actionWithTitle:[NSLocalizedStringFromTableInBundle(@"RESET_SETTINGS", @"Main", self.cvkBunlde, nil) componentsSeparatedByString:@" "].firstObject 
                                                        style:UIAlertActionStyleDestructive 
                                                      handler:^(UIAlertAction *action) {
                                                          LHProgressHUD *hud = [LHProgressHUD showAddedToView:UIApplication.sharedApplication.keyWindow.rootViewController.view];
                                                          hud.centerBackgroundView.blurStyle = LHBlurEffectStyleLight;
                                                          hud.infoColor = [UIColor colorWithWhite:0.55 alpha:1];
                                                          hud.spinnerColor = hud.infoColor;
                                                          
                                                          NSError *error = nil;
                                                          [[NSFileManager defaultManager] removeItemAtPath:self.prefsPath error:&error];
                                                          [[NSFileManager defaultManager] removeItemAtPath:CVK_FOLDER_PATH error:&error];
                                                          [[NSFileManager defaultManager] removeItemAtPath:[CVK_PREFS_PATH stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"] error:&error];
                                                          [self reloadSpecifiers];
                                                          CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
                                                          CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
                                                          CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.black.theme"), NULL, NULL, YES);
                                                          error?[hud showFailureWithStatus:@"" animated:YES]:[hud showSuccessWithStatus:@"" animated:YES];
                                                          [hud hideAfterDelay:1.5];
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}
@end
