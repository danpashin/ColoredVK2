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
#import "ColoredVKHUD.h"

@interface ColoredVKPrefsController ()
@property (strong, nonatomic, readonly) NSString *prefsPath;
@property (strong, nonatomic, readonly) NSBundle *cvkBundle;
@property (strong, nonatomic, readonly) NSString *cvkFolder;
@property (strong, nonatomic, readonly) PSSpecifier *errorMessage;
@property (strong, nonatomic, readonly) PSSpecifier *footer;
@property (strong, nonatomic, readonly) NSString *tweakVersion;
@property (strong, nonatomic, readonly) NSString *vkAppVersion;
@end

@implementation ColoredVKPrefsController

- (UIStatusBarStyle) preferredStatusBarStyle
{
    if ([[NSBundle mainBundle].executablePath.lastPathComponent isEqualToString:@"vkclient"]) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSString *plistName = @"Main";
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
        
        if (specifiersArray.count == 0) {
            specifiersArray = [NSMutableArray new];
            [specifiersArray addObject:self.errorMessage];
        }
        [specifiersArray addObject:self.footer];
        
//        for (PSSpecifier *specifier in specifiersArray) {
//            if ([specifier.identifier isEqualToString:@"manageAccount"]) {
//                if (!licenceContainsKey(@"login")) [specifier setProperty:@NO forKey:@"enabled"];
//            }
//        }
        
        _specifiers = [specifiersArray copy];
    }
    return _specifiers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
#ifndef COMPILE_APP
    [ColoredVKInstaller sharedInstaller];
#endif
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)view;
            tableView.tableHeaderView = [ColoredVKHeaderView headerForView:self.view];
            tableView.separatorColor = [UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1];
            break;
        }
    }
}

- (id)readPreferenceValue:(PSSpecifier*)specifier
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
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, NULL, YES);
    if ([specifier.identifier isEqualToString:@"enabled"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
    }
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
@end
