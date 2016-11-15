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

- (UIImage *)imageScaledToWidth:(CGFloat)width height:(CGFloat)height
{
    CGFloat oldWidth = self.size.width;
    CGFloat oldHeight = self.size.height;
    
    CGFloat scaleFactor = (oldWidth > oldHeight) ? width/oldWidth : height/oldHeight;
    
    return [self imageScaledToSize:CGSizeMake(oldWidth*scaleFactor, oldHeight*scaleFactor)];
}

- (UIImage *)imageScaledToSize:(CGSize)size
{
    CGFloat imageScale = [[UIDevice currentDevice].model isEqualToString:@"iPad"]?2:1;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale*imageScale);
    else UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    
    return newImage;
}@end
