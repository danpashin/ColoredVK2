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


NS_ASSUME_NONNULL_BEGIN

@interface ColoredVKPrefs : PSListController

@property (strong, nonatomic, readonly) NSBundle *cvkBundle;
@property (strong, nonatomic) NSMutableDictionary *cachedPrefs;

@property (assign, nonatomic) BOOL shouldChangeSwitchColor;

- (void)commonInit NS_REQUIRES_SUPER;

- (BOOL)openURL:(NSURL *)url;
- (void)presentPopover:(UIViewController *)controller;
- (NSArray <PSSpecifier*> *)specifiersForPlistName:(NSString *)plistName localize:(BOOL)localize;
- (void)showPurchaseAlert;

- (nullable id)readPreferenceValue:(PSSpecifier *)specifier;
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier;

- (void)writePrefsWithCompetion:(nullable void(^)(void))completionBlock;
- (void)readPrefsWithCompetion:(nullable void(^)(void))completionBlock;

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
