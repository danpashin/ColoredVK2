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


extern BOOL premiumEnabled;
extern ColoredVKMainController *cvkMainController;
extern NSBundle *cvkBunlde;

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

extern BOOL hideMenuSearch;
extern BOOL showBar;
extern BOOL shouldCheckUpdates;
extern BOOL changeSBColors;
extern BOOL hideMenuSeparators;
extern BOOL messagesUseBlur;
extern BOOL useCustomMessageReadColor;
extern BOOL useCustomDialogsUnreadColor;
extern BOOL menuUseBlur;
extern BOOL changeMessagesInput;

extern BOOL hideMessagesNavBarItems;
extern BOOL useMessageBubbleTintColor;
extern BOOL changeSwitchColor;
extern BOOL showCommentSeparators;
extern BOOL disableGroupCovers;
extern BOOL changeAudioPlayerAppearance;
extern BOOL enablePlayerGestures;
extern BOOL enabledSettingsImage;
extern BOOL hideMessagesListSeparators;
extern BOOL hideGroupsListSeparators;

extern BOOL hideAudiosSeparators;
extern BOOL hideFriendsSeparators;
extern BOOL hideVideosSeparators;
extern BOOL hideSettingsExtraSeparators;
extern BOOL messagesListUseBlur;
extern BOOL groupsListUseBlur;
extern BOOL audiosUseBlur;
extern BOOL friendsUseBlur;
extern BOOL videosUseBlur;
extern BOOL settingsUseBlur;

extern BOOL settingsExtraUseBlur;
extern BOOL messagesListUseBackgroundBlur;
extern BOOL groupsListUseBackgroundBlur;
extern BOOL audiosUseBackgroundBlur;
extern BOOL friendsUseBackgroundBlur;
extern BOOL videosUseBackgroundBlur;
extern BOOL settingsUseBackgroundBlur;
extern BOOL useMessagesListParallax;
extern BOOL useGroupsListParallax;
extern BOOL useAudioParallax;

extern BOOL useFriendsParallax;
extern BOOL useVideosParallax;
extern BOOL useSettingsParallax;
extern BOOL showMenuCell;
extern BOOL changeMessagesListTextColor;
extern BOOL changeGroupsListTextColor;
extern BOOL changeAudiosTextColor;
extern BOOL changeFriendsTextColor;
extern BOOL changeVideosTextColor;
extern BOOL changeSettingsTextColor;

extern BOOL useMessagesParallax;
extern BOOL enabledMessagesImage;
extern BOOL messagesUseBackgroundBlur;
extern BOOL changeMessagesTextColor;
extern BOOL enabledVideosImage;

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
extern UIColor *SBBackgroundColor;
extern UIColor *menuSeparatorColor;
extern UIColor *messageBubbleTintColor;
extern UIColor *messageBubbleSentTintColor;
extern UIColor *messagesTextColor;
extern UIColor *messagesBlurTone;
extern UIColor *menuBlurTone;

extern UIColor *messagesInputTextColor;
extern UIColor *messagesInputBackColor;
extern UIColor *dialogsUnreadColor;
extern UIColor *messageUnreadColor;
extern UIColor *menuSeparatorColor;
extern UIColor *barBackgroundColor;
extern UIColor *switchesTintColor;
extern UIColor *switchesOnTintColor;
extern UIColor *messagesListTextColor;
extern UIColor *groupsListTextColor;

extern UIColor *audiosTextColor;
extern UIColor *friendsTextColor;
extern UIColor *videosTextColor;
extern UIColor *settingsTextColor;
extern UIColor *videosBlurTone;
extern UIColor *settingsBlurTone;
extern UIColor *settingsExtraBlurTone;
extern UIColor *menuSelectionColor;
extern UIColor *SBForegroundColor;

extern CGFloat appCornerRadius;
extern CGFloat settingsExtraImageBlackout;
extern CGFloat menuImageBlackout;
extern CGFloat chatListImageBlackout;
extern CGFloat groupsListImageBlackout;
extern CGFloat audioImageBlackout;
extern CGFloat friendsImageBlackout;
extern CGFloat videosImageBlackout;
extern CGFloat settingsImageBlackout;
extern CGFloat chatImageBlackout;

extern CGFloat navbarImageBlackout;

extern UIBlurEffectStyle menuBlurStyle;
extern UIBlurEffectStyle messagesBlurStyle;
extern UIBlurEffectStyle messagesListBlurStyle;
extern UIBlurEffectStyle groupsListBlurStyle;
extern UIBlurEffectStyle audiosBlurStyle;
extern UIBlurEffectStyle friendsBlurStyle;
extern UIBlurEffectStyle videosBlurStyle;
extern UIBlurEffectStyle settingsBlurStyle;
extern UIBlurEffectStyle settingsExtraBlurStyle;

extern UIKeyboardAppearance keyboardStyle;
