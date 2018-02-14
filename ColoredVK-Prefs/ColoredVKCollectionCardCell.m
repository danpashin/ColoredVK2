//
//  ColoredVKCollectionCardCell.m
//  ColoredVK2
//
//  Created by Даниил on 13.02.18.
//

#import "ColoredVKCollectionCardCell.h"
#import <MXParallaxHeader.h>

@interface ColoredVKCollectionCardCell ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonWidthConstraint;

@end

@implementation ColoredVKCollectionCardCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.cornerRadius = 12.0f;
    self.layer.masksToBounds = YES;
    
    self.bottomButton.layer.cornerRadius = CGRectGetHeight(self.bottomButton.frame) / 2.0f;
    self.bottomButton.layer.borderWidth = 1.0f;
    self.bottomButton.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f);
    [self.bottomButton addTarget:self action:@selector(buttonUpdatedState:) forControlEvents:UIControlEventTouchDragEnter];
    [self.bottomButton addTarget:self action:@selector(buttonUpdatedState:) forControlEvents:UIControlEventTouchDragExit];
    [self.bottomButton addTarget:self action:@selector(buttonUpdatedStateToSelected:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonUpdatedState:(UIButton *)button
{    
    [self button:button setHighlighted:(button.state != UIControlStateNormal)];
}

- (void)buttonUpdatedStateToSelected:(UIButton *)button
{
    [self button:button setHighlighted:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self button:button setHighlighted:NO];
    });
}

- (void)button:(UIButton *)button setHighlighted:(BOOL)highlighted
{
    CGFloat alpha = highlighted ? 0.5f : 1.0f;
    CGColorRef newBorderColor = CGColorCreateCopyWithAlpha(button.layer.borderColor, alpha);
    
    CABasicAnimation *borderAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    borderAnimation.fromValue = (id)button.layer.borderColor;
    borderAnimation.toValue = (id)CFBridgingRelease(newBorderColor);
    borderAnimation.duration = 0.2f;
    [button.layer addAnimation:borderAnimation forKey:@"borderAnimation"];
    button.layer.borderColor = newBorderColor;
    
    UIColor *newTitleColor = [[button titleColorForState:UIControlStateNormal] colorWithAlphaComponent:alpha];
    [UIView transitionWithView:button.titleLabel duration:0.2f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [button setTitleColor:newTitleColor forState:UIControlStateNormal];
                    } completion:nil];
}


@end
