//
//  Tweak.m
//  ColoredVK
//
//  Created by Даниил on 21.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/


#import "Tweak.h"
#import <dlfcn.h>
#import "ColoredVKNewInstaller.h"
#import "ColoredVKBarDownloadButton.h"
//#import <CoreText/CoreText.h>

@interface PSListController : UIViewController
@end


BOOL premiumEnabled = NO;
BOOL VKSettingsEnabled;

BOOL enableNightTheme;

BOOL showFastDownloadButton;
BOOL showMenuCell;

NSBundle *cvkBunlde;
NSBundle *vksBundle;

BOOL enabled;
BOOL enabledBarColor;
BOOL showBar;
BOOL enabledToolBarColor;
BOOL enabledBarImage;
BOOL enabledTabbarColor;


BOOL enabledMenuImage;
BOOL hideMenuSeparators;
BOOL hideMessagesListSeparators;
BOOL hideGroupsListSeparators;
BOOL hideAudiosSeparators;
BOOL hideFriendsSeparators;
BOOL hideVideosSeparators;
BOOL hideSettingsSeparators;
BOOL hideSettingsExtraSeparators;

BOOL enabledMessagesImage;
BOOL enabledMessagesListImage;
BOOL enabledGroupsListImage;
BOOL enabledAudioImage;
BOOL changeAudioPlayerAppearance;
BOOL enablePlayerGestures;
BOOL enabledFriendsImage;
BOOL enabledVideosImage;
BOOL enabledSettingsImage;
BOOL enabledSettingsExtraImage;

CGFloat menuImageBlackout;
CGFloat chatImageBlackout;
CGFloat chatListImageBlackout;
CGFloat groupsListImageBlackout;
CGFloat audioImageBlackout;
CGFloat navbarImageBlackout;
CGFloat friendsImageBlackout;
CGFloat videosImageBlackout;
CGFloat settingsImageBlackout;
CGFloat settingsExtraImageBlackout;


CGFloat appCornerRadius;


BOOL useMenuParallax;
BOOL useMessagesListParallax;
BOOL useMessagesParallax;
BOOL useGroupsListParallax;
BOOL useAudioParallax;
BOOL useFriendsParallax;
BOOL useVideosParallax;
BOOL useSettingsParallax;
BOOL useSettingsExtraParallax;

BOOL hideMessagesNavBarItems;

BOOL hideMenuSearch;
BOOL changeSwitchColor;
BOOL changeSBColors;
BOOL shouldCheckUpdates;

BOOL useMessageBubbleTintColor;
BOOL useCustomMessageReadColor;

BOOL showCommentSeparators;
BOOL disableGroupCovers;

BOOL changeMenuTextColor;
BOOL changeMessagesListTextColor;
BOOL changeMessagesTextColor;
BOOL changeGroupsListTextColor;
BOOL changeAudiosTextColor;
BOOL changeFriendsTextColor;
BOOL changeVideosTextColor;
BOOL changeSettingsTextColor;
BOOL changeSettingsExtraTextColor;
BOOL changeMessagesInput;

BOOL useCustomDialogsUnreadColor;
UIColor *dialogsUnreadColor;

UIColor *menuSeparatorColor;
UIColor *barBackgroundColor;
UIColor *barForegroundColor;
UIColor *toolBarBackgroundColor;
UIColor *toolBarForegroundColor;
UIColor *tabbarForegroundColor;
UIColor *tabbarBackgroundColor;
UIColor *tabbarSelForegroundColor;
UIColor *SBBackgroundColor;
UIColor *SBForegroundColor;
UIColor *switchesTintColor;
UIColor *switchesOnTintColor;

UIColor *messageBubbleTintColor;
UIColor *messageBubbleSentTintColor;
UIColor *messageUnreadColor;

UIColor *menuTextColor;
UIColor *messagesListTextColor;
UIColor *messagesTextColor;
UIColor *groupsListTextColor;
UIColor *audiosTextColor;
UIColor *friendsTextColor;
UIColor *videosTextColor;
UIColor *settingsTextColor;
UIColor *settingsExtraTextColor;

UIColor *messagesInputTextColor;
UIColor *messagesInputBackColor;

UIColor *audioPlayerTintColor;
UIColor *menuSelectionColor;


UIColor *messagesBlurTone;
UIColor *messagesListBlurTone;
UIColor *groupsListBlurTone;
UIColor *audiosBlurTone;
UIColor *friendsBlurTone;
UIColor *videosBlurTone;
UIColor *settingsBlurTone;
UIColor *settingsExtraBlurTone;
UIColor *menuBlurTone;

BOOL messagesUseBlur;
BOOL messagesListUseBlur;
BOOL groupsListUseBlur;
BOOL audiosUseBlur;
BOOL friendsUseBlur;
BOOL videosUseBlur;
BOOL settingsUseBlur;
BOOL settingsExtraUseBlur;
BOOL menuUseBlur;

BOOL messagesUseBackgroundBlur;
BOOL messagesListUseBackgroundBlur;
BOOL groupsListUseBackgroundBlur;
BOOL audiosUseBackgroundBlur;
BOOL friendsUseBackgroundBlur;
BOOL videosUseBackgroundBlur;
BOOL settingsUseBackgroundBlur;
BOOL settingsExtraUseBackgroundBlur;
BOOL menuUseBackgroundBlur;


CVKCellSelectionStyle menuSelectionStyle;
UIKeyboardAppearance keyboardStyle;

UIBlurEffectStyle menuBlurStyle;
UIBlurEffectStyle messagesBlurStyle;
UIBlurEffectStyle messagesListBlurStyle;
UIBlurEffectStyle groupsListBlurStyle;
UIBlurEffectStyle audiosBlurStyle;
UIBlurEffectStyle friendsBlurStyle;
UIBlurEffectStyle videosBlurStyle;
UIBlurEffectStyle settingsBlurStyle;
UIBlurEffectStyle settingsExtraBlurStyle;

//NSString *customFontName;

ColoredVKMainController *cvkMainController;


#pragma mark Static methods
void reloadPrefs()
{
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:CVK_PREFS_PATH];
    
    enabled = [prefs[@"enabled"] boolValue];
    hideMenuSearch = [prefs[@"hideMenuSearch"] boolValue];
    enabledMenuImage = [prefs[@"enabledMenuImage"] boolValue];
    menuImageBlackout = [prefs[@"menuImageBlackout"] floatValue];
    useMenuParallax = [prefs[@"useMenuParallax"] boolValue];
    useMessagesParallax = [prefs[@"useMessagesParallax"] boolValue];
    barForegroundColor = [UIColor savedColorForIdentifier:@"BarForegroundColor" fromPrefs:prefs];
    showBar = [prefs[@"showBar"] boolValue];
    SBBackgroundColor = [UIColor savedColorForIdentifier:@"SBBackgroundColor" fromPrefs:prefs];
    SBForegroundColor = [UIColor savedColorForIdentifier:@"SBForegroundColor" fromPrefs:prefs];
    
    shouldCheckUpdates = prefs[@"checkUpdates"]?[prefs[@"checkUpdates"] boolValue]:YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStatusBar *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
        if (statusBar != nil) {
            if (enabled && enableNightTheme) {
                statusBar.foregroundColor = [UIColor whiteColor];
            } else if (enabled && changeSBColors) {
                statusBar.foregroundColor = SBForegroundColor;
                statusBar.backgroundColor = SBBackgroundColor;
            } else {
                statusBar.foregroundColor = nil;
                statusBar.backgroundColor = nil;
            }
        }
    });
    
    enabledBarImage = [prefs[@"enabledBarImage"] boolValue];
    enabledBarColor = [prefs[@"enabledBarColor"] boolValue];
    enabledToolBarColor = [prefs[@"enabledToolBarColor"] boolValue];
    enabledTabbarColor = [prefs[@"enabledTabbarColor"] boolValue];
    
    enabledMessagesImage = [prefs[@"enabledMessagesImage"] boolValue];
    hideMenuSeparators = [prefs[@"hideMenuSeparators"] boolValue];
    messagesUseBlur = [prefs[@"messagesUseBlur"] boolValue];
    messagesUseBackgroundBlur = [prefs[@"messagesUseBackgroundBlur"] boolValue];
    useCustomMessageReadColor = [prefs[@"useCustomMessageReadColor"] boolValue];
    useCustomDialogsUnreadColor = [prefs[@"useCustomDialogsUnreadColor"] boolValue];
    menuUseBlur = [prefs[@"menuUseBlur"] boolValue];
    menuUseBackgroundBlur = [prefs[@"menuUseBackgroundBlur"] boolValue];
    changeMessagesInput = [prefs[@"changeMessagesInput"] boolValue];
    
    navbarImageBlackout = [prefs[@"navbarImageBlackout"] floatValue];
    chatImageBlackout = [prefs[@"chatImageBlackout"] floatValue];
    hideMessagesNavBarItems = [prefs[@"hideMessagesNavBarItems"] boolValue];
    changeMenuTextColor = [prefs[@"changeMenuTextColor"] boolValue];
    changeMessagesTextColor = [prefs[@"changeMessagesTextColor"] boolValue];
    useMessageBubbleTintColor = [prefs[@"useMessageBubbleTintColor"] boolValue];
    menuSelectionStyle = prefs[@"menuSelectionStyle"]?[prefs[@"menuSelectionStyle"] integerValue]:CVKCellSelectionStyleTransparent;
    messagesBlurStyle = prefs[@"messagesBlurStyle"]?[prefs[@"messagesBlurStyle"] integerValue]:UIBlurEffectStyleLight;
    menuBlurStyle = prefs[@"menuBlurStyle"]?[prefs[@"menuBlurStyle"] integerValue]:UIBlurEffectStyleLight;
    
    menuSeparatorColor =         [UIColor savedColorForIdentifier:@"MenuSeparatorColor"         fromPrefs:prefs];
    menuSelectionColor =        [[UIColor savedColorForIdentifier:@"menuSelectionColor"         fromPrefs:prefs] colorWithAlphaComponent:0.3f];
    barBackgroundColor =         [UIColor savedColorForIdentifier:@"BarBackgroundColor"         fromPrefs:prefs];
    toolBarBackgroundColor =     [UIColor savedColorForIdentifier:@"ToolBarBackgroundColor"     fromPrefs:prefs];
    toolBarForegroundColor =     [UIColor savedColorForIdentifier:@"ToolBarForegroundColor"     fromPrefs:prefs];
    messageBubbleTintColor =     [UIColor savedColorForIdentifier:@"messageBubbleTintColor"     fromPrefs:prefs];
    messageBubbleSentTintColor = [UIColor savedColorForIdentifier:@"messageBubbleSentTintColor" fromPrefs:prefs];
    menuTextColor =              [UIColor savedColorForIdentifier:@"menuTextColor"              fromPrefs:prefs];
    messagesTextColor =          [UIColor savedColorForIdentifier:@"messagesTextColor"          fromPrefs:prefs];
    messagesBlurTone =          [[UIColor savedColorForIdentifier:@"messagesBlurTone"           fromPrefs:prefs] colorWithAlphaComponent:0.3f];
    menuBlurTone =              [[UIColor savedColorForIdentifier:@"menuBlurTone"               fromPrefs:prefs] colorWithAlphaComponent:0.3f];
    tabbarBackgroundColor =     [UIColor savedColorForIdentifier:@"TabbarBackgroundColor"       fromPrefs:prefs];
    tabbarForegroundColor =     [UIColor savedColorForIdentifier:@"TabbarForegroundColor"       fromPrefs:prefs];
    tabbarSelForegroundColor =  [UIColor savedColorForIdentifier:@"TabbarSelForegroundColor"    fromPrefs:prefs];
    messagesInputTextColor =    [UIColor savedColorForIdentifier:@"messagesInputTextColor"      fromPrefs:prefs];
    messagesInputBackColor =    [UIColor savedColorForIdentifier:@"messagesInputBackColor"      fromPrefs:prefs];
    dialogsUnreadColor =        [[UIColor savedColorForIdentifier:@"dialogsUnreadColor"         fromPrefs:prefs] colorWithAlphaComponent:0.3f];
    messageUnreadColor =        [[UIColor savedColorForIdentifier:@"messageReadColor"           fromPrefs:prefs] colorWithAlphaComponent:0.2f];
    
    ColoredVKVersionCompare compareResult = [[ColoredVKNewInstaller sharedInstaller].application compareAppVersionWithVersion:@"3.0"];
    if (!hideMenuSeparators && !prefs[@"MenuSeparatorColor"] && (compareResult == ColoredVKVersionCompareMore)) {
        menuSeparatorColor  = [UIColor colorWithRed:215/255.0f green:216/255.0f blue:217/255.0f alpha:1.0f];
    }
    
    showFastDownloadButton = prefs[@"showFastDownloadButton"] ? [prefs[@"showFastDownloadButton"] boolValue] : YES;
    showMenuCell = prefs[@"showMenuCell"] ? [prefs[@"showMenuCell"] boolValue] : YES;
    
    if (prefs && premiumEnabled) {
        
        enableNightTheme = prefs[@"nightThemeType"] ? ([prefs[@"nightThemeType"] integerValue] != -1) : NO;
        [cvkMainController.nightThemeScheme updateForType:[prefs[@"nightThemeType"] integerValue]];
        cvkMainController.nightThemeScheme.enabled = enableNightTheme;
        
        if (enableNightTheme && (compareResult == ColoredVKVersionCompareLess)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cvkMainController.menuBackgroundView.alpha = 0.0f;
                resetUISearchBar((UISearchBar*)cvkMainController.vkMainController.tableView.tableHeaderView);
            });
        }
       
        changeSBColors = [prefs[@"changeSBColors"] boolValue];
        changeSwitchColor = [prefs[@"changeSwitchColor"] boolValue];
        showCommentSeparators = prefs[@"showCommentSeparators"] ? ![prefs[@"showCommentSeparators"] boolValue] : NO;
        
        disableGroupCovers = [prefs[@"disableGroupCovers"] boolValue];
        
        enabledMessagesListImage = [prefs[@"enabledMessagesListImage"] boolValue];
        enabledGroupsListImage = [prefs[@"enabledGroupsListImage"] boolValue];
        enabledAudioImage = [prefs[@"enabledAudioImage"] boolValue];
        changeAudioPlayerAppearance = [prefs[@"changeAudioPlayerAppearance"] boolValue];
        enablePlayerGestures = prefs[@"enablePlayerGestures"] ? [prefs[@"enablePlayerGestures"] boolValue] : YES;
        enabledFriendsImage = [prefs[@"enabledFriendsImage"] boolValue];
        enabledVideosImage = [prefs[@"enabledVideosImage"] boolValue];
        enabledSettingsImage = [prefs[@"enabledSettingsImage"] boolValue];
        enabledSettingsExtraImage = [prefs[@"enabledSettingsExtraImage"] boolValue];
        
        hideMessagesListSeparators = [prefs[@"hideMessagesListSeparators"] boolValue];
        hideGroupsListSeparators = [prefs[@"hideGroupsListSeparators"] boolValue];
        hideAudiosSeparators = [prefs[@"hideAudiosSeparators"] boolValue];
        hideFriendsSeparators = [prefs[@"hideFriendsSeparators"] boolValue];
        hideVideosSeparators = [prefs[@"hideVideosSeparators"] boolValue];
        hideSettingsSeparators = [prefs[@"hideSettingsSeparators"] boolValue];
        hideSettingsExtraSeparators = [prefs[@"hideSettingsExtraSeparators"] boolValue];
        
        messagesListUseBlur = [prefs[@"messagesListUseBlur"] boolValue];
        groupsListUseBlur = [prefs[@"groupsListUseBlur"] boolValue];
        audiosUseBlur = [prefs[@"audiosUseBlur"] boolValue];
        friendsUseBlur = [prefs[@"friendsUseBlur"] boolValue];
        videosUseBlur = [prefs[@"videosUseBlur"] boolValue];
        settingsUseBlur = [prefs[@"settingsUseBlur"] boolValue];
        settingsExtraUseBlur = [prefs[@"settingsExtraUseBlur"] boolValue];
        
        messagesListUseBackgroundBlur = [prefs[@"messagesListUseBackgroundBlur"] boolValue];
        groupsListUseBackgroundBlur = [prefs[@"groupsListUseBackgroundBlur"] boolValue];
        audiosUseBackgroundBlur = [prefs[@"audiosUseBackgroundBlur"] boolValue];
        friendsUseBackgroundBlur = [prefs[@"friendsUseBackgroundBlur"] boolValue];
        videosUseBackgroundBlur = [prefs[@"videosUseBackgroundBlur"] boolValue];
        settingsUseBackgroundBlur = [prefs[@"settingsUseBackgroundBlur"] boolValue];
        settingsExtraUseBackgroundBlur = [prefs[@"settingsExtraUseBackgroundBlur"] boolValue];
        
        
        useMessagesListParallax = [prefs[@"useMessagesListParallax"] boolValue];
        useGroupsListParallax = [prefs[@"useGroupsListParallax"] boolValue];
        useAudioParallax = [prefs[@"useAudioParallax"] boolValue];
        useFriendsParallax = [prefs[@"useFriendsParallax"] boolValue];
        useVideosParallax = [prefs[@"useVideosParallax"] boolValue];
        useSettingsParallax = [prefs[@"useSettingsParallax"] boolValue];
        useSettingsExtraParallax = [prefs[@"useSettingsExtraParallax"] boolValue];
        
        chatListImageBlackout = [prefs[@"chatListImageBlackout"] floatValue];
        groupsListImageBlackout = [prefs[@"groupsListImageBlackout"] floatValue];
        audioImageBlackout = [prefs[@"audioImageBlackout"] floatValue];
        friendsImageBlackout = [prefs[@"friendsImageBlackout"] floatValue];
        videosImageBlackout = [prefs[@"videosImageBlackout"] floatValue];
        settingsImageBlackout = [prefs[@"settingsImageBlackout"] floatValue];
        settingsExtraImageBlackout = [prefs[@"settingsExtraImageBlackout"] floatValue];
        
        appCornerRadius = [prefs[@"appCornerRadius"] floatValue];
        
        
        changeMessagesListTextColor = [prefs[@"changeMessagesListTextColor"] boolValue];
        changeGroupsListTextColor = [prefs[@"changeGroupsListTextColor"] boolValue];
        changeAudiosTextColor = [prefs[@"changeAudiosTextColor"] boolValue];
        changeFriendsTextColor = [prefs[@"changeFriendsTextColor"] boolValue];
        changeVideosTextColor = [prefs[@"changeVideosTextColor"] boolValue];
        changeSettingsTextColor = [prefs[@"changeSettingsTextColor"] boolValue];
        changeSettingsExtraTextColor = [prefs[@"changeSettingsExtraTextColor"] boolValue];
        
        keyboardStyle = prefs[@"keyboardStyle"]?[prefs[@"keyboardStyle"] integerValue]:UIKeyboardAppearanceDefault;
        
        messagesListBlurStyle = prefs[@"messagesListBlurStyle"]?[prefs[@"messagesListBlurStyle"] integerValue]:UIBlurEffectStyleLight;
        groupsListBlurStyle = prefs[@"groupsListBlurStyle"]?[prefs[@"groupsListBlurStyle"] integerValue]:UIBlurEffectStyleLight;
        audiosBlurStyle = prefs[@"audiosBlurStyle"]?[prefs[@"audiosBlurStyle"] integerValue]:UIBlurEffectStyleLight;
        friendsBlurStyle = prefs[@"friendsBlurStyle"]?[prefs[@"friendsBlurStyle"] integerValue]:UIBlurEffectStyleLight;
        videosBlurStyle = prefs[@"videosBlurStyle"]?[prefs[@"videosBlurStyle"] integerValue]:UIBlurEffectStyleLight;
        settingsBlurStyle = prefs[@"settingsBlurStyle"]?[prefs[@"settingsBlurStyle"] integerValue]:UIBlurEffectStyleLight;
        settingsExtraBlurStyle = prefs[@"settingsExtraBlurStyle"]?[prefs[@"settingsExtraBlurStyle"] integerValue]:UIBlurEffectStyleLight;
        
        
        switchesTintColor =          [UIColor savedColorForIdentifier:@"switchesTintColor"          fromPrefs:prefs];
        switchesOnTintColor =        [UIColor savedColorForIdentifier:@"switchesOnTintColor"        fromPrefs:prefs];
        
        messagesListTextColor =      [UIColor savedColorForIdentifier:@"messagesListTextColor"      fromPrefs:prefs];
        groupsListTextColor =        [UIColor savedColorForIdentifier:@"groupsListTextColor"        fromPrefs:prefs];
        audiosTextColor =            [UIColor savedColorForIdentifier:@"audiosTextColor"            fromPrefs:prefs];
        friendsTextColor =           [UIColor savedColorForIdentifier:@"friendsTextColor"           fromPrefs:prefs];
        videosTextColor =            [UIColor savedColorForIdentifier:@"videosTextColor"            fromPrefs:prefs];
        settingsTextColor =          [UIColor savedColorForIdentifier:@"settingsTextColor"          fromPrefs:prefs];
        settingsExtraTextColor =     [UIColor savedColorForIdentifier:@"settingsExtraTextColor"     fromPrefs:prefs];
        
        messagesListBlurTone =      [[UIColor savedColorForIdentifier:@"messagesListBlurTone"       fromPrefs:prefs] colorWithAlphaComponent:0.3f];
        groupsListBlurTone =        [[UIColor savedColorForIdentifier:@"groupsListBlurTone"         fromPrefs:prefs] colorWithAlphaComponent:0.3f];
        audiosBlurTone =            [[UIColor savedColorForIdentifier:@"audiosBlurTone"             fromPrefs:prefs] colorWithAlphaComponent:0.3f];
        friendsBlurTone =           [[UIColor savedColorForIdentifier:@"friendsBlurTone"            fromPrefs:prefs] colorWithAlphaComponent:0.3f];
        videosBlurTone =            [[UIColor savedColorForIdentifier:@"videosBlurTone"             fromPrefs:prefs] colorWithAlphaComponent:0.3f];
        settingsBlurTone =          [[UIColor savedColorForIdentifier:@"settingsBlurTone"           fromPrefs:prefs] colorWithAlphaComponent:0.3f];
        settingsExtraBlurTone =     [[UIColor savedColorForIdentifier:@"settingsExtraBlurTone"      fromPrefs:prefs] colorWithAlphaComponent:0.3f];
        
//        customFontName = prefs[@"customFontName"] ? prefs[@"customFontName"] : @".SFUIText";
        
    }
    
    if (cvkMainController.navBarImageView)
        [cvkMainController.navBarImageView updateViewWithBlackout:navbarImageBlackout];
}


#pragma mark - AppDelegate
CHDeclareClass(AppDelegate);
CHDeclareMethod(2, BOOL, AppDelegate, application, UIApplication*, application, didFinishLaunchingWithOptions, NSDictionary *, options)
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [cvkBunlde load];
    reloadPrefs();
    
    BOOL orig = CHSuper(2, AppDelegate, application, application, didFinishLaunchingWithOptions, options);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
        installerCompletionBlock = ^(BOOL purchased) {
            premiumEnabled = purchased;
            reloadPrefs();
        };
        [newInstaller checkStatus];
    });
    
    return orig;
}

CHDeclareMethod(1, void, AppDelegate, applicationDidBecomeActive, UIApplication *, application)
{
    CHSuper(1, AppDelegate, applicationDidBecomeActive, application);
    
    actionChangeCornerRadius();
    
    if (cvkMainController.audioCover) {
        [cvkMainController.audioCover updateColorScheme];
    }
    
    [cvkMainController checkCrashes];
}



#pragma mark UINavigationBar
CHDeclareClass(UINavigationBar);
CHDeclareMethod(1, void, UINavigationBar, setBarTintColor, UIColor*, barTintColor)
{
    setupTranslucence(self, cvkMainController.nightThemeScheme.navbackgroundColor, !(enabled && enableNightTheme));
    
    if (enabled) {
        if (enableNightTheme) {
            barTintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        }
        else if (enabledBarImage && self.tag != 26) {
            if (cvkMainController.navBarImageView)  barTintColor = [UIColor colorWithPatternImage:cvkMainController.navBarImageView.imageView.image];
            else                                    barTintColor = barBackgroundColor;
        }
        else if (enabledBarColor && self.tag != 26) {
            barTintColor = barBackgroundColor;
        }
    }
    
    CHSuper(1, UINavigationBar, setBarTintColor, barTintColor);
}

CHDeclareMethod(1, void, UINavigationBar, setTintColor, UIColor*, tintColor)
{
    if (enabled) {
        self.barTintColor = self.barTintColor;
        if (enableNightTheme)
            tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
        else if (enabledBarColor && self.tag != 26)
            tintColor = barForegroundColor;
    }
    
    CHSuper(1, UINavigationBar, setTintColor, tintColor);
}

CHDeclareMethod(1, void, UINavigationBar, setTitleTextAttributes, NSDictionary*, attributes)
{
    NSMutableDictionary *mutableAttributes = [attributes mutableCopy];
    if (!mutableAttributes)
        mutableAttributes = [NSMutableDictionary dictionary];
    
    if (enabled) {
        if (enableNightTheme)
            mutableAttributes[NSForegroundColorAttributeName] = cvkMainController.nightThemeScheme.textColor;
        else if (enabledBarColor && self.tag != 26)
            mutableAttributes[NSForegroundColorAttributeName] = barForegroundColor;
    }
    
    CHSuper(1, UINavigationBar, setTitleTextAttributes, mutableAttributes);
}

CHDeclareMethod(1, void, UINavigationBar, setFrame, CGRect, frame)
{
    CHSuper(1, UINavigationBar, setFrame, frame);
    
    if ([self isKindOfClass:[UINavigationBar class]]) {
        self.tintColor = self.tintColor;
        self.titleTextAttributes = self.titleTextAttributes;
    }
}


#pragma mark VKMController
CHDeclareClass(VKMController);
CHDeclareMethod(0, void, VKMController, VKMNavigationBarUpdate)
{
    CHSuper(0, VKMController, VKMNavigationBarUpdate);
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (enabled) {
        if (!enableNightTheme && enabledBarImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL containsImageView = [navBar._backgroundView.subviews containsObject:[navBar._backgroundView viewWithTag:24]];
                BOOL containsBlur = [navBar._backgroundView.subviews containsObject:[navBar._backgroundView viewWithTag:10]];
                BOOL isAudioController = (changeAudioPlayerAppearance && (navBar.tag == 26));
                
                if (!containsBlur && !containsImageView && !isAudioController) {
                    if (!cvkMainController.navBarImageView) {
                        cvkMainController.navBarImageView = [ColoredVKWallpaperView viewWithFrame:navBar._backgroundView.bounds imageName:@"barImage" blackout:navbarImageBlackout];
                        cvkMainController.navBarImageView.tag = 24;
                        cvkMainController.navBarImageView.backgroundColor = [UIColor clearColor];
                    }
                    [cvkMainController.navBarImageView addToView:navBar._backgroundView animated:NO];
                    
                } else if (containsBlur || isAudioController) [cvkMainController.navBarImageView removeFromSuperview];
            });
        }
        else if (enabledBarColor) {
            [cvkMainController.navBarImageView removeFromSuperview];
        }
    } else [cvkMainController.navBarImageView removeFromSuperview];  
}


CHDeclareClass(UISearchBar);
CHDeclareMethod(0, void, UISearchBar, layoutSubviews)
{
    CHSuper(0, UISearchBar, layoutSubviews);
    
    if ([self.superview isKindOfClass:[UINavigationBar class]]) {
        if (enabled) {
            if (enableNightTheme)
                self.searchBarTextField.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            else if (enabledBarImage)
                self.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
            else if (enabledBarColor)
                self.searchBarTextField.backgroundColor = barBackgroundColor.darkerColor;
        } else {
            self.searchBarTextField.backgroundColor = [UIColor colorWithRed:0.078f green:0.227f blue:0.4f alpha:0.8f];
        }
    }
}


#pragma mark UITextInputTraits
CHDeclareClass(UITextInputTraits);
CHDeclareMethod(0, UIKeyboardAppearance, UITextInputTraits, keyboardAppearance) 
{
    if (enabled) {
        if (enableNightTheme)
            return UIKeyboardAppearanceDark;
        
        if (keyboardStyle != UIKeyboardAppearanceDefault)
            return keyboardStyle;
    }
    
    return CHSuper(0, UITextInputTraits, keyboardAppearance);
}


#pragma mark UISwitch
CHDeclareClass(UISwitch);
CHDeclareMethod(0, void, UISwitch, layoutSubviews)
{
    CHSuper(0, UISwitch, layoutSubviews);
    
    if ([self isKindOfClass:[UISwitch class]]) {
        if (enabled && enableNightTheme) {
            self.tintColor = [UIColor clearColor];
            self.onTintColor = cvkMainController.nightThemeScheme.switchOnTintColor;
            self.thumbTintColor = cvkMainController.nightThemeScheme.switchThumbTintColor;
            self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            self.layer.cornerRadius = 16.0f;
        } else if (enabled && changeSwitchColor) {
            self.tintColor = switchesTintColor;
            self.onTintColor = switchesOnTintColor;
            self.thumbTintColor = nil;
            self.backgroundColor = nil;
        } else {
            self.tintColor = nil;
            self.onTintColor = (self.tag == 228) ? CVKMainColor : nil;
            self.thumbTintColor = nil;
            self.backgroundColor = nil;
        }
    }
}


#pragma mark VKMLiveController 
CHDeclareClass(VKMLiveController);

CHDeclareMethod(0, UIStatusBarStyle, VKMLiveController, preferredStatusBarStyle)
{
    if (enabledGroupsListImage && [self.model.description containsString:@"GroupsSearchModel"])
        return UIStatusBarStyleLightContent;
    
    return CHSuper(0, VKMLiveController, preferredStatusBarStyle);
}

CHDeclareMethod(1, void, VKMLiveController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMLiveController, viewWillAppear, animated);
    
    if (enabled && !enableNightTheme && [self isKindOfClass:NSClassFromString(@"VKMLiveController")]) {
        NSArray <NSString *> *audioModelNames = @[@"AudioRecommendationsModel", @"AudioCatalogPlaylistsListModel", @"AudioCatalogExtendedPlaylistsListModel"];
        if (enabledAudioImage && [audioModelNames containsObject:CLASS_NAME(self.model)]) {
           UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
            if ([search isKindOfClass:[UISearchBar class]] && [search respondsToSelector:@selector(setBackgroundImage:)]) {
                search.backgroundImage = [UIImage new];
                search.tag = 4;
                search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
                NSDictionary *attributes = @{NSForegroundColorAttributeName:changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1 alpha:0.7f]};
                NSString *placeholder = (search.searchBarTextField.placeholder.length > 0) ? search.searchBarTextField.placeholder : @"";
                search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:attributes];
                search._scopeBarBackgroundView.superview.hidden = YES;
            }
        }
        
        if (enabledGroupsListImage && [self.model.description containsString:@"GroupsSearchModel"]) {
            self.tableView.separatorColor = [self.tableView.separatorColor colorWithAlphaComponent:0.2f];
            [ColoredVKMainController setImageToTableView:self.tableView withName:@"groupsListBackgroundImage" blackout:groupsListImageBlackout 
                                          parallaxEffect:useGroupsListParallax blurBackground:groupsListUseBackgroundBlur];
        }
    }
}

CHDeclareMethod(0, void, VKMLiveController, viewWillLayoutSubviews)
{
    CHSuper(0, VKMLiveController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && [self isKindOfClass:NSClassFromString(@"VKMLiveController")]) {
        NSArray <NSString *> *audioModelNames = @[@"AudioRecommendationsModel", @"AudioCatalogPlaylistsListModel", @"AudioCatalogExtendedPlaylistsListModel"];
        if (enabledAudioImage && [audioModelNames containsObject:CLASS_NAME(self.model)]) {
            [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                          parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
            self.tableView.separatorColor = [self.tableView.separatorColor colorWithAlphaComponent:0.2f];
            self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
            setBlur(self.navigationController.navigationBar, audiosUseBlur, audiosBlurTone, audiosBlurStyle);
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, VKMLiveController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMLiveController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && [self isKindOfClass:NSClassFromString(@"VKMLiveController")]) {
        NSArray <NSString *> *audioModelNames = @[@"AudioRecommendationsModel", @"AudioCatalogPlaylistsListModel", @"AudioCatalogExtendedPlaylistsListModel"];
        if (enabledAudioImage && [audioModelNames containsObject:CLASS_NAME(self.model)]) {
            performInitialCellSetup(cell);
            
            cell.textLabel.textColor = changeAudiosTextColor ? audiosTextColor : UITableViewCellTextColor;
            cell.detailTextLabel.textColor = changeAudiosTextColor ? audiosTextColor.darkerColor : UITableViewCellDetailedTextColor;
        }
        
        if (enabledGroupsListImage && [self.model.description containsString:@"GroupsSearchModel"]) {
            GroupCell *groupCell = (GroupCell *)cell;
            
            performInitialCellSetup(groupCell);
            
            UIColor *textColor = changeGroupsListTextColor ? groupsListTextColor : UITableViewCellTextColor;
            groupCell.status.textColor = textColor.darkerColor;
            groupCell.name.textColor = textColor;
            groupCell.status.backgroundColor = [UIColor clearColor];
            groupCell.name.backgroundColor = [UIColor clearColor];
        }
    }
    return cell;
}





#pragma mark VKMTableController
    // Настройка бара навигации
CHDeclareClass(VKMTableController);
CHDeclareMethod(1, void, VKMTableController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMTableController, viewWillAppear, animated);
    BOOL shouldAddBlur = NO;
    UIColor *blurColor = [UIColor clearColor];
    UIBlurEffectStyle blurStyle = 0;
    if (enabled) {
        NSString *selfName = CLASS_NAME(self);
        NSString *modelName = CLASS_NAME(self.model);
        NSArray *audioControllers = @[@"AudioAlbumController", @"AudioAlbumsController", @"AudioPlaylistController", @"AudioDashboardController", 
                                      @"AudioCatalogController", @"AudioCatalogOwnersListController", @"AudioCatalogAudiosListController", 
                                      @"AudioPlaylistDetailController", @"AudioPlaylistsController"];
        NSArray *friendsControllers = @[@"ProfileFriendsController", @"FriendsBDaysController", @"FriendsAllRequestsController"];
        NSArray *settingsExtraControllers = @[@"ProfileBannedController", @"ModernGeneralSettings", @"ModernAccountSettings",
                                              @"SettingsPrivacyController", @"PaymentsBalanceController", @"SubscriptionSettingsViewController", 
                                              @"AboutViewController", @"ModernPushSettingsController", @"VKP2PViewController", 
                                              @"SubscriptionsSettingsViewController"];
        
        if (messagesUseBlur && ([selfName isEqualToString:@"MultiChatController"] || [selfName isEqualToString:@"SingleUserChatController"])) {
            shouldAddBlur = YES;
            blurColor = messagesBlurTone;
            blurStyle = messagesBlurStyle;
        } else if (groupsListUseBlur && ([selfName isEqualToString:@"GroupsController"] || [modelName isEqualToString:@"GroupsSearchModel"])) {
            shouldAddBlur = YES;
            blurColor = groupsListBlurTone;
            blurStyle = groupsListBlurStyle;
        } else if (messagesListUseBlur && [selfName isEqualToString:@"DialogsController"]) {
            shouldAddBlur = YES;
            blurColor = messagesListBlurTone;
            blurStyle = messagesListBlurStyle;
        } else if (audiosUseBlur && [audioControllers containsObject:selfName]) {
            shouldAddBlur = YES;
            blurColor = audiosBlurTone;
            blurStyle = audiosBlurStyle;
        } 
        else if (friendsUseBlur && ([friendsControllers containsObject:selfName] || [modelName isEqualToString:@"ProfileFriendsModel"])) {
            shouldAddBlur = YES;
            blurColor = friendsBlurTone;
            blurStyle = friendsBlurStyle;
        } else if (videosUseBlur && ([selfName isEqualToString:@"VideoAlbumController"] || [modelName isEqualToString:@"VideoAlbumModel"])) {
            shouldAddBlur = YES;
            blurColor = videosBlurTone;
            blurStyle = videosBlurStyle;
        } else if (settingsUseBlur && [selfName isEqualToString:@"ModernSettingsController"]) {
            shouldAddBlur = YES;
            blurColor = settingsBlurTone;
            blurStyle = settingsBlurStyle;
        } else if (settingsExtraUseBlur && [settingsExtraControllers containsObject:selfName]) {
            shouldAddBlur = YES;
            blurColor = settingsExtraBlurTone;
            blurStyle = settingsExtraBlurStyle;
        } else if (menuUseBlur && [selfName isEqualToString:@"MenuViewController"]) {
            shouldAddBlur = YES;
            blurColor = menuBlurTone;
            blurStyle = menuBlurStyle;
        } else shouldAddBlur = NO;
    } else shouldAddBlur = NO;
    
    if (enabled && enableNightTheme) {
        shouldAddBlur = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.tableView.tableHeaderView isKindOfClass:[UISearchBar class]]) {
                UISearchBar *searchBar = (UISearchBar *)self.tableView.tableHeaderView;
                
                searchBar.barTintColor = cvkMainController.nightThemeScheme.foregroundColor;
                searchBar.translucent = NO;
                [searchBar setBackgroundImage:[UIImage imageWithColor:cvkMainController.nightThemeScheme.foregroundColor] 
                               forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
                searchBar.searchBarTextField.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
                searchBar.scopeBarBackgroundImage = [UIImage imageWithColor:cvkMainController.nightThemeScheme.foregroundColor];
            }
        });
    }
    
    resetNavigationBar(self.navigationController.navigationBar);
    setBlur(self.navigationController.navigationBar, shouldAddBlur, blurColor, blurStyle);
    
    resetTabBar();
    if ([cvkMainController.vkMainController isKindOfClass:[UITabBarController class]])
        setBlur(((UITabBarController *)cvkMainController.vkMainController).tabBar, shouldAddBlur, blurColor, blurStyle);
}

#pragma mark VKMToolbarController
    // Настройка тулбара
CHDeclareClass(VKMToolbarController);
CHDeclareMethod(1, void, VKMToolbarController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMToolbarController, viewWillAppear, animated);
    if ([self respondsToSelector:@selector(toolbar)]) {
        setToolBar(self.toolbar);
        if (!enableNightTheme && enabled && enabledToolBarColor) {
            self.segment.tintColor = toolBarForegroundColor;
        }
        
        BOOL shouldAddBlur = NO;
        UIColor *blurColor = [UIColor clearColor];
        UIBlurEffectStyle blurStyle = 0;
        if (enabled) {
            if (groupsListUseBlur && [CLASS_NAME(self) isEqualToString:@"GroupsController"]) {
                shouldAddBlur = YES;
                blurColor = groupsListBlurTone;
                blurStyle = groupsListBlurStyle;
            } else if (friendsUseBlur && [CLASS_NAME(self) isEqualToString:@"ProfileFriendsController"]) {
                shouldAddBlur = YES;
                blurColor = friendsBlurTone;
                blurStyle = friendsBlurStyle;
            } else shouldAddBlur = NO;
        } else shouldAddBlur = NO;
        
        if (enabled && enableNightTheme) {
            shouldAddBlur = NO;
        }
        
        setBlur(self.toolbar, shouldAddBlur, blurColor, blurStyle);
    }
}

#pragma mark NewsFeedController
CHDeclareClass(NewsFeedController);
CHDeclareMethod(0, BOOL, NewsFeedController, VKMTableFullscreenEnabled)
{
    if (enabled && showBar) return NO; 
    return CHSuper(0, NewsFeedController, VKMTableFullscreenEnabled);
}
CHDeclareMethod(0, BOOL, NewsFeedController, VKMScrollViewFullscreenEnabled)
{
    if (enabled && showBar) return NO;
    return CHSuper(0, NewsFeedController, VKMScrollViewFullscreenEnabled);
}


#pragma mark GroupsController - список групп
CHDeclareClass(GroupsController);
CHDeclareMethod(0, void, GroupsController, viewDidLoad)
{
    CHSuper(0, GroupsController, viewDidLoad);
    if ([self isKindOfClass:NSClassFromString(@"GroupsController")]) {
        if (enabled && !enableNightTheme && enabledGroupsListImage) {
            [ColoredVKMainController setImageToTableView:self.tableView withName:@"groupsListBackgroundImage" blackout:groupsListImageBlackout
                                          parallaxEffect:useGroupsListParallax blurBackground:groupsListUseBackgroundBlur];
            self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
            self.tableView.separatorColor = hideGroupsListSeparators ? [UIColor clearColor] : [self.tableView.separatorColor colorWithAlphaComponent:0.2f];
            self.segment.alpha = 0.9f;
            
            UIColor *textColor = changeGroupsListTextColor ? groupsListTextColor : [UIColor colorWithWhite:1.0f alpha:0.7f];
            UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
            if ([search isKindOfClass:NSClassFromString(@"VKSearchBar")]) {
                setupNewSearchBar((VKSearchBar *)search, textColor, groupsListBlurTone, groupsListBlurStyle);
            } else if ([search isKindOfClass:[UISearchBar class]] && [search respondsToSelector:@selector(setBackgroundImage:)]) {
                search.backgroundImage = [UIImage new];
                search.scopeBarBackgroundImage = [UIImage new];
                search.tag = 2;
                search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
                search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder 
                                                                                                  attributes:@{NSForegroundColorAttributeName:textColor}];
            }            
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, GroupsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, GroupsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"GroupsController")] && enabled && !enableNightTheme && enabledGroupsListImage) {
        if ([cell isKindOfClass:NSClassFromString(@"GroupCell")]) {
            GroupCell *groupCell = (GroupCell *)cell;
            performInitialCellSetup(groupCell);
            groupCell.name.textColor = changeGroupsListTextColor?groupsListTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
            groupCell.name.backgroundColor = UITableViewCellBackgroundColor;
            groupCell.status.textColor = changeGroupsListTextColor?groupsListTextColor:[UIColor colorWithWhite:0.8f alpha:0.9f];
            groupCell.status.backgroundColor = UITableViewCellBackgroundColor;
        } else  if ([cell isKindOfClass:NSClassFromString(@"VKMRendererCell")]) {
            performInitialCellSetup(cell);
            
            for (UIView *view in cell.contentView.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)view;
                    label.textColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
                    label.backgroundColor = [UIColor clearColor];
                }
            }
        }
        
    }
    
    return cell;
}



#pragma mark DialogsController - список диалогов
CHDeclareClass(DialogsController);

CHDeclareMethod(0, void, DialogsController, viewDidLoad)
{
    CHSuper(0, DialogsController, viewDidLoad);
    ColoredVKVersionCompare compareResult = [[ColoredVKNewInstaller sharedInstaller].application compareAppVersionWithVersion:@"3.0"];
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")] && (compareResult < 0)) {
        if (enabled && !enableNightTheme && enabledMessagesListImage) {
            [ColoredVKMainController setImageToTableView:self.tableView withName:@"messagesListBackgroundImage" blackout:chatListImageBlackout 
                                          parallaxEffect:useMessagesListParallax blurBackground:messagesListUseBackgroundBlur];
        }
    }
}

CHDeclareMethod(1, void, DialogsController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DialogsController, viewWillAppear, animated);
    if (!enableNightTheme && [self isKindOfClass:NSClassFromString(@"DialogsController")]) {
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if ([search isKindOfClass:[UISearchBar class]]) {
            search.tag = 1;
        }
        
        ColoredVKVersionCompare compareResult = [[ColoredVKNewInstaller sharedInstaller].application compareAppVersionWithVersion:@"3.0"];
        UIColor *placeholderColor = (compareResult >= 0) ? UITableViewCellTextColor : [UIColor colorWithRed:0.556863f green:0.556863f blue:0.576471f alpha:1.0f];
        placeholderColor = (enabled && changeMessagesListTextColor) ? messagesListTextColor : placeholderColor;
        
        if (enabled && enabledMessagesListImage) {
            self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
            self.tableView.separatorColor =  hideMessagesListSeparators ? [UIColor clearColor] : [self.tableView.separatorColor colorWithAlphaComponent:0.2f];
            
            if ([search isKindOfClass:NSClassFromString(@"VKSearchBar")]) {
                setupNewSearchBar((VKSearchBar *)search, placeholderColor, messagesListBlurTone, messagesListBlurStyle);
            } else if ([search isKindOfClass:[UISearchBar class]]) {
                search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
                search.backgroundImage = [UIImage new];
                search._scopeBarBackgroundView.superview.hidden = YES;
            }
            
        } else if (compareResult >= 0) {
            self.rptr.tintColor = nil;
            self.tableView.separatorColor = [UIColor colorWithRed:215/255.0f green:216/255.0f blue:217/255.0f alpha:1.0f];
            if ([search isKindOfClass:NSClassFromString(@"VKSearchBar")]) {
                resetNewSearchBar((VKSearchBar *)search);
            } if ([search isKindOfClass:[UISearchBar class]]) {
                search.searchBarTextField.backgroundColor = nil;
                search._scopeBarBackgroundView.superview.hidden = NO;
                search.backgroundImage = [UIImage imageWithColor:[UIColor colorWithRed:235/255.0f green:237/255.0f blue:240/255.0f alpha:1.0f]];
            } else {
                objc_removeAssociatedObjects(search);
            }
        }
        
        if ([search isKindOfClass:[UISearchBar class]]) {
            NSMutableAttributedString *placeholder = [search.searchBarTextField.attributedPlaceholder mutableCopy];
            [placeholder addAttribute:NSForegroundColorAttributeName value:placeholderColor range:NSMakeRange(0, placeholder.string.length)];
            search.searchBarTextField.attributedPlaceholder = placeholder;
        }
        
        if (compareResult >= 0) {
            if (enabled && !enableNightTheme && enabledMessagesListImage) {
                [ColoredVKMainController setImageToTableView:self.tableView withName:@"messagesListBackgroundImage" blackout:chatListImageBlackout 
                                              parallaxEffect:useMessagesListParallax blurBackground:messagesListUseBackgroundBlur];
                [ColoredVKMainController forceUpdateTableView:self.tableView withBlackout:chatListImageBlackout blurBackground:messagesListUseBackgroundBlur];
             } else
                 self.tableView.backgroundView = nil;
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, DialogsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    NewDialogCell *cell = (NewDialogCell *)CHSuper(2, DialogsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")]) {
        if (enabled && !enableNightTheme && enabledMessagesListImage ) {
            performInitialCellSetup(cell);
            cell.backgroundView.hidden = YES;
            
            if (!cell.dialog.head.read_state && cell.unread.hidden) cell.contentView.backgroundColor = useCustomDialogsUnreadColor?dialogsUnreadColor:[UIColor defaultColorForIdentifier:@"dialogsUnreadColor"];
            else cell.contentView.backgroundColor = [UIColor clearColor];
            
            cell.name.textColor = changeMessagesListTextColor?messagesListTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
            cell.time.textColor = cell.name.textColor;
            cell.attach.textColor = changeMessagesListTextColor?messagesListTextColor:[UIColor colorWithWhite:0.95f alpha:0.9f];
            if ([cell respondsToSelector:@selector(dialogText)]) cell.dialogText.textColor = cell.attach.textColor;
            if ([cell respondsToSelector:@selector(text)]) cell.text.textColor = cell.attach.textColor;
        } else {
            if (!cell.dialog.head.read_state && cell.unread.hidden)
                cell.contentView.backgroundColor = [UIColor colorWithRed:0.92f green:0.94f blue:0.96f alpha:1.0f];
            else
                cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
    return cell;
}

#pragma mark BackgroundView
CHDeclareClass(BackgroundView);
CHDeclareMethod(1, void, BackgroundView, drawRect, CGRect, rect)
{
    if (enabled) {
        self.layer.cornerRadius = self.cornerRadius;
        self.layer.masksToBounds = YES;
        if (enableNightTheme)
            self.layer.backgroundColor = cvkMainController.nightThemeScheme.unreadBackgroundColor.CGColor;
        else if (enabledMessagesListImage)
            self.layer.backgroundColor = useCustomDialogsUnreadColor ? dialogsUnreadColor.CGColor : [UIColor defaultColorForIdentifier:@"messageReadColor"].CGColor;
        else
            CHSuper(1, BackgroundView, drawRect, rect);
    } else CHSuper(1, BackgroundView, drawRect, rect);
}

#pragma mark DetailController + тулбар
CHDeclareClass(DetailController);
CHDeclareMethod(1, void, DetailController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DetailController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"DetailController")]) setToolBar(self.inputPanel);
}


#pragma mark ChatController + тулбар
CHDeclareClass(ChatController);
CHDeclareMethod(1, void, ChatController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, ChatController, viewWillAppear, animated);
    
    if ([self isKindOfClass:NSClassFromString(@"ChatController")]) {
        if ([self respondsToSelector:@selector(root)])
            if ([self.root respondsToSelector:@selector(inputPanelView)])
                if ([self.root.inputPanelView respondsToSelector:@selector(gapToolbar)])
                    [self.root.inputPanelView.gapToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        
        setToolBar(self.inputPanel);
        if (enabled && !enableNightTheme && messagesUseBlur)
            setBlur(self.inputPanel, YES, messagesBlurTone, messagesBlurStyle);
        
        if (enabled) {
            if (enableNightTheme) {
                if ([self.inputPanel respondsToSelector:@selector(pushToTalkCoverView)])
                    self.inputPanel.pushToTalkCoverView.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
            }
            else if (changeMessagesInput) {
                UIButton *inputViewButton = self.inputPanel.inputViewButton;
                [inputViewButton setImage:[[inputViewButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                inputViewButton.imageView.tintColor = messagesInputTextColor;
                
                self.inputPanel.overlay.backgroundColor = messagesInputBackColor;
                self.inputPanel.overlay.layer.borderColor = messagesInputBackColor.CGColor;
                self.inputPanel.textPanel.textColor = messagesInputTextColor;
                self.inputPanel.textPanel.tintColor = messagesInputTextColor;
                self.inputPanel.textPanel.placeholderLabel.textColor = messagesInputTextColor;
            }
        }
        
    }
}


CHDeclareMethod(0, void, ChatController, viewDidLoad)
{
    CHSuper(0, ChatController, viewDidLoad);
    
    if ([self isKindOfClass:NSClassFromString(@"ChatController")]) {
        if (enabled) {
            if (hideMessagesNavBarItems) {
                self.headerImage.hidden = YES;
                self.navigationItem.titleView.hidden = YES;
            }
            if (enabledMessagesImage) {
                self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
                [ColoredVKMainController setImageToTableView:self.tableView withName:@"messagesBackgroundImage" blackout:chatImageBlackout 
                                                        flip:YES parallaxEffect:useMessagesParallax blurBackground:messagesUseBackgroundBlur];
            }
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, ChatController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ChatController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && (enabledMessagesImage || enableNightTheme)) {
        if (!enableNightTheme) {
            for (id view in cell.contentView.subviews) {
                if ([view respondsToSelector:@selector(setTextColor:)])
                    [view setTextColor:changeMessagesTextColor?messagesTextColor:[UIColor colorWithWhite:1.0f alpha:0.7f]];
            }
        }
        if ([CLASS_NAME(cell) isEqualToString:@"UITableViewCell"]) cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

CHDeclareMethod(0, UIButton*, ChatController, editForward)
{
    UIButton *forwardButton = CHSuper(0, ChatController, editForward);
    if (enabled && !enableNightTheme && messagesUseBlur) {
        [forwardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [forwardButton setImage:[[forwardButton imageForState:UIControlStateNormal] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        for (UIView *subview in forwardButton.superview.subviews) {
            if ([subview isKindOfClass:[UIToolbar class]]) {
                setBlur(subview, YES, messagesBlurTone, messagesBlurStyle);
                break;
            }
        }
    }
    return forwardButton;
}



#pragma mark MessageCell
CHDeclareClass(MessageCell);
CHDeclareMethod(1, void, MessageCell, updateBackground, BOOL, animated)
{
    CHSuper(1, MessageCell, updateBackground, animated);
    
    if (enabled && (enabledMessagesImage || enableNightTheme)) {
        self.backgroundView = nil;
        if (!self.message.read_state) {
            if (enableNightTheme)
                self.backgroundColor = cvkMainController.nightThemeScheme.unreadBackgroundColor;
            else
                self.backgroundColor = useCustomMessageReadColor ? messageUnreadColor : [UIColor defaultColorForIdentifier:@"messageReadColor"];
        } else
            self.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark ChatCell
CHDeclareClass(ChatCell);
CHDeclareMethod(0, void, ChatCell, setBG)
{
    self.bg.alpha = 0.f;
    
    CHSuper(0, ChatCell, setBG);
    
    if (enabled && (useMessageBubbleTintColor || enableNightTheme)) {
        void (^bgHandler)(void) = ^(void){
            if (self.bg.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                self.bg.image = [self.bg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            if (enableNightTheme)
                self.bg.tintColor = self.message.incoming ? cvkMainController.nightThemeScheme.incomingBackgroundColor : cvkMainController.nightThemeScheme.outgoingBackgroundColor;
            else 
                self.bg.tintColor = self.message.incoming ? messageBubbleTintColor : messageBubbleSentTintColor;
        };
        
        bgHandler();
        dispatch_async(dispatch_get_main_queue(), bgHandler);
    }
    self.bg.alpha = 1.f;
}



#pragma mark VKMMainController
CHDeclareClass(VKMMainController);
CHDeclareMethod(0, NSArray*, VKMMainController, menu)
{
    NSArray *origMenu = CHSuper(0, VKMMainController, menu);
    
    if (showMenuCell) {
        NSMutableArray *tempArray = [origMenu mutableCopy];
        BOOL shouldInsert = NO;
        NSInteger index = 0;
        for (UITableViewCell *cell in tempArray) {
            if ([cell.textLabel.text isEqualToString:@"VKSettings"]) {
                shouldInsert = YES;
                index = [tempArray indexOfObject:cell];
                break;
            }
        }
        if (shouldInsert) [tempArray insertObject:cvkMainController.menuCell atIndex:index];
        else [tempArray addObject:cvkMainController.menuCell];
        
        origMenu = [tempArray copy];
    }
    
    return origMenu;
}

CHDeclareMethod(0, void, VKMMainController, viewDidLoad)
{
    CHSuper(0, VKMMainController, viewDidLoad);
    if (!cvkMainController.vkMainController)
        cvkMainController.vkMainController = self;
    
    if (![self isKindOfClass:[UITabBarController class]]) {
        if (!cvkMainController.menuBackgroundView) {
            CGRect bounds = [UIScreen mainScreen].bounds;
            CGFloat width = (bounds.size.width > bounds.size.height)?bounds.size.height:bounds.size.width;
            CGFloat height = (bounds.size.width < bounds.size.height)?bounds.size.height:bounds.size.width;
            cvkMainController.menuBackgroundView = [[ColoredVKWallpaperView alloc] initWithFrame:CGRectMake(0, 0, width, height) 
                                                                                       imageName:@"menuBackgroundImage" blackout:menuImageBlackout enableParallax:useMenuParallax blurBackground:menuUseBackgroundBlur];
        }
        
        if (enabled && enabledMenuImage && !enableNightTheme) {
            [cvkMainController.menuBackgroundView addToBack:self.view animated:NO];
            setupUISearchBar((UISearchBar*)self.tableView.tableHeaderView);
            self.tableView.backgroundColor = [UIColor clearColor];
        } else {
            
            UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            self.tableView.backgroundView = backView;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                backView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
            });
        }
    } else {
        setupTabbar();
    }
}

CHDeclareMethod(0, void, VKMMainController, viewWillLayoutSubviews)
{
    CHSuper(0, VKMMainController, viewWillLayoutSubviews);
    
    if (![self isKindOfClass:[UITabBarController class]] && enabled && enableNightTheme) {        
        self.view.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        if ([self.tableView.tableHeaderView isKindOfClass:[UISearchBar class]]) {
            self.tableView.tableHeaderView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, VKMMainController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMMainController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    NSDictionary *identifiers = @{@"customCell" : @228, @"cvkMenuCell": @405};
    if ([identifiers.allKeys containsObject:cell.reuseIdentifier]) {
        UISwitch *switchView = [cell viewWithTag:[identifiers[cell.reuseIdentifier] integerValue]];
        if ([switchView isKindOfClass:[UISwitch class]]) [switchView layoutSubviews];
    }
    
    
    if (enabled && !enableNightTheme)
        tableView.separatorColor = hideMenuSeparators ? [UIColor clearColor] : menuSeparatorColor;    
    else
        tableView.separatorColor = kMenuCellSeparatorColor;
    
    if (enabled && enableNightTheme) {
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    else if (enabled && enabledMenuImage) {
        cell.textLabel.textColor = changeMenuTextColor?menuTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
        cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = changeMenuTextColor?menuTextColor:[UIColor colorWithWhite:1.0f alpha:0.8f];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        UIView *selectedBackView = [UIView new];
        if (menuSelectionStyle == CVKCellSelectionStyleTransparent) selectedBackView.backgroundColor = menuSelectionColor;
        else if (menuSelectionStyle == CVKCellSelectionStyleBlurred) {
            selectedBackView.backgroundColor = [UIColor clearColor];
            if (![selectedBackView.subviews containsObject: [selectedBackView viewWithTag:100] ]) [selectedBackView addSubview:blurForView(selectedBackView, 100)];
            
        } else selectedBackView.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = selectedBackView;
        
        if (VKSettingsEnabled) {
            if ([cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)] && (menuSelectionStyle != CVKCellSelectionStyleNone)) 
                cell.contentView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
        }
        
        if ([cell respondsToSelector:@selector(badge)]) {
            [[cell valueForKeyPath:@"badge"] setTitleColor:changeMenuTextColor?menuTextColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
    } else {
        if ([cell respondsToSelector:@selector(badge)]) {
            [[cell valueForKeyPath:@"badge"] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        cell.imageView.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        cell.backgroundColor = kMenuCellBackgroundColor;
        cell.contentView.backgroundColor = kMenuCellBackgroundColor;
        cell.textLabel.textColor = kMenuCellTextColor;
        if (((indexPath.section == 1) && (indexPath.row == 0)) || 
            (VKSettingsEnabled && [cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)])) {
            cell.backgroundColor = kMenuCellSelectedColor; 
            cell.contentView.backgroundColor = kMenuCellSelectedColor; 
        }
        
        UIView *selectedBackView = [UIView new];
        selectedBackView.backgroundColor = kMenuCellSelectedColor;
        cell.selectedBackgroundView = selectedBackView;
    }
    return cell;
}

CHDeclareMethod(0, id, VKMMainController, VKMTableCreateSearchBar)
{
    if (enabled && hideMenuSearch) return nil;
    return CHSuper(0, VKMMainController, VKMTableCreateSearchBar);
}



#pragma mark MenuViewController
CHDeclareClass(MenuViewController);
CHDeclareMethod(0, void, MenuViewController, viewDidLoad)
{
    CHSuper(0, MenuViewController, viewDidLoad);
    if (!cvkMainController.vkMenuController)
        cvkMainController.vkMenuController = self;
    
    if (!cvkMainController.menuBackgroundView) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        CGFloat width = (bounds.size.width > bounds.size.height)?bounds.size.height:bounds.size.width;
        CGFloat height = (bounds.size.width < bounds.size.height)?bounds.size.height:bounds.size.width;
        cvkMainController.menuBackgroundView = [[ColoredVKWallpaperView alloc] initWithFrame:CGRectMake(0, 0, width, height) 
                                                                                   imageName:@"menuBackgroundImage" blackout:menuImageBlackout enableParallax:useMenuParallax blurBackground:menuUseBackgroundBlur];
    }
    
    if (enabled && enabledMenuImage) {
        [cvkMainController.menuBackgroundView addToBack:self.view animated:NO];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.tag = 24;
    }
}

CHDeclareMethod(2, UITableViewCell*, MenuViewController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, MenuViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && hideMenuSeparators) tableView.separatorColor = [UIColor clearColor]; 
    else if (enabled && !hideMenuSeparators) tableView.separatorColor = menuSeparatorColor; 
    else tableView.separatorColor = [UIColor colorWithRed:215/255.0f green:216/255.0f blue:217/255.0f alpha:1.0f];
    
    if (enabled && enableNightTheme) {
        cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = cvkMainController.nightThemeScheme.buttonColor;
        cell.textLabel.textColor = cvkMainController.nightThemeScheme.textColor;
        cell.contentView.backgroundColor = [UIColor clearColor];
    } else if (enabled && enabledMenuImage) {
        cell.textLabel.textColor = changeMenuTextColor?menuTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
        cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = changeMenuTextColor?menuTextColor:[UIColor colorWithWhite:1.0f alpha:0.8f];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        if ([cell isKindOfClass:NSClassFromString(@"MenuBirthdayCell")]) {
            MenuBirthdayCell *birthdayCell = (MenuBirthdayCell *)cell;
            birthdayCell.name.textColor = cell.textLabel.textColor;
            birthdayCell.status.textColor = cell.textLabel.textColor;
        }
        
        UIView *selectedBackView = [UIView new];
        if (menuSelectionStyle == CVKCellSelectionStyleTransparent) selectedBackView.backgroundColor = menuSelectionColor;
        else if (menuSelectionStyle == CVKCellSelectionStyleBlurred) {
            selectedBackView.backgroundColor = [UIColor clearColor];
            if (![selectedBackView.subviews containsObject: [selectedBackView viewWithTag:100] ]) [selectedBackView addSubview:blurForView(selectedBackView, 100)];
            
        } else selectedBackView.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = selectedBackView;
        
    } else {
        cell.imageView.tintColor = [UIColor colorWithRed:0.667f green:0.682f blue:0.702f alpha:1.0f];
        cell.backgroundColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor blackColor];
        
        cell.selectedBackgroundView = nil;
    }
    
    return cell;
}

CHDeclareMethod(3, void, MenuViewController, tableView, UITableView *, tableView, willDisplayHeaderView, UIView *, view, forSection, NSInteger, section)
{
    CHSuper(3, MenuViewController, tableView, tableView, willDisplayHeaderView, view, forSection, section);
    if ((enabled && !enableNightTheme && enabledMenuImage) && [view isKindOfClass:NSClassFromString(@"TablePrimaryHeaderView")]) {
        ((TablePrimaryHeaderView*)view).separator.alpha = 0.3f;
    }
}

CHDeclareMethod(0, NSArray*, MenuViewController, menu)
{
    NSArray *origMenu = CHSuper(0, MenuViewController, menu);
    
    if (showMenuCell) {
        NSMutableArray *tempArray = [origMenu mutableCopy];
        [tempArray addObject:cvkMainController.menuCell];
        
        origMenu = [tempArray copy];
    }
    
    return origMenu;
}





#pragma mark  HintsSearchDisplayController
CHDeclareClass(HintsSearchDisplayController);
CHDeclareMethod(1, void, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch, UISearchDisplayController*, controller)
{
    if (enabled && !enableNightTheme && enabledMenuImage) resetUISearchBar(controller.searchBar);
    CHSuper(1, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch, controller);
}

CHDeclareMethod(1, void, HintsSearchDisplayController, searchDisplayControllerDidEndSearch, UISearchDisplayController*, controller)
{
    if (enabled && !enableNightTheme && enabledMenuImage) setupUISearchBar(controller.searchBar);
    CHSuper(1, HintsSearchDisplayController, searchDisplayControllerDidEndSearch, controller);
}



#pragma mark - AUDIO

#pragma mark IOS7AudioController
CHDeclareClass(IOS7AudioController);
CHDeclareMethod(0, UIStatusBarStyle, IOS7AudioController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"IOS7AudioController")] && enabled && (enabledBarColor || changeAudioPlayerAppearance || enableNightTheme)) 
        return UIStatusBarStyleLightContent;
    else return CHSuper(0, IOS7AudioController, preferredStatusBarStyle);
}

CHDeclareMethod(0, void, IOS7AudioController, viewWillLayoutSubviews)
{
    CHSuper(0, IOS7AudioController, viewWillLayoutSubviews);
    
    if ([self isKindOfClass:NSClassFromString(@"IOS7AudioController")] && enabled && changeAudioPlayerAppearance) {
        if (!cvkMainController.audioCover) {
            cvkMainController.audioCover = [[ColoredVKAudioCover alloc] init];
            [cvkMainController.audioCover updateCoverForArtist:self.actor.text title:self.song.text];
        }
        [cvkMainController.audioCover updateViewFrame:self.view.bounds andSeparationPoint:self.hostView.frame.origin];
        [cvkMainController.audioCover addToView:self.view];
    }
}

CHDeclareMethod(0, void, IOS7AudioController, viewDidLoad)
{
    CHSuper(0, IOS7AudioController, viewDidLoad);
    
    
    if ([self isKindOfClass:NSClassFromString(@"IOS7AudioController")] && enabled) {
        if (enableNightTheme) {
            self.view.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            self.cover.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            self.hostView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
            [self.pp setImage:[[self.pp imageForState:UIControlStateSelected] imageWithTintColor:cvkMainController.nightThemeScheme.buttonColor] forState:UIControlStateSelected];
            setupAudioPlayer(self.hostView, cvkMainController.nightThemeScheme.buttonColor);
        }
        if (changeAudioPlayerAppearance) {
            if (!cvkMainController.audioCover) {
                cvkMainController.audioCover = [[ColoredVKAudioCover alloc] init];
                [cvkMainController.audioCover updateCoverForArtist:self.actor.text title:self.song.text];
            }
            [cvkMainController.audioCover updateViewFrame:self.view.bounds andSeparationPoint:self.hostView.frame.origin];
            [cvkMainController.audioCover addToView:self.view];
            
            audioPlayerTintColor = cvkMainController.audioCover.color;
            
            UINavigationBar *navBar = self.navigationController.navigationBar;
            navBar.tag = 26;
            navBar.topItem.titleView.hidden = YES;
            navBar.shadowImage = [UIImage new];
            [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            navBar.tintColor = [UIColor whiteColor];
            
            if (enablePlayerGestures) {
                navBar.topItem.leftBarButtonItems = @[];
                navBar.topItem.rightBarButtonItems = @[];
                self.navigationController.navigationBar.hidden = YES;
                
                [self.view addGestureRecognizer:[cvkMainController swipeForPlayerWithDirection:UISwipeGestureRecognizerDirectionDown 
                                                                                       handler:^{
                                                                                           if ([self respondsToSelector:@selector(done:)]) {
                                                                                               [self done:nil];
                                                                                           }
                                                                                       }]];
                
                [self.view addGestureRecognizer:[cvkMainController swipeForPlayerWithDirection:UISwipeGestureRecognizerDirectionLeft 
                                                                                       handler:^{
                                                                                           if ([self respondsToSelector:@selector(actionNext:)]) {
                                                                                               [self actionNext:nil];
                                                                                           }
                                                                                       }]];
                
                [self.view addGestureRecognizer:[cvkMainController swipeForPlayerWithDirection:UISwipeGestureRecognizerDirectionRight 
                                                                                       handler:^{
                                                                                           if ([self respondsToSelector:@selector(actionPrev:)]) {
                                                                                               [self actionPrev:nil];
                                                                                           }
                                                                                       }]];
                
                [self.view addGestureRecognizer:[cvkMainController swipeForPlayerWithDirection:UISwipeGestureRecognizerDirectionUp
                                                                                       handler:^{
                                                                                           if ([self respondsToSelector:@selector(actionPlaylist:)]) {
                                                                                               [self actionPlaylist:nil];
                                                                                           }
                                                                                       }]];
            }
            
            setupAudioPlayer(self.hostView, audioPlayerTintColor);
            self.cover.hidden = YES;
            self.hostView.backgroundColor = [UIColor clearColor];
            [self.pp setImage:[[self.pp imageForState:UIControlStateSelected] imageWithTintColor:audioPlayerTintColor] forState:UIControlStateSelected];
            
            cvkMainController.audioCover.updateCompletionBlock = ^(ColoredVKAudioCover *cover) {
                audioPlayerTintColor = cvkMainController.audioCover.color;
                [self.pp setImage:[[self.pp imageForState:UIControlStateSelected] imageWithTintColor:audioPlayerTintColor] forState:UIControlStateSelected];
                setupAudioPlayer(self.hostView, audioPlayerTintColor);
            };
        }
    }
}

#pragma mark AudioPlayer
CHDeclareClass(AudioPlayer);
CHDeclareMethod(2, void, AudioPlayer, switchTo, int, arg1, force, BOOL, force)
{
    CHSuper(2, AudioPlayer, switchTo, arg1, force, force);
    if (enabled && changeAudioPlayerAppearance) {
        if (!cvkMainController.audioCover)
            cvkMainController.audioCover = [[ColoredVKAudioCover alloc] init];
        
        if (self.state == 1)
            [cvkMainController.audioCover updateCoverForArtist:self.audio.performer title:self.audio.title];
    }
}

#pragma mark VKAudioQueuePlayer
CHDeclareClass(VKAudioQueuePlayer);
CHDeclareMethod(1, void, VKAudioQueuePlayer, switchTo, int, arg1)
{
    CHSuper(1, VKAudioQueuePlayer, switchTo, arg1);
    if (enabled && changeAudioPlayerAppearance) {
        if (!cvkMainController.audioCover)
            cvkMainController.audioCover = [[ColoredVKAudioCover alloc] init];
        
        if (self.state == 1)
            [cvkMainController.audioCover updateCoverForArtist:self.performer title:self.title];
    }
}



#pragma mark AudioAlbumController
CHDeclareClass(AudioAlbumController);
CHDeclareMethod(0, void, AudioAlbumController, viewDidLoad)
{
    CHSuper(0, AudioAlbumController, viewDidLoad);
    
    if (enabled && !enableNightTheme && enabledAudioImage && ([self isKindOfClass:NSClassFromString(@"AudioAlbumController")] || [self isKindOfClass:NSClassFromString(@"AudioAlbumsController")])) {
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if ([search isKindOfClass:[UISearchBar class]] && [search respondsToSelector:@selector(setBackgroundImage:)]) {
            search.backgroundImage = [UIImage new];
            search.tag = 3;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
            NSDictionary *attributes = @{NSForegroundColorAttributeName: changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1.0f alpha:0.7f]};
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder attributes:attributes];
            search._scopeBarBackgroundView.superview.hidden = YES;
        }
    }
}
CHDeclareMethod(0, void, AudioAlbumController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioAlbumController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && ([self isKindOfClass:NSClassFromString(@"AudioAlbumController")] || [self isKindOfClass:NSClassFromString(@"AudioAlbumsController")])) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor =  hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioAlbumController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioAlbumController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && ([self isKindOfClass:NSClassFromString(@"AudioAlbumController")] || [self isKindOfClass:NSClassFromString(@"AudioAlbumsController")])) {
        performInitialCellSetup(cell);
            
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:0.8f alpha:0.9f];
    }
    
    return cell;
}


#pragma mark AudioPlaylistController
CHDeclareClass(AudioPlaylistController);
CHDeclareMethod(0, UIStatusBarStyle, AudioPlaylistController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"AudioPlaylistController")] && enabled && (enabledBarColor || enabledAudioImage || enableNightTheme))
        return UIStatusBarStyleLightContent;
    else return CHSuper(0, AudioPlaylistController, preferredStatusBarStyle);
}
CHDeclareMethod(1, void, AudioPlaylistController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, AudioPlaylistController, viewWillAppear, animated);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioPlaylistController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioPlaylistController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioPlaylistController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioPlaylistController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:0.8f alpha:0.9f];
    }
    
    return cell;
}

#pragma mark AudioRenderer
CHDeclareClass(AudioRenderer);
CHDeclareMethod(0, UIButton*, AudioRenderer, playIndicator)
{
    UIButton *indicator = CHSuper(0, AudioRenderer, playIndicator);
    if (enabled && !enableNightTheme && enabledAudioImage) {
        [indicator setImage:[[indicator imageForState:UIControlStateNormal] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [indicator setImage:[[indicator imageForState:UIControlStateSelected] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateSelected];
    }
    return indicator;
}



/*
 AudioDashboardController - рутовый контроллер музыки пользователя, начиная с VK App 2.13
 */
#pragma mark AudioDashboardController
CHDeclareClass(AudioDashboardController);
CHDeclareMethod(0, void, AudioDashboardController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioDashboardController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioDashboardController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioDashboardController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioDashboardController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioDashboardController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
    }
    
    return cell;
}

#pragma mark AudioCatalogController
CHDeclareClass(AudioCatalogController);
CHDeclareMethod(0, void, AudioCatalogController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioCatalogController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioCatalogController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
}


CHDeclareMethod(2, UITableViewCell*, AudioCatalogController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioCatalogController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioCatalogController")]) {
        performInitialCellSetup(cell);
        
        void (^setupBlock)(UIView *view) = ^(UIView *view){
            if ([view isKindOfClass:NSClassFromString(@"AudioBlockCellHeaderView")]) {
                AudioBlockCellHeaderView *headerView = (AudioBlockCellHeaderView *)view;
                headerView.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
                headerView.subtitleLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
                [headerView.showAllButton setTitleColor:changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor forState:UIControlStateNormal];
            } else if ([view isKindOfClass:NSClassFromString(@"BlockCellHeaderView")]) {
                BlockCellHeaderView *headerView = (BlockCellHeaderView *)view;
                headerView.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
                headerView.subtitleLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
                [headerView.actionButton setTitleColor:changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor forState:UIControlStateNormal];
            }
        };
        
        if ([cell respondsToSelector:@selector(headerView)]) {
            setupBlock([cell valueForKey:@"headerView"]);
        } else {
            for (UIView *subview in cell.contentView.subviews) {
                setupBlock(subview);
            }
        }
    }
    
    return cell;
}

#pragma mark AudioCatalogOwnersListController
CHDeclareClass(AudioCatalogOwnersListController);
CHDeclareMethod(0, void, AudioCatalogOwnersListController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioCatalogOwnersListController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioCatalogOwnersListController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioCatalogOwnersListController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioCatalogOwnersListController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioCatalogOwnersListController")]) {
        performInitialCellSetup(cell);
        
        if ([cell isKindOfClass:NSClassFromString(@"GroupCell")]) {
            GroupCell *groupCell = (GroupCell *)cell;
            groupCell.name.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            groupCell.name.backgroundColor = UITableViewCellBackgroundColor;
            groupCell.status.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
            groupCell.status.backgroundColor = UITableViewCellBackgroundColor;
        }
        else if ([cell isKindOfClass:NSClassFromString(@"SourceCell")]) {
            SourceCell *sourceCell = (SourceCell *)cell;
            sourceCell.first.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            sourceCell.first.backgroundColor = UITableViewCellBackgroundColor;
            sourceCell.last.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
            sourceCell.last.backgroundColor = UITableViewCellBackgroundColor;
        }
    }
    
    return cell;
}


#pragma mark AudioCatalogAudiosListController
CHDeclareClass(AudioCatalogAudiosListController);
CHDeclareMethod(0, void, AudioCatalogAudiosListController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioCatalogAudiosListController, viewWillLayoutSubviews);
    
    if (enabled  && !enableNightTheme&& enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioCatalogAudiosListController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioCatalogAudiosListController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioCatalogAudiosListController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioCatalogAudiosListController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
    }
    
    return cell;
}



#pragma mark AudioPlaylistDetailController
CHDeclareClass(AudioPlaylistDetailController);
CHDeclareMethod(0, void, AudioPlaylistDetailController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioPlaylistDetailController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioPlaylistDetailController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioPlaylistDetailController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioPlaylistDetailController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioPlaylistDetailController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
    }
    
    return cell;
}

#pragma mark AudioPlaylistsController
CHDeclareClass(AudioPlaylistsController);
CHDeclareMethod(0, void, AudioPlaylistsController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioPlaylistsController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioPlaylistsController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if ([search isKindOfClass:[UISearchBar class]] && !enableNightTheme) {
            search.backgroundImage = [UIImage new];
            search.tag = 3;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
            NSDictionary *attributes = @{NSForegroundColorAttributeName: changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1.0f alpha:0.7f]};
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder attributes:attributes];
            search._scopeBarBackgroundView.superview.hidden = YES;
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioPlaylistsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioPlaylistsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioPlaylistsController")]) {
        performInitialCellSetup(cell);
    }
    
    return cell;
}

#pragma mark VKAudioPlayerListTableViewController
CHDeclareClass(VKAudioPlayerListTableViewController);
CHDeclareMethod(0, UIStatusBarStyle, VKAudioPlayerListTableViewController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"VKAudioPlayerListTableViewController")] && enabled && (enabledBarColor || enableNightTheme))
        return UIStatusBarStyleLightContent;
    else return CHSuper(0, VKAudioPlayerListTableViewController, preferredStatusBarStyle);
}

CHDeclareMethod(0, void, VKAudioPlayerListTableViewController, viewDidLoad)
{
    CHSuper(0, VKAudioPlayerListTableViewController, viewDidLoad);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"VKAudioPlayerListTableViewController")]) {
        self.navigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    }
}

CHDeclareMethod(0, void, VKAudioPlayerListTableViewController, viewWillLayoutSubviews)
{
    CHSuper(0, VKAudioPlayerListTableViewController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"VKAudioPlayerListTableViewController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
    }
}

CHDeclareMethod(2, UITableViewCell*, VKAudioPlayerListTableViewController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKAudioPlayerListTableViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"VKAudioPlayerListTableViewController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
    }
    
    return cell;
}




#pragma mark AudioAudiosBlockTableCell
CHDeclareClass(AudioAudiosBlockTableCell);
CHDeclareMethod(0, void, AudioAudiosBlockTableCell, layoutSubviews)
{
    CHSuper(0, AudioAudiosBlockTableCell, layoutSubviews);
    
    if (enabled && (enabledAudioImage || enableNightTheme) && [self isKindOfClass:NSClassFromString(@"AudioAudiosBlockTableCell")]) {
        performInitialCellSetup(self);
        if (enableNightTheme) {
            self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        } else {
            self.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            self.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
        }
        
    }
}

#pragma mark AudioPlaylistInlineCell
CHDeclareClass(AudioPlaylistInlineCell);
CHDeclareMethod(0, void, AudioPlaylistInlineCell, layoutSubviews)
{
    CHSuper(0, AudioPlaylistInlineCell, layoutSubviews);
    
    if (enabled && enabledAudioImage && !enableNightTheme && [self isKindOfClass:NSClassFromString(@"AudioPlaylistInlineCell")]) {
        self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        self.subtitleLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
    }
}

#pragma mark AudioOwnersBlockItemCollectionCell
CHDeclareClass(AudioOwnersBlockItemCollectionCell);
CHDeclareMethod(0, void, AudioOwnersBlockItemCollectionCell, layoutSubviews)
{
    CHSuper(0, AudioOwnersBlockItemCollectionCell, layoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioOwnersBlockItemCollectionCell")]) {
        self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
    }
}


#pragma mark AudioPlaylistCell
CHDeclareClass(AudioPlaylistCell);
CHDeclareMethod(0, void, AudioPlaylistCell, layoutSubviews)
{
    CHSuper(0, AudioPlaylistCell, layoutSubviews);
    
    if (enabled && (enabledAudioImage || enableNightTheme) && [self isKindOfClass:NSClassFromString(@"AudioPlaylistCell")]) {
        performInitialCellSetup(self);
        if (!enableNightTheme) {
            self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            self.artistLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            self.subtitleLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
        }
   }
}


#pragma mark AudioPlaylistsCell
CHDeclareClass(AudioPlaylistsCell);
CHDeclareMethod(0, void, AudioPlaylistsCell, layoutSubviews)
{
    CHSuper(0, AudioPlaylistsCell, layoutSubviews);
    
    if (enabled && (enabledAudioImage || enableNightTheme) && [self isKindOfClass:NSClassFromString(@"AudioPlaylistsCell")]) {
        performInitialCellSetup(self);
        if (enableNightTheme) {
            self.hostedView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        }
        else if (enabledAudioImage) {
            self.hostedView.backgroundColor = [UIColor clearColor];
            self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            [self.showAllButton setTitleColor:changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor forState:UIControlStateNormal];
        }
    }
}

#pragma mark AudioAudiosSpecialBlockView
CHDeclareClass(AudioAudiosSpecialBlockView);
CHDeclareMethod(0, void, AudioAudiosSpecialBlockView, layoutSubviews)
{
    CHSuper(0, AudioAudiosSpecialBlockView, layoutSubviews);
    
    if (enabled && (enabledAudioImage || enableNightTheme) && [self isKindOfClass:NSClassFromString(@"AudioAudiosSpecialBlockView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        if (!enableNightTheme) {
            self.backgroundColor = [UIColor clearColor];
            self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            self.subtitleLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
        }
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"GradientView")]) {
                subview.hidden = YES;
                break;
            }
        }

    }
}

#pragma mark AudioPlaylistView
CHDeclareClass(AudioPlaylistView);
CHDeclareMethod(0, void, AudioPlaylistView, layoutSubviews)
{
    CHSuper(0, AudioPlaylistView, layoutSubviews);
    
    if (enabled && enableNightTheme) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
    else if (enabled && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioPlaylistView")]) {
        self.backgroundColor = [UIColor clearColor];
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)subview;
                label.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            } else if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                [button setTitleColor:changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor forState:UIControlStateNormal];
                
            }
        }
        
    }
}

#pragma mark -





#pragma mark PhotoBrowserController
CHDeclareClass(PhotoBrowserController);
CHDeclareMethod(1, void, PhotoBrowserController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, PhotoBrowserController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"PhotoBrowserController")]) {
        if (showFastDownloadButton) {
            ColoredVKBarDownloadButton *saveButton = [ColoredVKBarDownloadButton button];
            __weak typeof(self) weakSelf = self;
            saveButton.urlBlock = ^NSString*() {
                NSString *imageSource = @"";
                int indexOfPage = (int)(weakSelf.paging.contentOffset.x / weakSelf.paging.frame.size.width);
                VKPhotoSized *photo = [weakSelf photoForPage:indexOfPage];
                if (photo.variants != nil) {
                    int maxVariantIndex = 0;
                    for (VKImageVariant *variant in photo.variants.allValues) {
                        if (variant.type > maxVariantIndex) {
                            maxVariantIndex = variant.type;
                            imageSource = variant.src;
                        }
                    }
                }
                return imageSource;
            };
            saveButton.rootViewController = self;
            NSMutableArray *buttons = [self.navigationItem.rightBarButtonItems mutableCopy];
            if (buttons.count < 2) [buttons addObject:saveButton];
            self.navigationItem.rightBarButtonItems = [buttons copy];
        }
    }
}



#pragma mark VKMBrowserController
CHDeclareClass(VKMBrowserController);

CHDeclareMethod(0, UIStatusBarStyle, VKMBrowserController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"VKMBrowserController")] && enabled && (enabledBarColor || enableNightTheme))
        return UIStatusBarStyleLightContent;
    else return CHSuper(0, VKMBrowserController, preferredStatusBarStyle);
}

CHDeclareMethod(0, void, VKMBrowserController, viewDidLoad)
{
    CHSuper(0, VKMBrowserController, viewDidLoad);
    if ([self isKindOfClass:NSClassFromString(@"VKMBrowserController")] && showFastDownloadButton) {
        self.navigationItem.rightBarButtonItem = [ColoredVKBarDownloadButton buttonWithURL:self.target.url.absoluteString rootController:self];
    }
}

CHDeclareMethod(1, void, VKMBrowserController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMBrowserController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"VKMBrowserController")]) {
        setupTranslucence(self.toolbar, cvkMainController.nightThemeScheme.navbackgroundColor, !(enabled && enableNightTheme));
        
        if (enabled && enableNightTheme) {
            self.webScrollView.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            self.webView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
            [self.safariButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        else if (enabled && enabledBarColor && !enableNightTheme) {
            self.headerTitle.textColor = barForegroundColor;
        }
        resetNavigationBar(self.navigationController.navigationBar);
        resetTabBar();
    }
}

CHDeclareMethod(1, void, VKMBrowserController, webViewDidFinishLoad, UIWebView *, webView)
{
    CHSuper(1, VKMBrowserController, webViewDidFinishLoad, webView);
    hideFastButtonForController(self);
}

CHDeclareMethod(2, void, VKMBrowserController, webView, UIWebView *, webView, didFailLoadWithError, NSError *, error)
{
    CHSuper(2, VKMBrowserController, webView, webView, didFailLoadWithError, error);
    hideFastButtonForController(self);
}


#pragma mark UserWallController
CHDeclareClass(UserWallController);
CHDeclareMethod(0, void, UserWallController, updateProfile)
{
    CHSuper(0, UserWallController, updateProfile);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.profile.item) {
            NSDictionary <NSString *, NSString *> *users = @{@"89911723": @"DeveloperNavIcon", @"125879328": @"id125879328_NavIcon"};
            NSString *stringID = [NSString stringWithFormat:@"%@", self.profile.item.user.uid];
            
            if (users[stringID]) {
                CGRect navBarFrame = self.navigationController.navigationBar.bounds;
                UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                titleView.center = CGPointMake(CGRectGetMidX(navBarFrame), CGRectGetMidY(navBarFrame));
                titleView.image = [UIImage imageNamed:users[stringID] inBundle:cvkBunlde compatibleWithTraitCollection:nil];
                if ([stringID isEqualToString:@"89911723"]) {
                    titleView.image = [titleView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    titleView.tintColor = enableNightTheme ? cvkMainController.nightThemeScheme.textColor : barForegroundColor;
                }
                [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    titleView.alpha = 0.0f;
                    self.navigationItem.titleView = titleView;
                    titleView.alpha = 1.0f;
                } completion:nil];
            }
        }
    });
}



#pragma mark VKMLiveSearchController
CHDeclareClass(VKMLiveSearchController);
CHDeclareMethod(1, void, VKMLiveSearchController, searchDisplayControllerWillBeginSearch, UISearchDisplayController*, controller)
{
    CHSuper(1, VKMLiveSearchController, searchDisplayControllerWillBeginSearch, controller);
    setupSearchController(controller, NO);
}

CHDeclareMethod(1, void, VKMLiveSearchController, searchDisplayControllerWillEndSearch, UISearchDisplayController*, controller)
{
    setupSearchController(controller, YES);
    CHSuper(1, VKMLiveSearchController, searchDisplayControllerWillEndSearch, controller);
}

CHDeclareMethod(2, UITableViewCell*, VKMLiveSearchController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMLiveSearchController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    setupCellForSearchController(cell, self);    
    return cell;
}

#pragma mark DialogsSearchController
CHDeclareClass(DialogsSearchController);
CHDeclareMethod(1, void, DialogsSearchController, searchDisplayControllerWillBeginSearch, UISearchDisplayController*, controller)
{
    CHSuper(1, DialogsSearchController, searchDisplayControllerWillBeginSearch, controller);
    setupSearchController(controller, NO);
    if (enabled && !enableNightTheme && enabledMessagesImage)
        controller.searchResultsTableView.separatorColor = [controller.searchResultsTableView.separatorColor colorWithAlphaComponent:0.2f];
}

CHDeclareMethod(1, void, DialogsSearchController, searchDisplayControllerWillEndSearch, UISearchDisplayController*, controller)
{
    setupSearchController(controller, YES);
    CHSuper(1, DialogsSearchController, searchDisplayControllerWillEndSearch, controller);
}

CHDeclareMethod(2, UITableViewCell*, DialogsSearchController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, DialogsSearchController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    setupCellForSearchController(cell, self);
    return cell;
}


void setupNewDialogsSearchController(DialogsSearchResultsController *controller)
{
    if (![controller respondsToSelector:@selector(tableView)])
        return;
    
    if (enabled && !enableNightTheme && enabledMessagesListImage) {
        if ([controller.parentViewController isKindOfClass:NSClassFromString(@"DialogsController")]) {
            DialogsController *dialogsController = (DialogsController *)controller.parentViewController;
            if ([dialogsController.tableView.backgroundView isKindOfClass:[ColoredVKWallpaperView class]]) {
                controller.tableView.backgroundView = [dialogsController.tableView.backgroundView copy];
                controller.tableView.separatorColor = dialogsController.tableView.separatorColor;
            }
        }
    }
}


CHDeclareClass(DialogsSearchResultsController);

//CHDeclareMethod(0, UIStatusBarStyle, DialogsController, preferredStatusBarStyle)
//{
//    if (enabled && !enableNightTheme && enabledMessagesListImage)
//        return UIStatusBarStyleLightContent;
//    
//    return CHSuper(0, DialogsController, preferredStatusBarStyle);
//}

CHDeclareMethod(1, void, DialogsSearchResultsController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DialogsSearchResultsController, viewWillAppear, animated);
    
    setupNewDialogsSearchController(self);
}

CHDeclareMethod(2, UITableViewCell*, DialogsSearchResultsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, DialogsSearchResultsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledMessagesListImage) {
        performInitialCellSetup (cell);
        cell.backgroundView.hidden = YES;
        UIColor *textColor = changeMessagesListTextColor ? messagesListTextColor : UITableViewCellTextColor;
        UIColor *detailedTextColor = changeMessagesListTextColor ? messagesListTextColor : UITableViewCellTextColor;
        
        if ([cell isKindOfClass:NSClassFromString(@"SourceCell")]) {
            SourceCell *sourceCell = (SourceCell *)cell;
            sourceCell.last.textColor = detailedTextColor;
            sourceCell.last.backgroundColor = [UIColor clearColor];
            sourceCell.first.textColor =  textColor;
            sourceCell.first.backgroundColor = [UIColor clearColor];
        }
        else if ([cell isKindOfClass:NSClassFromString(@"NewDialogCell")]) {
            NewDialogCell *dialogCell = (NewDialogCell *)cell;
            dialogCell.name.textColor = textColor;
            dialogCell.name.backgroundColor = [UIColor clearColor];
            dialogCell.time.textColor = textColor;
            dialogCell.time.backgroundColor = [UIColor clearColor];
            if ([dialogCell respondsToSelector:@selector(dialogText)]) {
                dialogCell.dialogText.textColor = detailedTextColor;
                dialogCell.dialogText.backgroundColor = [UIColor clearColor];
            }
        }
    }
    return cell;
}

#pragma mark -
#pragma mark VKSettings
#pragma mark -

#pragma mark PSListController
CHDeclareClass(PSListController);

CHDeclareMethod(1, void, PSListController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, PSListController, viewWillAppear, animated);
    resetNavigationBar(self.navigationController.navigationBar);
    resetTabBar();
}

CHDeclareMethod(0, UIStatusBarStyle, PSListController, preferredStatusBarStyle)
{
    return UIStatusBarStyleLightContent;
}

#pragma mark SelectAccountTableViewController
@interface SelectAccountTableViewController : UITableViewController @end
CHDeclareClass(SelectAccountTableViewController);
CHDeclareMethod(1, void, SelectAccountTableViewController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, SelectAccountTableViewController, viewWillAppear, animated);
    resetNavigationBar(self.navigationController.navigationBar);
    resetTabBar();
}

#pragma mark vksprefsListController
@interface vksprefsListController : PSListController @end
CHDeclareClass(vksprefsListController);
CHDeclareMethod(2, UITableViewCell *, vksprefsListController, tableView, UITableView *, tableView, cellForRowAtIndexPath, NSIndexPath *, indexPath)
{
    UITableViewCell * cell = CHSuper(2, vksprefsListController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
        cell.accessoryView.tag = 404;
    }
    
    return cell;
}



#pragma mark - MessageController
CHDeclareClass(MessageController);
CHDeclareMethod(1, void, MessageController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, MessageController, viewWillAppear, animated);
    resetNavigationBar(self.navigationController.navigationBar);
    resetTabBar();
}



#pragma mark VKComment
CHDeclareClass(VKComment);
CHDeclareMethod(0, BOOL, VKComment, separatorDisabled)
{
    if (enabled) return showCommentSeparators;
    return CHSuper(0, VKComment, separatorDisabled);
}



#pragma mark ProfileCoverInfo
CHDeclareClass(ProfileCoverInfo);
CHDeclareMethod(0, BOOL, ProfileCoverInfo, enabled)
{
    if (enabled && disableGroupCovers) return NO;
    return CHSuper(0, ProfileCoverInfo, enabled);
}



#pragma mark ProfileCoverImageView
CHDeclareClass(ProfileCoverImageView);
CHDeclareMethod(0, UIView *, ProfileCoverImageView, overlayView)
{
    UIView *overlayView = CHSuper(0, ProfileCoverImageView, overlayView);
    if (enabled) {
        if (enableNightTheme) {
            overlayView.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        }
        else if (enabledBarImage) {
            if (![overlayView.subviews containsObject:[overlayView viewWithTag:23]]) {
                ColoredVKWallpaperView *overlayImageView  = [ColoredVKWallpaperView viewWithFrame:overlayView.bounds imageName:@"barImage" blackout:navbarImageBlackout];
                [overlayView addSubview:overlayImageView];
            }
        }
        else if (enabledBarColor) {
            overlayView.backgroundColor = barBackgroundColor;
            if ([overlayView.subviews containsObject:[overlayView viewWithTag:23]]) [[overlayView viewWithTag:23] removeFromSuperview];
        }
    }
    
    return overlayView;
}


#pragma mark PostEditController
CHDeclareClass(PostEditController);
CHDeclareMethod(0, UIStatusBarStyle, PostEditController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"PostEditController")] && enabled && (enabledBarColor || enableNightTheme))
        return UIStatusBarStyleLightContent;
    return CHSuper(0, PostEditController, preferredStatusBarStyle);
}

CHDeclareMethod(0, void, PostEditController, viewDidLoad)
{
    CHSuper(0, PostEditController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

#pragma mark ProfileInfoEditController
CHDeclareClass(ProfileInfoEditController);
CHDeclareMethod(0, UIStatusBarStyle, ProfileInfoEditController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"ProfileInfoEditController")] && enabled && (enabledBarColor || enableNightTheme))
        return UIStatusBarStyleLightContent;
    return CHSuper(0, ProfileInfoEditController, preferredStatusBarStyle);
}

#pragma mark OptionSelectionController
CHDeclareClass(OptionSelectionController);
CHDeclareMethod(0, UIStatusBarStyle, OptionSelectionController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"OptionSelectionController")] && enabled && (enabledBarColor || enableNightTheme))
        return UIStatusBarStyleLightContent;
    return CHSuper(0, OptionSelectionController, preferredStatusBarStyle);
}

CHDeclareMethod(1, void, OptionSelectionController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, OptionSelectionController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"OptionSelectionController")]) {
        resetNavigationBar(self.navigationController.navigationBar);
        resetTabBar();
    }
}

#pragma mark VKRegionSelectionViewController
CHDeclareClass(VKRegionSelectionViewController);
CHDeclareMethod(0, UIStatusBarStyle, VKRegionSelectionViewController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"VKRegionSelectionViewController")] && enabled && (enabledBarColor || enableNightTheme))
        return UIStatusBarStyleLightContent;
    return CHSuper(0, VKRegionSelectionViewController, preferredStatusBarStyle);
}



#pragma mark ProfileFriendsController
CHDeclareClass(ProfileFriendsController);
CHDeclareMethod(0, void, ProfileFriendsController, viewWillLayoutSubviews)
{
    CHSuper(0, ProfileFriendsController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledFriendsImage && [self isKindOfClass:NSClassFromString(@"ProfileFriendsController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"friendsBackgroundImage" blackout:friendsImageBlackout 
                                      parallaxEffect:useFriendsParallax blurBackground:friendsUseBackgroundBlur];
        self.tableView.separatorColor = hideFriendsSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.tableView.sectionIndexColor = UITableViewCellTextColor;
        self.tableView.tag = 22;
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        
        UIColor *textColor = changeFriendsTextColor?friendsTextColor:[UIColor colorWithWhite:1.0f alpha:0.7f];
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if ([search isKindOfClass:NSClassFromString(@"VKSearchBar")]) {
            setupNewSearchBar((VKSearchBar *)search, textColor, friendsBlurTone, friendsBlurStyle);
        } else if ([search isKindOfClass:[UISearchBar class]] && [search respondsToSelector:@selector(setBackgroundImage:)]) {
            search.backgroundImage = [UIImage new];
            search.tag = 6;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder
                                                                                              attributes:@{NSForegroundColorAttributeName:textColor}];
            search._scopeBarBackgroundView.superview.hidden = YES;
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, ProfileFriendsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ProfileFriendsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledFriendsImage && [self isKindOfClass:NSClassFromString(@"ProfileFriendsController")]) {
        performInitialCellSetup(cell);
            
        if ([cell isKindOfClass:NSClassFromString(@"SourceCell")]) {
            SourceCell *sourceCell = (SourceCell *)cell;
            sourceCell.last.textColor = changeFriendsTextColor?friendsTextColor:UITableViewCellTextColor;
            sourceCell.last.backgroundColor = UITableViewCellBackgroundColor;
            sourceCell.first.textColor = changeFriendsTextColor?friendsTextColor:UITableViewCellTextColor;
            sourceCell.first.backgroundColor = UITableViewCellBackgroundColor;
        } else {
            cell.textLabel.textColor = changeFriendsTextColor?friendsTextColor:UITableViewCellTextColor;
        }
    }
    
    return cell;
}


#pragma mark FriendsBDaysController
CHDeclareClass(FriendsBDaysController);
CHDeclareMethod(0, void, FriendsBDaysController, viewWillLayoutSubviews)
{
    CHSuper(0, FriendsBDaysController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledFriendsImage && [self isKindOfClass:NSClassFromString(@"FriendsBDaysController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"friendsBackgroundImage" blackout:friendsImageBlackout 
                                      parallaxEffect:useFriendsParallax blurBackground:friendsUseBackgroundBlur];
        self.tableView.separatorColor = hideFriendsSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.tableView.tag = 22;
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
}

CHDeclareMethod(2, UITableViewCell*, FriendsBDaysController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, FriendsBDaysController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledFriendsImage && [self isKindOfClass:NSClassFromString(@"FriendsBDaysController")]) {
        performInitialCellSetup(cell);
        
        FriendBdayCell *sourceCell = (FriendBdayCell *)cell;
        sourceCell.name.textColor = changeFriendsTextColor?friendsTextColor:UITableViewCellTextColor;
        sourceCell.name.backgroundColor = UITableViewCellBackgroundColor;
        sourceCell.status.textColor = changeFriendsTextColor?friendsTextColor.darkerColor:UITableViewCellDetailedTextColor;
        sourceCell.status.backgroundColor = UITableViewCellBackgroundColor;
    }
    
    return cell;
}


#pragma mark FriendsAllRequestsController
CHDeclareClass(FriendsAllRequestsController);
CHDeclareMethod(1, void, FriendsAllRequestsController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, FriendsAllRequestsController, viewWillAppear, animated);
    
    if (enabled && !enableNightTheme && enabledFriendsImage && [self isKindOfClass:NSClassFromString(@"FriendsAllRequestsController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"friendsBackgroundImage" blackout:friendsImageBlackout 
                                      parallaxEffect:useFriendsParallax blurBackground:friendsUseBackgroundBlur];
        self.tableView.separatorColor = hideFriendsSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        if ([self respondsToSelector:@selector(toolbar)])
            setBlur(self.toolbar, friendsUseBlur, friendsBlurTone, friendsBlurStyle);
    }
}

CHDeclareMethod(2, UITableViewCell*, FriendsAllRequestsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, FriendsAllRequestsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledFriendsImage && [self isKindOfClass:NSClassFromString(@"FriendsAllRequestsController")]) {
        performInitialCellSetup(cell);
        
        for (UIView *view in cell.contentView.subviews) {
            view.backgroundColor = [UIColor clearColor];
            if ([view isKindOfClass:[UILabel class]]) ((UILabel*)view).textColor = changeFriendsTextColor?friendsTextColor:UITableViewCellTextColor;
        }
    }
    
    return cell;
}




#pragma mark VideoAlbumController
CHDeclareClass(VideoAlbumController);
CHDeclareMethod(0, void, VideoAlbumController, viewWillLayoutSubviews)
{
    CHSuper(0, VideoAlbumController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledVideosImage && [self isKindOfClass:NSClassFromString(@"VideoAlbumController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"videosBackgroundImage" blackout:videosImageBlackout 
                                      parallaxEffect:useVideosParallax blurBackground:videosUseBackgroundBlur];
        self.tableView.separatorColor = hideVideosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        setBlur(self.toolbar, YES, videosBlurTone, videosBlurStyle);
        
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        UIColor *textColor =  changeVideosTextColor ? videosTextColor : [UIColor colorWithWhite:1.0f alpha:0.7f];
        
        if ([search isKindOfClass:NSClassFromString(@"VKSearchBar")]) {
            setupNewSearchBar((VKSearchBar *)search, textColor, videosBlurTone, videosBlurStyle);
        } else if ([search isKindOfClass:[UISearchBar class]] && [search respondsToSelector:@selector(setBackgroundImage:)]) {
            search.backgroundImage = [UIImage new];
            search.tag = 6;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder 
                                                                                              attributes:@{NSForegroundColorAttributeName:textColor}];
            search._scopeBarBackgroundView.superview.hidden = YES;
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, VideoAlbumController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VideoAlbumController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledVideosImage && [self isKindOfClass:NSClassFromString(@"VideoAlbumController")]) {
        performInitialCellSetup(cell);
        
        if ([cell isKindOfClass:NSClassFromString(@"VideoCell")]) {
            VideoCell *videoCell = (VideoCell *)cell;
            videoCell.videoTitleLabel.textColor = changeVideosTextColor?videosTextColor:UITableViewCellTextColor;
            videoCell.videoTitleLabel.backgroundColor = UITableViewCellBackgroundColor;
            videoCell.authorLabel.textColor = changeVideosTextColor?videosTextColor.darkerColor:UITableViewCellDetailedTextColor;
            videoCell.authorLabel.backgroundColor = UITableViewCellBackgroundColor;
            videoCell.viewCountLabel.textColor = changeVideosTextColor?videosTextColor.darkerColor:UITableViewCellDetailedTextColor;
            videoCell.viewCountLabel.backgroundColor = UITableViewCellBackgroundColor;
        }
        
    }
    
    return cell;
}




#pragma mark UITableView
CHDeclareClass(UITableView);
CHDeclareMethod(6, UITableViewHeaderFooterView*, UITableView, _sectionHeaderView, BOOL, arg1, withFrame, CGRect, frame, forSection, NSInteger, section, floating, BOOL, floating, reuseViewIfPossible, BOOL, reuse, willDisplay, BOOL, display)
{
    UITableViewHeaderFooterView *view = CHSuper(6, UITableView, _sectionHeaderView, arg1, withFrame, frame, forSection, section, floating, floating, reuseViewIfPossible, reuse, willDisplay, display);
    
    if (enabled)
        setupHeaderFooterView(view, self);
    
    return view;
}

CHDeclareMethod(1, void, UITableView, setBackgroundView, UIView*, backgroundView)
{
    if (enabled && enableNightTheme) {
        if (!backgroundView)
            backgroundView = [UIView new];
        objc_setAssociatedObject(self, "backgroundViewCachedColor", backgroundView.backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        backgroundView.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
    if ([self.backgroundView isKindOfClass:[ColoredVKWallpaperView class]] && [backgroundView isKindOfClass:NSClassFromString(@"TeaserView")]) {
        TeaserView *teaserView = (TeaserView *)backgroundView;
        teaserView.labelTitle.textColor = UITableViewCellTextColor;
        teaserView.labelText.textColor = UITableViewCellTextColor;
        [self.backgroundView addSubview:teaserView];
        
        teaserView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":teaserView}]];
        [self.backgroundView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":teaserView}]];
    } else {
        CHSuper(1, UITableView, setBackgroundView, backgroundView);
    }
}

CHDeclareMethod(2, void, UITableView, _configureCellForDisplay, UITableViewCell *, cell, forIndexPath, NSIndexPath *, indexPath)
{
    CHSuper(2, UITableView, _configureCellForDisplay, cell, forIndexPath, indexPath);
    
    if (enabled && enableNightTheme) {
        UIView *selectedView = [UIView new];
        selectedView.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        
        cell.selectedBackgroundView = selectedView;
    }
}

CHDeclareMethod(0, void, UITableView, layoutSubviews)
{
    CHSuper(0, UITableView, layoutSubviews);
    
    self.backgroundColor = self.backgroundColor;
    self.separatorColor = self.separatorColor;
    
    if (enabled) {
        if ([self.tableFooterView isKindOfClass:NSClassFromString(@"LoadingFooterView")] && [self.backgroundView isKindOfClass:[ColoredVKWallpaperView class]]) {
            LoadingFooterView *footerView = (LoadingFooterView *)self.tableFooterView;
            footerView.label.textColor = UITableViewCellTextColor;
            footerView.anim.color = UITableViewCellTextColor;
        }
    }
}

CHDeclareMethod(1, void, UITableView, setSeparatorColor, UIColor *, separatorColor)
{
    if (![separatorColor isEqual:cvkMainController.nightThemeScheme.backgroundColor])
        objc_setAssociatedObject(self, "cachedSeparatorColor", [separatorColor copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (enabled && enableNightTheme)
        separatorColor = cvkMainController.nightThemeScheme.backgroundColor;
    else
        separatorColor = objc_getAssociatedObject(self, "cachedSeparatorColor");
    
    CHSuper(1, UITableView, setSeparatorColor, separatorColor);
}

CHDeclareMethod(1, void, UITableView, setBackgroundColor, UIColor *, backgroundColor)
{
    if (![backgroundColor isEqual:cvkMainController.nightThemeScheme.backgroundColor])
        objc_setAssociatedObject(self, "cachedBackgroundColor", [backgroundColor copy], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (enabled && enableNightTheme)
        backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    else {
        self.backgroundView.backgroundColor = objc_getAssociatedObject(self, "backgroundViewCachedColor");
        backgroundColor = objc_getAssociatedObject(self, "cachedBackgroundColor");
    }
    
    CHSuper(1, UITableView, setBackgroundColor, backgroundColor);
}


#pragma mark - UIAlertController
CHDeclareClass(UIAlertController);
CHDeclareMethod(0, void, UIAlertController, viewDidLoad)
{
    setupPopoverPresentation(self);
    CHSuper(0, UIAlertController, viewDidLoad);
}

#pragma mark - UIActivityViewController
CHDeclareClass(UIActivityViewController);
CHDeclareMethod(0, void, UIActivityViewController, viewDidLoad)
{
    setupPopoverPresentation(self);
    CHSuper(0, UIActivityViewController, viewDidLoad);
}




#pragma mark - ModernSettingsController

CHDeclareClass(ModernSettingsController);
CHDeclareMethod(2, NSInteger, ModernSettingsController, tableView, UITableView *, tableView, numberOfRowsInSection, NSInteger, section)
{
    NSInteger rowsCount = CHSuper(2, ModernSettingsController, tableView, tableView, numberOfRowsInSection, section);
    if (section == 1) {
        rowsCount++;
    }
    return rowsCount;
        
}

CHDeclareMethod(2, UITableViewCell*, ModernSettingsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ModernSettingsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (!cell) {
        cell = cvkMainController.settingsCell;
        cell.backgroundColor = (enabled && enableNightTheme) ? cvkMainController.nightThemeScheme.foregroundColor : [UIColor whiteColor];
        cell.textLabel.textColor = (enabled && enableNightTheme) ? cvkMainController.nightThemeScheme.textColor : [UIColor blackColor];
        cell.imageView.tintColor = kVKMainColor;
        
        ColoredVKVersionCompare compareResult = [[ColoredVKNewInstaller sharedInstaller].application compareAppVersionWithVersion:@"3.0"];
        if (compareResult >= 0)
            cell.imageView.tintColor = [UIColor colorWithRed:0.667f green:0.682f blue:0.702f alpha:1.0f];
    }
    
    return cell;
}

CHDeclareMethod(3, void, ModernSettingsController, tableView, UITableView*, tableView, willDisplayCell, UITableViewCell *, cell, forRowAtIndexPath, NSIndexPath*, indexPath)
{
    CHSuper(3, ModernSettingsController, tableView, tableView, willDisplayCell, cell, forRowAtIndexPath, indexPath);
    
    if ([self isKindOfClass:NSClassFromString(@"ModernSettingsController")]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([cell.textLabel.text.lowercaseString isEqualToString:@"vksettings"]) {
                cell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
            }
            
            if (enabled && !enableNightTheme && enabledSettingsImage) {
                performInitialCellSetup(cell);
                cell.textLabel.textColor = changeSettingsTextColor ? settingsTextColor : UITableViewCellTextColor;
                cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.imageView.tintColor = cell.textLabel.textColor;
            }
        });
    }
}

CHDeclareMethod(2, void, ModernSettingsController, tableView, UITableView*, tableView, didSelectRowAtIndexPath, NSIndexPath*, indexPath)
{
    CHSuper(2, ModernSettingsController, tableView, tableView, didSelectRowAtIndexPath, indexPath);
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.reuseIdentifier isEqualToString:cvkMainController.settingsCell.reuseIdentifier]) {
        [cvkMainController actionOpenPreferencesPush:YES];
    }
}

CHDeclareMethod(0, void, ModernSettingsController, viewWillLayoutSubviews)
{
    CHSuper(0, ModernSettingsController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledSettingsImage && [self isKindOfClass:NSClassFromString(@"ModernSettingsController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"settingsBackgroundImage" blackout:settingsImageBlackout 
                                      parallaxEffect:useSettingsParallax blurBackground:settingsUseBackgroundBlur];
        
        if (hideSettingsSeparators) 
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        else
            self.tableView.separatorColor = [self.tableView.separatorColor colorWithAlphaComponent:0.5f];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIColor *textColor = changeSettingsTextColor ? settingsTextColor : UITableViewCellTextColor;
            for (UIView *subview in self.tableView.tableHeaderView.subviews) {
                if ([subview respondsToSelector:@selector(setTextColor:)]) {
                    UILabel *label = (UILabel *)subview;
                    label.textColor = textColor;
                }
                if ([subview respondsToSelector:@selector(setTitleColor:forState:)]) {
                    UIButton *button = (UIButton *)subview;
                    [button setTitleColor:textColor forState:button.state];
                }
            }
        });
    }
}


CHDeclareClass(BaseSectionedSettingsController);
CHDeclareMethod(0, void, BaseSectionedSettingsController, viewWillLayoutSubviews)
{
    CHSuper(0, BaseSectionedSettingsController, viewWillLayoutSubviews);
    NSArray <Class> *settingsExtraClasses = @[NSClassFromString(@"ModernGeneralSettings"), NSClassFromString(@"ModernAccountSettings"), NSClassFromString(@"AboutViewController")];
    if ([settingsExtraClasses containsObject:[self class]])
         setupExtraSettingsController(self);
}

CHDeclareMethod(2, UITableViewCell*, BaseSectionedSettingsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, BaseSectionedSettingsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    NSArray <Class> *settingsExtraClasses = @[NSClassFromString(@"ModernGeneralSettings"), NSClassFromString(@"ModernAccountSettings"), NSClassFromString(@"AboutViewController")];
    if ([settingsExtraClasses containsObject:[self class]])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark ProfileBannedController
CHDeclareClass(ProfileBannedController);
CHDeclareMethod(0, void, ProfileBannedController, viewWillLayoutSubviews)
{
    CHSuper(0, ProfileBannedController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"ProfileBannedController")])
        setupExtraSettingsController(self);
}

CHDeclareMethod(2, UITableViewCell*, ProfileBannedController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ProfileBannedController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"ProfileBannedController")])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark SettingsPrivacyController
CHDeclareClass(SettingsPrivacyController);
CHDeclareMethod(0, void, SettingsPrivacyController, viewWillLayoutSubviews)
{
    CHSuper(0, SettingsPrivacyController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"SettingsPrivacyController")])
        setupExtraSettingsController(self);
}

CHDeclareMethod(2, UITableViewCell*, SettingsPrivacyController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, SettingsPrivacyController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"SettingsPrivacyController")])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark PaymentsBalanceController
CHDeclareClass(PaymentsBalanceController);
CHDeclareMethod(0, void, PaymentsBalanceController, viewWillLayoutSubviews)
{
    CHSuper(0, PaymentsBalanceController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"PaymentsBalanceController")])
        setupExtraSettingsController(self);
}

CHDeclareMethod(2, UITableViewCell*, PaymentsBalanceController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, PaymentsBalanceController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"PaymentsBalanceController")])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark SubscriptionsSettingsViewController
CHDeclareClass(SubscriptionsSettingsViewController);
CHDeclareMethod(0, void, SubscriptionsSettingsViewController, viewWillLayoutSubviews)
{
    CHSuper(0, SubscriptionsSettingsViewController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"SubscriptionsSettingsViewController")])
        setupExtraSettingsController(self);
}

CHDeclareMethod(2, UITableViewCell*, SubscriptionsSettingsViewController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, SubscriptionsSettingsViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"SubscriptionsSettingsViewController")])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark ModernPushSettingsController
CHDeclareClass(ModernPushSettingsController);
CHDeclareMethod(0, void, ModernPushSettingsController, viewWillLayoutSubviews)
{
    CHSuper(0, ModernPushSettingsController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"ModernPushSettingsController")])
        setupExtraSettingsController(self);
}

CHDeclareMethod(2, UITableViewCell*, ModernPushSettingsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ModernPushSettingsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"ModernPushSettingsController")])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark VKP2PViewController
CHDeclareClass(VKP2PViewController);
CHDeclareMethod(0, void, VKP2PViewController, viewWillLayoutSubviews)
{
    CHSuper(0, VKP2PViewController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"VKP2PViewController")])
        setupExtraSettingsController(self);
}

CHDeclareMethod(2, UITableViewCell*, VKP2PViewController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKP2PViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"VKP2PViewController")])
        setupExtraSettingsCell(cell);
    return cell;
}

CHDeclareClass(DiscoverFeedController);
CHDeclareMethod(1, void, DiscoverFeedController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DiscoverFeedController, viewWillAppear, animated);
    
    if ([self isKindOfClass:NSClassFromString(@"DiscoverFeedController")]) {
        resetTabBar();
        
        if ([self respondsToSelector:@selector(topGradientBackgroundView)]) {
            self.topGradientBackgroundView.hidden = (enabled && enableNightTheme);
        }
    }
}


CHDeclareClass(VKSearchBar);
CHDeclareMethod(2, void, VKSearchBar, setActive, BOOL, active, animated, BOOL, animated)
{
    CHSuper(2, VKSearchBar, setActive, active, animated, animated);
    NSNumber *customized = objc_getAssociatedObject(self, "cvk_customized");
    if (!customized)
        customized = @NO;
    
    if (!enableNightTheme) {
        if (enabled && customized.boolValue) {
            if (active) {
                UIColor *blurColor = objc_getAssociatedObject(self, "cvk_blurColor");            
                NSNumber *blurStyle = objc_getAssociatedObject(self, "cvk_blurStyle");
                if (!blurStyle)
                    blurStyle = @(UIBlurEffectStyleLight);
                setBlur(self.backgroundView, YES, blurColor, blurStyle.integerValue);
            } else {
                setBlur(self.backgroundView, NO, nil, 0);
            }
        } else {
            resetNewSearchBar(self);
        }
    }
}

CHDeclareMethod(0, void, VKSearchBar, layoutSubviews)
{
    CHSuper(0, VKSearchBar, layoutSubviews);
    
    NSNumber *customized = objc_getAssociatedObject(self, "cvk_customized");
    if (!customized)
        customized = @NO;
    
    void (^changeBlock)(void) = ^(void){
        if (enabled && enableNightTheme) {
            if ([self.superview isKindOfClass:NSClassFromString(@"DiscoverFeedTitleView")] || [self.superview isKindOfClass:[UINavigationBar class]]) {
                self.backgroundView.backgroundColor = [UIColor clearColor];
                self.textFieldBackground.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
            } else {
                self.backgroundView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
                self.textFieldBackground.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
            }
            
            objc_setAssociatedObject(self.placeholderLabel, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
            self.placeholderLabel.textColor = cvkMainController.nightThemeScheme.detailTextColor;
            
            self.segmentedControl.layer.borderColor = cvkMainController.nightThemeScheme.buttonSelectedColor.CGColor;
        } else if (!customized.boolValue || !enabled) {
            resetNewSearchBar(self);
        }
    };
    changeBlock();
    dispatch_async(dispatch_get_main_queue(), changeBlock);
}

CHDeclareClass(VKSession);
CHDeclareMethod(2, id, VKSession, initWithUserId, NSNumber *, userID, andToken, id, token)
{
    [ColoredVKNewInstaller sharedInstaller].vkUserID = userID;
    
    return CHSuper(2, VKSession, initWithUserId, userID, andToken, token);
}


//UIFont *customFontForSize(CGFloat fontSize, BOOL bold)
//{
//    if (enabled && customFontName && ![customFontName isEqualToString:@".SFUIText"]) {
//        NSString *fontName = customFontName;
//        if (bold)
//            fontName = [fontName stringByAppendingString:@"-Bold"];
//        
//        CTFontDescriptorRef fontDescriptor = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)@{(id)kCTFontFamilyNameAttribute:fontName});
//        CTFontRef fontRef = CTFontCreateWithFontDescriptor(fontDescriptor, fontSize, nil);
//        
//        UIFont *font = [UIFont fontWithName:(__bridge_transfer NSString *)CTFontCopyPostScriptName(fontRef) size:fontSize];
//        CFRelease(fontRef);
//        CFRelease(fontDescriptor);
//        
//        return font;
//    }
//    
//    return nil;
//}
//
//CHDeclareClass(UIFont);
//CHDeclareClassMethod(1, UIFont *, UIFont, systemFontOfSize, CGFloat, fontSize)
//{
//    UIFont *customFont = customFontForSize(fontSize, NO);
//    if (customFont)
//        return customFont;
//    
//    return CHSuper(1, UIFont, systemFontOfSize, fontSize);
//}
//
//CHDeclareClassMethod(1, UIFont *, UIFont, boldSystemFontOfSize, CGFloat, fontSize)
//{
//    UIFont *customFont = customFontForSize(fontSize, YES);
//    if (customFont)
//        return customFont;
//    
//    return CHSuper(1, UIFont, boldSystemFontOfSize, fontSize);
//}



CHConstructor
{
    
    @autoreleasepool {
        
        
//        dlopen([[NSBundle mainBundle] pathForResource:@"FLEXDylib" ofType:@"dylib"].UTF8String, RTLD_NOW);
        
        cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        vksBundle = [NSBundle bundleWithPath:VKS_BUNDLE_PATH];
        cvkMainController = [ColoredVKMainController new];
        cvkMainController.nightThemeScheme = [ColoredVKNightThemeColorScheme sharedScheme];
        
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
        if (![[NSFileManager defaultManager] fileExistsAtPath:CVK_PREFS_PATH]) 
            prefs = [NSMutableDictionary new];
        prefs[@"vkVersion"] = [ColoredVKNewInstaller sharedInstaller].application.detailedVersion;
        [prefs writeToFile:CVK_PREFS_PATH atomically:YES];
        VKSettingsEnabled = (NSClassFromString(@"VKSettings") != nil);
        
        CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterAddObserver(center, nil, reloadPrefsNotify,  CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(center, nil, reloadMenuNotify,   CFSTR("com.daniilpashin.coloredvk2.reload.menu"),   nil, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(center, nil, updateCornerRadius, CFSTR("com.daniilpashin.coloredvk2.update.corners"),nil, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(center, nil, updateNightTheme,   CFSTR("com.daniilpashin.coloredvk2.night.theme"),   nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}
