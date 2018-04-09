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

extern BOOL premiumEnabled;
extern ColoredVKMainController *cvkMainController;
extern NSBundle *cvkBunlde;
extern NSBundle *vksBundle;
extern BOOL VKSettingsEnabled;

extern CVKCellSelectionStyle menuSelectionStyle;

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
