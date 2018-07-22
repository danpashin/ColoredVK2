//
//  ColoredVKPasscodeButton.m
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import "ColoredVKPasscodeButton.h"
#import "UIImage+ColoredVK.h"
#import "ColoredVKNightScheme.h"
#import <objc/runtime.h>

@implementation ColoredVKPasscodeButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.masksToBounds = YES;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize] * 1.5f];
    self.tintColor = [UIColor whiteColor];
    
    NIGHT_THEME_DISABLE_CUSTOMISATION(self);
    NIGHT_THEME_DISABLE_CUSTOMISATION(self.titleLabel);
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    BOOL nightSchemeEnabled = [ColoredVKNightScheme sharedScheme].enabled;
    UIColor *backgroundColor = [UIColor colorWithWhite:nightSchemeEnabled ? 0.0f : 1.0f alpha:1.0f];
    [self setBackgroundImage:[UIImage cvk_imageWithColor:backgroundColor] forState:UIControlStateNormal];
    
    [self setBackgroundImage:[UIImage cvk_imageWithColor:CVKAltColor] forState:UIControlStateHighlighted];
    
    [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.layer.cornerRadius = CGRectGetHeight(self.frame) / 2.0f;
    });
}

@end
