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

BOOL isNew3XClient;

BOOL premiumEnabled;
ColoredVKMainController *cvkMainController;
NSBundle *vksBundle;

CVKCellSelectionStyle menuSelectionStyle;

BOOL enableNightTheme;
BOOL enabled;
BOOL enabledToolBarColor;
BOOL enabledTabbarColor;
BOOL enabledBarColor;
BOOL enabledMessagesListImage;
BOOL enabledGroupsListImage;
BOOL enabledAudioImage;
BOOL enabledMenuImage;
BOOL enabledFriendsImage;

BOOL changeMenuTextColor;
BOOL enabledSettingsExtraImage;
BOOL useSettingsExtraParallax;
BOOL settingsExtraUseBackgroundBlur;
BOOL changeSettingsExtraTextColor;
BOOL hideSettingsSeparators;
BOOL showFastDownloadButton;
BOOL useMenuParallax;
BOOL menuUseBackgroundBlur;
BOOL enabledBarImage;

BOOL hideMenuSearch;
BOOL showBar;
BOOL shouldCheckUpdates;
BOOL changeSBColors;
BOOL hideMenuSeparators;
BOOL messagesUseBlur;
BOOL useCustomMessageReadColor;
BOOL useCustomDialogsUnreadColor;
BOOL menuUseBlur;
BOOL changeMessagesInput;

BOOL hideMessagesNavBarItems;
BOOL useMessageBubbleTintColor;
BOOL changeSwitchColor;
BOOL showCommentSeparators;
BOOL disableGroupCovers;
BOOL changeAudioPlayerAppearance;
BOOL enablePlayerGestures;
BOOL enabledSettingsImage;
BOOL hideMessagesListSeparators;
BOOL hideGroupsListSeparators;

BOOL hideAudiosSeparators;
BOOL hideFriendsSeparators;
BOOL hideVideosSeparators;
BOOL hideSettingsExtraSeparators;
BOOL messagesListUseBlur;
BOOL groupsListUseBlur;
BOOL audiosUseBlur;
BOOL friendsUseBlur;
BOOL videosUseBlur;
BOOL settingsUseBlur;

BOOL settingsExtraUseBlur;
BOOL messagesListUseBackgroundBlur;
BOOL groupsListUseBackgroundBlur;
BOOL audiosUseBackgroundBlur;
BOOL friendsUseBackgroundBlur;
BOOL videosUseBackgroundBlur;
BOOL settingsUseBackgroundBlur;
BOOL useMessagesListParallax;
BOOL useGroupsListParallax;
BOOL useAudioParallax;

BOOL useFriendsParallax;
BOOL useVideosParallax;
BOOL useSettingsParallax;
BOOL showMenuCell;
BOOL changeMessagesListTextColor;
BOOL changeGroupsListTextColor;
BOOL changeAudiosTextColor;
BOOL changeFriendsTextColor;
BOOL changeVideosTextColor;
BOOL changeSettingsTextColor;

BOOL useMessagesParallax;
BOOL enabledMessagesImage;
BOOL messagesUseBackgroundBlur;
BOOL changeMessagesTextColor;
BOOL enabledVideosImage;

UIColor *barForegroundColor;
UIColor *toolBarBackgroundColor;
UIColor *toolBarForegroundColor;
UIColor *messagesListBlurTone;
UIColor *groupsListBlurTone;
UIColor *audiosBlurTone;
UIColor *friendsBlurTone;
UIColor *audioPlayerTintColor;
UIColor *menuTextColor;
UIColor *tabbarBackgroundColor;

UIColor *tabbarSelForegroundColor;
UIColor *tabbarForegroundColor;
UIColor *settingsExtraTextColor;
UIColor *SBBackgroundColor;
UIColor *menuSeparatorColor;
UIColor *messageBubbleTintColor;
UIColor *messageBubbleSentTintColor;
UIColor *messagesTextColor;
UIColor *messagesBlurTone;
UIColor *menuBlurTone;

UIColor *messagesInputTextColor;
UIColor *messagesInputBackColor;
UIColor *dialogsUnreadColor;
UIColor *messageUnreadColor;
UIColor *menuSeparatorColor;
UIColor *barBackgroundColor;
UIColor *switchesTintColor;
UIColor *switchesOnTintColor;
UIColor *messagesListTextColor;
UIColor *groupsListTextColor;

UIColor *audiosTextColor;
UIColor *friendsTextColor;
UIColor *videosTextColor;
UIColor *settingsTextColor;
UIColor *videosBlurTone;
UIColor *settingsBlurTone;
UIColor *settingsExtraBlurTone;
UIColor *menuSelectionColor;
UIColor *SBForegroundColor;

CGFloat appCornerRadius;
CGFloat settingsExtraImageBlackout;
CGFloat menuImageBlackout;
CGFloat chatListImageBlackout;
CGFloat groupsListImageBlackout;
CGFloat audioImageBlackout;
CGFloat friendsImageBlackout;
CGFloat videosImageBlackout;
CGFloat settingsImageBlackout;
CGFloat chatImageBlackout;

CGFloat navbarImageBlackout;

UIBlurEffectStyle menuBlurStyle;
UIBlurEffectStyle messagesBlurStyle;
UIBlurEffectStyle messagesListBlurStyle;
UIBlurEffectStyle groupsListBlurStyle;
UIBlurEffectStyle audiosBlurStyle;
UIBlurEffectStyle friendsBlurStyle;
UIBlurEffectStyle videosBlurStyle;
UIBlurEffectStyle settingsBlurStyle;
UIBlurEffectStyle settingsExtraBlurStyle;

UIKeyboardAppearance keyboardStyle;
