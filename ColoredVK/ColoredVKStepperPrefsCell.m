//
//  ColoredVKImagePrefs.m
//  ColoredVK
//
//  Created by Даниил on 26.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKStepperPrefsCell.h"
#import "PrefixHeader.h"
#import "ColoredVKJailCheck.h"

@implementation ColoredVKStepperPrefsCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    
    if (self) {
        prefsPath = CVK_PREFS_PATH;
        NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:prefsPath];
        
        UIStepper *stepper = [UIStepper new];
        stepper.minimumValue = 0.0;
        stepper.maximumValue = 0.6;
        stepper.stepValue = 0.1;
        stepper.value = [prefs[specifier.identifier] floatValue];
        stepper.tintColor = [self colorForStepperValue:stepper.value];
        [stepper addTarget:self action:@selector(updateStepperValue:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = stepper;
	}
    return self;
}

- (void)updateStepperValue:(UIStepper*)stepper
{
    stepper.tintColor = [self colorForStepperValue:stepper.value];
    
    NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    
    [tweakSettings setValue:@(stepper.value) forKey:(self.specifier).identifier];
    [tweakSettings writeToFile:prefsPath atomically:YES];
    
    if ([(self.specifier).identifier isEqualToString:@"menuImageBlackout"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
    }
}


- (UIColor *)colorForStepperValue:(double)value
{
    switch ([[NSString stringWithFormat:@"%.1f", value] componentsSeparatedByString:@"."].lastObject.intValue) {
        case 0: return [UIColor colorWithRed:23.00f/255.0f green:108.0f/255.0f blue:208.0f/255.0f alpha:1];
        case 1: return [UIColor colorWithRed:50.00f/255.0f green:134.0f/255.0f blue:232.0f/255.0f alpha:1];
        case 2: return [UIColor colorWithRed:96.00f/255.0f green:161.0f/255.0f blue:237.0f/255.0f alpha:1];
        case 3: return [UIColor colorWithRed:232.0f/255.0f green:128.0f/255.0f blue:50.00f/255.0f alpha:1];
        case 4: return [UIColor colorWithRed:232.0f/255.0f green:103.0f/255.0f blue:50.00f/255.0f alpha:1];
        case 5: return [UIColor colorWithRed:232.0f/255.0f green:57.00f/255.0f blue:50.00f/255.0f alpha:1];
        case 6: return [UIColor colorWithRed:200.0f/255.0f green:27.00f/255.0f blue:21.00f/255.0f alpha:1];
        default:return [UIColor blackColor];
    }
}
@end
