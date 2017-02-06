//
//  UIImage+ColoredVK.m
//  ColoredVK
//
//  Created by Даниил on 09.08.16.
//
//

#import "UIImage+ColoredVK.h"

@implementation UIImage (ColoredVK)
+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [self imageWithColor:color andSize:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    if (CGSizeEqualToSize(CGSizeZero, size)) size = CGSizeMake(1, 1);
    UIView *colorView = [UIView new];
    colorView.frame = (CGRect){{0, 0}, size};
    colorView.backgroundColor = color;
    UIImage *colorImage;
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return colorImage;
}

- (UIImage *)imageWithTintColor:(UIColor *)tintColor
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        [tintColor setFill];
        CGContextTranslateCTM(context, 0, self.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextClipToMask(context, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
        CGContextFillRect(context, CGRectMake(0, 0, self.size.width, self.size.height));
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    UIGraphicsEndImageContext();
    
    return [UIImage new];
}

- (UIImage *)imageWithOverlayColor:(UIColor *)overlayColor
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
        [[UIImage imageWithColor:overlayColor] drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    UIGraphicsEndImageContext();
    
    return [UIImage new];
}
@end
