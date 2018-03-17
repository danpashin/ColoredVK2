//
//  ColoredVKAnimatedButton.m
//  test
//
//  Created by Даниил on 10.03.18.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "ColoredVKAnimatedButton.h"
#import "PrefixHeader.h"
#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, ColoredVKLayerXPosition) {
    ColoredVKLayerXPositionLeft,
    ColoredVKLayerXPositionRight
};

static const CGFloat kButtonHeightRatio = 1.5f;

@interface ColoredVKAnimatedButton ()

@property (strong, nonatomic) CAGradientLayer *leftLayer;
@property (strong, nonatomic) CAGradientLayer *rightLayer;

@property (assign, nonatomic) BOOL animated;

@end

@implementation ColoredVKAnimatedButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    objc_setAssociatedObject(self, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self.titleLabel, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
    
    self.layer.masksToBounds = YES;
    
    CGRect leftLayerFrame = CGRectMake(0, 0, CGRectGetWidth(self.frame) + 10.0f, CGRectGetHeight(self.frame) * kButtonHeightRatio);
    self.leftLayer = [self layerWithFrame:leftLayerFrame locations:@[@0, @0] xPosition:ColoredVKLayerXPositionLeft];
    [self.layer addSublayer:self.leftLayer];
    
    CGRect rightLayerFrame = CGRectMake(0, 0, CGRectGetWidth(self.frame) + 10.0f, CGRectGetHeight(self.frame) * kButtonHeightRatio);
    self.rightLayer = [self layerWithFrame:rightLayerFrame locations:@[@1, @0] xPosition:ColoredVKLayerXPositionRight];
    [self.layer addSublayer:self.rightLayer];
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.alpha = 0.0f;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (!self.window || self.animated)
        return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.animated = YES;
        
        CABasicAnimation *leftLayerAnimation = [self layerAnimationWithOldValue:self.leftLayer.locations newValue:@[@1, @1]];
        [self.leftLayer addAnimation:leftLayerAnimation forKey:@"xLocation"];
        self.leftLayer.locations = @[@1, @1];
        
        CABasicAnimation *rightLayerAnimation = [self layerAnimationWithOldValue:self.rightLayer.locations newValue:@[@0, @0]];
        [self.rightLayer addAnimation:rightLayerAnimation forKey:@"xLocation"];
        self.rightLayer.locations =  @[@0, @0];
        
        CGPoint origCenter = self.center;
        CGRect newFrame = self.frame;
        newFrame.size.height *= kButtonHeightRatio;
        
        UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction;
        [UIView animateWithDuration:0.4f delay:0.1f options:options animations:^{
            super.frame = newFrame;
            self.center = origCenter;
        } completion:^(BOOL finished)  {
            self.backgroundColor = self.tintColor;
            self.rightLayer.hidden = YES;
            self.leftLayer.hidden = YES;
            [UIView animateWithDuration:0.3f delay:0.0f options:options animations:^{
                self.titleLabel.alpha = 1.0f;
            } completion:nil];
        }];
    });
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    [self updateLayerColors:self.leftLayer xPosition:ColoredVKLayerXPositionLeft];
    [self updateLayerColors:self.rightLayer xPosition:ColoredVKLayerXPositionRight];
}

- (void)updateLayerColors:(CAGradientLayer *)layer xPosition:(ColoredVKLayerXPosition)xPosition
{
    if (xPosition == ColoredVKLayerXPositionLeft)
        layer.colors = @[(id)self.tintColor.CGColor, (id)[UIColor clearColor].CGColor];
    else
        layer.colors = @[(id)[UIColor clearColor].CGColor, (id)self.tintColor.CGColor];
}

- (void)invokeSelectBlock
{
    if (self.selectHandler)
        self.selectHandler();
}


#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    self.leftLayer.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame) + 10.0f, CGRectGetHeight(frame) * kButtonHeightRatio);
    self.rightLayer.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame) + 10.0f, CGRectGetHeight(frame) * kButtonHeightRatio);
}

- (void)setText:(NSString *)text
{
    _text = text;
    
    [self setTitle:text forState:UIControlStateNormal];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    self.animated = NO;
    self.rightLayer.hidden = NO;
    self.leftLayer.hidden = NO;
}

- (void)setSelectHandler:(void (^)(void))selectHandler
{
    _selectHandler = selectHandler;
    
    if (selectHandler) {
        [self addTarget:selectHandler action:@selector(invokeSelectBlock) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark -
#pragma mark Getters
#pragma mark -

- (CAGradientLayer *)layerWithFrame:(CGRect)frame locations:(NSArray *)locations xPosition:(ColoredVKLayerXPosition)xPosition
{
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = frame;
    layer.locations = locations;
    layer.startPoint = CGPointMake(0.0f, 0.5f);
    layer.endPoint = CGPointMake(1.0f, 0.5f);
    [self updateLayerColors:layer xPosition:xPosition];
    
    return layer;
}

- (CABasicAnimation *)layerAnimationWithOldValue:(id)oldValue newValue:(id)newValue
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.duration = 0.3f;
    animation.fromValue = oldValue;
    animation.toValue = newValue;
    
    return animation;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGRect origRect = [super titleRectForContentRect:contentRect];
    return CGRectInset(origRect, IS_IPAD ? 6.0f : 0.0f, 6.0f);
}

@end
