//
//  ColoredVKPrefs.h
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import "UIScrollView+EmptyDataSet.h"
#import "ColoredVKPrefsTableView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ColoredVKPrefs : PSListController <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIViewControllerPreviewingDelegate>

@property (strong, nonatomic) NSMutableDictionary *cachedPrefs;
@property (strong, nonatomic, readonly) ColoredVKPrefsTableView *table;

- (void)commonInit NS_REQUIRES_SUPER;
- (void)updateAppearance:(BOOL)animated NS_REQUIRES_SUPER;

- (BOOL)openURL:(NSString *)stringURL;
- (void)presentPopover:(UIViewController *)controller;
- (NSArray <PSSpecifier*> *)specifiersForPlistName:(NSString *)plistName localize:(BOOL)localize;

- (nullable id)readPreferenceValue:(PSSpecifier *)specifier NS_REQUIRES_SUPER;
- (void)setPreferenceValue:(nullable id)value specifier:(PSSpecifier *)specifier NS_REQUIRES_SUPER;
- (void)setPreferenceValue:(nullable id)value forKey:(NSString *)key NS_REQUIRES_SUPER;
- (void)updateSpecifierWithKey:(NSString *)key;

- (void)writePrefsWithCompetion:(nullable void(^)(void))completionBlock NS_REQUIRES_SUPER;
- (void)readPrefsWithCompetion:(nullable void(^)(void))completionBlock NS_REQUIRES_SUPER;

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView;

@end

NS_ASSUME_NONNULL_END
