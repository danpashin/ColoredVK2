//
//  UIColor+ColoredVK.h
//  ColoredVK
//
//  Created by Даниил on 09.08.16.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (ColoredVK)
/**
 Creates color from string
 */
+ (UIColor *)colorFromString:(NSString *)string;
/**
 Creates color from string (only hex strings are allowed)
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString;
/**
 Creates color darker than current
 */
+ (UIColor *)darkerColorForColor:(UIColor *)color;
@end
