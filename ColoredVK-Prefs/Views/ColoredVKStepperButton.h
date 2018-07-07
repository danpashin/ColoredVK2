//
//  ColoredVKStepperButton.h
//  ColoredVK2
//
//  Created by Даниил on 09.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

#import <UIKit/UIView.h>

@class ColoredVKStepperButton;
@protocol ColoredVKStepperButtonDelegate <NSObject>
- (void)stepperButton:(ColoredVKStepperButton *)stepperButton didUpdateValue:(CGFloat)value;
@end

@interface ColoredVKStepperButton : UIView

@property (assign, nonatomic) CGFloat minValue;
@property (assign, nonatomic) CGFloat maxValue;
@property (assign, nonatomic) CGFloat value;
@property (assign, nonatomic) CGFloat step;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) BOOL shouldShake;
@property (weak, nonatomic) id <ColoredVKStepperButtonDelegate> delegate;

@end
