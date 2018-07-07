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
+ (UIColor *)cvk_colorFromString:(NSString *)string;

/**
 Возвращает сохраненный цвет для идентификаторов ColoredVK
 */
+ (UIColor *)cvk_savedColorForIdentifier:(NSString *)identifier;

/**
 Возвращает сохраненный цвет из настроек для идентификаторов for ColoredVK
 */
+ (UIColor *)cvk_savedColorForIdentifier:(NSString *)identifier fromPrefs:(NSDictionary *)prefs;

/**
 Возвращает стандартный цвет для идентификаторов ColoredVK
 */
+ (UIColor *)cvk_defaultColorForIdentifier:(NSString *)identifier;

/**
 Затемняет цвет на 0.2
 */
@property (nonatomic, readonly, copy) UIColor *cvk_darkerColor;

@property (nonatomic, readonly, copy) NSString *cvk_stringValue;
@property (nonatomic, readonly, copy) NSString *cvk_rgbStringValue;
@property (nonatomic, readonly, copy) NSString *cvk_hexStringValue;

@end
