//
//  ColoredVKStepperButton.h
//  ColoredVK2
//
//  Created by Даниил on 09.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColoredVKStepperButton;
@protocol ColoredVKStepperButtonDelegate <NSObject>

- (void)stepperButton:(ColoredVKStepperButton *)stepperButton didUpdateValue:(NSInteger)value;

@end


@interface ColoredVKStepperButton : UIView

@property (assign, nonatomic) NSInteger minValue;
@property (assign, nonatomic) NSInteger maxValue;
@property (assign, nonatomic) NSInteger value;
@property (assign, nonatomic) NSInteger step;
@property (assign, nonatomic) CGFloat height;

@property (assign, nonatomic) BOOL shouldShake;

@property (weak, nonatomic) id <ColoredVKStepperButtonDelegate> delegate;

@end
