//
//  ColoredVKPasscodeButton.m
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import "ColoredVKPasscodeButton.h"
#import "UIImage+ColoredVK.h"
#import "PrefixHeader.h"
#import "ColoredVKNightThemeColorScheme.h"
#import <objc/runtime.h>

@implementation ColoredVKPasscodeButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.masksToBounds = YES;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize] * 1.5f];
    self.tintColor = [UIColor whiteColor];
    
    objc_setAssociatedObject(self, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(self.titleLabel, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    BOOL nightSchemeEnabled = [ColoredVKNightThemeColorScheme sharedScheme].enabled;
    UIColor *backgroundColor = [UIColor colorWithWhite:nightSchemeEnabled ? 0.0f : 1.0f alpha:1.0f];
    [self setBackgroundImage:[UIImage imageWithColor:backgroundColor] forState:UIControlStateNormal];
    
    [self setBackgroundImage:[UIImage imageWithColor:CVKAltColor] forState:UIControlStateHighlighted];
    
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
