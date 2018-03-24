//
//  ColoredVKPasscodeButton.m
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import "ColoredVKPasscodeButton.h"
#import "UIImage+ColoredVK.h"

@implementation ColoredVKPasscodeButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = CGRectGetHeight(self.frame) / 2.0f;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize] * 1.5f];
    
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1.0f alpha:0.15f]] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1.0f alpha:0.45f]] forState:UIControlStateHighlighted];
}

@end
