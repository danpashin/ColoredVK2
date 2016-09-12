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


#define CVK_JAIL_BUNDLE_PATH     @"/Library/PreferenceBundles/ColoredVK2.bundle"
#define VKS_JAIL_BUNDLE_PATH     @"/Library/PreferenceBundles/vksprefs.bundle"
#define CVK_JAIL_PREFS_PATH      @"/var/mobile/Library/Preferences/com.daniilpashin.coloredvk2.plist"
#define CVK_JAIL_FOLDER_PATH     @"/var/mobile/Library/Preferences/ColoredVK2"

#define CVK_NON_JAIL_BUNDLE_PATH     [[NSBundle mainBundle] pathForResource: @"ColoredVK2" ofType: @"bundle"]
#define VKS_NON_JAIL_BUNDLE_PATH     [[NSBundle mainBundle] pathForResource: @"vksprefs" ofType: @"bundle"]
#define CVK_NON_JAIL_PREFS_PATH      [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.daniilpashin.coloredvk2.plist"]
#define CVK_NON_JAIL_FOLDER_PATH     [NSHomeDirectory() stringByAppendingString:@"/Documents/ColoredVK2"]


#define CVKLog(obj) NSLog(@"[COLOREDVK] %@", obj)
#define IS_IPAD  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define UIKitLocalizedString(key) [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:key value:@"" table:nil]

#define kColoredVKVersion @"3.0.1-beta-1"