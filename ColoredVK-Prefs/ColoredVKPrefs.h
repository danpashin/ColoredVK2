//
//  ColoredVKPrefs.h
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>
#import "PrefixHeader.h"
#import "UIScrollView+EmptyDataSet.h"
#import "ColoredVKNightThemeColorScheme.h"

@interface ColoredVKPrefs : PSListController <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, readonly) NSString *tweakVersion;
@property (nonatomic, readonly) NSString *vkAppVersion;
@property (assign, nonatomic, readonly) BOOL app_is_vk;

@property (strong, nonatomic) ColoredVKNightThemeColorScheme *nightThemeColorScheme;
@property (assign, nonatomic) BOOL enableNightTheme;

@property (strong, nonatomic, readonly) NSString *prefsPath;
@property (strong, nonatomic, readonly) NSBundle *cvkBundle;
@property (strong, nonatomic, readonly) NSString *cvkFolder;

@property (weak, nonatomic) UITableView *prefsTableView;

- (BOOL)openURL:(NSURL *)url;
- (void)presentPopover:(UIViewController *)controller;
- (NSArray <PSSpecifier*> *)specifiersForPlistName:(NSString *)plistName localize:(BOOL)localize;
- (void)showPurchaseAlert;

- (id)readPreferenceValue:(PSSpecifier *)specifier;
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier;
- (PSSpecifier *)specifierForIndexPath:(NSIndexPath *)indexPath;

@end
