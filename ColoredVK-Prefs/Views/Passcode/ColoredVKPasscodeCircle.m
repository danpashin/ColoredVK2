//
//  ColoredVKPasscodeCircle.m
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import "ColoredVKPasscodeCircle.h"

@implementation ColoredVKPasscodeCircle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit
{
    self.layer.cornerRadius = CGRectGetHeight(self.frame) / 2.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = CVKAltColor.CGColor;
}

- (void)setFilled:(BOOL)filled
{
    [self setFilled:filled animated:NO];
}

- (void)setFilled:(BOOL)filled animated:(BOOL)animated
{
    _filled = filled;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        void (^animationBlock)(void) = ^{
            self.backgroundColor = filled ? CVKAltColor : [UIColor clearColor];
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction
                             animations:animationBlock completion:nil];
        } else {
            animationBlock();
        }
    });
}

@end
