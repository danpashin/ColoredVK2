//
//  ColoredVKPrefs.h
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Preferences.h"
#import "PrefixHeader.h"

@interface ColoredVKPrefs : PSListController 

@property (nonatomic, readonly) PSSpecifier *footer;
@property (nonatomic, readonly) PSSpecifier *errorMessage;
@property (nonatomic, readonly) NSString *tweakVersion;
@property (nonatomic, readonly) NSString *vkAppVersion;

@property (strong, nonatomic, readonly) NSString *prefsPath;
@property (strong, nonatomic, readonly) NSBundle *cvkBundle;
@property (strong, nonatomic, readonly) NSString *cvkFolder;
@property (strong, nonatomic) NSString *lastImageIdentifier;

@property (strong, nonatomic) UITableView *prefsTableView;

- (void)openURL:(NSURL *)url;
- (void)presentPopover:(UIViewController *)controller;

@end
