//
//  Tweak.m
//  ColoredVK
//
//  Created by Даниил on 21.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/


#import "CaptainHook/CaptainHook.h"

#import "ColoredVKNewInstaller.h"
#import "PrefixHeader.h"
#import "ColoredVKMainController.h"
#import "Tweak.h"
#import "ColoredVKBarDownloadButton.h"
#import "ColoredVKAlertController.h"
#import "ColoredVKUpdatesController.h"
#import <dlfcn.h>
#import "Preferences.h"
#import "ColoredVKPrefs.h"
#import "ColoredVKHeaderView.h"



BOOL tweakEnabled = NO;
BOOL VKSettingsEnabled;

BOOL enableNightTheme;

BOOL showFastDownloadButton;
BOOL showMenuCell;

NSString *prefsPath;
NSString *cvkFolder;
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

ColoredVKMainController *cvkMainController;


void resetUISearchBar(UISearchBar *searchBar);



#pragma mark Static methods
void reloadPrefs()
{
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:prefsPath];
    
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
            if (enabled && changeSBColors) {
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
    menuSelectionColor =        [[UIColor savedColorForIdentifier:@"menuSelectionColor"         fromPrefs:prefs] colorWithAlphaComponent:0.3];
    barBackgroundColor =         [UIColor savedColorForIdentifier:@"BarBackgroundColor"         fromPrefs:prefs];
    toolBarBackgroundColor =     [UIColor savedColorForIdentifier:@"ToolBarBackgroundColor"     fromPrefs:prefs];
    toolBarForegroundColor =     [UIColor savedColorForIdentifier:@"ToolBarForegroundColor"     fromPrefs:prefs];
    messageBubbleTintColor =     [UIColor savedColorForIdentifier:@"messageBubbleTintColor"     fromPrefs:prefs];
    messageBubbleSentTintColor = [UIColor savedColorForIdentifier:@"messageBubbleSentTintColor" fromPrefs:prefs];
    menuTextColor =              [UIColor savedColorForIdentifier:@"menuTextColor"              fromPrefs:prefs];
    messagesTextColor =          [UIColor savedColorForIdentifier:@"messagesTextColor"          fromPrefs:prefs];
    messagesBlurTone =          [[UIColor savedColorForIdentifier:@"messagesBlurTone"           fromPrefs:prefs] colorWithAlphaComponent:0.3];
    menuBlurTone =              [[UIColor savedColorForIdentifier:@"menuBlurTone"               fromPrefs:prefs] colorWithAlphaComponent:0.3];
    tabbarBackgroundColor =     [UIColor savedColorForIdentifier:@"TabbarBackgroundColor"       fromPrefs:prefs];
    tabbarForegroundColor =     [UIColor savedColorForIdentifier:@"TabbarForegroundColor"       fromPrefs:prefs];
    tabbarSelForegroundColor =  [UIColor savedColorForIdentifier:@"TabbarSelForegroundColor"    fromPrefs:prefs];
    messagesInputTextColor =    [UIColor savedColorForIdentifier:@"messagesInputTextColor"      fromPrefs:prefs];
    messagesInputBackColor =    [UIColor savedColorForIdentifier:@"messagesInputBackColor"      fromPrefs:prefs];
    dialogsUnreadColor =        [[UIColor savedColorForIdentifier:@"dialogsUnreadColor"         fromPrefs:prefs] colorWithAlphaComponent:0.3];
    messageUnreadColor =        [[UIColor savedColorForIdentifier:@"messageReadColor"           fromPrefs:prefs] colorWithAlphaComponent:0.2];
    
    if (!hideMenuSeparators && !prefs[@"MenuSeparatorColor"] && [cvkMainController compareAppVersionWithVersion:@"3.0"] == ColoredVKVersionCompareMore) {
        menuSeparatorColor  = [UIColor colorWithRed:215/255.0f green:216/255.0f blue:217/255.0 alpha:1.0f];
    }
    
    showFastDownloadButton = prefs[@"showFastDownloadButton"] ? [prefs[@"showFastDownloadButton"] boolValue] : YES;
    showMenuCell = prefs[@"showMenuCell"] ? [prefs[@"showMenuCell"] boolValue] : YES;
    
    if (prefs && tweakEnabled) {
        
        enableNightTheme = prefs[@"nightThemeType"] ? ([prefs[@"nightThemeType"] integerValue] != -1) : NO;
        [cvkMainController.nightThemeScheme updateForType:[prefs[@"nightThemeType"] integerValue]];
        
        if (enableNightTheme && ([cvkMainController compareAppVersionWithVersion:@"3.0"] == ColoredVKVersionCompareLess)) {
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
        
        messagesListBlurTone =      [[UIColor savedColorForIdentifier:@"messagesListBlurTone"       fromPrefs:prefs] colorWithAlphaComponent:0.3];
        groupsListBlurTone =        [[UIColor savedColorForIdentifier:@"groupsListBlurTone"         fromPrefs:prefs] colorWithAlphaComponent:0.3];
        audiosBlurTone =            [[UIColor savedColorForIdentifier:@"audiosBlurTone"             fromPrefs:prefs] colorWithAlphaComponent:0.3];
        friendsBlurTone =           [[UIColor savedColorForIdentifier:@"friendsBlurTone"            fromPrefs:prefs] colorWithAlphaComponent:0.3];
        videosBlurTone =            [[UIColor savedColorForIdentifier:@"videosBlurTone"             fromPrefs:prefs] colorWithAlphaComponent:0.3];
        settingsBlurTone =          [[UIColor savedColorForIdentifier:@"settingsBlurTone"           fromPrefs:prefs] colorWithAlphaComponent:0.3];
        settingsExtraBlurTone =     [[UIColor savedColorForIdentifier:@"settingsExtraBlurTone"      fromPrefs:prefs] colorWithAlphaComponent:0.3];
        
    }
    
    if (cvkMainController.navBarImageView)
        [cvkMainController.navBarImageView updateViewWithBlackout:navbarImageBlackout];
}


void showAlertWithMessage(NSString *message)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:@"ColoredVK 2" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
        [alertController present];
    });
}


void setBlur(UIView *bar, BOOL set, UIColor *color, UIBlurEffectStyle style)
{
    if (UIAccessibilityIsReduceTransparencyEnabled())
        return;
    
    if (set) {
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blurEffectView.tag = 10;
        blurEffectView.backgroundColor = color;
        
        UIView *borderView = [UIView new];
        borderView.backgroundColor = [UIColor whiteColor];
        borderView.alpha = 0.15;
        [blurEffectView.contentView addSubview:borderView];
        
        NSString *verticalFormat = @"";
        if ([bar isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navbar = (UINavigationBar *)bar;
            UIView *backgroundView = navbar._backgroundView;
            verticalFormat = @"V:[view(0.5)]|";
            
            if (![backgroundView.subviews containsObject:[backgroundView viewWithTag:10]]) {
                [navbar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
                navbar.shadowImage = [UIImage new];
                
                blurEffectView.frame = backgroundView.bounds;
                borderView.frame = CGRectMake(0, blurEffectView.frame.size.height - 0.5, blurEffectView.frame.size.width, 0.5);
                
                [backgroundView addSubview:blurEffectView];
                [backgroundView sendSubviewToBack:blurEffectView];
                
            }
        } 
        else if  ([bar isKindOfClass:[UIToolbar class]]) {
            UIToolbar *toolBar = (UIToolbar *)bar;
            verticalFormat = @"V:|[view(0.5)]";
            
            if (![toolBar.subviews containsObject:[toolBar viewWithTag:10]]) {
                toolBar.barTintColor = [UIColor clearColor];
                blurEffectView.frame = CGRectMake(0, 0, toolBar.frame.size.width, toolBar.frame.size.height);
                borderView.frame = CGRectMake(0, 0, toolBar.frame.size.width, 0.5);
                
                [toolBar addSubview:blurEffectView];
                [toolBar sendSubviewToBack:blurEffectView];
                [toolBar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
            }
        } else if  ([bar isKindOfClass:[UITabBar class]]) {
            UITabBar *tabbar = (UITabBar *)bar;
            verticalFormat = @"V:|[view(0.5)]";
            
            if (![tabbar.subviews containsObject:[tabbar viewWithTag:10]]) {
                blurEffectView.frame = CGRectMake(0, 0, tabbar.frame.size.width, tabbar.frame.size.height);
                borderView.frame = CGRectMake(0, 0, tabbar.frame.size.width, 0.5);
                
                [tabbar addSubview:blurEffectView];
                [tabbar sendSubviewToBack:blurEffectView];
                tabbar.backgroundImage = [UIImage new];
            }
        }
        
        if (verticalFormat.length > 2) {
            borderView.translatesAutoresizingMaskIntoConstraints = NO;
            [blurEffectView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalFormat options:0 metrics:nil views:@{@"view":borderView}]];
            [blurEffectView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"  options:0 metrics:nil views:@{@"view":borderView}]];
        }
    } else {
        if ([bar isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navbar = (UINavigationBar *)bar;
            UIView *backgroundView = navbar._backgroundView;
            if ([backgroundView.subviews containsObject:[backgroundView viewWithTag:10]]) {
                [[backgroundView viewWithTag:10] removeFromSuperview];
                [navbar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            }
        } else if  ([bar isKindOfClass:[UIToolbar class]]) {
            UIToolbar *toolBar = (UIToolbar *)bar;
            if ([toolBar.subviews containsObject:[toolBar viewWithTag:10]]) [[toolBar viewWithTag:10] removeFromSuperview];
        } else if  ([bar isKindOfClass:[UITabBar class]]) {
            UITabBar *tabbar = (UITabBar *)bar;
            tabbar.backgroundImage = nil;
            if ([tabbar.subviews containsObject:[tabbar viewWithTag:10]]) [[tabbar viewWithTag:10] removeFromSuperview];
        }
    }
}

void setupTranslucence(UIView *view, UIColor *backColor, BOOL remove)
{
    if ([view respondsToSelector:@selector(_backgroundView)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *backView = objc_msgSend(view, @selector(_backgroundView));
            
            if (remove) {
                if ([backView.subviews containsObject:[backView viewWithTag:4545]]) {
                    [[backView viewWithTag:4545] removeFromSuperview];
                
                    for (UIView *subview in backView.subviews) {
                        if ([subview isKindOfClass:[UIVisualEffectView class]]) {
                            subview.alpha = 0.0f;
                            subview.hidden = NO;
                            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                                subview.alpha = 1.0f;
                            } completion:nil];
                        }
                    }
                }
                return;
            }
            if (![backView.subviews containsObject:[backView viewWithTag:4545]]) {
                UIView *newBackView = [[UIView alloc] init];
                newBackView.tag = 4545;
                newBackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                newBackView.backgroundColor = backColor;
                [backView addSubview:newBackView];
                
                for (UIView *subview in backView.subviews) {
                    if ([subview isKindOfClass:[UIVisualEffectView class]]) {
                        newBackView.frame = subview.frame;
                        subview.hidden = YES;
                    }
                }
            }
        });
    }
}

void setToolBar(UIToolbar *toolbar)
{
    if (enabled && [toolbar respondsToSelector:@selector(setBarTintColor:)]) {
        if (enableNightTheme) {
            toolbar.barTintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
            toolbar.tintColor = cvkMainController.nightThemeScheme.textColor;
            setupTranslucence(toolbar, cvkMainController.nightThemeScheme.navbackgroundColor, NO);
        } else if (enabledToolBarColor) {
            
            NSArray *controllersToChange = @[@"UIView", @"RootView"];
            if ([controllersToChange containsObject:CLASS_NAME(toolbar.superview)]) {
                BOOL canUseTint = YES;
                BOOL needsButtonColor = NO;
                for (id view in toolbar.subviews) {
                    if ([@"InputPanelViewTextView" isEqualToString:CLASS_NAME(view)]) {
                        canUseTint = NO;
                        needsButtonColor = YES;
                        break;
                    }
                }
                
                toolbar.barTintColor = toolBarBackgroundColor;
                if (canUseTint) toolbar.tintColor = toolBarForegroundColor;
                
                if (needsButtonColor) {
                    for (UIView *view in toolbar.subviews) {
                        if ([view isKindOfClass:UIButton.class]) {
                            UIButton *btn = (UIButton *)view;
                            [btn setTitleColor:toolBarForegroundColor.darkerColor forState:UIControlStateDisabled];
                            [btn setTitleColor:toolBarForegroundColor forState:UIControlStateNormal];
                            BOOL btnToExclude = NO;
                            NSMutableArray <NSString *> *btnsWithActionsToExclude = [NSMutableArray arrayWithObject:@"actionToggleEmoji:"];
                            if ([cvkMainController compareAppVersionWithVersion:@"3.0"] >= 0) {
                                [btnsWithActionsToExclude addObject:@"send:"];
                                [btnsWithActionsToExclude addObject:@"actionSendInline:"];
                            }
                            
                            for (NSString *action in [btn actionsForTarget:btn.allTargets.allObjects[0] forControlEvent:UIControlEventTouchUpInside]) {
                                if ([btnsWithActionsToExclude containsObject:action]) btnToExclude = YES;
                            }
                            if (!btnToExclude && btn.currentImage)
                                [btn setImage:[[btn imageForState:UIControlStateNormal] imageWithTintColor:toolBarForegroundColor] forState:UIControlStateNormal];
                        }
                    }
                    
                }
                
            }
        } 
    } else setBlur(toolbar, NO, nil, 0);
}


void setupSearchController(UISearchDisplayController *controller, BOOL reset)
{
    BOOL shouldCustomize = NO;
    UIColor *blurColor = [UIColor clearColor];
    UIBlurEffectStyle blurStyle = 0;
    int tag = (int)controller.searchBar.tag;
    if ((tag == 1) && enabledMessagesListImage) {
        shouldCustomize = YES;
        blurColor = messagesListBlurTone;
        blurStyle = messagesListBlurStyle;
    } else if ((tag == 2) && enabledGroupsListImage) {
        shouldCustomize = YES;
        blurColor = groupsListBlurTone;
        blurStyle = groupsListBlurStyle;
    }    else if ((tag == 3) && enabledAudioImage) {
        shouldCustomize = YES;
        blurColor = audiosBlurTone;
        blurStyle = audiosBlurStyle;
    } else if ((tag == 4) && enabledAudioImage) {
        shouldCustomize = YES;
        blurColor = audiosBlurTone;
        blurStyle = audiosBlurStyle;
    }  else if ((tag == 5) && enabledMenuImage) {
        shouldCustomize = YES;
    } else if ((tag == 6) && enabledFriendsImage) {
        shouldCustomize = YES;
        blurColor = friendsBlurTone;
        blurStyle = friendsBlurStyle;
    }
    
    if (enabled && !enableNightTheme && shouldCustomize) {
        if (reset) {
            void (^removeAllBlur)(void) = ^void() {
                [[controller.searchBar._backgroundView viewWithTag:10] removeFromSuperview];
                [[controller.searchBar._scopeBarBackgroundView.superview viewWithTag:10] removeFromSuperview];
                controller.searchBar.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            };
            [UIView animateWithDuration:0.1 delay:0 options:0 animations:^{ removeAllBlur(); } completion:^(BOOL finished) { removeAllBlur(); }];
        } else {
            controller.searchResultsTableView.tag = 21;
            UIViewController *parentController = controller.searchContentsController.parentViewController;
            if ([parentController isKindOfClass:NSClassFromString(@"VKMNavigationController")]) {
                VKMNavigationController *navigation = (VKMNavigationController *)parentController;
                if (navigation.childViewControllers.count>0) {
                    if ([navigation.childViewControllers.firstObject isKindOfClass:NSClassFromString(@"VKSelectorContainerControllerDropdown")]) {
                        VKSelectorContainerControllerDropdown *dropdown = (VKSelectorContainerControllerDropdown *)navigation.childViewControllers.firstObject;
                        VKMTableController *tableController = (VKMTableController *)dropdown.currentViewController;
                        if ([tableController respondsToSelector:@selector(tableView)] && [tableController.tableView.backgroundView isKindOfClass:[ColoredVKWallpaperView class]]) {
                            ColoredVKWallpaperView *backView = (ColoredVKWallpaperView*)tableController.tableView.backgroundView;
                            ColoredVKWallpaperView *imageView = [ColoredVKWallpaperView viewWithFrame:[UIScreen mainScreen].bounds imageName:backView.name blackout:backView.blackout];
                            controller.searchResultsTableView.backgroundView = imageView;
                        }
                    } else if ([navigation.childViewControllers.firstObject respondsToSelector:@selector(tableView)]) {
                        VKMTableController *tableController = (VKMTableController*)navigation.childViewControllers.firstObject;
                        if ([tableController.tableView.backgroundView isKindOfClass:[ColoredVKWallpaperView class]]) {
                            ColoredVKWallpaperView *backView = (ColoredVKWallpaperView*)tableController.tableView.backgroundView;
                            ColoredVKWallpaperView *imageView = [ColoredVKWallpaperView viewWithFrame:[UIScreen mainScreen].bounds imageName:backView.name blackout:backView.blackout];
                            controller.searchResultsTableView.backgroundView = imageView;
                        }
                    }
                }
            }
            
            controller.searchBar.tintColor = [UIColor whiteColor];
            controller.searchBar.searchBarTextField.textColor = [UIColor whiteColor];
            [controller.searchBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
            
            UIView *backgroundView = (controller.searchBar)._backgroundView;
            UIVisualEffectView *barBlurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:blurStyle]];
            barBlurEffectView.backgroundColor = blurColor;
            barBlurEffectView.frame = CGRectMake(0, 0, backgroundView.superview.frame.size.width, backgroundView.superview.frame.size.height+21);
            barBlurEffectView.tag = 10;
            [backgroundView addSubview:barBlurEffectView];
            [backgroundView sendSubviewToBack:barBlurEffectView];
            
            if (controller.searchBar.scopeButtonTitles.count >= 2) {
                [UIView animateWithDuration:0.1 delay:0 options:0 animations:^{
                    UIView *scopeBackgroundView = (controller.searchBar)._scopeBarBackgroundView;
                    scopeBackgroundView.hidden = YES;
                    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:blurStyle]];
                    blurEffectView.frame = scopeBackgroundView.superview.bounds;
                    blurEffectView.backgroundColor = blurColor;
                    blurEffectView.tag = 10;
                    [scopeBackgroundView.superview addSubview:blurEffectView];
                    [scopeBackgroundView.superview sendSubviewToBack:blurEffectView];
                } completion:nil];
            }
            
        }
    }
}


void setupAudioPlayer(UIView *hostView, UIColor *color)
{
    if (!color) color = audioPlayerTintColor;
    for (UIView *view in hostView.subviews) {
        view.backgroundColor = [UIColor clearColor];
        if ([view respondsToSelector:@selector(setTextColor:)]) ((UILabel *)view).textColor = color;
        if ([view respondsToSelector:@selector(setImage:forState:)]) 
            [(UIButton*)view setImage:[[(UIButton*)view imageForState:UIControlStateNormal] imageWithTintColor:color] forState:UIControlStateNormal];
    }
}

void setupCellForSearchController(UITableViewCell *cell, UISearchDisplayController *searchController)
{
    if (![searchController.searchResultsTableView.backgroundView isKindOfClass:[ColoredVKWallpaperView class]]) return;
    BOOL shouldCustomize = NO;
    int tag = (int)((UISearchController *)searchController).searchBar.tag;
    if ((tag == 1) && enabledMessagesListImage) shouldCustomize = YES;
    else if ((tag == 2) && enabledGroupsListImage) shouldCustomize = YES;
    else if ((tag == 3) && enabledAudioImage) shouldCustomize = YES;
    else if ((tag == 4) && enabledAudioImage) shouldCustomize = YES;
    else if ((tag == 6) && enabledFriendsImage)  shouldCustomize = YES;
    
    
    if (enabled && !enableNightTheme && shouldCustomize) {
        cell.backgroundColor = [UIColor clearColor];
        
        if ([cell isKindOfClass:NSClassFromString(@"SourceCell")] || [cell isKindOfClass:NSClassFromString(@"UserCell")]) {
            SourceCell *sourceCell = (SourceCell *)cell;
            sourceCell.last.textColor = UITableViewCellTextColor;
            sourceCell.last.backgroundColor = UITableViewCellBackgroundColor;
            sourceCell.first.textColor = UITableViewCellTextColor;
            sourceCell.first.backgroundColor = UITableViewCellBackgroundColor;
        } else if ([cell isKindOfClass:NSClassFromString(@"NewDialogCell")]) {
            NewDialogCell *dialogCell = (NewDialogCell *)cell;
            dialogCell.backgroundView = nil;
            if (!dialogCell.dialog.head.read_state && dialogCell.unread.hidden) dialogCell.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
            else dialogCell.contentView.backgroundColor = UITableViewCellBackgroundColor;
            
            dialogCell.name.textColor = UITableViewCellTextColor;
            dialogCell.time.textColor = UITableViewCellTextColor;
            if ([dialogCell respondsToSelector:@selector(dialogText)]) dialogCell.dialogText.textColor = [UIColor colorWithWhite:0.95 alpha:0.9];
            if ([dialogCell respondsToSelector:@selector(text)]) dialogCell.text.textColor = [UIColor colorWithWhite:0.95 alpha:0.9];
            dialogCell.attach.textColor = [UIColor colorWithWhite:0.95 alpha:0.9];
        } else if ([cell isKindOfClass:NSClassFromString(@"GroupCell")]) {
            GroupCell *groupCell = (GroupCell *)cell;
            groupCell.name.textColor = UITableViewCellTextColor;
            groupCell.name.backgroundColor = UITableViewCellBackgroundColor;
            groupCell.status.textColor = UITableViewCellDetailedTextColor;
            groupCell.status.backgroundColor = UITableViewCellBackgroundColor;
        } else if ([cell isKindOfClass:NSClassFromString(@"VideoCell")]) {
            VideoCell *videoCell = (VideoCell *)cell;
            videoCell.videoTitleLabel.textColor = UITableViewCellTextColor;
            videoCell.videoTitleLabel.backgroundColor = UITableViewCellBackgroundColor;
            videoCell.authorLabel.textColor = UITableViewCellDetailedTextColor;
            videoCell.authorLabel.backgroundColor = UITableViewCellBackgroundColor;
            videoCell.viewCountLabel.textColor = UITableViewCellDetailedTextColor;
            videoCell.viewCountLabel.backgroundColor = UITableViewCellBackgroundColor;
        } else {
            cell.textLabel.textColor = UITableViewCellTextColor;
            cell.textLabel.backgroundColor = UITableViewCellBackgroundColor;
            cell.detailTextLabel.textColor = UITableViewCellDetailedTextColor;
            cell.detailTextLabel.backgroundColor = UITableViewCellBackgroundColor;
        }
        
        UIView *backView = [UIView new];
        backView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        cell.selectedBackgroundView = backView;
    }
}

UIVisualEffectView *blurForView(UIView *view, NSInteger tag)
{
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    blurEffectView.frame = view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurEffectView.tag = tag;
    
    return blurEffectView;
}


void setupUISearchBar(UISearchBar *searchBar)
{
    if (![searchBar isKindOfClass:[UISearchBar class]])
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *barBackground = searchBar.subviews[0].subviews[0];
        if (menuSelectionStyle == CVKCellSelectionStyleBlurred) {
            searchBar.backgroundColor = [UIColor clearColor];
            if (![barBackground.subviews containsObject: [barBackground viewWithTag:102] ]) [barBackground addSubview:blurForView(barBackground, 102)];
        } else if (menuSelectionStyle == CVKCellSelectionStyleTransparent) {
            if ([barBackground.subviews containsObject: [barBackground viewWithTag:102]]) [[barBackground viewWithTag:102] removeFromSuperview];
            searchBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        } else {
            if ([barBackground.subviews containsObject: [barBackground viewWithTag:102]]) [[barBackground viewWithTag:102] removeFromSuperview];
            searchBar.backgroundColor = [UIColor clearColor];
        }
        
        UIView *subviews = searchBar.subviews.lastObject;
        UITextField *barTextField = subviews.subviews[1];
        if ([barTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
            barTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:barTextField.placeholder  
                                                                                 attributes:@{NSForegroundColorAttributeName:changeMenuTextColor?menuTextColor:[UIColor colorWithWhite:1 alpha:0.5]}];
        }
    });
}

void resetUISearchBar(UISearchBar *searchBar)
{
    if (![searchBar isKindOfClass:[UISearchBar class]])
        return;
    
    if (enabled && enableNightTheme)
        searchBar.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    else
        searchBar.backgroundColor = kMenuCellBackgroundColor;
    
    UIView *barBackground = searchBar.subviews[0].subviews[0];
    if ([barBackground.subviews containsObject: [barBackground viewWithTag:102] ]) [[barBackground viewWithTag:102] removeFromSuperview];
    
    UIView *subviews = searchBar.subviews.lastObject;
    UITextField *barTextField = subviews.subviews[1];
    if ([barTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        barTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:barTextField.placeholder
                                                                             attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:162/255.0f green:168/255.0f blue:173/255.0f alpha:1]}];
    }
}

void performInitialCellSetup(UITableViewCell *cell)
{
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    UIView *backView = [UIView new];
    backView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    cell.selectedBackgroundView = backView;
}

void resetNavigationBar(UINavigationBar *navBar)
{
    setBlur(navBar, NO, nil, 0);
    navBar._backgroundView.alpha = 1.0;
    [cvkMainController.navBarImageView removeFromSuperview];
    navBar.barTintColor = kNavigationBarBarTintColor;
    for (UIView *subview in navBar._backgroundView.subviews) {
        if ([subview isKindOfClass:[UIVisualEffectView class]]) subview.hidden = NO;
    }
}

void actionChangeCornerRadius()
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        window.layer.masksToBounds = YES;
        
        CGFloat cornerRaduis = enabled ? appCornerRadius : 0.0f;
        
        CABasicAnimation *cornerAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        cornerAnimation.fromValue = @(window.layer.cornerRadius);
        cornerAnimation.toValue = @(cornerRaduis);
        cornerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        cornerAnimation.duration = 0.3f;
        
        window.layer.cornerRadius = cornerRaduis;
        [window.layer addAnimation:cornerAnimation forKey:@"cornerAnimation"];
    });
}

void uncaughtExceptionHandler(NSException *exception)
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    NSString *stringDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDictionary *crash = @{@"reason": exception.reason, @"callStackReturnAddresses": exception.callStackReturnAddresses, 
                            @"callStackSymbols":exception.callStackSymbols, @"date":stringDate};
    [crash writeToFile:CVK_CRASH_PATH atomically:YES];
}



void setupTabbar()
{
    UITabBarController *controller = (UITabBarController *)cvkMainController.vkMainController;
    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBar *tabbar = controller.tabBar;
        setupTranslucence(tabbar, cvkMainController.nightThemeScheme.navbackgroundColor, !(enabled && enableNightTheme));
        if (enabled && enableNightTheme) {
            tabbar.barTintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
            tabbar.tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
            if ([tabbar respondsToSelector:@selector(setUnselectedItemTintColor:)])
                tabbar.unselectedItemTintColor = cvkMainController.nightThemeScheme.buttonColor;
        } else if (enabled && enabledTabbarColor) {
            tabbar.barTintColor = tabbarBackgroundColor;
            tabbar.tintColor = tabbarSelForegroundColor;
            if ([tabbar respondsToSelector:@selector(setUnselectedItemTintColor:)])
                tabbar.unselectedItemTintColor = tabbarForegroundColor;
        } else {
            tabbar.barTintColor = [UIColor defaultColorForIdentifier:@"TabbarBackgroundColor"];
            tabbar.tintColor = [UIColor defaultColorForIdentifier:@"TabbarSelForegroundColor"];
            if ([tabbar respondsToSelector:@selector(setUnselectedItemTintColor:)])
                tabbar.unselectedItemTintColor = [UIColor defaultColorForIdentifier:@"TabbarForegroundColor"];
        }
        
        for (UITabBarItem *item in tabbar.items) {
            if (SYSTEM_VERSION_IS_MORE_THAN(@"10.0")) {
                item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            } else {
                UIColor *tintColor = (enabled && enabledTabbarColor) ? (enableNightTheme ? cvkMainController.nightThemeScheme.buttonColor : tabbarForegroundColor) : [UIColor defaultColorForIdentifier:@"TabbarForegroundColor"];
                 item.image = [item.image imageWithTintColor:tintColor];
            }
            item.selectedImage = [item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
}

void resetTabBar()
{
    if ([cvkMainController.vkMainController isKindOfClass:[UITabBarController class]]) {
        UITabBar *tabbar = ((UITabBarController *)cvkMainController.vkMainController).tabBar;
        setupTranslucence(tabbar, nil, YES);
        setBlur(tabbar, NO, nil, 0);
        
        setupTabbar();
    }
}

void setupHeaderFooterView(UITableViewHeaderFooterView *view, UITableView *tableView)
{
    void (^setColors)() = ^{
        if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
            view.contentView.backgroundColor = [UIColor clearColor];
            view.backgroundView.backgroundColor = [UIColor clearColor];
            view.textLabel.backgroundColor = [UIColor clearColor];
            view.textLabel.textColor = (tableView.tag == 24) ? UITableViewCellTextColor.darkerColor : UITableViewCellTextColor;
            view.detailTextLabel.textColor = (tableView.tag == 24) ? UITableViewCellTextColor.darkerColor : UITableViewCellTextColor;
        }
    };
    if (enableNightTheme) {
        if (![tableView.delegate isKindOfClass:[ColoredVKPrefs class]]) {
            if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
                view.contentView.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
                view.backgroundView.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            }
        }
    } else if (tableView.tag == 21) {
        setColors();
        
        if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
            UIVisualEffectView *blurView = blurForView(view, 5);
            if (![view.contentView.subviews containsObject:[view.contentView viewWithTag:5]])   [view.contentView addSubview:blurView];
        }
    } else if (tableView.tag == 22) {
        setColors();
        
        if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
            view.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
        }
    } else if (tableView.tag == 24) {
        setColors();
    }
}

void setupNewDialogCellFromNightTheme(NewDialogCell *dialogCell)
{
    if (enabled && enableNightTheme && [dialogCell isKindOfClass:NSClassFromString(@"NewDialogCell")]) {
        dialogCell.contentView.backgroundColor = [UIColor clearColor];
        dialogCell.backgroundView.hidden = YES;
        
        if (!dialogCell.dialog.head.read_state && dialogCell.unread.hidden)
            dialogCell.backgroundColor = cvkMainController.nightThemeScheme.unreadBackgroundColor;
        else
            dialogCell.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        dialogCell.name.textColor = cvkMainController.nightThemeScheme.textColor;
        dialogCell.time.textColor = cvkMainController.nightThemeScheme.textColor;
        dialogCell.attach.textColor = cvkMainController.nightThemeScheme.textColor;
        
        if ([dialogCell respondsToSelector:@selector(dialogText)])
            dialogCell.dialogText.textColor = cvkMainController.nightThemeScheme.textColor;
        if ([dialogCell respondsToSelector:@selector(text)])
            dialogCell.text.textColor = cvkMainController.nightThemeScheme.textColor;
    }
}


#pragma mark - AppDelegate
CHDeclareClass(AppDelegate);
CHDeclareMethod(2, BOOL, AppDelegate, application, UIApplication*, application, didFinishLaunchingWithOptions, NSDictionary *, options)
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [cvkBunlde load];
    reloadPrefs();
    
    CHSuper(2, AppDelegate, application, application, didFinishLaunchingWithOptions, options);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
        installerCompletionBlock = ^(BOOL purchased) {
            tweakEnabled = purchased;
            reloadPrefs();
        };
        [newInstaller checkStatus];
    });
    
    return YES;
}

CHDeclareMethod(1, void, AppDelegate, applicationDidBecomeActive, UIApplication *, application)
{
    CHSuper(1, AppDelegate, applicationDidBecomeActive, application);
    
    actionChangeCornerRadius();
    
    if (cvkMainController.audioCover) {
        [cvkMainController.audioCover updateColorScheme];
    }
    
//    [cvkMainController sendStats];
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
        else if (enabledBarImage) {
            if (cvkMainController.navBarImageView)  barTintColor = [UIColor colorWithPatternImage:cvkMainController.navBarImageView.imageView.image];
            else                                    barTintColor = barBackgroundColor;
        }
        else if (enabledBarColor) {
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
        else if (enabledBarColor)
            tintColor = barForegroundColor;
    }
    
    CHSuper(1, UINavigationBar, setTintColor, tintColor);
}

CHDeclareMethod(1, void, UINavigationBar, setTitleTextAttributes, NSDictionary*, attributes)
{
    NSMutableDictionary *mutableAttributes = [attributes mutableCopy];
    if (enabled) {
        if (enableNightTheme)
            mutableAttributes[NSForegroundColorAttributeName] = cvkMainController.nightThemeScheme.textColor;
        else if (enabledBarColor)
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
                search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
                NSDictionary *attributes = @{NSForegroundColorAttributeName:changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1 alpha:0.7]};
                NSString *placeholder = (search.searchBarTextField.placeholder.length > 0) ? search.searchBarTextField.placeholder : @"";
                search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:attributes];
                search._scopeBarBackgroundView.superview.hidden = YES;
            }
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
            self.tableView.separatorColor = [self.tableView.separatorColor colorWithAlphaComponent:0.2];
            self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
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
            
            cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
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
        } else if (groupsListUseBlur && [selfName isEqualToString:@"GroupsController"]) {
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
        else if (friendsUseBlur && [friendsControllers containsObject:selfName]) {
            shouldAddBlur = YES;
            blurColor = friendsBlurTone;
            blurStyle = friendsBlurStyle;
        } else if (videosUseBlur && [selfName isEqualToString:@"VideoAlbumController"]) {
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
            self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
            self.tableView.separatorColor = hideGroupsListSeparators ? [UIColor clearColor] : [self.tableView.separatorColor colorWithAlphaComponent:0.2];
            self.segment.alpha = 0.9;
            
            UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
            if ([search isKindOfClass:[UISearchBar class]] && [search respondsToSelector:@selector(setBackgroundImage:)]) {
                search.backgroundImage = [UIImage new];
                search.scopeBarBackgroundImage = [UIImage new];
                search.tag = 2;
                search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
                NSDictionary *attributes = @{NSForegroundColorAttributeName:changeGroupsListTextColor?groupsListTextColor:[UIColor colorWithWhite:1 alpha:0.7]};
                search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder attributes:attributes];
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
            groupCell.name.textColor = changeGroupsListTextColor?groupsListTextColor:[UIColor colorWithWhite:1 alpha:0.9];
            groupCell.name.backgroundColor = UITableViewCellBackgroundColor;
            groupCell.status.textColor = changeGroupsListTextColor?groupsListTextColor:[UIColor colorWithWhite:0.8 alpha:0.9];
            groupCell.status.backgroundColor = UITableViewCellBackgroundColor;
        } else  if ([cell isKindOfClass:NSClassFromString(@"VKMRendererCell")]) {
            performInitialCellSetup(cell);
            
            for (UIView *view in cell.contentView.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)view;
                    label.textColor = [UIColor colorWithWhite:1 alpha:0.9];
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
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")] && ([cvkMainController compareAppVersionWithVersion:@"3.0"] < 0)) {
        if (enabled && !enableNightTheme && enabledMessagesListImage) {
            [ColoredVKMainController setImageToTableView:self.tableView withName:@"messagesListBackgroundImage" blackout:chatListImageBlackout 
                                          parallaxEffect:useMessagesListParallax blurBackground:messagesListUseBackgroundBlur];
        }
    }
}

CHDeclareMethod(1, void, DialogsController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DialogsController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")]) {
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if (![search isKindOfClass:[UISearchBar class]])
            search = nil;
        else
            search.tag = 1;
        
        UIColor *placeholderColor = (enabled && !enableNightTheme && changeMessagesListTextColor) ? messagesListTextColor : [UIColor colorWithRed:0.556863 green:0.556863 blue:0.576471 alpha:1.0f];
        if (enabled && !enableNightTheme && enabledMessagesListImage) {
            self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
            self.tableView.separatorColor =  hideMessagesListSeparators ? [UIColor clearColor] : [self.tableView.separatorColor colorWithAlphaComponent:0.2];
            
            if (search) {
                search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
                search.backgroundImage = [UIImage new];
                search._scopeBarBackgroundView.superview.hidden = YES;
            }
            
        } else if ([cvkMainController compareAppVersionWithVersion:@"3.0"] >= 0) {
            self.rptr.tintColor = nil;
            self.tableView.separatorColor = [UIColor colorWithRed:215/255.0f green:216/255.0f blue:217/255.0f alpha:1.0f];
            if (search) {
                search.searchBarTextField.backgroundColor = nil;
                search._scopeBarBackgroundView.superview.hidden = NO;
                search.backgroundImage = [UIImage imageWithColor:[UIColor colorWithRed:235/255.0f green:237/255.0f blue:240/255.0f alpha:1.0f]];
            }
        }
        
        if (search) {
            NSMutableAttributedString *placeholder = [search.searchBarTextField.attributedPlaceholder mutableCopy];
            [placeholder addAttribute:NSForegroundColorAttributeName value:placeholderColor range:NSMakeRange(0, placeholder.string.length)];
            search.searchBarTextField.attributedPlaceholder = placeholder;
        }
        
        if ([cvkMainController compareAppVersionWithVersion:@"3.0"] >= 0) {
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
            
            cell.name.textColor = changeMessagesListTextColor?messagesListTextColor:[UIColor colorWithWhite:1 alpha:0.9];
            cell.time.textColor = cell.name.textColor;
            cell.attach.textColor = changeMessagesListTextColor?messagesListTextColor:[UIColor colorWithWhite:0.95 alpha:0.9];
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
                self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
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
                    [view setTextColor:changeMessagesTextColor?messagesTextColor:[UIColor colorWithWhite:1 alpha:0.7]];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.bg.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                self.bg.image = [self.bg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            if (enableNightTheme)
                self.bg.tintColor = self.message.incoming ? cvkMainController.nightThemeScheme.incomingBackgroundColor : cvkMainController.nightThemeScheme.outgoingBackgroundColor;
            else 
                self.bg.tintColor = self.message.incoming ? messageBubbleTintColor : messageBubbleSentTintColor;
        });
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
        }
    } else {
        setupTabbar();
    }
}

CHDeclareMethod(0, void, VKMMainController, viewWillLayoutSubviews)
{
    CHSuper(0, VKMMainController, viewWillLayoutSubviews);
    
    if (![self isKindOfClass:[UITabBarController class]] && enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
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
        cell.textLabel.textColor = changeMenuTextColor?menuTextColor:[UIColor colorWithWhite:1 alpha:0.9];
        cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = changeMenuTextColor?menuTextColor:[UIColor colorWithWhite:1 alpha:0.8];
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
                cell.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        }
        
        if ([cell respondsToSelector:@selector(badge)]) {
            [[cell valueForKeyPath:@"badge"] setTitleColor:changeMenuTextColor?menuTextColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
    } else {
        if ([cell respondsToSelector:@selector(badge)]) {
            [[cell valueForKeyPath:@"badge"] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        cell.imageView.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
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
    else tableView.separatorColor = [UIColor colorWithRed:215/255.0f green:216/255.0f blue:217/255.0 alpha:1.0f];
    
    if (enabled && enableNightTheme) {
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
        ((TablePrimaryHeaderView*)view).separator.alpha = 0.3;
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
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            NSDictionary *attributes = @{NSForegroundColorAttributeName: changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1 alpha:0.7]};
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
        self.tableView.separatorColor =  hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioAlbumController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioAlbumController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && ([self isKindOfClass:NSClassFromString(@"AudioAlbumController")] || [self isKindOfClass:NSClassFromString(@"AudioAlbumsController")])) {
        performInitialCellSetup(cell);
            
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1 alpha:0.9];
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:0.8 alpha:0.9];
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
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioPlaylistController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioPlaylistController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:NSClassFromString(@"AudioPlaylistController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1 alpha:0.9];
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:0.8 alpha:0.9];
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
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
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
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
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
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
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
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
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
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
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
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
        
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if ([search isKindOfClass:[UISearchBar class]] && !enableNightTheme) {
            search.backgroundImage = [UIImage new];
            search.tag = 3;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            NSDictionary *attributes = @{NSForegroundColorAttributeName: changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1 alpha:0.7]};
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
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
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
            saveButton.urlBlock = ^NSString*() {
                NSString *imageSource = @"";
                int indexOfPage = self.paging.contentOffset.x / self.paging.frame.size.width;
                VKPhotoSized *photo = [self photoForPage:indexOfPage];
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

CHDeclareMethod(1, void, VKMBrowserController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMBrowserController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"VKMBrowserController")]) {
        if (showFastDownloadButton) {
            self.navigationItem.rightBarButtonItem = [ColoredVKBarDownloadButton buttonWithURL:self.target.url.absoluteString rootController:self];
        }
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

void hideFastButtonForController(VKMBrowserController *browserController)
{
    if (showFastDownloadButton) {
        NSString *imageURL = [browserController.webView stringByEvaluatingJavaScriptFromString:@"(function(){ var allImages = document.querySelectorAll('img'); if (allImages.length == 1) return allImages[0].src; else return \"\"; })();"];
        
        NSString *title = [browserController.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        if (imageURL.length == 0 || ([title containsString:@"jpg"] || [title containsString:@"png"])) {
            browserController.navigationItem.rightBarButtonItem = nil;
        }
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


#pragma mark VKGroupProfile
CHDeclareClass(VKGroupProfile);
CHDeclareMethod(0, BOOL, VKGroupProfile, verified)
{
    if ([self.group.gid isEqual:@55161589])
        return YES;
    return CHSuper(0, VKGroupProfile, verified);
}

#pragma mark VKProfile
CHDeclareClass(VKProfile);
CHDeclareMethod(0, BOOL, VKProfile, verified)
{
    NSArray *verifiedUsers = @[@89911723, @93264161, @125879328, @73369298, @147469494, @283990174];
    if ([verifiedUsers containsObject:self.user.uid])
        return YES;
    return CHSuper(0, VKProfile, verified);
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
        controller.searchResultsTableView.separatorColor = [controller.searchResultsTableView.separatorColor colorWithAlphaComponent:0.2];
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
        self.tableView.separatorColor = hideFriendsSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.tableView.sectionIndexColor = UITableViewCellTextColor;
        self.tableView.tag = 22;
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
        
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if ([search isKindOfClass:[UISearchBar class]] && [search respondsToSelector:@selector(setBackgroundImage:)]) {
            search.backgroundImage = [UIImage new];
            search.tag = 6;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            NSDictionary *attributes = @{NSForegroundColorAttributeName: changeFriendsTextColor?friendsTextColor:[UIColor colorWithWhite:1 alpha:0.7]};
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder attributes:attributes];
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
        self.tableView.separatorColor = hideFriendsSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.tableView.tag = 22;
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
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
        self.tableView.separatorColor = hideFriendsSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
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
        self.tableView.separatorColor = hideVideosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
        setBlur(self.toolbar, YES, videosBlurTone, videosBlurStyle);
        
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if ([search isKindOfClass:[UISearchBar class]] && [search respondsToSelector:@selector(setBackgroundImage:)]) {
            search.backgroundImage = [UIImage new];
            search.tag = 6;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            NSDictionary *attributes = @{NSForegroundColorAttributeName: changeVideosTextColor?videosTextColor:[UIColor colorWithWhite:1 alpha:0.7]};
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder attributes:attributes];
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


#pragma mark - UIViewController

CHDeclareClass(UIViewController);
CHDeclareMethod(3, void, UIViewController, presentViewController, UIViewController *, viewControllerToPresent, animated, BOOL, flag, completion, id, completion)
{
    if (![CLASS_NAME(self) containsString:@"ColoredVK"] || ![CLASS_NAME(viewControllerToPresent) containsString:@"ColoredVK"]) {
        NSArray <Class> *classes = @[[UIAlertController class], [UIActivityViewController class]];
        
        if ([classes containsObject:[viewControllerToPresent class]] && IS_IPAD) {
            viewControllerToPresent.modalPresentationStyle = UIModalPresentationPopover;
            viewControllerToPresent.popoverPresentationController.permittedArrowDirections = 0;
            viewControllerToPresent.popoverPresentationController.sourceView = self.view;
            viewControllerToPresent.popoverPresentationController.sourceRect = self.view.bounds;
        }
    }
    
    CHSuper(3, UIViewController, presentViewController, viewControllerToPresent, animated, flag, completion, completion);
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
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.imageView.tintColor = kVKMainColor;
        
        if ([cvkMainController compareAppVersionWithVersion:@"3.0"] >= 0)
            cell.imageView.tintColor = [UIColor colorWithRed:0.667 green:0.682 blue:0.702 alpha:1.0f];
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

void setupExtraSettingsController(VKMTableController *controller)
{
    if (![controller isKindOfClass:NSClassFromString(@"VKMTableController")])
        return;
    
    if (enabled && !enableNightTheme && enabledSettingsExtraImage) {
        [ColoredVKMainController setImageToTableView:controller.tableView withName:@"settingsExtraBackgroundImage" blackout:settingsExtraImageBlackout 
                                      parallaxEffect:useSettingsExtraParallax blurBackground:settingsExtraUseBackgroundBlur];
        
        if (hideSettingsSeparators) 
            controller.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        else
            controller.tableView.separatorColor = [controller.tableView.separatorColor colorWithAlphaComponent:0.5f];
        
        controller.rptr.tintColor = changeSettingsExtraTextColor ? settingsExtraTextColor : UITableViewCellTextColor;
        controller.tableView.tag = 24;
    }
}

void setupExtraSettingsCell(UITableViewCell *cell)
{
    if (enabled && !enableNightTheme && enabledSettingsExtraImage) {
        performInitialCellSetup(cell);
        UIColor *textColor = changeSettingsExtraTextColor ? settingsExtraTextColor : UITableViewCellTextColor;
        UIColor *detailedTextColor = changeSettingsExtraTextColor ? settingsExtraTextColor : UITableViewCellTextColor;
        cell.textLabel.textColor = textColor;
        cell.detailTextLabel.textColor = detailedTextColor;
        if ([cell isKindOfClass:NSClassFromString(@"SourceCell")]) {
            SourceCell *sourceCell = (SourceCell *)cell;
            sourceCell.last.textColor = textColor;
            sourceCell.last.backgroundColor = UITableViewCellBackgroundColor;
            sourceCell.first.textColor = textColor;
            sourceCell.first.backgroundColor = UITableViewCellBackgroundColor;
        }
        else if ([cell isKindOfClass:NSClassFromString(@"VKMRendererCell")]) {
            for (UIView *subview in cell.contentView.subviews) {
                if ([subview isKindOfClass:[UILabel class]]) {
                    ((UILabel *)subview).textColor = textColor;
                }
            }
        } else if ([cell isKindOfClass:NSClassFromString(@"CommunityCommentsCell")]) {
            CommunityCommentsCell *commentsCell =  (CommunityCommentsCell *)cell;
            commentsCell.titleLabel.textColor = textColor;
            commentsCell.titleLabel.backgroundColor = UITableViewCellBackgroundColor;
            commentsCell.subtitleLabel.textColor = textColor;
            commentsCell.subtitleLabel.backgroundColor = UITableViewCellBackgroundColor;
        }
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
    }
}

#pragma mark -
#pragma mark NIGHT THEME
#pragma mark -

NSAttributedString *attributedStringForNightTheme(NSAttributedString * text)
{
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithAttributedString:text];
    if (enabled && enableNightTheme) {
        [mutableString enumerateAttributesInRange:NSMakeRange(0, mutableString.length) options:0 
                                       usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
                                           
                                           void (^setColor)(BOOL isLink, BOOL forMOCTLabel) = ^(BOOL isLink, BOOL forMOCTLabel) {
                                               NSString *attribute = forMOCTLabel ? @"CTForegroundColor" : NSForegroundColorAttributeName;
                                               
                                               id textColor = cvkMainController.nightThemeScheme.textColor;
                                               if (isLink)
                                                   textColor = cvkMainController.nightThemeScheme.linkTextColor;
                                               
                                               if (forMOCTLabel) {
                                                   textColor = (id)((UIColor *)textColor).CGColor;
                                                   if (isLink) {
                                                       [mutableString addAttribute:@"MOCTLinkInactiveAttributeName" value:@{@"CTForegroundColor": textColor} range:range];
                                                       [mutableString addAttribute:@"MOCTLinkActiveAttributeName" value:@{@"CTForegroundColor": textColor} range:range];
                                                   }
                                               }
                                               [mutableString addAttribute:attribute value:textColor range:range];
                                           };
                                           
                                           if (attrs[@"MOCTLinkAttributeName"])
                                               setColor(YES, YES);
                                           else if (attrs[@"VKTextLink"] || attrs[@"NSLink"])
                                               setColor(YES, NO);
                                           else {
                                               if (attrs[@"CTForegroundColor"])
                                                   setColor(NO, YES);
                                               else
                                                   setColor(NO, NO);
                                           }
                                       }];
    }
    
    return mutableString;
}

CHDeclareClass(VKRenderedText);
CHDeclareClassMethod(2, id, VKRenderedText, renderedText, NSAttributedString *, text, withSettings, id, withSettings)
{
    NSAttributedString *newText = attributedStringForNightTheme(text);
//    CVKLog(@"%@", newText);
    return CHSuper(2, VKRenderedText, renderedText, newText, withSettings, withSettings);
}


CHDeclareClass(MOCTRender);
CHDeclareClassMethod(2, id, MOCTRender, render, NSAttributedString *, text, width, double, width)
{
    NSAttributedString *newText = attributedStringForNightTheme(text);
//    CVKLog(@"%@", newText);
    return CHSuper(2, MOCTRender, render, newText, width, width);
}

CHDeclareClass(VKMLabelRender);
CHDeclareClassMethod(4, id, VKMLabelRender, renderForText, NSString *, text, attributes, NSDictionary*, attributes, width, double, width, height, double, height)
{
    NSMutableDictionary *mutableAttributes = [attributes mutableCopy];
    
    if (mutableAttributes[@"CTForegroundColor"]) {
        if (!mutableAttributes[NSLinkAttributeName])
            mutableAttributes[@"CTForegroundColor"] = cvkMainController.nightThemeScheme.textColor;
        else
            mutableAttributes[@"CTForegroundColor"] = cvkMainController.nightThemeScheme.linkTextColor;
    }
    
    return CHSuper(4, VKMLabelRender, renderForText, text, attributes, mutableAttributes, width, width, height, height);
}

CHDeclareClass(ProfileView);
CHDeclareMethod(0, void, ProfileView, layoutSubviews)
{
    CHSuper(0, ProfileView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"ProfileView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        self.blocksScroll.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareMethod(1, void, ProfileView, setButtonStatus, UIButton *, buttonStatus)
{
    if (enabled && enableNightTheme) {
        [buttonStatus setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateNormal];
        [buttonStatus setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateSelected];
        [buttonStatus setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateHighlighted];
        
        [buttonStatus setBackgroundImage:[[buttonStatus backgroundImageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                                forState:UIControlStateNormal];
        [buttonStatus setBackgroundImage:[[buttonStatus backgroundImageForState:UIControlStateSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                                forState:UIControlStateSelected];
        [buttonStatus setBackgroundImage:[[buttonStatus backgroundImageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                                forState:UIControlStateHighlighted];
        
        if (cvkMainController.nightThemeScheme.type == CVKNightThemeTypeBlack)
            buttonStatus.tintColor = cvkMainController.nightThemeScheme.backgroundColor;
        else
            buttonStatus.tintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
    }
    
    
    CHSuper(1, ProfileView, setButtonStatus, buttonStatus);
}

CHDeclareMethod(1, void, ProfileView, setButtonEdit, UIButton *, buttonEdit)
{
    if (enabled && enableNightTheme) {
        [buttonEdit setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateNormal];
        [buttonEdit setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateSelected];
        [buttonEdit setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateHighlighted];
        
        [buttonEdit setBackgroundImage:[[buttonEdit backgroundImageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                              forState:UIControlStateNormal];
        [buttonEdit setBackgroundImage:[[buttonEdit backgroundImageForState:UIControlStateSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                              forState:UIControlStateSelected];
        [buttonEdit setBackgroundImage:[[buttonEdit backgroundImageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                              forState:UIControlStateHighlighted];
        
        switch (cvkMainController.nightThemeScheme.type) {
            case CVKNightThemeTypeBlack:
                buttonEdit.tintColor = cvkMainController.nightThemeScheme.backgroundColor;
                break;
                
            case CVKNightThemeTypeCustom:
                buttonEdit.tintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
                break;
                
            default:
                buttonEdit.tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
                break;
        }
    }
    
    
    CHSuper(1, ProfileView, setButtonEdit, buttonEdit);
}

CHDeclareMethod(1, void, ProfileView, setButtonMessage, UIButton *, buttonMessage)
{
    if (enabled && enableNightTheme) {
        [buttonMessage setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateNormal];
        [buttonMessage setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateSelected];
        [buttonMessage setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateHighlighted];
        
        [buttonMessage setBackgroundImage:[[buttonMessage backgroundImageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                                 forState:UIControlStateNormal];
        [buttonMessage setBackgroundImage:[[buttonMessage backgroundImageForState:UIControlStateSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                                 forState:UIControlStateSelected];
        [buttonMessage setBackgroundImage:[[buttonMessage backgroundImageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                                 forState:UIControlStateHighlighted];
        
        switch (cvkMainController.nightThemeScheme.type) {
            case CVKNightThemeTypeBlack:
                buttonMessage.tintColor = cvkMainController.nightThemeScheme.backgroundColor;
                break;
                
            case CVKNightThemeTypeCustom:
                buttonMessage.tintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
                break;
                
            default:
                buttonMessage.tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
                break;
        }
    }
    
    
    CHSuper(1, ProfileView, setButtonMessage, buttonMessage);
}


CHDeclareClass(UITableViewCell);
CHDeclareMethod(0, void, UITableViewCell, layoutSubviews)
{
    CHSuper(0, UITableViewCell, layoutSubviews);
    
    if ([self isKindOfClass:[PSTableCell class]]) {
        if ([((PSTableCell *)self).cellTarget isKindOfClass:[ColoredVKPrefs class]])
            return;
    }
    if ([self isKindOfClass:NSClassFromString(@"MessageCell")])
        return;
    
    if ([self isKindOfClass:NSClassFromString(@"UITableViewCell")]) {
        if ((self.textLabel.textAlignment == NSTextAlignmentCenter) && [CLASS_NAME(self) isEqualToString:@"UITableViewCell"])
            self.backgroundColor = [UIColor clearColor];
        else {
            if (enabled && enableNightTheme)
                self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        }
        
        if (enabled && enableNightTheme) {
            self.textLabel.textColor = cvkMainController.nightThemeScheme.textColor;
            self.detailTextLabel.textColor = cvkMainController.nightThemeScheme.textColor;
            self.textLabel.backgroundColor = [UIColor clearColor];
            self.detailTextLabel.backgroundColor = [UIColor clearColor];
        }
    }
}

CHDeclareMethod(1, void, UITableViewCell, setSelectedBackgroundView, UIView *, view)
{
    if (enabled && enableNightTheme) {
        view.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
    CHSuper(1, UITableViewCell, setSelectedBackgroundView, view);
}


CHDeclareClass(UIButton);
CHDeclareMethod(0, void, UIButton, layoutSubviews)
{
    CHSuper(0, UIButton, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:[UIButton class]]) {
        
        if (![self isKindOfClass:NSClassFromString(@"VKMImageButton")] && ![self isKindOfClass:NSClassFromString(@"HighlightableButton")]) {
            if ([CLASS_NAME(self) containsString:@"UINavigation"] || [CLASS_NAME(self.superview) containsString:@"UINavigation"])
                [self setTitleColor:cvkMainController.nightThemeScheme.buttonSelectedColor forState:UIControlStateNormal];
            else
                [self setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateNormal];
            
            BOOL shouldChangeColor = ((NSNumber *)objc_getAssociatedObject(self, "shouldChangeImageColor")).boolValue;
            
            NSArray <NSString *> *namesToExclude = @[@"attachments/remove", @"search/clear"];
            if (![namesToExclude containsObject:[self imageForState:UIControlStateNormal].imageAsset.assetName] || shouldChangeColor) {
                if ((CGRectGetWidth(self.imageView.frame) <= 40.0f && CGRectGetHeight(self.imageView.frame) <= 40.0f) || shouldChangeColor) {
                    [self setImage:[[self imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                    self.imageView.tintColor = cvkMainController.nightThemeScheme.buttonColor;
                }
            }
        }
    }
}

CHDeclareClass(UISegmentedControl);
CHDeclareMethod(0, void, UISegmentedControl, layoutSubviews)
{
    CHSuper(0, UISegmentedControl, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"UISegmentedControl")]) {
        self.tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(UILabel);
CHDeclareMethod(0, void, UILabel, layoutSubviews)
{
    CHSuper(0, UILabel, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"UILabel")] && ![CLASS_NAME(self.superview) isEqualToString:@"HighlightableButton"]) {
        
        if ([self isKindOfClass:NSClassFromString(@"HighlightableLabel")]) {
            self.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
            self.textColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
        } else {
            self.backgroundColor = [UIColor clearColor];
            self.textColor = cvkMainController.nightThemeScheme.textColor;
        }
    }
}

CHDeclareClass(UITextView);
CHDeclareMethod(1, void, UITextView, setAttributedText, NSAttributedString *, text)
{
    if (enabled && enableNightTheme) {
        text = attributedStringForNightTheme(text);
    }
    CHSuper(1, UITextView, setAttributedText, text);
}

CHDeclareMethod(1, void, UITextView, setLinkTextAttributes, NSDictionary *, linkTextAttributes)
{
    if (enabled && enableNightTheme) {
        linkTextAttributes = @{NSForegroundColorAttributeName: cvkMainController.nightThemeScheme.linkTextColor};
    }
    CHSuper(1, UITextView, setLinkTextAttributes, linkTextAttributes);
}

CHDeclareMethod(1, void, UITextView, insertText, id, text)
{
    CHSuper(1, UITextView, insertText, text);
    
    if (enabled && enableNightTheme) {
        self.textColor = cvkMainController.nightThemeScheme.textColor;
    }
}

CHDeclareMethod(1, void, UITextView, paste, id, text)
{
    CHSuper(1, UITextView, paste, text);
    
    if (enabled && enableNightTheme) {
        self.textColor = cvkMainController.nightThemeScheme.textColor;
    }
}

CHDeclareMethod(0, void, UITextView, layoutSubviews)
{
    CHSuper(0, UITextView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"UITextView")]) {
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = cvkMainController.nightThemeScheme.textColor;
    }
}

CHDeclareClass(UITextField);
CHDeclareMethod(0, void, UITextField, layoutSubviews)
{
    CHSuper(0, UITextField, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"UITextField")]) {
        self.tintColor = cvkMainController.nightThemeScheme.textColor;
        
        if ([CLASS_NAME(self) isEqualToString:@"UITextField"])
            self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareMethod(1, void, UITextField, paste, id, paste)
{
    if (enabled && enableNightTheme) {
        self.textColor = cvkMainController.nightThemeScheme.textColor;
    }
    
    CHSuper(1, UITextField, paste, paste);
}

CHDeclareMethod(0, void, UITextField, _updateLabel)
{
    if (enabled && enableNightTheme) {
        self.textColor = cvkMainController.nightThemeScheme.textColor;
    }
    
    CHSuper(0, UITextField, _updateLabel);
}

CHDeclareClass(UIImageView);
CHDeclareMethod(0, void, UIImageView, layoutSubviews)
{
    CHSuper(0, UIImageView, layoutSubviews);
    
    if (enabled && enableNightTheme) {
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(UICollectionView);
CHDeclareMethod(0, void, UICollectionView, layoutSubviews)
{
    CHSuper(0, UICollectionView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"UICollectionView")]) {
        
        NSNumber *shouldDisableBackgroundColor = (NSNumber*)objc_getAssociatedObject(self, "shouldDisableBackgroundColor");
        if ([shouldDisableBackgroundColor isKindOfClass:[NSNumber class]] && shouldDisableBackgroundColor.boolValue)
            self.backgroundColor = [UIColor clearColor];
        else
            self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(UICollectionViewCell);
CHDeclareMethod(0, void, UICollectionViewCell, layoutSubviews)
{
    CHSuper(0, UICollectionViewCell, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"UICollectionViewCell")] && ![self isKindOfClass:NSClassFromString(@"_UIAlertControllerTextFieldViewCollectionCell")]) {
        
        NSNumber *shouldDisableBackgroundColor = (NSNumber*)objc_getAssociatedObject(self, "shouldDisableBackgroundColor");
        if (!([shouldDisableBackgroundColor isKindOfClass:[NSNumber class]] && shouldDisableBackgroundColor.boolValue)) {
            self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
            self.contentView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
            self.backgroundView.hidden = YES;
        }
    }
}

CHDeclareClass(NewsFeedPostAndStoryCreationButtonBar);
CHDeclareMethod(0, void, NewsFeedPostAndStoryCreationButtonBar, layoutSubviews)
{
    CHSuper(0, NewsFeedPostAndStoryCreationButtonBar, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"NewsFeedPostAndStoryCreationButtonBar")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(Node5TableViewCell);
CHDeclareMethod(0, void, Node5TableViewCell, layoutSubviews)
{
    CHSuper(0, Node5TableViewCell, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"Node5TableViewCell")]) {
        
        for (UIView *subview in  self.contentView.subviews) {
            subview.backgroundColor = [UIColor clearColor];
        }
    }
}

CHDeclareClass(Node5CollectionViewCell);
CHDeclareMethod(0, void, Node5CollectionViewCell, layoutSubviews)
{
    CHSuper(0, Node5CollectionViewCell, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"Node5CollectionViewCell")]) {
        
        if (self.contentView.subviews > 0) {
            for (UIView *subview in  self.contentView.subviews.firstObject.subviews) {
                if ([CLASS_NAME(subview) isEqualToString:@"UIImageView"]) {
                    subview.hidden = YES;
                }
            }
        }
    }
}

CHDeclareClass(InputPanelView);
CHDeclareMethod(0, void, InputPanelView, layoutSubviews)
{
    CHSuper(0, InputPanelView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"InputPanelView")]) {
        self.overlay.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        self.overlay.layer.borderColor = cvkMainController.nightThemeScheme.backgroundColor.CGColor;
    }
}

CHDeclareClass(AdminInputPanelView);
CHDeclareMethod(0, void, AdminInputPanelView, layoutSubviews)
{
    CHSuper(0, AdminInputPanelView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"AdminInputPanelView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        if ([self respondsToSelector:@selector(gapToolbar)])
            [self.gapToolbar setBackgroundImage:[UIImage imageWithColor:cvkMainController.nightThemeScheme.backgroundColor] 
                             forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
}

static void setupNightSeparatorForView(UIView *view)
{
    if ([CLASS_NAME(view) isEqualToString:@"UIView"]) {
        if (enabled && enableNightTheme) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([cvkMainController.vkMainController respondsToSelector:@selector(tabBarShadowView)]) {
                    if ([view isEqual:cvkMainController.vkMainController.tabBarShadowView])
                        return;
                }
                UIColor *cachedBackgroundColor = objc_getAssociatedObject(view, "cachedBackgroundColor");
                if (!cachedBackgroundColor) {
                    objc_setAssociatedObject(view, "cachedBackgroundColor", view.backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    cachedBackgroundColor = view.backgroundColor;
                }
                
                if ((CGRectGetHeight(view.frame) < 3.0f) && !CGSizeEqualToSize(CGSizeZero, view.frame.size))
                    view.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
                else
                    view.backgroundColor = cachedBackgroundColor;
            });
        }
    }
}

CHDeclareClass(UIView);
CHDeclareMethod(1, void, UIView, setFrame, CGRect, frame)
{
    CHSuper(1, UIView, setFrame, frame);
    
    setupNightSeparatorForView(self);
}

CHDeclareMethod(0, void, UIView, layoutSubviews)
{
    CHSuper(0, UIView, layoutSubviews);
    
    setupNightSeparatorForView(self);
}


CHDeclareClass(UIToolbar);
CHDeclareMethod(1, void, UIToolbar, setFrame, CGRect, frame)
{
    CHSuper(1, UIToolbar, setFrame, frame);
    
    setupTranslucence(self, cvkMainController.nightThemeScheme.navbackgroundColor, !(enabled && enableNightTheme));
}

CHDeclareClass(PollAnswerButton);
CHDeclareMethod(0, void, PollAnswerButton, layoutSubviews)
{
    CHSuper(0, PollAnswerButton, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"PollAnswerButton")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        self.progressView.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
    }
}

CHDeclareClass(VKAPBottomToolbar);
CHDeclareMethod(0, void, VKAPBottomToolbar, layoutSubviews)
{
    CHSuper(0, VKAPBottomToolbar, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"VKAPBottomToolbar")]) {
        self.bg.barTintColor = cvkMainController.nightThemeScheme.backgroundColor;
        self.bg.tintColor = cvkMainController.nightThemeScheme.textColor;
    }
}

CHDeclareClass(WallModeRenderer);
CHDeclareMethod(0, UIButton *, WallModeRenderer, buttonAll)
{
    UIButton *buttonAll = CHSuper(0, WallModeRenderer, buttonAll);
    
    if (enabled && enableNightTheme) {
        [buttonAll setTitleColor:cvkMainController.nightThemeScheme.textColor forState:buttonAll.state];
        
        UIImage *selectedImage = [[buttonAll backgroundImageForState:UIControlStateSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [buttonAll setBackgroundImage:selectedImage forState:UIControlStateSelected];
        buttonAll.tintColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
    
    return buttonAll;
}

CHDeclareMethod(0, UIButton *, WallModeRenderer, buttonFilter)
{
    UIButton *buttonFilter = CHSuper(0, WallModeRenderer, buttonFilter);
    
    if (enabled && enableNightTheme) {
        [buttonFilter setTitleColor:cvkMainController.nightThemeScheme.textColor forState:buttonFilter.state];
        
        UIImage *selectedImage = [[buttonFilter backgroundImageForState:UIControlStateSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [buttonFilter setBackgroundImage:selectedImage forState:UIControlStateSelected];
        buttonFilter.tintColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
    
    return buttonFilter;
}


CHDeclareClass(SeparatorWithBorders);
CHDeclareMethod(0, void, SeparatorWithBorders, layoutSubviews)
{
    CHSuper(0, SeparatorWithBorders, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"SeparatorWithBorders")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        self.borderColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
}

CHDeclareClass(Component5HostView);
CHDeclareMethod(0, void, Component5HostView, layoutSubviews)
{
    CHSuper(0, Component5HostView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"Component5HostView")]) {
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(LookupAddressBookFriendsViewController);
CHDeclareMethod(0, void, LookupAddressBookFriendsViewController, viewDidLoad)
{
    CHSuper(0, LookupAddressBookFriendsViewController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (UIView *subview in self.lookupTeaserViewController.componentView.subviews) {
                subview.backgroundColor = [UIColor clearColor];
            }
        });
    }
}

CHDeclareClass(MessageController);
CHDeclareMethod(0, void, MessageController, viewDidLoad)
{
    CHSuper(0, MessageController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
}

CHDeclareClass(ProductMarketCellForProfileGallery);
CHDeclareMethod(0, void, ProductMarketCellForProfileGallery, layoutSubviews)
{
    CHSuper(0, ProductMarketCellForProfileGallery, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"ProductMarketCellForProfileGallery")]) {
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(MarketGalleryDecoration);
CHDeclareMethod(0, void, MarketGalleryDecoration, layoutSubviews)
{
    CHSuper(0, MarketGalleryDecoration, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"MarketGalleryDecoration")]) {
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(StoreStockItemView);
CHDeclareMethod(0, void, StoreStockItemView, layoutSubviews)
{
    CHSuper(0, StoreStockItemView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"StoreStockItemView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(VKPhotoPicker);
CHDeclareMethod(0, UIStatusBarStyle, VKPhotoPicker, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"VKPhotoPicker")] && enabled && (enabledBarColor || enableNightTheme || enabledBarImage))
        return UIStatusBarStyleLightContent;
    else return CHSuper(0, VKPhotoPicker, preferredStatusBarStyle);
}

CHDeclareMethod(0, void, VKPhotoPicker, viewDidLoad)
{
    CHSuper(0, VKPhotoPicker, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.pickerToolbar.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        self.pickerToolbar.bg._backgroundView.hidden = YES;
        self.navigationBar.tintColor = self.navigationBar.tintColor;
    }
}

CHDeclareClass(MainMenuPlayer);
CHDeclareMethod(0, void, MainMenuPlayer, highlightUpdated)
{
    CHSuper(0, MainMenuPlayer, highlightUpdated);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"MainMenuPlayer")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        if ([self respondsToSelector:@selector(titleLabel)]) {
            self.titleLabel.textColor = cvkMainController.nightThemeScheme.textColor;
        } 
        if ([self respondsToSelector:@selector(playerTitle)]) {
            self.playerTitle.textColor = cvkMainController.nightThemeScheme.textColor;
        }
        
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UIToolbar class]]) {
                subview.hidden = YES;
            }
        }
    }
}

CHDeclareClass(VKMTableViewSearchHeaderView);
CHDeclareMethod(1, VKMTableViewSearchHeaderView*, VKMTableViewSearchHeaderView, initWithFrame, CGRect, frame)
{
    VKMTableViewSearchHeaderView *headerView = CHSuper(1, VKMTableViewSearchHeaderView, initWithFrame, frame);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"VKMTableViewSearchHeaderView")]) {
        [self setBackgroundImage:[UIImage imageWithColor:cvkMainController.nightThemeScheme.foregroundColor] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
    
    return headerView;
}

CHDeclareClass(VKMNavigationController);
CHDeclareMethod(0, void, VKMNavigationController, viewDidLoad)
{
    CHSuper(0, VKMNavigationController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
    }
}

CHDeclareClass(PersistentBackgroundColorView);
CHDeclareMethod(0, void, PersistentBackgroundColorView, layoutSubviews)
{
    CHSuper(0, PersistentBackgroundColorView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"PersistentBackgroundColorView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        self.persistentBackgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
}

CHDeclareClass(GiftSendController);
CHDeclareMethod(2, UITableViewCell*, GiftSendController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, GiftSendController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"GiftSendController")]) {
        cell.contentView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
    return cell;
}

CHDeclareClass(GiftsCatalogController);
CHDeclareMethod(2, UITableViewCell*, GiftsCatalogController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, GiftsCatalogController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"GiftsCatalogController")]) {
        cell.contentView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
    return cell;
}

CHDeclareClass(DefaultHighlightButton);
CHDeclareMethod(0, void, DefaultHighlightButton, layoutSubviews)
{
    CHSuper(0, DefaultHighlightButton, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"DefaultHighlightButton")]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([CLASS_NAME(self.superview) isEqualToString:@"UIView"])
                self.superview.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        });
    }
}

CHDeclareClass(_UITableViewHeaderFooterContentView);
CHDeclareMethod(1, void, _UITableViewHeaderFooterContentView, setBackgroundColor, UIColor *, backgroundColor)
{
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"_UITableViewHeaderFooterContentView")]) {
        backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
    
    CHSuper(1, _UITableViewHeaderFooterContentView, setBackgroundColor, backgroundColor);
}

CHDeclareClass(StoreController);
CHDeclareMethod(0, void, StoreController, viewDidLoad)
{
    CHSuper(0, StoreController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        [self.toolbar setBackgroundImage:[UIImage imageWithColor:cvkMainController.nightThemeScheme.foregroundColor] 
                      forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
}

CHDeclareClass(UIRefreshControl);
CHDeclareMethod(0, void, UIRefreshControl, layoutSubviews)
{
    CHSuper(0, UIRefreshControl, layoutSubviews);
    
    if (enabled && enableNightTheme)
        self.tintColor = cvkMainController.nightThemeScheme.buttonColor;
}


CHDeclareClass(UIActivityIndicatorView);
CHDeclareMethod(0, void, UIActivityIndicatorView, layoutSubviews)
{
    CHSuper(0, UIActivityIndicatorView, layoutSubviews);
    
    if (enabled && enableNightTheme)
        self.color = cvkMainController.nightThemeScheme.buttonColor;
}


CHDeclareClass(DiscoverLayoutMask);
CHDeclareMethod(0, void, DiscoverLayoutMask, layoutSubviews)
{
    CHSuper(0, DiscoverLayoutMask, layoutSubviews);
    
    self.hidden = (enabled && enableNightTheme);
}

CHDeclareClass(DiscoverLayoutShadow);
CHDeclareMethod(0, void, DiscoverLayoutShadow, layoutSubviews)
{
    CHSuper(0, DiscoverLayoutShadow, layoutSubviews);
    
    self.hidden = (enabled && enableNightTheme);
}

CHDeclareClass(UIVisualEffectView);
CHDeclareMethod(0, void, UIVisualEffectView, didMoveToSuperview)
{
    CHSuper(0, UIVisualEffectView, didMoveToSuperview);
    
    if (enabled && enableNightTheme && [self.effect isKindOfClass:[UIBlurEffect class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *className = CLASS_NAME(self.superview.superview);
            if ([className containsString:@"_UIAlertController"] || [className containsString:@"_UIPopoverView"]) {
                self.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.6f];
            }
        });
    }
}

CHDeclareClass(_UIAlertControlleriOSActionSheetCancelBackgroundView);
CHDeclareMethod(0, void, _UIAlertControlleriOSActionSheetCancelBackgroundView, layoutSubviews)
{
    CHSuper(0, _UIAlertControlleriOSActionSheetCancelBackgroundView, layoutSubviews);
    
    if (enabled && enableNightTheme && self.subviews.count > 0)
        self.subviews.firstObject.backgroundColor = [UIColor clearColor];
}

CHDeclareClass(UIAlertController);
CHDeclareMethod(0, void, UIAlertController, viewDidLoad)
{
    CHSuper(0, UIAlertController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.tintColor = [UIColor colorWithRed:0.1f green:0.59f blue:0.94f alpha:1.0f];
    }
}

CHDeclareMethod(1, void, UIAlertController, addTextFieldWithConfigurationHandler, id, handler)
{
    if (![self isKindOfClass:[ColoredVKAlertController class]]) {
        void (^newHandler)(UITextField * _Nonnull textField) = ^(UITextField * _Nonnull textField){
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIView *viewToRoundSuperView = textField.superview.superview;
                if (viewToRoundSuperView) {
                    for (UIView *subview in textField.superview.superview.subviews) {
                        subview.backgroundColor = [UIColor clearColor];
                        if ([subview isKindOfClass:[UIVisualEffectView class]])
                            subview.hidden = YES;
                    }
                    UIView *viewToRound = textField.superview;
                    textField.backgroundColor = (enabled && enableNightTheme) ? cvkMainController.nightThemeScheme.backgroundColor : [UIColor whiteColor];
                    viewToRound.backgroundColor = (enabled && enableNightTheme) ? cvkMainController.nightThemeScheme.backgroundColor : [UIColor whiteColor];
                    viewToRound.layer.cornerRadius = 5.0f;
                    viewToRound.layer.borderWidth = 0.5f;
                    viewToRound.layer.borderColor = (enabled && enableNightTheme) ? [UIColor clearColor].CGColor : [UIColor colorWithWhite:0.85f alpha:1.0f].CGColor;
                    viewToRound.layer.masksToBounds = YES;
                }
            });
            
            void (^configurationHandler)(UITextField *textField) = handler;
            
            configurationHandler(textField);
        };
        CHSuper(1,  UIAlertController, addTextFieldWithConfigurationHandler, newHandler);
        
    } else {
        CHSuper(1,  UIAlertController, addTextFieldWithConfigurationHandler, handler);
    }
}

CHDeclareClass(_UIAlertControllerTextFieldViewController);
CHDeclareMethod(0, void, _UIAlertControllerTextFieldViewController, viewDidLoad)
{
    CHSuper(0, _UIAlertControllerTextFieldViewController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        objc_setAssociatedObject(self.collectionView, "shouldDisableBackgroundColor", @1, OBJC_ASSOCIATION_ASSIGN);
    }
}



CHDeclareClass(VKP2PDetailedView);
CHDeclareMethod(0, void, VKP2PDetailedView, layoutSubviews)
{
    CHSuper(0, VKP2PDetailedView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"VKP2PDetailedView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(NewDialogCell);
CHDeclareMethod(0, void, NewDialogCell, layoutSubviews)
{
    CHSuper(0, NewDialogCell, layoutSubviews);
    setupNewDialogCellFromNightTheme(self);
}

CHDeclareMethod(0, void, NewDialogCell, prepareForReuse)
{
    setupNewDialogCellFromNightTheme(self);
    CHSuper(0, NewDialogCell, prepareForReuse);
}


CHDeclareClass(FreshNewsButton);
CHDeclareMethod(1, id, FreshNewsButton, initWithFrame, CGRect, frame)
{
    FreshNewsButton *button = CHSuper(1, FreshNewsButton, initWithFrame, frame);
    if (enabled && enableNightTheme) {
        [button.button setBackgroundImage:[[button.button backgroundImageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        button.button.imageView.tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
    }
    
    return button;
}

CHDeclareClass(TouchHighlightControl);
CHDeclareMethod(1, id, TouchHighlightControl, initWithFrame, CGRect, frame)
{
    TouchHighlightControl *control = CHSuper(1, TouchHighlightControl, initWithFrame, frame);
    
    if (enabled && enableNightTheme) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (UIView *subview in control.subviews) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    if ([imageView.image.imageAsset.assetName containsString:@"post/settings"]) {
                        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        imageView.tintColor = cvkMainController.nightThemeScheme.textColor;
                    }
                }
            }
        });
    }
    
    return control;
}

CHDeclareClass(CommentSourcePickerController);
CHDeclareMethod(0, void, CommentSourcePickerController, viewDidLayoutSubviews)
{
    CHSuper(0, CommentSourcePickerController, viewDidLayoutSubviews);
    
    if (enabled && enableNightTheme && [self respondsToSelector:@selector(containerView)]) {
        if (self.containerView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.containerView.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            });
        }
    }
}

CHDeclareClass(NewsFeedPostCreationButton);
CHDeclareMethod(2, void, NewsFeedPostCreationButton, setBackgroundColor, UIColor *, color, forState, UIControlState, state)
{
    if (enabled && enableNightTheme) {
            if (state == UIControlStateNormal)
            color = cvkMainController.nightThemeScheme.foregroundColor;
        else if (state == UIControlStateHighlighted)
            color = cvkMainController.nightThemeScheme.backgroundColor;
    }
    
    CHSuper(2, NewsFeedPostCreationButton, setBackgroundColor, color, forState, state);
}

CHDeclareClass(LandingPageController);
CHDeclareMethod(0, void, LandingPageController, viewDidLoad)
{
    CHSuper(0, LandingPageController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        
        for (UIView *subview in self.view.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                [button setBackgroundImage:[[button backgroundImageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                [button setBackgroundImage:[[button backgroundImageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
                button.tintColor = cvkMainController.nightThemeScheme.foregroundColor;
            }
        }
    }
}

CHDeclareClass(UITableViewIndex);
CHDeclareMethod(0, void, UITableViewIndex, layoutSubviews)
{
    CHSuper(0, UITableViewIndex, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"UITableViewIndex")]) {
        self.indexBackgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(SketchViewController);
CHDeclareMethod(0, void, SketchViewController, viewDidLoad)
{
    CHSuper(0, SketchViewController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        if ([self respondsToSelector:@selector(drawView)])
            self.drawView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        
        for (UIView *subview in self.view.subviews) {
            if ([CLASS_NAME(subview) isEqualToString:@"UIView"]) {
                subview.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
            }
        }
    }
}

CHDeclareClass(SketchController);
CHDeclareMethod(0, void, SketchController, viewDidLoad)
{
    CHSuper(0, SketchController, viewDidLoad);
    
    if (enabled && enableNightTheme && [self respondsToSelector:@selector(sketchView)]) {
        self.sketchView.drawView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        self.sketchView.colorPaletteView.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        self.sketchView.colorPaletteView.collectionView.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        self.sketchView.backgroundColor = [UIColor redColor];
        
        for (UIView *subview in self.sketchView.subviews) {
            if ([subview isKindOfClass:[UIToolbar class]]) {
                UIToolbar *toolbar = (UIToolbar *)subview;
                [toolbar setBackgroundImage:[UIImage imageWithColor:cvkMainController.nightThemeScheme.navbackgroundColor] 
                         forToolbarPosition:UIBarPositionAny 
                                 barMetrics:UIBarMetricsDefault];
            }
        }
    }
}

CHDeclareClass(EmojiSelectionView);
CHDeclareMethod(0, void, EmojiSelectionView, layoutSubviews)
{
    CHSuper(0, EmojiSelectionView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"EmojiSelectionView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(LicensesViewController);
CHDeclareMethod(0, void, LicensesViewController, viewDidLoad)
{
    CHSuper(0, LicensesViewController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
}

CHDeclareClass(VKAudioPlayerViewController);
CHDeclareMethod(0, UIStatusBarStyle, VKAudioPlayerViewController, preferredStatusBarStyle)
{
    if (enabled && enableNightTheme)
        return UIStatusBarStyleLightContent;
    
    return CHSuper(0, VKAudioPlayerViewController, preferredStatusBarStyle);
}

CHDeclareMethod(0, void, VKAudioPlayerViewController, viewDidLoad)
{
    CHSuper(0, VKAudioPlayerViewController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        self.pageController.view.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        self.backgroundView.hidden = YES;
        
        UIView *effectView = [[UIView alloc] initWithFrame:self.toolbarView.bounds];
        effectView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.toolbarView.contentView addSubview:effectView];
        [self.toolbarView.contentView sendSubviewToBack:effectView];
        
        for (UIView *subview in self.view.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                subview.hidden = YES;
            }
        }
    }
}

CHDeclareClass(PopupWindowView);
CHDeclareMethod(0, UIView *, PopupWindowView, contentView)
{
    UIView *contentView = CHSuper(0, PopupWindowView, contentView);
    
    if (enabled && enableNightTheme) {
        contentView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
    
    return contentView;
}

CHDeclareClass(VKAudioPlayerControlsViewController);
CHDeclareMethod(0, void, VKAudioPlayerControlsViewController, viewDidLoad)
{
    CHSuper(0, VKAudioPlayerControlsViewController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
            objc_setAssociatedObject(self.pp,   "shouldChangeImageColor", @1, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(self.prev, "shouldChangeImageColor", @1, OBJC_ASSOCIATION_ASSIGN);
            objc_setAssociatedObject(self.next, "shouldChangeImageColor", @1, OBJC_ASSOCIATION_ASSIGN);
    }
}


CHDeclareClass(MasksController);
CHDeclareMethod(0, void, MasksController, viewDidLoad)
{
    CHSuper(0, MasksController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        objc_setAssociatedObject(self.collectionView, "shouldDisableBackgroundColor", @1, OBJC_ASSOCIATION_ASSIGN);
    }
}

CHDeclareMethod(2, UICollectionViewCell *, MasksController, collectionView, UICollectionView *, collectionView, cellForItemAtIndexPath, NSIndexPath *, indexPath)
{
    UICollectionViewCell *cell = CHSuper(2, MasksController, collectionView, collectionView, cellForItemAtIndexPath, indexPath);
    objc_setAssociatedObject(cell, "shouldDisableBackgroundColor", @1, OBJC_ASSOCIATION_ASSIGN);
    return cell;
}

CHDeclareClass(VKPPNoAccessView);
CHDeclareMethod(0, void, VKPPNoAccessView, layoutSubviews)
{
    CHSuper(0, VKPPNoAccessView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"VKPPNoAccessView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(UIImage);
CHDeclareClassMethod(1, UIImage *, UIImage, imageNamed, NSString *, name)
{
    UIImage *orig = CHSuper(1, UIImage, imageNamed, name);
    
    if (enabled && enableNightTheme) {
        if ([orig.imageAsset.assetName containsString:@"badge"]) {
            orig = [orig imageWithTintColor:cvkMainController.nightThemeScheme.backgroundColor];
        }
    }
    
    return orig;
}




#pragma mark Static methods
static void reloadPrefsNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    reloadPrefs();
    if ([cvkMainController.vkMainController respondsToSelector:@selector(dialogsController)]) {
        DialogsController *dialogsController = (DialogsController *)cvkMainController.vkMainController.dialogsController;
        if ([dialogsController respondsToSelector:@selector(tableView)]) {
            [dialogsController.tableView reloadData];
        }
    }
    [cvkMainController reloadSwitch:enabled];
    
    setupTabbar();
}

static void reloadMenuNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL shouldShow = (enabled && !enableNightTheme && enabledMenuImage);
        
        VKMLiveController *menuController = nil;
        if ([cvkMainController.vkMainController isKindOfClass:[UITabBarController class]]) {
            menuController = cvkMainController.vkMenuController;
            
            if (menuController.navigationController.viewControllers.count > 0) {
                if ([menuController.navigationController.viewControllers.lastObject isEqual:menuController]) {
                    [menuController viewWillAppear:YES];
                }
            }
        } else {
            menuController = cvkMainController.vkMainController;
            menuController.view.backgroundColor = (enabled && enableNightTheme) ? cvkMainController.nightThemeScheme.backgroundColor : kMenuCellBackgroundColor;
        }
        
        UITableView *menuTableView = menuController.tableView;
        
        UISearchBar *searchBar = (UISearchBar *)menuTableView.tableHeaderView;
        if (searchBar) {
            shouldShow ? setupUISearchBar(searchBar) : resetUISearchBar(searchBar);
            [menuTableView deselectRowAtIndexPath:menuTableView.indexPathForSelectedRow animated:YES];
        }
        
        NSTimeInterval animationDuration = 0.2f;
        UIViewAnimationOptions options = UIViewAnimationOptionAllowUserInteraction;
        
        if (shouldShow) {
            if (menuTableView) {
                setupUISearchBar(searchBar);
                [menuTableView reloadData];
                menuTableView.backgroundColor = [UIColor clearColor];
            }
            
            [UIView animateWithDuration:animationDuration delay:0 options:options animations:^{
                cvkMainController.menuBackgroundView.alpha = 1.0f;
            } completion:nil];
        } else {
            [UIView animateWithDuration:animationDuration delay:0 options:options animations:^{
                cvkMainController.menuBackgroundView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                if (menuTableView) {
                    if ([cvkMainController.vkMainController isKindOfClass:[UITabBarController class]])
                        menuTableView.backgroundColor = [UIColor colorWithRed:235/255.0f green:237/255.0f blue:240/255.0f alpha:1.0f];
                    else
                        menuTableView.backgroundColor = kMenuCellBackgroundColor;
                    [menuTableView reloadData];
                    resetUISearchBar(searchBar);
                }
            }];
        }
        
        cvkMainController.menuBackgroundView.parallaxEnabled = useMenuParallax;
        cvkMainController.menuBackgroundView.blurBackground = menuUseBackgroundBlur;
        if (shouldShow) {
            [cvkMainController.menuBackgroundView updateViewWithBlackout:menuImageBlackout];
            [cvkMainController.menuBackgroundView addToBack:menuController.view animated:NO];
        }
    });
}

void updateCornerRadius(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    actionChangeCornerRadius();
}

void updateNightTheme(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    [cvkMainController.nightThemeScheme updateForType:[prefs[@"nightThemeType"] integerValue]];
    
    resetTabBar();
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([cvkMainController.vkMainController respondsToSelector:@selector(newsController)]) {
            NewsSelectorController *newsSelector = (NewsSelectorController *)cvkMainController.vkMainController.newsController;
            if ([newsSelector respondsToSelector:@selector(currentViewController)]) {
                MainNewsFeedController *newsController = (MainNewsFeedController *)newsSelector.currentViewController;
                if ([newsController respondsToSelector:@selector(VKMScrollViewReset)]) {
                    [newsController VKMScrollViewReset];
                }
            }
        }
        
        if ([cvkMainController.vkMainController respondsToSelector:@selector(dialogsController)]) {
            DialogsController *dialogsController = (DialogsController *)cvkMainController.vkMainController.dialogsController;
            if ([dialogsController respondsToSelector:@selector(VKMScrollViewReset)]) {
                [dialogsController VKMScrollViewReset];
                [dialogsController VKMScrollViewReloadData];
            }
        }
        
        if ([cvkMainController.vkMainController respondsToSelector:@selector(discoverController)]) {
            VKMTableController *discoverController = (VKMTableController *)cvkMainController.vkMainController.discoverController;
            if ([discoverController respondsToSelector:@selector(VKMScrollViewReset)]) {
                [discoverController VKMScrollViewReset];
                [discoverController VKMScrollViewReloadData];
            }
        }
    });
}

CHConstructor
{
    @autoreleasepool {
//        dlopen([[NSBundle mainBundle] pathForResource:@"FLEXDylib" ofType:@"dylib"].UTF8String, RTLD_NOW);
        
        prefsPath = CVK_PREFS_PATH;
        cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        vksBundle = [NSBundle bundleWithPath:VKS_BUNDLE_PATH];
        cvkFolder = CVK_FOLDER_PATH;
        cvkMainController = [ColoredVKMainController new];
        cvkMainController.nightThemeScheme = [ColoredVKNightThemeColorScheme colorSchemeForType:CVKNightThemeTypeBlack];
        
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:prefsPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:prefsPath]) prefs = [NSMutableDictionary new];
        prefs[@"vkVersion"] = cvkMainController.appVersionDetailed;
        [prefs writeToFile:prefsPath atomically:YES];
        VKSettingsEnabled = (NSClassFromString(@"VKSettings") != nil)?YES:NO;
        
        CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterAddObserver(center, nil, reloadPrefsNotify,  CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), nil, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(center, nil, reloadMenuNotify,   CFSTR("com.daniilpashin.coloredvk2.reload.menu"),   nil, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(center, nil, updateCornerRadius, CFSTR("com.daniilpashin.coloredvk2.update.corners"),nil, CFNotificationSuspensionBehaviorDeliverImmediately);
        CFNotificationCenterAddObserver(center, nil, updateNightTheme,   CFSTR("com.daniilpashin.coloredvk2.night.theme"),   nil, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
}
