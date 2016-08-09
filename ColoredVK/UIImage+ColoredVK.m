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
    UIView *colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    colorView.backgroundColor = color;
    UIImage *colorImage;
    UIGraphicsBeginImageContext(colorView.bounds.size);
    [colorView.layer renderInContext:UIGraphicsGetCurrentContext()];
    colorImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return colorImage;
}
@end
