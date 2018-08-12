//
//  UIView+ColoredVK.m
//  ColoredVK
//
//  Created by Даниил on 12/08/2018.
//

#import "UIView+ColoredVK.h"

@implementation UIView (ColoredVK)

- (UIViewController * _Nullable)cvk_parentViewController
{
    UIResponder *responder = self;
    while ([responder isKindOfClass:[UIView class]])
        responder = [responder nextResponder];
    
    if ([responder isKindOfClass:[UIViewController class]])
        return (UIViewController *)responder;
    
    return nil;
}

@end
