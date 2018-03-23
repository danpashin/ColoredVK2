//
//  Tweak.h
//  ColoredVK
//
//  Created by Даниил on 20/11/16.
//
//

#import "PrefixHeader.h"
#import "CaptainHook/CaptainHook.h"

#import "ColoredVKMainController.h"
#import "ColoredVKAlertController.h"
#import "VKMethods.h"
#import "UIImage+ColoredVK.h"
#import "ColoredVKNewInstaller.h"
#import "UIColor+ColoredVK.h"


#define kMenuCellBackgroundColor [UIColor colorWithRed:56/255.0f green:69/255.0f blue:84/255.0f alpha:1.0f]
#define kMenuCellSelectedColor [UIColor colorWithRed:47/255.0f green:58/255.0f blue:71/255.0f alpha:1.0f]
#define kMenuCellSeparatorColor [UIColor colorWithRed:72/255.0f green:86/255.0f blue:97/255.0f alpha:1.0f]
#define kMenuCellTextColor [UIColor colorWithRed:233/255.0f green:234/255.0f blue:235/255.0f alpha:1.0f]

#define kNavigationBarBarTintColor [UIColor colorWithRed:0.235294f green:0.439216f blue:0.662745f alpha:1.0f]
#define kVKMainColor [UIColor colorWithRed:88/255.0f green:133/255.0f blue:184/255.0f alpha:1.0f]

#define UITableViewCellTextColor         [UIColor colorWithWhite:1.0f alpha:0.9f]
#define UITableViewCellDetailedTextColor [UIColor colorWithWhite:0.8f alpha:0.9f]
#define UITableViewCellBackgroundColor   [UIColor clearColor]

typedef NS_ENUM(NSInteger, CVKCellSelectionStyle) {
    CVKCellSelectionStyleNone = 0,
    CVKCellSelectionStyleTransparent,
    CVKCellSelectionStyleBlurred
};

void reloadPrefs(void);
void reloadPrefsNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
void reloadMenuNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
void updateCornerRadius(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
void updateNightTheme(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);

void showAlertWithMessage(NSString *message);

void setBlur(UIView *bar, BOOL set, UIColor *color, UIBlurEffectStyle style);
void setToolBar(UIToolbar *toolbar);
void setupTranslucence(UIView *view, UIColor *backColor, BOOL remove);

void setupTabbar(void);
void resetTabBar(void);
void setupHeaderFooterView(UITableViewHeaderFooterView *view, UITableView *tableView);
void setupNewDialogCellFromNightTheme(NewDialogCell *dialogCell);

void performInitialCellSetup(UITableViewCell *cell);
void setupAudioPlayer(UIView *hostView, UIColor *color);
void actionChangeCornerRadius(void);

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
void setupNightTextField(UITextField *textField);

void setupNewSearchBar(VKSearchBar *searchBar, UIColor *tintColor, UIColor *blurTone, UIBlurEffectStyle blurStyle);
void resetNewSearchBar(VKSearchBar *searchBar);
void setupPopoverPresentation(UIViewController *viewController);

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
extern BOOL enabledBarImage;

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
