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
+ (UIColor * _Nonnull)colorFromString:(NSString * _Nonnull)string;
/**
 Creates color from string (only hex strings are allowed)
 */
+ (UIColor * _Nonnull)colorFromHexString:(NSString * _Nonnull )hexString;
/**
 Creates color darker than current
 */
+ (UIColor * _Nonnull)darkerColorForColor:(UIColor * _Nonnull)color;
/**
 Returns saved color for ColoredVK identifiers
 */
+ ( UIColor * _Nonnull)savedColorForIdentifier:(NSString * _Nonnull)identifier;
/**
 Returns standart color for ColoredVK identifiers
 */
+ (UIColor * _Nonnull)defaultColorForIdentifier:(NSString * _Nonnull)identifier;


/**
 Returns color with 20.0 white
 */
+ (UIColor * _Nonnull)lightBlackColor;
/**
 Returns color with 10.0 white
 */
+ (UIColor * _Nonnull)darkBlackColor;
/**
 Returns color with 178.5 red
 */
+ (UIColor * _Nonnull)buttonsTintColor;
@end
