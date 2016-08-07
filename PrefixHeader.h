//
//  PrefixHeader.pch
//  ColoredVK
//
//  Created by Даниил on 25.07.16.
//
//



//#define AUTOMATIC_PATHS_DETECTION

//#define DEBUG

#define COMPILE_FOR_JAILBREAK

#ifdef COMPILE_FOR_JAILBREAK

#define CVK_BUNDLE_PATH     @"/Library/PreferenceBundles/ColoredVK.bundle"
#define VKS_BUNDLE_PATH     @"/Library/PreferenceBundles/vksprefs.bundle"
#define CVK_PREFS_PATH      @"/var/mobile/Library/Preferences/com.daniilpashin.coloredvk.plist"
#define CVK_FOLDER_PATH     @"/var/mobile/Library/Preferences/ColoredVK"

#define CVK_LICENCE_PATH    @"/var/mobile/Library/Preferences/com.daniilpashin.coloredvk.license"

#else

#define CVK_BUNDLE_PATH     [[NSBundle mainBundle] pathForResource: @"ColoredVK" ofType: @"bundle"]
#define VKS_BUNDLE_PATH     [[NSBundle mainBundle] pathForResource: @"vksprefs" ofType: @"bundle"]
#define CVK_PREFS_PATH      [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.daniilpashin.coloredvk.plist"]
#define CVK_FOLDER_PATH     [NSHomeDirectory() stringByAppendingString:@"/Documents/ColoredVK"]

#define CVK_LICENCE_PATH    [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.daniilpashin.coloredvk.license"]

#endif

#define kColoredVKVersion @"3.0-beta-4"