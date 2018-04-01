//
//  ColoredVKStepperPrefsCell.m
//  ColoredVK
//
//  Created by Даниил on 26.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColoredVKStepperButton.h"
#import "PrefixHeader.h"
#import "ColoredVKStepperPrefsCell.h"

@interface ColoredVKStepperPrefsCell () <ColoredVKStepperButtonDelegate>
@end

@implementation ColoredVKStepperPrefsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if (self) {
        
        NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:CVK_PREFS_PATH];
        
        ColoredVKStepperButton *stepperButton = [[ColoredVKStepperButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 320.0f)];
        stepperButton.minValue = [[specifier propertyForKey:@"minValue"] floatValue];
        stepperButton.maxValue =  [[specifier propertyForKey:@"maxValue"] floatValue];
        stepperButton.step = [specifier propertyForKey:@"step"] ? [[specifier propertyForKey:@"step"] floatValue] : 0.1f;
        stepperButton.value = [prefs[specifier.identifier] floatValue];
        stepperButton.delegate = self;
        self.accessoryView = stepperButton;
	}
    return self;
}


#pragma mark - ColoredVKStepperButtonDelegate

- (void)stepperButton:(ColoredVKStepperButton *)stepperButton didUpdateValue:(CGFloat)value
{
    if (self.specifier.identifier.length == 0)
        return;
    
    NSMutableDictionary *tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    tweakSettings[self.specifier.identifier] = [NSString stringWithFormat:@"%.2f", value];
    [tweakSettings writeToFile:CVK_PREFS_PATH atomically:YES];
    
    if ([self.specifier.identifier isEqualToString:@"menuImageBlackout"])
        POST_CORE_NOTIFICATION(kPackageNotificationReloadMenu);
    else
        POST_CORE_NOTIFICATION(kPackageNotificationReloadPrefs);
    
    if ([self.specifier.identifier isEqualToString:@"appCornerRadius"])
        POST_CORE_NOTIFICATION(kPackageNotificationUpdateAppCorners);
}

@end
