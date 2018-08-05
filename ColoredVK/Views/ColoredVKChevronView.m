//
//  ColoredVKChevronView.m
//  test
//
//  Created by Даниил on 03/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "ColoredVKChevronView.h"

@interface ColoredVKChevronView ()

@property (strong, nonatomic) UIBezierPath * openedPath;
@property (strong, nonatomic) UIBezierPath *closedPath;

@property(nonatomic, readonly, strong) CAShapeLayer *layer;
@end


@implementation ColoredVKChevronView
@dynamic layer;

static const CGFloat chevronHeight = 20.0f;

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.fillColor = nil;
        self.layer.lineWidth = 5.0f;
        self.layer.lineCap = kCALineCapRound;
        
        self.tintColor = [UIColor darkGrayColor];
        self.state = ColoredVKChevronViewStateClosed;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    self.layer.strokeColor = self.tintColor.CGColor;
}

- (void)setFrame:(CGRect)frame
{
    frame.size = CGSizeMake(chevronHeight * 2.0f, chevronHeight);
    super.frame = frame;
    
    CGMutablePathRef openedPath = CGPathCreateMutable();
    CGPathMoveToPoint(openedPath, NULL, CGRectGetMinX(frame) + 1.0f, CGRectGetMidY(frame));
    CGPathAddLineToPoint(openedPath, NULL, CGRectGetMidX(frame), CGRectGetMaxY(frame) - 1.0f);
    CGPathAddLineToPoint(openedPath, NULL, CGRectGetMaxX(frame) - 1.0f, CGRectGetMidY(frame));
    self.openedPath = [UIBezierPath bezierPathWithCGPath:openedPath];
    CFRelease(openedPath);
    
    CGMutablePathRef closedPath = CGPathCreateMutable();
    CGPathMoveToPoint(closedPath, NULL, CGRectGetMinX(frame) + 1.0f, CGRectGetMidY(frame));
    CGPathAddLineToPoint(closedPath, NULL, CGRectGetMidX(frame), CGRectGetMidY(frame));
    CGPathAddLineToPoint(closedPath, NULL, CGRectGetMaxX(frame) - 1.0f, CGRectGetMidY(frame));
    self.closedPath = [UIBezierPath bezierPathWithCGPath:closedPath];
    CFRelease(closedPath);
}

- (void)setState:(ColoredVKChevronViewState)state
{
    [self setState:state animated:NO];
}

- (void)setState:(ColoredVKChevronViewState)state animated:(BOOL)animated
{
    if (self.state == state)
        return;
    
    _state = state;
    
    CGPathRef layerPath = nil;
    if (state == ColoredVKChevronViewStateOpened) {
        layerPath = self.openedPath.CGPath;
    } else if (state == ColoredVKChevronViewStateClosed) {
        layerPath = self.closedPath.CGPath;
    }
    
    if (animated) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.fromValue = (__bridge id)self.layer.path;
        pathAnimation.toValue = (__bridge id)layerPath;
        pathAnimation.duration = 0.2f;
        [self.layer addAnimation:pathAnimation forKey:@"pathAnimation"];
        self.layer.path = layerPath;
    } else {
        self.layer.path = layerPath;
    }
}

@end
