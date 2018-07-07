//
//  ColoredVKShadowView.m
//  ColoredVK2
//
//  Created by Даниил on 18.04.18.
//

#import "ColoredVKShadowView.h"

@implementation ColoredVKShadowView

+ (ColoredVKShadowView *)shadowWithFrame:(CGRect)frame size:(CGFloat)size cornerRadius:(CGFloat)cornerRadius
{
    return [self shadowWithFrame:frame size:size cornerRadius:cornerRadius offset:0.0f];
}

+ (ColoredVKShadowView *)shadowWithFrame:(CGRect)frame size:(CGFloat)size cornerRadius:(CGFloat)cornerRadius offset:(CGFloat)offset
{
    ColoredVKShadowView *shadowView = [[ColoredVKShadowView alloc] initWithFrame:frame size:size cornerRadius:cornerRadius 
                                                                          offset:offset color:[UIColor colorWithWhite:0.0f alpha:0.15f]];
    [shadowView renderShadow];
    
    return shadowView;
}

- (instancetype)initWithFrame:(CGRect)frame size:(CGFloat)size cornerRadius:(CGFloat)cornerRadius offset:(CGFloat)offset color:(UIColor *)color
{
    CGRect viewFrame = CGRectInset(frame, -size, -size);
    self = [super initWithFrame:viewFrame];
    if (self) {
        self.size = size;
        self.cornerRadius = cornerRadius;
        self.offset = offset;
        self.color = color;
    }
    return self;
}

- (void)renderShadow
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGRect roundedRect = CGRectMake(self.size, self.size, CGRectGetWidth(self.frame)-2*self.size, CGRectGetHeight(self.frame)-2*self.size);
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:roundedRect cornerRadius:self.cornerRadius];
        CGContextAddRect(context, CGContextGetClipBoundingBox(context));
        CGContextAddPath(context, shadowPath.CGPath);
        CGContextEOClip(context);
        
        CGContextSetStrokeColorWithColor(context, self.color.CGColor);
        CGContextAddPath(context, shadowPath.CGPath);
        CGContextSetShadowWithColor(context, CGSizeMake(0, self.offset), self.size, self.color.CGColor);
        CGContextFillPath(context);
        
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
}

@end
