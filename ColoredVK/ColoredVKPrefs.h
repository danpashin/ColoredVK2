//
//  ColoredVKPrefs.h
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Preferences.h"

@interface ColoredVKPrefs : PSListController 

@property (nonatomic, readonly) PSSpecifier *footer;
@property (nonatomic, readonly) PSSpecifier *errorMessage;
@property (nonatomic, readonly, getter=getTweakVersion) NSString *tweakVersion;
@property (nonatomic, readonly, getter=getVKVersion) NSString *VKVersion;

@end
