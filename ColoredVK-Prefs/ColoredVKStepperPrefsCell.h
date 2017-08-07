//
//  ColoredVKStepperPrefsCell.h
//  ColoredVK
//
//  Created by Даниил on 26.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "PSTableCell.h"
#import "PSSpecifier.h"
#import "ColoredVKStepperButton.h"

@interface ColoredVKStepperPrefsCell : PSTableCell <ColoredVKStepperButtonDelegate>

@property (strong, nonatomic) ColoredVKStepperButton *stepperButton;

@end
