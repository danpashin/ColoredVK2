//
//  PrefixHeader.pch
//  ColoredVK
//
//  Created by Даниил on 25.07.16.
//
//

#import "NSString+ColoredVK.h"
#import "UIColor+ColoredVK.h"


#define CVK_CRASH_PATH      [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/Crash.txt"]

#ifdef  COMPILE_FOR_JAIL

#define CVK_BUNDLE_PATH     @"/Library/PreferenceBundles/ColoredVK2.bundle"
#define VKS_BUNDLE_PATH     @"/Library/PreferenceBundles/vksprefs.bundle"
#define CVK_PREFS_PATH      @"/var/mobile/Library/Preferences/com.daniilpashin.coloredvk2.plist"
#define CVK_FOLDER_PATH     @"/var/mobile/Library/Preferences/ColoredVK2"
#define CVK_CACHE_PATH      [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/ColoredVK2"]
#define CVK_BACKUP_PATH     @"/var/mobile/Documents/ColoredVK2_Backups/"

#elif defined COMPILE_APP

#define CVK_BUNDLE_PATH     [NSBundle mainBundle].bundlePath
#define CVK_PREFS_PATH      [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.daniilpashin.coloredvk2.plist"]
#define CVK_FOLDER_PATH     @"/var/mobile/Library/Preferences/ColoredVK2"
#define CVK_CACHE_PATH      @"/var/mobile/Library/Caches/com.daniilpashin.coloredvk2/"
#define CVK_BACKUP_PATH     @"/var/mobile/Documents/ColoredVK2_Backups/"

#else

#define CVK_BUNDLE_PATH     [[NSBundle mainBundle] pathForResource: @"ColoredVK2" ofType: @"bundle"]
#define VKS_BUNDLE_PATH     [[NSBundle mainBundle] pathForResource: @"vksprefs" ofType: @"bundle"]
#define CVK_PREFS_PATH      [NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/com.daniilpashin.coloredvk2.plist"]
#define CVK_FOLDER_PATH     [NSHomeDirectory() stringByAppendingString:@"/Documents/ColoredVK2"]
#define CVK_CACHE_PATH      [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/ColoredVK2"]
#define CVK_BACKUP_PATH     [NSHomeDirectory() stringByAppendingString:@"/Documents/ColoredVK2_Backups"]

#endif

#if defined(TARGET_OS_SIMULATOR) && defined(COMPILE_APP)
#undef CVK_PREFS_PATH
#define CVK_PREFS_PATH @"/var/mobile/Library/Preferences/com.daniilpashin.coloredvk2.plist"
#endif

#define IS_IPAD                               (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define UIKitLocalizedString(key)             [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:key value:@"" table:nil]
#define CVKLocalizedStringFromTableInBundle(key, tbl, bndl) [bndl localizedStringForKey:key value:@"" table:tbl]
#define CVKLocalizedStringFromTable(key, tbl) CVKLocalizedStringFromTableInBundle(key, tbl, [NSBundle bundleWithPath:CVK_BUNDLE_PATH])
#define CVKLocalizedString(key)               CVKLocalizedStringFromTable(key, nil)
#define CVKLocalizedStringInBundle(key, bndl) CVKLocalizedStringFromTableInBundle(key, nil, bndl)
#define SYSTEM_VERSION_IS_LESS_THAN(version)  ([[UIDevice currentDevice].systemVersion compare:version options:NSNumericSearch] != NSOrderedDescending)
#define CLASS_NAME(obj)                       NSStringFromClass([obj class])

#define CVKMainColor [UIColor colorWithRed:90/255.0f green:130/255.0f blue:180/255.0f alpha:1.0f]

#define CVKLog(args...)			NSLog(@"[COLOREDVK2]: %@", [NSString stringWithFormat:args])
#define CVKLogSource(args...)	NSLog(@"[COLOREDVK2]: @ " CHStringify(__LINE__) " in %s: %@", __FUNCTION__, [NSString stringWithFormat:args])

static NSString * _Nullable const kPackageIdentifier = @"com.daniilpashin.coloredvk2";
static NSString * _Nullable const kPackageName = @"ColoredVK 2";
static NSString * _Nullable const kPackageVersion = @"4.4.1";

static NSString * _Nullable const kPackageAPIURL = @"https://api.danpashin.ru/v1.2";
static NSString * _Nullable const kPackageDevLink = @"https://vk.com/danpashin";
static NSString * _Nullable const kPackageAccountRegisterLink = @"https://danpashin.ru/projects/coloredvk/index.html#register";
static NSString * _Nullable const kPackageFaqLink = @"https://danpashin.ru/projects/coloredvk/faq.html";
static NSString * _Nullable const kPackagePurchaseLink = @"https://danpashin.ru/projects/coloredvk/purchase/";


