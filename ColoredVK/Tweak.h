//
//  Tweak.h
//  ColoredVK
//
//  Created by Даниил on 20/11/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define kMenuCellBackgroundColor [UIColor colorWithRed:56.0/255.0f green:69.0/255.0f blue:84.0/255.0f alpha:1]
#define kMenuCellSelectedColor [UIColor colorWithRed:47.0/255.0f green:58.0/255.0f blue:71.0/255.0f alpha:1]
#define kMenuCellSeparatorColor [UIColor colorWithRed:72.0/255.0f green:86.0/255.0f blue:97.0/255.0f alpha:1]
#define kMenuCellTextColor [UIColor colorWithRed:233.0/255.0f green:234.0/255.0f blue:235.0/255.0f alpha:1]

#define kNavigationBarBarTintColor [UIColor colorWithRed:0.235294 green:0.439216 blue:0.662745 alpha:1]
#define kVKMainColor [UIColor colorWithRed:88/255.0f green:133/255.0f blue:184/255.0f alpha:1.0f]

//#define kNightThemeBackgroundColor      [UIColor colorWithRed:0.08f green:0.11f blue:0.15f alpha:1.0f]
//#define kNightThemeForegroundColor      [UIColor colorWithRed:0.11f green:0.16f blue:0.21f alpha:1.0f]
//#define kNightThemeNavBackgroundColor   [UIColor colorWithRed:0.15f green:0.20f blue:0.27f alpha:1.0f]
//
//#define kNightThemeTextColor            [UIColor colorWithWhite:0.9f alpha:0.9f]
//#define kNightThemeUnreadBackgroundColor [UIColor colorWithRed:0.14f green:0.18f blue:0.22f alpha:1.0f]
//#define kNightThemeIncomingBackgroundColor [UIColor colorWithRed:0.21f green:0.29f blue:0.36f alpha:1.0f]
//#define kNightThemeOutcomingBackgroundColor [UIColor colorWithRed:0.21f green:0.37f blue:0.56f alpha:1.0f]
//#define kNightThemeLinkColor                [UIColor colorWithRed:0.21f green:0.64f blue:0.96f alpha:1.0f]

typedef NS_ENUM(NSInteger, CVKCellSelectionStyle) {
    CVKCellSelectionStyleNone = 0,
    CVKCellSelectionStyleTransparent,
    CVKCellSelectionStyleBlurred
};

extern BOOL enableNightTheme;
extern BOOL enabled;
extern CVKCellSelectionStyle menuSelectionStyle;

