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
    if (CGSizeEqualToSize(CGSizeZero, size)) {
        size = CGSizeMake(1, 1);
    }
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
@end
