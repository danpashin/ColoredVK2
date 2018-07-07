//
//  TweakVariables.h
//  ColoredVK2
//
//  Created by Даниил on 31.03.18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ColoredVKMainController;

/*
 *  Completion block вызывается на главном потоке
 */
void reloadPrefs(void(^completion)(void));

typedef NS_ENUM(NSInteger, CVKCellSelectionStyle) {
    CVKCellSelectionStyleNone = 0,
    CVKCellSelectionStyleTransparent,
    CVKCellSelectionStyleBlurred
};

static BOOL isNew3XClient;

static BOOL premiumEnabled;
static ColoredVKMainController *cvkMainController;
static NSBundle *vksBundle;

static CVKCellSelectionStyle menuSelectionStyle;

static BOOL enableNightTheme;
static BOOL enabled;
static BOOL enabledToolBarColor;
static BOOL enabledTabbarColor;
static BOOL enabledBarColor;
static BOOL enabledMessagesListImage;
static BOOL enabledGroupsListImage;
static BOOL enabledAudioImage;
static BOOL enabledMenuImage;
static BOOL enabledFriendsImage;

static BOOL changeMenuTextColor;
static BOOL enabledSettingsExtraImage;
static BOOL useSettingsExtraParallax;
static BOOL settingsExtraUseBackgroundBlur;
static BOOL changeSettingsExtraTextColor;
static BOOL hideSettingsSeparators;
static BOOL showFastDownloadButton;
static BOOL useMenuParallax;
static BOOL menuUseBackgroundBlur;
static BOOL enabledBarImage;

static BOOL hideMenuSearch;
static BOOL showBar;
static BOOL shouldCheckUpdates;
static BOOL changeSBColors;
static BOOL hideMenuSeparators;
static BOOL messagesUseBlur;
static BOOL useCustomMessageReadColor;
static BOOL useCustomDialogsUnreadColor;
static BOOL menuUseBlur;
static BOOL changeMessagesInput;

static BOOL hideMessagesNavBarItems;
static BOOL useMessageBubbleTintColor;
static BOOL changeSwitchColor;
static BOOL showCommentSeparators;
static BOOL disableGroupCovers;
static BOOL changeAudioPlayerAppearance;
static BOOL enablePlayerGestures;
static BOOL enabledSettingsImage;
static BOOL hideMessagesListSeparators;
static BOOL hideGroupsListSeparators;

static BOOL hideAudiosSeparators;
static BOOL hideFriendsSeparators;
static BOOL hideVideosSeparators;
static BOOL hideSettingsExtraSeparators;
static BOOL messagesListUseBlur;
static BOOL groupsListUseBlur;
static BOOL audiosUseBlur;
static BOOL friendsUseBlur;
static BOOL videosUseBlur;
static BOOL settingsUseBlur;

static BOOL settingsExtraUseBlur;
static BOOL messagesListUseBackgroundBlur;
static BOOL groupsListUseBackgroundBlur;
static BOOL audiosUseBackgroundBlur;
static BOOL friendsUseBackgroundBlur;
static BOOL videosUseBackgroundBlur;
static BOOL settingsUseBackgroundBlur;
static BOOL useMessagesListParallax;
static BOOL useGroupsListParallax;
static BOOL useAudioParallax;

static BOOL useFriendsParallax;
static BOOL useVideosParallax;
static BOOL useSettingsParallax;
static BOOL showMenuCell;
static BOOL changeMessagesListTextColor;
static BOOL changeGroupsListTextColor;
static BOOL changeAudiosTextColor;
static BOOL changeFriendsTextColor;
static BOOL changeVideosTextColor;
static BOOL changeSettingsTextColor;

static BOOL useMessagesParallax;
static BOOL enabledMessagesImage;
static BOOL messagesUseBackgroundBlur;
static BOOL changeMessagesTextColor;
static BOOL enabledVideosImage;

static UIColor *barForegroundColor;
static UIColor *toolBarBackgroundColor;
static UIColor *toolBarForegroundColor;
static UIColor *messagesListBlurTone;
static UIColor *groupsListBlurTone;
static UIColor *audiosBlurTone;
static UIColor *friendsBlurTone;
static UIColor *audioPlayerTintColor;
static UIColor *menuTextColor;
static UIColor *tabbarBackgroundColor;

static UIColor *tabbarSelForegroundColor;
static UIColor *tabbarForegroundColor;
static UIColor *settingsExtraTextColor;
static UIColor *SBBackgroundColor;
static UIColor *menuSeparatorColor;
static UIColor *messageBubbleTintColor;
static UIColor *messageBubbleSentTintColor;
static UIColor *messagesTextColor;
static UIColor *messagesBlurTone;
static UIColor *menuBlurTone;

static UIColor *messagesInputTextColor;
static UIColor *messagesInputBackColor;
static UIColor *dialogsUnreadColor;
static UIColor *messageUnreadColor;
static UIColor *menuSeparatorColor;
static UIColor *barBackgroundColor;
static UIColor *switchesTintColor;
static UIColor *switchesOnTintColor;
static UIColor *messagesListTextColor;
static UIColor *groupsListTextColor;

static UIColor *audiosTextColor;
static UIColor *friendsTextColor;
static UIColor *videosTextColor;
static UIColor *settingsTextColor;
static UIColor *videosBlurTone;
static UIColor *settingsBlurTone;
static UIColor *settingsExtraBlurTone;
static UIColor *menuSelectionColor;
static UIColor *SBForegroundColor;

static CGFloat appCornerRadius;
static CGFloat settingsExtraImageBlackout;
static CGFloat menuImageBlackout;
static CGFloat chatListImageBlackout;
static CGFloat groupsListImageBlackout;
static CGFloat audioImageBlackout;
static CGFloat friendsImageBlackout;
static CGFloat videosImageBlackout;
static CGFloat settingsImageBlackout;
static CGFloat chatImageBlackout;

static CGFloat navbarImageBlackout;

static UIBlurEffectStyle menuBlurStyle;
static UIBlurEffectStyle messagesBlurStyle;
static UIBlurEffectStyle messagesListBlurStyle;
static UIBlurEffectStyle groupsListBlurStyle;
static UIBlurEffectStyle audiosBlurStyle;
static UIBlurEffectStyle friendsBlurStyle;
static UIBlurEffectStyle videosBlurStyle;
static UIBlurEffectStyle settingsBlurStyle;
static UIBlurEffectStyle settingsExtraBlurStyle;

static UIKeyboardAppearance keyboardStyle;
