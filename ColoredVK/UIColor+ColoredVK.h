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
 Creates color darker than current
 */
@property (nonatomic, readonly, copy) UIColor *darkerColor;
/**
 Returns saved color for ColoredVK identifiers
 */
+ (UIColor *)savedColorForIdentifier:(NSString *)identifier;
/**
 Returns color from preferences dictionary for ColoredVK identifiers
 */
+ (UIColor *)savedColorForIdentifier:(NSString *)identifier fromPrefs:(NSDictionary *)prefs;
/**
 Returns standart color for ColoredVK identifiers
 */
+ (UIColor *)defaultColorForIdentifier:(NSString *)identifier;


typedef NS_ENUM (NSUInteger, UIGradientStyle) {
    UIGradientStyleLeftToRight,
    UIGradientStyleRadial,
    UIGradientStyleTopToBottom
};

+ (UIColor *)colorWithGradientStyle:(UIGradientStyle)gradientStyle withFrame:(CGRect)frame andColors:(NSArray<UIColor *> *)colors;


@property (nonatomic, readonly, copy) NSString *stringValue;
@property (nonatomic, readonly, copy) NSString *rgbStringValue;
@property (nonatomic, readonly, copy) NSString *hexStringValue;
@end
