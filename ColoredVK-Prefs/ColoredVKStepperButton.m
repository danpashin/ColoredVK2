//
//  ColoredVKStepperButton.m
//  ColoredVK2
//
//  Created by Даниил on 09.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

#import "ColoredVKStepperButton.h"


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
    self.layer.cornerRadius = 4;
    
    self.height = 32;
    self.value = 0;
    self.minValue = 0;
    self.maxValue = 5;
    self.step = 1;
    self.shouldShake = YES;
    
    
    self.decreaseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.decreaseButton setTitle:@"-" forState:UIControlStateNormal];
    self.decreaseButton.titleLabel.font = [UIFont boldSystemFontOfSize:21];
    [self.decreaseButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.decreaseButton addTarget:self action:@selector(actionDecrease) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *decreasePress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeValueWithGesture:)];
    decreasePress.accessibilityLabel = @"decrease";
    [self.decreaseButton addGestureRecognizer:decreasePress];
    
    
    self.increaseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.increaseButton setTitle:@"+" forState:UIControlStateNormal];
    self.increaseButton.titleLabel.font = [UIFont boldSystemFontOfSize:21];
    [self.increaseButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.increaseButton addTarget:self action:@selector(actionIncrease) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *increasePress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(changeValueWithGesture:)];
    increasePress.accessibilityLabel = @"increase";
    [self.increaseButton addGestureRecognizer:increasePress];
    
    self.valueLabel = [UILabel new];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    self.valueLabel.font = [UIFont systemFontOfSize:15.0f];
    
    [self addSubview:self.decreaseButton];
    [self addSubview:self.increaseButton];
    [self addSubview:self.valueLabel];
    
    [self setupConstraints];
}

- (void)setupConstraints
{
    self.decreaseButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.increaseButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.decreaseButton}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.increaseButton}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.valueLabel}]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[decreaseButton(buttonWidth)][valueLabel][increaseButton(buttonWidth)]|" 
                                                                 options:0 metrics:@{@"buttonWidth":@(self.height)} 
                                                                   views:@{@"decreaseButton":self.decreaseButton, @"valueLabel":self.valueLabel, @"increaseButton":self.increaseButton}]];
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
        animation.values = @[@(positionX-5),@(positionX),@(positionX+5)];
        animation.repeatCount = 3;
        animation.duration = 0.07;
        animation.autoreverses = YES;
        [self.layer addAnimation:animation forKey:nil];
    }
}

- (void)changeValueWithGesture:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.timer = [NSTimer timerWithTimeInterval:0.3f target:self selector:@selector(timerAction:) userInfo:@{@"recognizer":recognizer} repeats:YES];
        [self.timer fire];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self.timer invalidate];
    }
}

- (void)timerAction:(NSTimer *)timer
{
    UILongPressGestureRecognizer *recognizer = timer.userInfo ? timer.userInfo[@"recognizer"] : nil;
    
    if (recognizer) {
        if ([recognizer.accessibilityLabel isEqualToString:@"increase"])
            [self actionIncrease];
        else if ([recognizer.accessibilityLabel isEqualToString:@"decrease"])
            [self actionDecrease];
    }
}

@end
