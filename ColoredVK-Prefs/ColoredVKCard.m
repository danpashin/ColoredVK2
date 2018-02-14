//
//  ColoredVKCard.m
//  ColoredVK2
//
//  Created by Даниил on 13.02.18.
//

#import "ColoredVKCard.h"

@implementation ColoredVKCard

- (UIColor *)titleColor
{
    if (!_titleColor) {
        _titleColor = [UIColor whiteColor];
    }
    return _titleColor;
}

- (UIColor *)backgroundColor
{
    if (!_backgroundColor) {
        _backgroundColor = [UIColor whiteColor];
    }
    return _backgroundColor;
}

- (CGFloat)backgroundImageAlpha
{
    if (!_backgroundImageAlpha) {
        _backgroundImageAlpha = 0.6f;
    }
    return _backgroundImageAlpha;
}

- (UIColor *)buttonTintColor
{
    if (!_buttonTintColor) {
        _buttonTintColor = [UIColor colorWithRed:248/255.0f green:148/255.0f blue:6/255.0f alpha:1.0f];
    }
    return _buttonTintColor;
}

- (void)setButtonAction:(SEL)buttonAction
{
    if (self.buttonTarget && ![self.buttonTarget respondsToSelector:buttonAction]) {
        buttonAction = nil;
        self.buttonTarget = nil;
    }
    
    _buttonAction = buttonAction;
}

@end
