//
//  ColoredVKStepperButton.m
//  ColoredVK2
//
//  Created by Даниил on 09.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

#import "ColoredVKStepperButton.h"
#import <UIKit/UIKit.h>

@interface ColoredVKStepperButton ()

@property (strong, nonatomic) UIButton *decreaseButton;
@property (strong, nonatomic) UILabel *valueLabel;
@property (strong, nonatomic) UIButton *increaseButton;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation ColoredVKStepperButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupButton];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupButton];
        self.frame = frame;
    }
    return self;
}

- (void)setupButton
{
    self.backgroundColor = [UIColor clearColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4.0f;
    
    _height = 44.0f;
    _value = 0.0f;
    _minValue = 0.0f;
    _maxValue = 5.0f;
    _step = 1.0f;
    _shouldShake = YES;
    
    _decreaseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_decreaseButton setTitle:@"-" forState:UIControlStateNormal];
    _decreaseButton.titleLabel.font = [UIFont boldSystemFontOfSize:21];
    [_decreaseButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_decreaseButton addTarget:self action:@selector(actionDecrease) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *decreasePress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeValueWithGesture:)];
    decreasePress.accessibilityLabel = @"decrease";
    [_decreaseButton addGestureRecognizer:decreasePress];
    
    _increaseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_increaseButton setTitle:@"+" forState:UIControlStateNormal];
    _increaseButton.titleLabel.font = [UIFont boldSystemFontOfSize:21];
    [_increaseButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_increaseButton addTarget:self action:@selector(actionIncrease) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *increasePress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeValueWithGesture:)];
    increasePress.accessibilityLabel = @"increase";
    [_increaseButton addGestureRecognizer:increasePress];
    
    _valueLabel = [UILabel new];
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    _valueLabel.font = [UIFont systemFontOfSize:15.0f];
    
    [self addSubview:_decreaseButton];
    [self addSubview:_increaseButton];
    [self addSubview:_valueLabel];
    
    _decreaseButton.translatesAutoresizingMaskIntoConstraints = NO;
    _increaseButton.translatesAutoresizingMaskIntoConstraints = NO;
    _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":_decreaseButton}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":_increaseButton}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":_valueLabel}]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[decreaseButton(buttonWidth)][valueLabel][increaseButton(buttonWidth)]|" 
                                                                 options:0 metrics:@{@"buttonWidth":@(_height)} 
                                                                   views:@{@"decreaseButton":_decreaseButton, @"valueLabel":_valueLabel, @"increaseButton":_increaseButton}]];
}

#pragma mark - Setters
- (void)setFrame:(CGRect)frame
{
    frame.size.height = self.height;
    super.frame = frame;
}

- (void)setBounds:(CGRect)bounds
{
    bounds.size.height = self.height;
    super.bounds = bounds;
}

- (void)setValue:(CGFloat)value
{
    _value = value;
    
    self.valueLabel.text = [NSString stringWithFormat:@"%.1f", self.value];
}

#pragma mark - Actions

- (void)actionDecrease
{
    if (self.value - self.step >= self.minValue) {
        self.value -= self.step;
        
        if ([self.delegate respondsToSelector:@selector(stepperButton:didUpdateValue:)])
            [self.delegate stepperButton:self didUpdateValue:self.value];
        
    } else {
        [self actionShake];
    }
}

- (void)actionIncrease
{
    if (self.value + self.step <= self.maxValue) {
        self.value += self.step;
        
        if ([self.delegate respondsToSelector:@selector(stepperButton:didUpdateValue:)])
            [self.delegate stepperButton:self didUpdateValue:self.value];
        
    } else {
        [self actionShake];
    }
}

- (void)actionShake
{
    if (self.shouldShake) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
        CGFloat positionX = self.layer.position.x;
        animation.values = @[@(positionX - 5.0f), @(positionX), @(positionX + 5.0f)];
        animation.repeatCount = 3.0f;
        animation.duration = 0.07f;
        animation.autoreverses = YES;
        [self.layer addAnimation:animation forKey:nil];
    }
}

- (void)changeValueWithGesture:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(timerAction:) userInfo:recognizer repeats:YES];
        [self.timer fire];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)timerAction:(NSTimer *)timer
{
    UILongPressGestureRecognizer *recognizer = timer.userInfo;
    
    if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        if ([recognizer.accessibilityLabel isEqualToString:@"increase"])
            [self actionIncrease];
        else if ([recognizer.accessibilityLabel isEqualToString:@"decrease"])
            [self actionDecrease];
    }
}

@end
