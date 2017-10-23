//
//  ColoredVKNightThemeColorScheme.h
//  ColoredVK2
//
//  Created by Даниил on 19.10.17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CVKNightThemeType) {
    CVKNightThemeTypeDarkBlue = 0,
    CVKNightThemeTypeBlack,
    CVKNightThemeTypeCustom
};

@interface ColoredVKNightThemeColorScheme : NSObject

+ (instancetype)colorSchemeForType:(CVKNightThemeType)type;

@property (assign, nonatomic, readonly) CVKNightThemeType type;

@property (strong, nonatomic, readonly) UIColor *backgroundColor;
@property (strong, nonatomic, readonly) UIColor *navbackgroundColor;
@property (strong, nonatomic, readonly) UIColor *foregroundColor;

@property (strong, nonatomic, readonly) UIColor *textColor;
@property (strong, nonatomic, readonly) UIColor *linkTextColor;
@property (strong, nonatomic, readonly) UIColor *unreadBackgroundColor;
@property (strong, nonatomic, readonly) UIColor *incomingBackgroundColor;
@property (strong, nonatomic, readonly) UIColor *outgoingBackgroundColor;

@property (strong, nonatomic, readonly) UIColor *buttonColor;
@property (strong, nonatomic, readonly) UIColor *buttonSelectedColor;
@property (strong, nonatomic, readonly) UIColor *switchTintColor;
@property (strong, nonatomic, readonly) UIColor *switchOnTintColor;

/**
 Инициализирует темно-синюю схему
 */
- (instancetype)init;

- (instancetype)initWithType:(CVKNightThemeType)type;
- (void)updateForType:(CVKNightThemeType)type;

@end
