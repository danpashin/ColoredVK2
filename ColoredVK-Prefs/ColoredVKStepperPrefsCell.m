//
//  ColoredVKImagePrefs.m
//  ColoredVK
//
//  Created by Даниил on 26.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKStepperPrefsCell.h"
#import "PrefixHeader.h"
#import "PPNumberButton.h"

@implementation ColoredVKStepperPrefsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:style reuseIdentifier:identifier specifier:specifier];
    if (self) {
        NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:CVK_PREFS_PATH];        
        
        PPNumberButton *numberButton = [PPNumberButton numberButtonWithFrame:CGRectMake(0, 0, 75, 30)];
        numberButton.shakeAnimation = YES;
        numberButton.minValue = 0;
        numberButton.maxValue = 6;
        numberButton.currentNumber = [prefs[self.specifier.identifier] componentsSeparatedByString:@"."].lastObject.integerValue;
        numberButton.increaseTitle = @"＋";
        numberButton.decreaseTitle = @"－";
        numberButton.resultBlock = ^(NSInteger number, BOOL increaseStatus) {
            NSMutableDictionary *tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
            
            tweakSettings[self.specifier.identifier] = [NSString stringWithFormat:@"0.%i", (int)number];
            [tweakSettings writeToFile:CVK_PREFS_PATH atomically:YES];
            
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, NULL, YES);
            if ([self.specifier.identifier isEqualToString:@"menuImageBlackout"])
                CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
        };
        self.accessoryView = numberButton;
	}
    return self;
}

@end
