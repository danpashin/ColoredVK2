//
//  ColoredVKPrefsController.m
//  ColoredVK
//
//  Created by Даниил on 19.07.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKPrefsController.h"
#import "PrefixHeader.h"

@implementation ColoredVKPrefsController

- (UIStatusBarStyle) preferredStatusBarStyle
{
#ifndef COMPILE_FOR_JAIL
    return UIStatusBarStyleLightContent;
#else
    return UIStatusBarStyleDefault;
#endif
}

- (id)specifiers
{
    prefsPath = CVK_PREFS_PATH;
    cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    
    NSString *plistName = @"ColoredVKMainPrefs";
    
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
    
    [UISwitch appearanceWhenContainedIn:self.class, nil].tintColor = [UIColor colorWithRed:235.0/255.0f green:235.0/255.0f blue:235.0/255.0f alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].onTintColor = [UIColor colorWithRed:90/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1.0];
    [UISwitch appearanceWhenContainedIn:self.class, nil].tag = 404;
    [UITableView appearanceWhenContainedIn:self.class, nil].separatorColor = [UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1];
    
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
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] init];
    [prefs addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:prefsPath]];
    [prefs setValue:value forKey:specifier.properties[@"key"]];
    [prefs writeToFile:prefsPath atomically:YES];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.messages"), NULL, NULL, YES);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.black.theme"), NULL, NULL, YES);
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

@end
