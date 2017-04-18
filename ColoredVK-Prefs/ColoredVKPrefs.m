//
//  ColoredVKPrefs.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//

#import "ColoredVKPrefs.h"


@implementation ColoredVKPrefs

- (UIStatusBarStyle)preferredStatusBarStyle
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
            specifier.name = NSLocalizedStringFromTableInBundle(specifier.name, @"ColoredVK", self.bundle, nil);
            
            if (specifier.properties[@"footerText"]) [specifier setProperty:NSLocalizedStringFromTableInBundle(specifier.properties[@"footerText"], @"ColoredVK", self.bundle, nil) forKey:@"footerText"];
            if (specifier.properties[@"label"]) [specifier setProperty:NSLocalizedStringFromTableInBundle(specifier.properties[@"label"], @"ColoredVK", self.bundle, nil) forKey:@"label"];
            if (specifier.properties[@"validTitles"]) {
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
                for (NSString *key in specifier.titleDictionary.allKeys) [tempDict setValue:NSLocalizedStringFromTableInBundle(specifier.titleDictionary[key], @"ColoredVK", self.bundle, nil) forKey:key];
                specifier.titleDictionary = [tempDict copy];
            }
            
            if ([specifier.identifier isEqualToString:@"checkUpdates"]) [specifier setProperty:@([kColoredVKVersion containsString:@"beta"]) forKey:@"enabled"];
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
            self.prefsTableView = (UITableView *)view;
            self.prefsTableView.separatorColor = CVKTableViewSeparatorColor;
            break;
        }
    }
    self.navigationItem.title = self.specifier?self.specifier.name:@"";
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
    if (prefs == nil) { prefs = [NSMutableDictionary new]; [prefs writeToFile:self.prefsPath atomically:YES]; }
    
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
    
    NSArray *identificsToReloadMenu = @[@"enabled", @"menuSelectionStyle", @"hideMenuSeparators", @"changeSwitchColor", @"useMenuParallax", @"changeMenuTextColor"];
    if ([identificsToReloadMenu containsObject:specifier.identifier])
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
}


- (PSSpecifier *)footer
{
    NSString *footerText = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"TWEAK_FOOTER_TEXT", nil, self.bundle, nil), self.tweakVersion, self.vkAppVersion ];
    PSSpecifier *footer = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [footer setProperty:[footerText stringByAppendingString:@"\n\n© Daniil Pashin 2015"] forKey:@"footerText"];
    [footer setProperty:@"1" forKey:@"footerAlignment"];
    return footer;
}

- (PSSpecifier *)errorMessage
{
    PSSpecifier *errorMessage = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [errorMessage setProperty:[NSLocalizedStringFromTableInBundle(@"LOADING_TWEAK_FILES_ERROR_MESSAGE", nil, self.bundle, nil) stringByAppendingString:@"\n\nhttps://vk.com/danpashin"] forKey:@"footerText"];
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

- (void)openURL:(NSURL *)url
{
    UIApplication *application = [UIApplication sharedApplication];
    
    if ([application canOpenURL:url]) {
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) [application openURL:url options:@{} completionHandler:^(BOOL success) {}];
        else [application openURL:url];
    }
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
