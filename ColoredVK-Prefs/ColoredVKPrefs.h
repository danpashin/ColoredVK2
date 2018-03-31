//
//  ColoredVKPrefs.h
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <PSSpecifier.h>
#import <PSListController.h>

#import "PrefixHeader.h"
#import "ColoredVKNightThemeColorScheme.h"

@interface ColoredVKPrefs : PSListController

@property (strong, nonatomic, readonly) NSBundle *cvkBundle;

@property (assign, nonatomic) BOOL shouldChangeSwitchColor;
@property (weak, nonatomic) UITableView *prefsTableView;

- (void)commonInit NS_REQUIRES_SUPER;

- (BOOL)openURL:(NSURL *)url;
- (void)presentPopover:(UIViewController *)controller;
- (NSArray <PSSpecifier*> *)specifiersForPlistName:(NSString *)plistName localize:(BOOL)localize;
- (void)showPurchaseAlert;

- (id)readPreferenceValue:(PSSpecifier *)specifier;
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier;

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView;

@end
