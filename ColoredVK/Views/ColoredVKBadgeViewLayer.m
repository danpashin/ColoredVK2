//
//  ColoredVKBadgeViewLayer.m
//  ColoredVK2
//
//  Created by Даниил on 16.07.18.
//

#import "ColoredVKBadgeViewLayer.h"
#import "ColoredVKMainController.h"
#import "UIView+ColoredVK.h"
#import <objc/runtime.h>

extern BOOL enabled;
extern BOOL enableNightTheme;

@implementation ColoredVKBadgeViewLayer

- (void)setFillColor:(CGColorRef)fillColor
{
    if (enabled && enableNightTheme) {
        if ([self.delegate isKindOfClass:[UIView class]]) {
            UIViewController *parentViewController = ((UIView *)self.delegate).cvk_parentViewController;
            if (parentViewController && [parentViewController isKindOfClass:objc_lookUpClass("DLVController")]) {
                const CGFloat *components = CGColorGetComponents(fillColor);
                if (components[2] >= 0.79f) {
                    fillColor = cvkMainController.nightThemeScheme.buttonSelectedColor.CGColor;
                } else if (components[2] > 0.0f) {
                    fillColor = cvkMainController.nightThemeScheme.navbackgroundColor.CGColor;
                }
            }
        }
    }
    
    super.fillColor = fillColor;
}

@end
