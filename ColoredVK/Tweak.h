//
//  Tweak.h
//  ColoredVK
//
//  Created by Даниил on 20/11/16.
//
//

#import "ColoredVKMainController.h"
#import "ColoredVKAlertController.h"
#import "UIImage+ColoredVK.h"
#import "ColoredVKNewInstaller.h"
#import "UIColor+ColoredVK.h"
#import "NSObject+ColoredVK.h"
#import "VKMethods.h"

#import "TweakFunctions.h"
#import "TweakVariables.h"

#import "CaptainHook/CaptainHook.h"
#import "fishhook.h"


#define CVKHook(return_type, name, args...)\
static return_type (*name ## _orig)(args);\
return_type name ## _hook(args);\
static void __attribute__((constructor)) name ## _constructor() {\
rebind_symbols((struct rebinding[1]){{#name, name ## _hook, (void *)&name ## _orig}}, 1);\
}\
return_type name ## _hook(args)

#define CVKHookSuper(name, args...)\
name ## _orig(args)


#define kMenuCellBackgroundColor [UIColor colorWithRed:56/255.0f green:69/255.0f blue:84/255.0f alpha:1.0f]
#define kMenuCellSelectedColor [UIColor colorWithRed:47/255.0f green:58/255.0f blue:71/255.0f alpha:1.0f]
#define kMenuCellSeparatorColor [UIColor colorWithRed:72/255.0f green:86/255.0f blue:97/255.0f alpha:1.0f]
#define kMenuCellTextColor [UIColor colorWithRed:233/255.0f green:234/255.0f blue:235/255.0f alpha:1.0f]

#define kNavigationBarBarTintColor [UIColor colorWithRed:0.235294f green:0.439216f blue:0.662745f alpha:1.0f]
#define kVKMainColor [UIColor colorWithRed:88/255.0f green:133/255.0f blue:184/255.0f alpha:1.0f]

#define UITableViewCellTextColor         [UIColor colorWithWhite:1.0f alpha:0.9f]
#define UITableViewCellDetailedTextColor [UIColor colorWithWhite:0.8f alpha:0.9f]
#define UITableViewCellBackgroundColor   [UIColor clearColor]
