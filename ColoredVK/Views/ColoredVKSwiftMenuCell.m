//
//  ColoredVKSwiftMenuCell.m
//  ColoredVK2
//
//  Created by Даниил on 04/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "ColoredVKSwiftMenuCell.h"
#import "ColoredVKSwiftMenuButton.h"

@interface ColoredVKSwiftMenuCell ()
@property (strong, nonatomic) UIImageView *imageView;
@end


@interface _UIBackdropView : UIView
- (instancetype)initWithStyle:(NSUInteger)arg1;
@end

@implementation ColoredVKSwiftMenuCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 20.0f;
        self.layer.masksToBounds = YES;
        
        _UIBackdropView *blurView = [[_UIBackdropView alloc] initWithStyle:4007];
        blurView.frame = self.bounds;
        blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView = blurView;
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.imageView];
        
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.imageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
        [self.imageView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
        [self.imageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
        [self.imageView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
    }
    return self;
}

- (void)setButtonModel:(ColoredVKSwiftMenuButton *)buttonModel
{
    _buttonModel = buttonModel;
    
    self.imageView.image = [buttonModel.icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setSelected:NO animated:NO];
}

- (void)setSelected:(BOOL)selected
{
    [self setSelected:selected animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected && self.buttonModel && !self.buttonModel.canHighlight)
        return;
    
    [super setSelected:selected];
    
    UIColor *backgroundColor = nil;
    UIColor *tintColor = nil;
    if (selected) {
        backgroundColor = [UIColor whiteColor];
        tintColor = self.buttonModel.selectedTintColor;
    } else {
        backgroundColor = [UIColor clearColor];
        tintColor = self.buttonModel.unselectedTintColor;
    }
    
    void (^animationBlock)(void) = ^{
        self.imageView.backgroundColor = backgroundColor;
        self.imageView.tintColor = tintColor;
    };
    
    if (animated) {
        UIViewAnimationOptions options = UIViewAnimationOptionOverrideInheritedOptions | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionTransitionCrossDissolve;
        [UIView animateWithDuration:0.3f delay:0.0f options:options animations:animationBlock completion:nil];
        
//        [self.collectionView.collectionViewLayout invalidateLayout];
        
        CGRect oldFrame = self.frame;
        CGRect frame = CGRectInset(oldFrame, -2.0f, -2.0f);
        [UIView transitionWithView:self duration:0.1f options:options animations:^{
            self.frame = frame;
        } completion:^(BOOL finished) {
            [UIView transitionWithView:self duration:0.1f options:options animations:^{
                self.frame = oldFrame;
            } completion:nil];
        }];
    } else {
        animationBlock();
    }
}

@end
