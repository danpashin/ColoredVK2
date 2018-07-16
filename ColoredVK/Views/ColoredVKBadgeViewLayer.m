//
//  ColoredVKBadgeViewLayer.m
//  ColoredVK2
//
//  Created by Даниил on 16.07.18.
//

#import "ColoredVKBadgeViewLayer.h"
#import "ColoredVKMainController.h"

extern BOOL enabled;
extern BOOL enableNightTheme;

@implementation ColoredVKBadgeViewLayer

- (void)setFillColor:(CGColorRef)fillColor
{
    if (enabled && enableNightTheme) {
        const CGFloat *components = CGColorGetComponents(fillColor);
        if (components[2] >= 0.79f) {
            fillColor = cvkMainController.nightThemeScheme.buttonSelectedColor.CGColor;
        } else if (components[2] > 0.0f) {
            fillColor = cvkMainController.nightThemeScheme.navbackgroundColor.CGColor;
        }
    }
    
    super.fillColor = fillColor;
}

@end
