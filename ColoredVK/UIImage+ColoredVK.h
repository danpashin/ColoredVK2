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
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 Creates image with color and specified size  
 */
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

- (UIImage *)imageWithTintColor:(UIColor *)tintColor;

@end
