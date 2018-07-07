//
//  UIImage+ColoredVK.h
//  ColoredVK
//
//  Created by Даниил on 09.08.16.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (ColoredVK)

/**
 Creates image with color and size 1x1
 */
+ (UIImage *)cvk_imageWithColor:(UIColor *)color;

/**
 Creates image with color and specified size  
 */
+ (UIImage *)cvk_imageWithColor:(UIColor *)color size:(CGSize)size;

- (UIImage *)cvk_imageWithTintColor:(UIColor *)tintColor;

@end
