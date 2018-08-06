//
//  ColoredVKSwiftMenuCell.m
//  ColoredVK2
//
//  Created by Даниил on 04/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "ColoredVKSwiftMenuCell.h"
#import "ColoredVKSwiftMenuButton.h"

@interface _UIBackdropView : UIView
- (instancetype)initWithStyle:(NSUInteger)arg1;
@property (strong, nonatomic, readonly) UIView *contentView;
@end

@interface ColoredVKSwiftMenuCell ()
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic, strong, nullable) _UIBackdropView *backgroundView;
@end


@implementation ColoredVKSwiftMenuCell
@dynamic backgroundView;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.layer.cornerRadius = 21.0f;
        self.contentView.layer.masksToBounds = YES;
        
        _UIBackdropView *blurView = [[_UIBackdropView alloc] initWithStyle:4007];
        blurView.frame = self.bounds;
        blurView.layer.masksToBounds = YES;
        blurView.layer.cornerRadius = self.contentView.layer.cornerRadius;
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
        self.imageView.tintColor = tintColor;
        self.backgroundView.contentView.backgroundColor = backgroundColor;
    };
    
    if (animated) {
        UIViewAnimationOptions options = UIViewAnimationOptionOverrideInheritedOptions | UIViewAnimationOptionAllowUserInteraction;
        [UIView animateWithDuration:0.3f delay:0.0f options:options animations:animationBlock completion:nil];
        
//        [self.collectionView.collectionViewLayout invalidateLayout];
        
        CGRect oldFrame = self.backgroundView.frame;
        CGRect frame = CGRectInset(oldFrame, -2.0f, -2.0f);
        [UIView transitionWithView:self.backgroundView duration:0.1f options:options animations:^{
            self.backgroundView.frame = frame;
        } completion:^(BOOL finished) {
            [UIView transitionWithView:self.backgroundView duration:0.1f options:options animations:^{
                self.backgroundView.frame = oldFrame;
            } completion:nil];
        }];
    } else {
        animationBlock();
    }
}

@end
