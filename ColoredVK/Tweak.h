//
//  Tweak.h
//  ColoredVK
//
//  Created by Даниил on 20/11/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PrefixHeader.h"

#import "ColoredVKMainController.h"
#import "ColoredVKAlertController.h"
#import "ColoredVKPrefs.h"
#import "VKMethods.h"


#define kMenuCellBackgroundColor [UIColor colorWithRed:56.0/255.0f green:69.0/255.0f blue:84.0/255.0f alpha:1]
#define kMenuCellSelectedColor [UIColor colorWithRed:47.0/255.0f green:58.0/255.0f blue:71.0/255.0f alpha:1]
#define kMenuCellSeparatorColor [UIColor colorWithRed:72.0/255.0f green:86.0/255.0f blue:97.0/255.0f alpha:1]
#define kMenuCellTextColor [UIColor colorWithRed:233.0/255.0f green:234.0/255.0f blue:235.0/255.0f alpha:1]

#define kNavigationBarBarTintColor [UIColor colorWithRed:0.235294 green:0.439216 blue:0.662745 alpha:1]
#define kVKMainColor [UIColor colorWithRed:88/255.0f green:133/255.0f blue:184/255.0f alpha:1.0f]

#define UITableViewCellTextColor         [UIColor colorWithWhite:1 alpha:0.9]
#define UITableViewCellDetailedTextColor [UIColor colorWithWhite:0.8 alpha:0.9]
#define UITableViewCellBackgroundColor   [UIColor clearColor]

typedef NS_ENUM(NSInteger, CVKCellSelectionStyle) {
    CVKCellSelectionStyleNone = 0,
    CVKCellSelectionStyleTransparent,
    CVKCellSelectionStyleBlurred
};

void reloadPrefs();
void reloadPrefsNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
void reloadMenuNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
void updateCornerRadius(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
void updateNightTheme(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);

void showAlertWithMessage(NSString *message);

void setBlur(UIView *bar, BOOL set, UIColor *color, UIBlurEffectStyle style);
void setToolBar(UIToolbar *toolbar);
void setupTranslucence(UIView *view, UIColor *backColor, BOOL remove);

void setupTabbar();
void resetTabBar();
void setupHeaderFooterView(UITableViewHeaderFooterView *view, UITableView *tableView);
void setupNewDialogCellFromNightTheme(NewDialogCell *dialogCell);

void performInitialCellSetup(UITableViewCell *cell);
void setupAudioPlayer(UIView *hostView, UIColor *color);
void actionChangeCornerRadius();

void resetUISearchBar(UISearchBar *searchBar);
void setupUISearchBar(UISearchBar *searchBar);
void resetNavigationBar(UINavigationBar *navBar);

void uncaughtExceptionHandler(NSException *exception);

void setupSearchController(UISearchDisplayController *controller, BOOL reset);
void setupCellForSearchController(UITableViewCell *cell, UISearchDisplayController *searchController);
void hideFastButtonForController(VKMBrowserController *browserController);

void setupExtraSettingsController(VKMTableController *controller);
void setupExtraSettingsCell(UITableViewCell *cell);
void setupNightSeparatorForView(UIView *view);
void setupNewSearchBar(VKSearchBar *searchBar, UIColor *tintColor, UIColor *blurTone, UIBlurEffectStyle blurStyle);
void resetNewSearchBar(VKSearchBar *searchBar);

UIVisualEffectView *blurForView(UIView *view, NSInteger tag);
NSAttributedString *attributedStringForNightTheme(NSAttributedString * text);



extern CVKCellSelectionStyle menuSelectionStyle;
extern ColoredVKMainController *cvkMainController;

extern BOOL enableNightTheme;
extern BOOL enabled;
extern BOOL enabledToolBarColor;
extern BOOL enabledTabbarColor;
extern BOOL enabledBarColor;
extern BOOL enabledMessagesListImage;
extern BOOL enabledGroupsListImage;
extern BOOL enabledAudioImage;
extern BOOL enabledMenuImage;
extern BOOL enabledFriendsImage;
extern BOOL changeMenuTextColor;
extern BOOL enabledSettingsExtraImage;
extern BOOL useSettingsExtraParallax;
extern BOOL settingsExtraUseBackgroundBlur;
extern BOOL changeSettingsExtraTextColor;
extern BOOL hideSettingsSeparators;
extern BOOL showFastDownloadButton;
extern BOOL useMenuParallax;
extern BOOL menuUseBackgroundBlur;

extern UIColor *barForegroundColor;
extern UIColor *toolBarBackgroundColor;
extern UIColor *toolBarForegroundColor;
extern UIColor *messagesListBlurTone;
extern UIColor *groupsListBlurTone;
extern UIColor *audiosBlurTone;
extern UIColor *friendsBlurTone;
extern UIColor *audioPlayerTintColor;
extern UIColor *menuTextColor;
extern UIColor *tabbarBackgroundColor;
extern UIColor *tabbarSelForegroundColor;
extern UIColor *tabbarForegroundColor;
extern UIColor *settingsExtraTextColor;

extern CGFloat appCornerRadius;
extern CGFloat settingsExtraImageBlackout;
extern CGFloat menuImageBlackout;

extern UIBlurEffectStyle messagesListBlurStyle;
extern UIBlurEffectStyle groupsListBlurStyle;
extern UIBlurEffectStyle audiosBlurStyle;
extern UIBlurEffectStyle friendsBlurStyle;
