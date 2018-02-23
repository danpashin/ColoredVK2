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
 Создает цвет из строки
 */
+ (UIColor *)colorFromString:(NSString *)string;

/**
 Затемняет цвет на 0.2
 */
@property (nonatomic, readonly, copy) UIColor *darkerColor;

/**
 Возвращает сохраненный цвет для идентификаторов ColoredVK
 */
+ (UIColor *)savedColorForIdentifier:(NSString *)identifier;

/**
 Возвращает сохраненный цвет из настроек для идентификаторов for ColoredVK
 */
+ (UIColor *)savedColorForIdentifier:(NSString *)identifier fromPrefs:(NSDictionary *)prefs;

/**
 Возвращает стандартный цвет для идентификаторов ColoredVK
 */
+ (UIColor *)defaultColorForIdentifier:(NSString *)identifier;


@property (nonatomic, readonly, copy) NSString *stringValue;
@property (nonatomic, readonly, copy) NSString *rgbStringValue;
@property (nonatomic, readonly, copy) NSString *hexStringValue;

@end
