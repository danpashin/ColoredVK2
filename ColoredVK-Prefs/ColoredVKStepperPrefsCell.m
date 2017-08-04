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
        
        NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:CVK_PREFS_PATH];
        
        self.stepperButton = [[ColoredVKStepperButton alloc] initWithFrame:CGRectMake(0, 0, 80, 32)];
        self.stepperButton.minValue = 0;
        self.stepperButton.maxValue = 6;
        self.stepperButton.value = [prefs[specifier.identifier] componentsSeparatedByString:@"."].lastObject.integerValue;
        self.stepperButton.delegate = self;
        self.accessoryView = self.stepperButton;
	}
    return self;
}


#pragma mark - ColoredVKStepperButtonDelegate

- (void)stepperButton:(ColoredVKStepperButton *)stepperButton didUpdateValue:(NSInteger)value
{
    NSMutableDictionary *tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    tweakSettings[self.specifier.identifier] = [NSString stringWithFormat:@"0.%i", (int)value];
    [tweakSettings writeToFile:CVK_PREFS_PATH atomically:YES];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, NULL, YES);
    if ([self.specifier.identifier isEqualToString:@"menuImageBlackout"])
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
}

@end
