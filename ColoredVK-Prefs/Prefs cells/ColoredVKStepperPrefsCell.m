//
//  ColoredVKStepperPrefsCell.m
//  ColoredVK
//
//  Created by Даниил on 26.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColoredVKStepperButton.h"
#import "ColoredVKStepperPrefsCell.h"

@interface ColoredVKStepperPrefsCell () <ColoredVKStepperButtonDelegate>
@property (strong, nonatomic) ColoredVKStepperButton *stepperButton;
@end

@implementation ColoredVKStepperPrefsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {
        self.stepperButton = [[ColoredVKStepperButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 120.0f, 320.0f)];
        self.stepperButton.minValue = [[specifier propertyForKey:@"minValue"] floatValue];
        self.stepperButton.maxValue =  [[specifier propertyForKey:@"maxValue"] floatValue];
        self.stepperButton.step = [specifier propertyForKey:@"step"] ? [[specifier propertyForKey:@"step"] floatValue] : 0.1f;
        self.stepperButton.delegate = self;
        self.accessoryView = self.stepperButton;
	}
    return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier
{
    [super refreshCellContentsWithSpecifier:specifier];
    self.stepperButton.value = [self.currentPrefsValue floatValue];
}

#pragma mark - ColoredVKStepperButtonDelegate

- (void)stepperButton:(ColoredVKStepperButton *)stepperButton didUpdateValue:(CGFloat)value
{
    if ([self.cellTarget respondsToSelector:self.cellAction]) {
        NSString *string = [NSString stringWithFormat:@"%.2f", value];
        objc_msgSend(self.cellTarget, self.cellAction, string, self.specifier);
    }
}

@end
