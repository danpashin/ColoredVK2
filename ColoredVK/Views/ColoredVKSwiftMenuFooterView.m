//
//  ColoredVKSwiftMenuFooterView.m
//  ColoredVK2
//
//  Created by Даниил on 04/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "ColoredVKSwiftMenuFooterView.h"

@implementation ColoredVKSwiftMenuFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        [self addSubview:vibrancyView];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        self.titleLabel.textColor = [UIColor blackColor];
        [vibrancyView.contentView addSubview:self.titleLabel];
        
        vibrancyView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":vibrancyView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[view]|" options:0 metrics:nil views:@{@"view":vibrancyView}]];
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.titleLabel}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":self.titleLabel}]];
    }
    return self;
}
@end
