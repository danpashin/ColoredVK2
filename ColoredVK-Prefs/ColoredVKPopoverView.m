//
//  ColoredVKPopoverView.m
//  ColoredVK2
//
//  Created by Даниил on 09.05.17.
//
//

#import "ColoredVKPopoverView.h"

@implementation ColoredVKPopoverView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    self.blurStyle = UIBlurEffectStyleLight;
    self.blurBackground = YES;
}


- (void)setBlurBackground:(BOOL)blurBackground
{
    _blurBackground = blurBackground;
    
    if (self.blurBackground) {
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:self.blurStyle]];
        blurView.frame = self.bounds;
        blurView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.2];
        self.backgroundView = blurView;
    } else {
        if ([self.backgroundView isKindOfClass:[UIVisualEffectView class]]) [self.backgroundView removeFromSuperview];
    }
}

- (void)setBlurStyle:(UIBlurEffectStyle)blurStyle
{
    _blurStyle = blurStyle;
    
    if (self.blurBackground && [self.backgroundView isKindOfClass:[UIVisualEffectView class]]) {
        UIVisualEffectView *blurView = (UIVisualEffectView *)self.backgroundView;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            blurView.effect = [UIBlurEffect effectWithStyle:self.blurStyle];
        } completion:nil];
    }
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    _backgroundView = backgroundView;
    
    if (self.backgroundView) {
        self.backgroundView.tag = 2;
        if (!self.backgroundView.superview) [self insertSubview:self.backgroundView atIndex:0];
        
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView]|" options:0 metrics:nil views:@{@"backgroundView":self.backgroundView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundView]|" options:0 metrics:nil views:@{@"backgroundView":self.backgroundView}]];
    }
}

- (void)setContentView:(UIView *)contentView
{
    _contentView = contentView;
    
    if (self.contentView) {
        self.contentView.tag = 2;
        self.contentView.center = self.center;
        if (!self.contentView.superview) [self addSubview:self.contentView];
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[contentView]-|" options:0 metrics:@{@"height":@(self.contentView.bounds.size.height)} views:@{@"contentView":self.contentView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[contentView]-|" options:0 metrics:nil views:@{@"contentView":self.contentView}]];
    }
}

@end
