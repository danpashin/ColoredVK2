//
//  ColoredVKNightScheme.h
//  ColoredVK2
//
//  Created by Даниил on 19.10.17.
//

#import <Foundation/NSObject.h>
@class UIColor;

typedef NS_ENUM(NSInteger, CVKNightThemeType) {
    CVKNightThemeTypeDisabled = -1,
    CVKNightThemeTypeDarkBlue = 0,
    CVKNightThemeTypeBlack,
    CVKNightThemeTypeCustom,
    CVKNightThemeTypeTrueBlack,
};

@interface ColoredVKNightScheme : NSObject

+ (instancetype)sharedScheme;

@property (assign, atomic) BOOL enabled;
@property (assign, nonatomic, readonly) CVKNightThemeType type;
@property (assign, nonatomic) CVKNightThemeType userSelectedType;

@property (strong, nonatomic, readonly) UIColor *backgroundColor;
@property (strong, nonatomic, readonly) UIColor *navbackgroundColor;
@property (strong, nonatomic, readonly) UIColor *foregroundColor;

@property (strong, nonatomic, readonly) UIColor *detailTextColor;
@property (strong, nonatomic, readonly) UIColor *textColor;
@property (strong, nonatomic, readonly) UIColor *linkTextColor;
@property (strong, nonatomic, readonly) UIColor *unreadBackgroundColor;
@property (strong, nonatomic, readonly) UIColor *incomingBackgroundColor;
@property (strong, nonatomic, readonly) UIColor *outgoingBackgroundColor;

@property (strong, nonatomic, readonly) UIColor *buttonColor;
@property (strong, nonatomic, readonly) UIColor *buttonSelectedColor;
@property (strong, nonatomic, readonly) UIColor *switchThumbTintColor;
@property (strong, nonatomic, readonly) UIColor *switchOnTintColor;

- (void)updateForType:(CVKNightThemeType)type;

@end
