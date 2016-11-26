//
//  PrefixHeader.pch
//  ColoredVK
//
//  Created by Даниил on 25.07.16.
//
//

#import "NSString+ColoredVK.h"
#import "UIColor+ColoredVK.h"
#import "UIImage+ColoredVK.h"



#ifdef  COMPILE_FOR_JAIL
#define CVK_BUNDLE_PATH     @"/Library/PreferenceBundles/ColoredVK2.bundle"
#define VKS_BUNDLE_PATH     @"/Library/PreferenceBundles/vksprefs.bundle"
#define CVK_PREFS_PATH      @"/var/mobile/Library/Preferences/com.daniilpashin.coloredvk2.plist"
#define CVK_FOLDER_PATH     @"/var/mobile/Library/Preferences/ColoredVK2"
#else
#define CVK_BUNDLE_PATH     [NSBundle.mainBundle pathForResource: @"ColoredVK2" ofType: @"bundle"]
#define VKS_BUNDLE_PATH     [NSBundle.mainBundle pathForResource: @"vksprefs" ofType: @"bundle"]
#define CVK_PREFS_PATH      [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.daniilpashin.coloredvk2.plist"]
#define CVK_FOLDER_PATH     [NSHomeDirectory() stringByAppendingString:@"/Documents/ColoredVK2"]
#endif

#define IS_IPAD                               UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define UIKitLocalizedString(key)             [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:key value:@"" table:nil]
#define CVKLocalizedStringFromTable(key, tbl) [[NSBundle bundleWithPath:CVK_BUNDLE_PATH] localizedStringForKey:key value:@"" table:tbl]
#define CVKLocalizedString(key)               CVKLocalizedStringFromTable(key, nil)
#define SYSTEM_VERSION_MORE_THAN(version)     (UIDevice.currentDevice.systemVersion.floatValue >= version)
#define IS_IOS_9_OR_LATER                     SYSTEM_VERSION_MORE_THAN(9.0)
#define IS_IOS_10_OR_LATER                    SYSTEM_VERSION_MORE_THAN(10.0)
#define CLASS_NAME(obj)                       NSStringFromClass([obj class])

#define kColoredVKVersion @"3.2.1"

#ifdef CHAppName
    #undef CHAppName
#endif 
#define CHAppName "[COLOREDVK 2]"

#define API_VERSION @"1.2"

//#define COMPILE_WITH_BLACK_THEME
