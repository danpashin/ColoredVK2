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

typedef NS_ENUM(NSInteger, CVKCellSelectionStyle) {
    CVKCellSelectionStyleNone = 0,
    CVKCellSelectionStyleTransparent,
    CVKCellSelectionStyleBlurred
};

extern BOOL enableNightTheme;
extern BOOL enabled;
extern CVKCellSelectionStyle menuSelectionStyle;

