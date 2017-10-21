//
//  ColoredVKStepperPrefsCell.m
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
        
        self.stepperButton = [[ColoredVKStepperButton alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
        self.stepperButton.minValue = [[specifier propertyForKey:@"minValue"] floatValue];
        self.stepperButton.maxValue =  [[specifier propertyForKey:@"maxValue"] floatValue];
        self.stepperButton.step = [specifier propertyForKey:@"step"] ? [[specifier propertyForKey:@"step"] floatValue] : 0.1f;
        self.stepperButton.value = [prefs[specifier.identifier] floatValue];
        self.stepperButton.delegate = self;
        self.accessoryView = self.stepperButton;
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
    
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, NULL, YES);
    
    if ([self.specifier.identifier isEqualToString:@"menuImageBlackout"]) {
        CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
    } else if ([self.specifier.identifier isEqualToString:@"appCornerRadius"]) {
        CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.update.corners"), NULL, NULL, YES);
    }
}

@end
