//
//  UIColor+ColoredVK.h
//  ColoredVK
//
//  Created by Даниил on 09.08.16.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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
/**
 Returns saved color for ColoredVK identifiers
 */
+ ( UIColor *)savedColorForIdentifier:(NSString *)identifier;
/**
 Returns standart color for ColoredVK identifiers
 */
+ (UIColor *)defaultColorForIdentifier:(NSString *)identifier;


/**
 Returns color with 20.0 white
 */
+ (UIColor *)lightBlackColor;
/**
 Returns color with 10.0 white
 */
+ (UIColor *)darkBlackColor;
/**
 Returns color with 178.5 red
 */
+ (UIColor *)buttonsTintColor;

+ (UIColor *)colorAtPoint:(CGPoint)point inImage:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
