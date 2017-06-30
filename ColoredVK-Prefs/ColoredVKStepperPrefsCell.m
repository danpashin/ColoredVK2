//
//  ColoredVKImagePrefs.m
//  ColoredVK
//
//  Created by Даниил on 26.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKStepperPrefsCell.h"
#import "PrefixHeader.h"

@implementation ColoredVKStepperPrefsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if (self) {
        self.idSpecifier = specifier;
        
        NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:CVK_PREFS_PATH];
        
        ColoredVKStepperButton *stepperButton = [[ColoredVKStepperButton alloc] initWithFrame:CGRectMake(0, 0, 80, 32)];
        stepperButton.maxValue = 6;
        stepperButton.value = [prefs[specifier.identifier] componentsSeparatedByString:@"."].lastObject.integerValue;
        stepperButton.delegate = self;
        self.accessoryView = stepperButton;
	}
    return self;
}


#pragma mark - ColoredVKStepperButtonDelegate

- (void)stepperButton:(ColoredVKStepperButton *)stepperButton didUpdateValue:(NSInteger)value
{
    NSMutableDictionary *tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    tweakSettings[self.idSpecifier.identifier] = [NSString stringWithFormat:@"0.%i", (int)value];
    [tweakSettings writeToFile:CVK_PREFS_PATH atomically:YES];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, NULL, YES);
    if ([self.idSpecifier.identifier isEqualToString:@"menuImageBlackout"])
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
}

@end
