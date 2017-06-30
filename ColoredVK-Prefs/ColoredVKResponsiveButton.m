//
//  ColoredVKResponsiveButton.m
//  ColoredVK2
//
//  Created by Даниил on 30.06.17.
//
//

#import "ColoredVKResponsiveButton.h"

@implementation ColoredVKResponsiveButton


- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    [super setTitle:title forState:state];
    
    if (!_cachedTitle) _cachedTitle = title;
}

@end
