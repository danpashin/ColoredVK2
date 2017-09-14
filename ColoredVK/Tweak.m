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



BOOL tweakEnabled = NO;
BOOL VKSettingsEnabled;

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

BOOL useCustomDialogsUnreadColor;
UIColor *dialogsUnreadColor;

UIColor *menuSeparatorColor;
UIColor *barBackgroundColor;
UIColor *barForegroundColor;
UIColor *toolBarBackgroundColor;
UIColor *toolBarForegroundColor;
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

BOOL messagesUseBlur;
BOOL messagesListUseBlur;
BOOL groupsListUseBlur;
BOOL audiosUseBlur;
BOOL friendsUseBlur;
BOOL videosUseBlur;
BOOL settingsUseBlur;
BOOL settingsExtraUseBlur;

BOOL messagesUseBackgroundBlur;
BOOL messagesListUseBackgroundBlur;
BOOL groupsListUseBackgroundBlur;
BOOL audiosUseBackgroundBlur;
BOOL friendsUseBackgroundBlur;
BOOL videosUseBackgroundBlur;
BOOL settingsUseBackgroundBlur;
BOOL settingsExtraUseBackgroundBlur;


CVKCellSelectionStyle menuSelectionStyle;
UIKeyboardAppearance keyboardStyle;

UIBlurEffectStyle messagesBlurStyle;
UIBlurEffectStyle messagesListBlurStyle;
UIBlurEffectStyle groupsListBlurStyle;
UIBlurEffectStyle audiosBlurStyle;
UIBlurEffectStyle friendsBlurStyle;
UIBlurEffectStyle videosBlurStyle;
UIBlurEffectStyle settingsBlurStyle;
UIBlurEffectStyle settingsExtraBlurStyle;

ColoredVKMainController *cvkMainController;



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
    enabledMessagesImage = [prefs[@"enabledMessagesImage"] boolValue];
    hideMenuSeparators = [prefs[@"hideMenuSeparators"] boolValue];
    messagesUseBlur = [prefs[@"messagesUseBlur"] boolValue];
    messagesUseBackgroundBlur = [prefs[@"messagesUseBackgroundBlur"] boolValue];
    
    navbarImageBlackout = [prefs[@"navbarImageBlackout"] floatValue];
    chatImageBlackout = [prefs[@"chatImageBlackout"] floatValue];
    hideMessagesNavBarItems = [prefs[@"hideMessagesNavBarItems"] boolValue];
    changeMenuTextColor = [prefs[@"changeMenuTextColor"] boolValue];
    changeMessagesTextColor = [prefs[@"changeMessagesTextColor"] boolValue];
    useMessageBubbleTintColor = [prefs[@"useMessageBubbleTintColor"] boolValue];
    menuSelectionStyle = prefs[@"menuSelectionStyle"]?[prefs[@"menuSelectionStyle"] integerValue]:CVKCellSelectionStyleTransparent;
    messagesBlurStyle = prefs[@"messagesBlurStyle"]?[prefs[@"messagesBlurStyle"] integerValue]:UIBlurEffectStyleLight;
    
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
    
    showFastDownloadButton = prefs[@"showFastDownloadButton"] ? [prefs[@"showFastDownloadButton"] boolValue] : YES;
    showMenuCell = prefs[@"showMenuCell"] ? [prefs[@"showMenuCell"] boolValue] : YES;
    
    if ([cvkMainController compareAppVersionWithVersion:@"2.4"] == ColoredVKVersionCompareLess)
        showMenuCell = YES;
    
    if (prefs && tweakEnabled) {
       
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
        
        useCustomMessageReadColor = [prefs[@"useCustomMessageReadColor"] boolValue];
        useCustomDialogsUnreadColor = [prefs[@"useCustomDialogsUnreadColor"] boolValue];
        
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
        messageUnreadColor =        [[UIColor savedColorForIdentifier:@"messageReadColor"           fromPrefs:prefs] colorWithAlphaComponent:0.2];
        
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
        dialogsUnreadColor =        [[UIColor savedColorForIdentifier:@"dialogsUnreadColor"         fromPrefs:prefs] colorWithAlphaComponent:0.3];
        
        
        if (cvkMainController.navBarImageView) [cvkMainController.navBarImageView updateViewWithBlackout:navbarImageBlackout];
        
    }
}


void showAlertWithMessage(NSString *message)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:@"ColoredVK 2" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
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
        [blurEffectView addSubview:borderView];
        
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
        }
        
        if (verticalFormat.length > 2) {
            borderView.translatesAutoresizingMaskIntoConstraints = NO;
            [blurEffectView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalFormat options:0 metrics:nil views:@{@"view":borderView}]];
            [blurEffectView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"  options:0 metrics:nil views:@{@"view":borderView}]];
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
        }
    }
}

void setToolBar(UIToolbar *toolbar)
{
    if (enabled && [toolbar respondsToSelector:@selector(setBarTintColor:)]) {
        if (enabledToolBarColor) {
            
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
    
    if (enabled && shouldCustomize) {
        if (reset) {
            void (^removeAllBlur)() = ^void() {
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
        if ([view respondsToSelector:@selector(setImage:forState:)]) [(UIButton*)view setImage:[[(UIButton*)view imageForState:UIControlStateNormal] imageWithTintColor:color] forState:UIControlStateNormal];
        if ([view isKindOfClass:MPVolumeView.class]) {
            MPVolumeSlider *slider = ((MPVolumeView*)view).volumeSlider;
            for (UIView *subview in slider.subviews) {
                if ([subview isKindOfClass:UIImageView.class]) {
                    NSString *assetName = ((UIImageView*)subview).image.imageAsset.assetName;
                    if ([assetName containsString:@"/"]) assetName = [assetName componentsSeparatedByString:@"/"].lastObject;
                    NSArray *namesToPass = @[@"volume_min", @"volume_max", @"volume_min_max"];
                    if ([namesToPass containsObject:assetName]) {
                        ((UIImageView*)subview).image = [((UIImageView*)subview).image imageWithTintColor:color.darkerColor];
                        ((UIImageView*)subview).image.imageAsset.assetName = @"volume_min_max";
                    }
                }
            }
        }
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
    
    
    if (enabled && shouldCustomize) {
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


#pragma mark - AppDelegate
CHDeclareClass(AppDelegate);
CHOptimizedMethod(2, self, BOOL, AppDelegate, application, UIApplication*, application, didFinishLaunchingWithOptions, NSDictionary *, options)
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
        [newInstaller checkStatusAndShowAlert:NO];
    });
    
    return YES;
}

CHOptimizedMethod(1, self, void, AppDelegate, applicationDidBecomeActive, UIApplication *, application)
{    
    CHSuper(1, AppDelegate, applicationDidBecomeActive, application);
    
    actionChangeCornerRadius();
    
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    [newInstaller updateAccountInfo:^{
        [newInstaller checkStatusAndShowAlert:NO];
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ColoredVKUpdatesController *updatesController = [ColoredVKUpdatesController new];
        if (updatesController.shouldCheckUpdates)
            [updatesController checkUpdates];
    });
    
    if (cvkMainController.audioCover) {
        [cvkMainController.audioCover updateColorScheme];
    }
    
    [cvkMainController sendStats];
    [cvkMainController checkCrashes];
}



#pragma mark UINavigationBar
CHDeclareClass(UINavigationBar);
CHOptimizedMethod(1, self, void, UINavigationBar, setBarTintColor, UIColor*, barTintColor)
{
    if (enabled) {
        if (enabledBarImage) {
            if (cvkMainController.navBarImageView) barTintColor = [UIColor colorWithPatternImage:cvkMainController.navBarImageView.imageView.image];
            else barTintColor = barBackgroundColor;
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL containsImageView = [self._backgroundView.subviews containsObject:[self._backgroundView viewWithTag:24]];
                BOOL containsBlur = [self._backgroundView.subviews containsObject:[self._backgroundView viewWithTag:10]];
                BOOL isAudioController = (changeAudioPlayerAppearance && (self.tag == 26));
                
                if (!containsBlur && !containsImageView && !isAudioController) {
                    if (!cvkMainController.navBarImageView) {
                        cvkMainController.navBarImageView = [ColoredVKWallpaperView viewWithFrame:self._backgroundView.bounds imageName:@"barImage" blackout:navbarImageBlackout];
                        cvkMainController.navBarImageView.tag = 24;
                        cvkMainController.navBarImageView.backgroundColor = [UIColor clearColor];
                    }
                    [cvkMainController.navBarImageView addToView:self._backgroundView animated:NO];
                
                } else if (containsBlur || isAudioController) [cvkMainController.navBarImageView removeFromSuperview];
            });
        }
        else if (enabledBarColor) {
            barTintColor = barBackgroundColor;
            [cvkMainController.navBarImageView removeFromSuperview];
        }
    } else [cvkMainController.navBarImageView removeFromSuperview];
    
    CHSuper(1, UINavigationBar, setBarTintColor, barTintColor);
}

CHOptimizedMethod(1, self, void, UINavigationBar, setTintColor, UIColor*, tintColor)
{
    if (enabled && enabledBarColor) {
        self.barTintColor = self.barTintColor;
        tintColor = barForegroundColor;
    }
    
    CHSuper(1, UINavigationBar, setTintColor, tintColor);
}

CHOptimizedMethod(1, self, void, UINavigationBar, setTitleTextAttributes, NSDictionary*, attributes)
{
    if (enabled && enabledBarColor) {
        attributes = @{NSForegroundColorAttributeName:barForegroundColor};
    }
    
    CHSuper(1, UINavigationBar, setTitleTextAttributes, attributes);
}


#pragma mark UITextInputTraits
CHDeclareClass(UITextInputTraits);
CHOptimizedMethod(0, self, UIKeyboardAppearance, UITextInputTraits, keyboardAppearance) 
{
    if (enabled && (keyboardStyle != UIKeyboardAppearanceDefault))
        return keyboardStyle;
    
    return CHSuper(0, UITextInputTraits, keyboardAppearance);
}


#pragma mark UISwitch
CHDeclareClass(UISwitch);
CHOptimizedMethod(0, self, void, UISwitch, layoutSubviews)
{
    CHSuper(0, UISwitch, layoutSubviews);
    
    if ([self isKindOfClass:[UISwitch class]]) {
        if (enabled && changeSwitchColor) {
            self.onTintColor = switchesOnTintColor;
            self.tintColor = switchesTintColor;
            self.thumbTintColor = nil;
        } else {
            self.tintColor = nil;
            self.thumbTintColor = nil;
            if (self.tag == 228) self.onTintColor = CVKMainColor;
            else self.onTintColor = nil;
        }
    }
}


#pragma mark VKMLiveController 
CHDeclareClass(VKMLiveController);
CHOptimizedMethod(1, self, void, VKMLiveController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMLiveController, viewWillAppear, animated);
    
    if (enabled && [self isKindOfClass:NSClassFromString(@"VKMLiveController")]) {
        NSArray <NSString *> *audioModelNames = @[@"AudioRecommendationsModel", @"AudioCatalogPlaylistsListModel", @"AudioCatalogExtendedPlaylistsListModel"];
        if (enabledAudioImage && [audioModelNames containsObject:CLASS_NAME(self.model)]) {
           UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
            if ([search isKindOfClass:[UISearchBar class]]) {
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

CHOptimizedMethod(0, self, void, VKMLiveController, viewWillLayoutSubviews)
{
    CHSuper(0, VKMLiveController, viewWillLayoutSubviews);
    
    if (enabled && [self isKindOfClass:NSClassFromString(@"VKMLiveController")]) {
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

CHOptimizedMethod(2, self, UITableViewCell*, VKMLiveController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMLiveController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && [self isKindOfClass:NSClassFromString(@"VKMLiveController")]) {
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
CHOptimizedMethod(1, self, void, VKMTableController, viewWillAppear, BOOL, animated)
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
                                              @"AboutViewController", @"ModernPushSettingsController", @"VKP2PViewController"];
        
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
        } else shouldAddBlur = NO;
    } else shouldAddBlur = NO;
    
    resetNavigationBar(self.navigationController.navigationBar);
    setBlur(self.navigationController.navigationBar, shouldAddBlur, blurColor, blurStyle);
}

#pragma mark VKMToolbarController
    // Настройка тулбара
CHDeclareClass(VKMToolbarController);
CHOptimizedMethod(1, self, void, VKMToolbarController, viewWillAppear, BOOL, animated)
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
        
        setBlur(self.toolbar, shouldAddBlur, blurColor, blurStyle);
    }
}

#pragma mark NewsFeedController
CHDeclareClass(NewsFeedController);
CHOptimizedMethod(0, self, BOOL, NewsFeedController, VKMTableFullscreenEnabled)
{
    if (enabled && showBar) return NO; 
    return CHSuper(0, NewsFeedController, VKMTableFullscreenEnabled);
}
CHOptimizedMethod(0, self, BOOL, NewsFeedController, VKMScrollViewFullscreenEnabled)
{
    if (enabled && showBar) return NO;
    return CHSuper(0, NewsFeedController, VKMScrollViewFullscreenEnabled);
}

#pragma mark PhotoFeedController
CHDeclareClass(PhotoFeedController);
CHOptimizedMethod(0, self, BOOL, PhotoFeedController, VKMTableFullscreenEnabled)
{
    if (enabled && showBar) return NO; 
    return CHSuper(0, PhotoFeedController, VKMTableFullscreenEnabled);
}
CHOptimizedMethod(0, self, BOOL, PhotoFeedController, VKMScrollViewFullscreenEnabled)
{
    if (enabled && showBar) return NO; 
    return CHSuper(0, PhotoFeedController, VKMScrollViewFullscreenEnabled);
}


#pragma mark GroupsController - список групп
CHDeclareClass(GroupsController);
CHOptimizedMethod(0, self, void, GroupsController, viewWillLayoutSubviews)
{
    CHSuper(0, GroupsController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"GroupsController")]) {
        if (enabled && enabledGroupsListImage) {
            [ColoredVKMainController setImageToTableView:self.tableView withName:@"groupsListBackgroundImage" blackout:groupsListImageBlackout
                                          parallaxEffect:useGroupsListParallax blurBackground:groupsListUseBackgroundBlur];
            self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
            self.tableView.separatorColor = (enabled && hideGroupsListSeparators)?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
            self.segment.alpha = 0.9;
            
            UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;search.backgroundImage = [UIImage new];
            search.scopeBarBackgroundImage = [UIImage new];
            search.tag = 2;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            NSDictionary *attributes = @{NSForegroundColorAttributeName:changeGroupsListTextColor?groupsListTextColor:[UIColor colorWithWhite:1 alpha:0.7]};
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder attributes:attributes];
            
            if ([cvkMainController compareAppVersionWithVersion:@"2.5"] <= ColoredVKVersionCompareEqual) {
                for (UIView *view in self.view.subviews) {
                         if ([view isKindOfClass:[UIToolbar class]] && groupsListUseBlur) { setBlur(view, YES, groupsListBlurTone, groupsListBlurStyle); break; }
                    else if ([view isKindOfClass:[UIToolbar class]] && enabledToolBarColor) { setToolBar((UIToolbar*)view); break; } 
                }
            }
            
        }
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, GroupsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, GroupsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"GroupsController")] && (enabled && enabledGroupsListImage)) {
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

CHOptimizedMethod(0, self, void, DialogsController, viewWillLayoutSubviews)
{
    CHSuper(0, DialogsController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")] && ([cvkMainController compareAppVersionWithVersion:@"3.0"] < 0)) {
        if (enabled && enabledMessagesListImage) {
            [ColoredVKMainController setImageToTableView:self.tableView withName:@"messagesListBackgroundImage" blackout:chatListImageBlackout 
                                          parallaxEffect:useMessagesListParallax blurBackground:messagesListUseBackgroundBlur];
        }
    }
}

CHOptimizedMethod(1, self, void, DialogsController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DialogsController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")]) {
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if (![search isKindOfClass:[UISearchBar class]])
            search = nil;
        else
            search.tag = 1;
        
        UIColor *placeholderColor = changeMessagesListTextColor?messagesListTextColor:[UIColor colorWithWhite:1 alpha:0.7];
        if (enabled && enabledMessagesListImage) {
            self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
            self.tableView.separatorColor = (enabled && hideMessagesListSeparators)?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
            
            if (search) {
                search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
                search.backgroundImage = [UIImage new];
                search._scopeBarBackgroundView.superview.hidden = YES;
            }
            
        } else if ([cvkMainController compareAppVersionWithVersion:@"3.0"] >= 0) {
            self.rptr.tintColor = nil;
            self.tableView.separatorColor = [UIColor colorWithRed:215/255.0f green:216/255.0f blue:217/255.0f alpha:1.0f];
            if (search) {
                placeholderColor = [UIColor colorWithRed:0.556863 green:0.556863 blue:0.576471 alpha:1.0f];
                search.searchBarTextField.backgroundColor = nil;
                search._scopeBarBackgroundView.superview.hidden = NO;
                search.backgroundImage = [UIImage imageWithColor:[UIColor colorWithRed:235/255.0f green:237/255.0f blue:240/255.0f alpha:1.0f]];
            }
        }
        
        if (search) {
            NSMutableAttributedString *placeholder = [search.searchBarTextField.attributedPlaceholder mutableCopy];
            [placeholder addAttribute:NSForegroundColorAttributeName value:placeholderColor range:NSMakeRange(0, placeholder.mutableString.length)];
            search.searchBarTextField.attributedPlaceholder = placeholder;
        }
        
        if ([cvkMainController compareAppVersionWithVersion:@"3.0"] >= 0) {
            if (enabled && enabledMessagesListImage) {
                [ColoredVKMainController setImageToTableView:self.tableView withName:@"messagesListBackgroundImage" blackout:chatListImageBlackout 
                                              parallaxEffect:useMessagesListParallax blurBackground:messagesListUseBackgroundBlur];
             } else
                 self.tableView.backgroundView = nil;
        }
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, DialogsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")] && enabled) {
        NewDialogCell *cell = (NewDialogCell *)CHSuper(2, DialogsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
        if (enabledMessagesListImage) {
            performInitialCellSetup(cell);
            cell.backgroundView.hidden = YES;
            
            if (!cell.dialog.head.read_state && cell.unread.hidden) cell.contentView.backgroundColor = useCustomDialogsUnreadColor?dialogsUnreadColor:[UIColor defaultColorForIdentifier:@"dialogsUnreadColor"];
            else cell.contentView.backgroundColor = [UIColor clearColor];
            
            cell.name.textColor = changeMessagesListTextColor?messagesListTextColor:[UIColor colorWithWhite:1 alpha:0.9];
            cell.time.textColor = cell.name.textColor;
            cell.attach.textColor = changeMessagesListTextColor?messagesListTextColor:[UIColor colorWithWhite:0.95 alpha:0.9];
            if ([cell respondsToSelector:@selector(dialogText)]) cell.dialogText.textColor = cell.attach.textColor;
            if ([cell respondsToSelector:@selector(text)]) cell.text.textColor = cell.attach.textColor;
        }
        return cell;
    }
    return CHSuper(2, DialogsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
}

#pragma mark BackgroundView
CHDeclareClass(BackgroundView);
CHOptimizedMethod(1, self, void, BackgroundView, drawRect, CGRect, rect)
{
    if (enabled) {
        self.layer.cornerRadius = self.cornerRadius;
        self.layer.masksToBounds = YES;
        if (enabledMessagesListImage)
            self.layer.backgroundColor = useCustomDialogsUnreadColor ? dialogsUnreadColor.CGColor : [UIColor defaultColorForIdentifier:@"messageReadColor"].CGColor;
        else
            CHSuper(1, BackgroundView, drawRect, rect);
    } else CHSuper(1, BackgroundView, drawRect, rect);
}

#pragma mark DetailController + тулбар
CHDeclareClass(DetailController);
CHOptimizedMethod(1, self, void, DetailController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DetailController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"DetailController")]) setToolBar(self.inputPanel);
}


#pragma mark ChatController + тулбар
CHDeclareClass(ChatController);
CHOptimizedMethod(1, self, void, ChatController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, ChatController, viewWillAppear, animated);
    
    if ([self isKindOfClass:NSClassFromString(@"ChatController")]) {
        setToolBar(self.inputPanel);
        if (enabled && messagesUseBlur)
            setBlur(self.inputPanel, YES, messagesBlurTone, messagesBlurStyle);
        
//        for (UIView *subview in self.inputPanel.subviews) {
//            if ([subview isKindOfClass:NSClassFromString(@"DefaultHighlightButton")]) {
//                UIButton *button = (UIButton *)subview;
//                [button setImage:[[button imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//                button.imageView.tintColor = self.inputPanel.tintColor;
//            }
//            if ([subview isKindOfClass:[UITextView class]]) {
//                UITextView *textView = (UITextView *)subview;
//                textView.backgroundColor = [UIColor clearColor];
//                textView.textColor = self.inputPanel.tintColor;
//            }
//            if ([CLASS_NAME(subview) isEqualToString:@"UIView"]) {
//                subview.backgroundColor = [UIColor clearColor];
//            }
//        }
    }
}

CHOptimizedMethod(0, self, void, ChatController, viewWillLayoutSubviews)
{
    CHSuper(0, ChatController, viewWillLayoutSubviews);
    
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

CHOptimizedMethod(2, self, UITableViewCell*, ChatController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ChatController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled) {
        if (enabledMessagesImage) {
            for (id view in cell.contentView.subviews) { 
                if ([view respondsToSelector:@selector(setTextColor:)]) [view setTextColor:changeMessagesTextColor?messagesTextColor:[UIColor colorWithWhite:1 alpha:0.7]]; 
            }
            if ([CLASS_NAME(cell) isEqualToString:@"UITableViewCell"]) cell.backgroundColor = [UIColor clearColor];
        }
    }
    
    return cell;
}

CHOptimizedMethod(0, self, UIButton*, ChatController, editForward)
{
    UIButton *forwardButton = CHSuper(0, ChatController, editForward);
    if (enabled && messagesUseBlur) {
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
CHOptimizedMethod(1, self, void, MessageCell, updateBackground, BOOL, animated)
{
    CHSuper(1, MessageCell, updateBackground, animated);
    
    if (enabled && enabledMessagesImage) {
        self.backgroundView = nil;
        if (!self.message.read_state)
            self.backgroundColor = useCustomMessageReadColor ? messageUnreadColor : [UIColor defaultColorForIdentifier:@"messageReadColor"];
        else
            self.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark ChatCell
CHDeclareClass(ChatCell);
CHOptimizedMethod(0, self, void, ChatCell, setBG)
{
    self.bg.alpha = 0.f;
    
    CHSuper(0, ChatCell, setBG);
    
    if (enabled && useMessageBubbleTintColor) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.bg.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                self.bg.image = [self.bg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            self.bg.tintColor = self.message.incoming ? messageBubbleTintColor : messageBubbleSentTintColor;
        });
    }
    self.bg.alpha = 1.f;
}



#pragma mark VKMMainController
CHDeclareClass(VKMMainController);
CHOptimizedMethod(0, self, NSArray*, VKMMainController, menu)
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

CHOptimizedMethod(0, self, void, VKMMainController, viewDidLoad)
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
                                                                                       imageName:@"menuBackgroundImage" blackout:menuImageBlackout enableParallax:useMenuParallax blurBackground:NO];
        }
        
        if (enabled && enabledMenuImage) {
            [cvkMainController.menuBackgroundView addToBack:self.view animated:NO];
            setupUISearchBar((UISearchBar*)self.tableView.tableHeaderView);
            self.tableView.backgroundColor = [UIColor clearColor];
        }
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, VKMMainController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMMainController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    NSDictionary *identifiers = @{@"customCell" : @228, @"cvkMenuCell": @405};
    if ([identifiers.allKeys containsObject:cell.reuseIdentifier]) {
        UISwitch *switchView = [cell viewWithTag:[identifiers[cell.reuseIdentifier] integerValue]];
        if ([switchView isKindOfClass:[UISwitch class]]) [switchView layoutSubviews];
    }
    
    
    if (enabled && hideMenuSeparators) tableView.separatorColor = [UIColor clearColor]; 
    else if (enabled && !hideMenuSeparators) tableView.separatorColor = menuSeparatorColor; 
    else tableView.separatorColor = kMenuCellSeparatorColor;
    
    if (enabled && enabledMenuImage) {
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

CHOptimizedMethod(0, self, id, VKMMainController, VKMTableCreateSearchBar)
{
    if (enabled && hideMenuSearch) return nil;
    return CHSuper(0, VKMMainController, VKMTableCreateSearchBar);
}



#pragma mark MenuViewController
CHDeclareClass(MenuViewController);
CHOptimizedMethod(0, self, void, MenuViewController, viewDidLoad)
{
    CHSuper(0, MenuViewController, viewDidLoad);
    if (!cvkMainController.vkMenuController)
        cvkMainController.vkMenuController = self;
    
    if (!cvkMainController.menuBackgroundView) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        CGFloat width = (bounds.size.width > bounds.size.height)?bounds.size.height:bounds.size.width;
        CGFloat height = (bounds.size.width < bounds.size.height)?bounds.size.height:bounds.size.width;
        cvkMainController.menuBackgroundView = [[ColoredVKWallpaperView alloc] initWithFrame:CGRectMake(0, 0, width, height) 
                                                                                   imageName:@"menuBackgroundImage" blackout:menuImageBlackout enableParallax:useMenuParallax blurBackground:NO];
    }
    
    if (enabled && enabledMenuImage) {
        [cvkMainController.menuBackgroundView addToBack:self.view animated:NO];
        self.tableView.backgroundColor = [UIColor clearColor];
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, MenuViewController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, MenuViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && hideMenuSeparators) tableView.separatorColor = [UIColor clearColor]; 
    else if (enabled && !hideMenuSeparators) tableView.separatorColor = menuSeparatorColor; 
    else tableView.separatorColor = [UIColor colorWithRed:215/255.0f green:216/255.0f blue:217/255.0 alpha:1.0f];
    
    if (enabled && enabledMenuImage) {
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
        
    } else {
        cell.imageView.tintColor = [UIColor colorWithRed:0.667f green:0.682f blue:0.702f alpha:1.0f];
        cell.backgroundColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor blackColor];
        
        cell.selectedBackgroundView = nil;
    }
    
    return cell;
}





#pragma mark  HintsSearchDisplayController
CHDeclareClass(HintsSearchDisplayController);
CHOptimizedMethod(1, self, void, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch, UISearchDisplayController*, controller)
{
    if (enabled && enabledMenuImage) resetUISearchBar(controller.searchBar);
    CHSuper(1, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch, controller);
}

CHOptimizedMethod(1, self, void, HintsSearchDisplayController, searchDisplayControllerDidEndSearch, UISearchDisplayController*, controller)
{
    if (enabled && enabledMenuImage) setupUISearchBar(controller.searchBar);
    CHSuper(1, HintsSearchDisplayController, searchDisplayControllerDidEndSearch, controller);
}



#pragma mark - AUDIO

#pragma mark IOS7AudioController
CHDeclareClass(IOS7AudioController);
CHOptimizedMethod(0, self, UIStatusBarStyle, IOS7AudioController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"IOS7AudioController")] && ( enabled && (enabledBarColor || changeAudioPlayerAppearance))) return UIStatusBarStyleLightContent;
    else return CHSuper(0, IOS7AudioController, preferredStatusBarStyle);
}

CHOptimizedMethod(0, self, void, IOS7AudioController, viewWillLayoutSubviews)
{
    CHSuper(0, IOS7AudioController, viewWillLayoutSubviews);
    
    if ([self isKindOfClass:NSClassFromString(@"IOS7AudioController")] && (enabled && changeAudioPlayerAppearance)) {
        if (!cvkMainController.audioCover) {
            cvkMainController.audioCover = [[ColoredVKAudioCover alloc] init];
            [cvkMainController.audioCover updateCoverForArtist:self.actor.text title:self.song.text];
        }
        [cvkMainController.audioCover updateViewFrame:self.view.frame andSeparationPoint:self.hostView.frame.origin];
        [cvkMainController.audioCover addToView:self.view];
    }
}

CHOptimizedMethod(0, self, void, IOS7AudioController, viewDidLoad)
{
    CHSuper(0, IOS7AudioController, viewDidLoad);
    
    if ([self isKindOfClass:NSClassFromString(@"IOS7AudioController")] && (enabled && changeAudioPlayerAppearance)) {
        if (!cvkMainController.audioCover) {
            cvkMainController.audioCover = [[ColoredVKAudioCover alloc] init];
            [cvkMainController.audioCover updateCoverForArtist:self.actor.text title:self.song.text];
        }
        [cvkMainController.audioCover updateViewFrame:self.view.frame andSeparationPoint:self.hostView.frame.origin];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *ppImage = [[self.pp imageForState:UIControlStateSelected] imageWithTintColor:audioPlayerTintColor];
            UIImage *minimumTrackImage = [[self.seek minimumTrackImageForState:UIControlStateNormal] imageWithTintColor:[UIColor colorWithRed:229/255.0f green:230/255.0f blue:231/255.0f alpha:1]];
            UIImage *maximumTrackImage = [[self.seek maximumTrackImageForState:UIControlStateNormal] imageWithTintColor:[UIColor colorWithRed:200/255.0f green:201/255.0f blue:202/255.0f alpha:1]];
            UIImage *thumbImage = [[self.seek thumbImageForState:UIControlStateNormal] imageWithTintColor:[UIColor blackColor]];
            
            [self.pp setImage:ppImage forState:UIControlStateSelected];
            [self.seek setMinimumTrackImage:minimumTrackImage forState:UIControlStateNormal];
            [self.seek setMaximumTrackImage:maximumTrackImage forState:UIControlStateNormal];
            [self.seek setThumbImage:thumbImage forState:UIControlStateNormal];
        });
        
        cvkMainController.audioCover.updateCompletionBlock = ^(ColoredVKAudioCover *cover) {
            audioPlayerTintColor = cvkMainController.audioCover.color;
            [self.pp setImage:[[self.pp imageForState:UIControlStateSelected] imageWithTintColor:audioPlayerTintColor] forState:UIControlStateSelected];
            setupAudioPlayer(self.hostView, audioPlayerTintColor);
        };
    }
}

#pragma mark AudioPlayer
CHDeclareClass(AudioPlayer);
CHOptimizedMethod(2, self, void, AudioPlayer, switchTo, int, arg1, force, BOOL, force)
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
CHOptimizedMethod(1, self, void, VKAudioQueuePlayer, switchTo, int, arg1)
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
CHOptimizedMethod(0, self, void, AudioAlbumController, viewDidLoad)
{
    CHSuper(0, AudioAlbumController, viewDidLoad);
    
    if ((enabled && enabledAudioImage) && ([self isKindOfClass:NSClassFromString(@"AudioAlbumController")] || [self isKindOfClass:NSClassFromString(@"AudioAlbumsController")])) {
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if (search) {
            search.backgroundImage = [UIImage new];
            search.tag = 3;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            NSDictionary *attributes = @{NSForegroundColorAttributeName: changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1 alpha:0.7]};
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder attributes:attributes];
            search._scopeBarBackgroundView.superview.hidden = YES;
        }
    }
}
CHOptimizedMethod(0, self, void, AudioAlbumController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioAlbumController, viewWillLayoutSubviews);
    
    if ((enabled && enabledAudioImage) && ([self isKindOfClass:NSClassFromString(@"AudioAlbumController")] || [self isKindOfClass:NSClassFromString(@"AudioAlbumsController")])) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor =  hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, AudioAlbumController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioAlbumController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ((enabled && enabledAudioImage) && ([self isKindOfClass:NSClassFromString(@"AudioAlbumController")] || [self isKindOfClass:NSClassFromString(@"AudioAlbumsController")])) {
        performInitialCellSetup(cell);
            
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1 alpha:0.9];
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:0.8 alpha:0.9];
    }
    
    return cell;
}


#pragma mark AudioPlaylistController
CHDeclareClass(AudioPlaylistController);
CHOptimizedMethod(0, self, UIStatusBarStyle, AudioPlaylistController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"AudioPlaylistController")] && (enabled && (enabledBarColor || enabledAudioImage))) return UIStatusBarStyleLightContent;
    else return CHSuper(0, AudioPlaylistController, preferredStatusBarStyle);
}
CHOptimizedMethod(1, self, void, AudioPlaylistController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, AudioPlaylistController, viewWillAppear, animated);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioPlaylistController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, AudioPlaylistController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioPlaylistController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioPlaylistController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1 alpha:0.9];
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:0.8 alpha:0.9];
    }
    
    return cell;
}

#pragma mark AudioRenderer
CHDeclareClass(AudioRenderer);
CHOptimizedMethod(0, self, UIButton*, AudioRenderer, playIndicator)
{
    UIButton *indicator = CHSuper(0, AudioRenderer, playIndicator);
    if (enabled && enabledAudioImage) {
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
CHOptimizedMethod(0, self, void, AudioDashboardController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioDashboardController, viewWillLayoutSubviews);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioDashboardController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, AudioDashboardController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioDashboardController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioDashboardController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
    }
    
    return cell;
}

#pragma mark AudioCatalogController
CHDeclareClass(AudioCatalogController);
CHOptimizedMethod(0, self, void, AudioCatalogController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioCatalogController, viewWillLayoutSubviews);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioCatalogController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
}


CHOptimizedMethod(2, self, UITableViewCell*, AudioCatalogController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioCatalogController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioCatalogController")]) {
        performInitialCellSetup(cell);
        
        if ([cell respondsToSelector:@selector(headerView)] && [[cell valueForKey:@"headerView"] isKindOfClass:NSClassFromString(@"AudioBlockCellHeaderView")]) {
            AudioBlockCellHeaderView *headerView = [cell valueForKey:@"headerView"];
            headerView.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            headerView.subtitleLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
            [headerView.showAllButton setTitleColor:changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor forState:UIControlStateNormal];
        }
    }
    
    return cell;
}

#pragma mark AudioCatalogOwnersListController
CHDeclareClass(AudioCatalogOwnersListController);
CHOptimizedMethod(0, self, void, AudioCatalogOwnersListController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioCatalogOwnersListController, viewWillLayoutSubviews);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioCatalogOwnersListController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, AudioCatalogOwnersListController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioCatalogOwnersListController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioCatalogOwnersListController")]) {
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
CHOptimizedMethod(0, self, void, AudioCatalogAudiosListController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioCatalogAudiosListController, viewWillLayoutSubviews);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioCatalogAudiosListController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, AudioCatalogAudiosListController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioCatalogAudiosListController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioCatalogAudiosListController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
    }
    
    return cell;
}



#pragma mark AudioPlaylistDetailController
CHDeclareClass(AudioPlaylistDetailController);
CHOptimizedMethod(0, self, void, AudioPlaylistDetailController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioPlaylistDetailController, viewWillLayoutSubviews);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioPlaylistDetailController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, AudioPlaylistDetailController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioPlaylistDetailController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioPlaylistDetailController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
    }
    
    return cell;
}

#pragma mark AudioPlaylistsController
CHDeclareClass(AudioPlaylistsController);
CHOptimizedMethod(0, self, void, AudioPlaylistsController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioPlaylistsController, viewWillLayoutSubviews);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioPlaylistsController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
        
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if (search) {
            search.backgroundImage = [UIImage new];
            search.tag = 3;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            NSDictionary *attributes = @{NSForegroundColorAttributeName: changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1 alpha:0.7]};
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder attributes:attributes];
            search._scopeBarBackgroundView.superview.hidden = YES;
        }
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, AudioPlaylistsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioPlaylistsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioPlaylistsController")]) {
        performInitialCellSetup(cell);
    }
    
    return cell;
}

#pragma mark VKAudioPlayerListTableViewController
CHDeclareClass(VKAudioPlayerListTableViewController);
CHOptimizedMethod(0, self, void, VKAudioPlayerListTableViewController, viewWillLayoutSubviews)
{
    CHSuper(0, VKAudioPlayerListTableViewController, viewWillLayoutSubviews);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"VKAudioPlayerListTableViewController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout 
                                      parallaxEffect:useAudioParallax blurBackground:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, VKAudioPlayerListTableViewController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKAudioPlayerListTableViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"VKAudioPlayerListTableViewController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
    }
    
    return cell;
}




#pragma mark AudioAudiosBlockTableCell
CHDeclareClass(AudioAudiosBlockTableCell);
CHOptimizedMethod(0, self, void, AudioAudiosBlockTableCell, layoutSubviews)
{
    CHSuper(0, AudioAudiosBlockTableCell, layoutSubviews);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioAudiosBlockTableCell")]) {
        performInitialCellSetup(self);
        self.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        self.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
    }
}

#pragma mark AudioPlaylistInlineCell
CHDeclareClass(AudioPlaylistInlineCell);
CHOptimizedMethod(0, self, void, AudioPlaylistInlineCell, layoutSubviews)
{
    CHSuper(0, AudioPlaylistInlineCell, layoutSubviews);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioPlaylistInlineCell")]) {
        self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        self.subtitleLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
    }
}

#pragma mark AudioOwnersBlockItemCollectionCell
CHDeclareClass(AudioOwnersBlockItemCollectionCell);
CHOptimizedMethod(0, self, void, AudioOwnersBlockItemCollectionCell, layoutSubviews)
{
    CHSuper(0, AudioOwnersBlockItemCollectionCell, layoutSubviews);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioOwnersBlockItemCollectionCell")]) {
        self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
    }
}


#pragma mark AudioPlaylistCell
CHDeclareClass(AudioPlaylistCell);
CHOptimizedMethod(0, self, void, AudioPlaylistCell, layoutSubviews)
{
    CHSuper(0, AudioPlaylistCell, layoutSubviews);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioPlaylistCell")]) {
        performInitialCellSetup(self);
        self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        self.artistLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        self.subtitleLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
   }
}


#pragma mark AudioPlaylistsCell
CHDeclareClass(AudioPlaylistsCell);
CHOptimizedMethod(0, self, void, AudioPlaylistsCell, layoutSubviews)
{
    CHSuper(0, AudioPlaylistsCell, layoutSubviews);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioPlaylistsCell")]) {
        performInitialCellSetup(self);
        self.hostedView.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        [self.showAllButton setTitleColor:changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor forState:UIControlStateNormal];
    }
}

#pragma mark AudioAudiosSpecialBlockView
CHDeclareClass(AudioAudiosSpecialBlockView);
CHOptimizedMethod(0, self, void, AudioAudiosSpecialBlockView, layoutSubviews)
{
    CHSuper(0, AudioAudiosSpecialBlockView, layoutSubviews);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioAudiosSpecialBlockView")]) {        
        self.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        self.subtitleLabel.textColor = changeAudiosTextColor?audiosTextColor.darkerColor:UITableViewCellDetailedTextColor;
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
CHOptimizedMethod(0, self, void, AudioPlaylistView, layoutSubviews)
{
    CHSuper(0, AudioPlaylistView, layoutSubviews);
    
    if ((enabled && enabledAudioImage) && [self isKindOfClass:NSClassFromString(@"AudioPlaylistView")]) {        
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
CHOptimizedMethod(1, self, void, PhotoBrowserController, viewWillAppear, BOOL, animated)
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

CHOptimizedMethod(0, self, UIStatusBarStyle, VKMBrowserController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"VKMBrowserController")] && (enabled && enabledBarColor)) return UIStatusBarStyleLightContent;
    else return CHSuper(0, VKMBrowserController, preferredStatusBarStyle);
}

CHOptimizedMethod(1, self, void, VKMBrowserController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMBrowserController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"VKMBrowserController")]) {
        if (showFastDownloadButton) {
            ColoredVKBarDownloadButton *saveButton = [ColoredVKBarDownloadButton buttonWithURL:self.target.url.absoluteString rootController:self];
            self.navigationItem.rightBarButtonItem = saveButton;
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:self.target.url] queue:[NSOperationQueue mainQueue] 
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                       if (![[response.MIMEType componentsSeparatedByString:@"/"].firstObject isEqualToString:@"image"]) self.navigationItem.rightBarButtonItem = nil;
                                   }];
            
        }
        
        if (enabled && enabledBarColor) {
            for (UIView *view in self.navigationItem.titleView.subviews) if ([view respondsToSelector:@selector(setTextColor:)]) ((UILabel*)view).textColor = barForegroundColor;
        }
        resetNavigationBar(self.navigationController.navigationBar);
    }
}


#pragma mark VKGroupProfile
CHDeclareClass(VKGroupProfile);
CHOptimizedMethod(0, self, BOOL, VKGroupProfile, verified)
{
    if ([self.group.gid isEqual:@55161589])
        return YES;
    return CHSuper(0, VKGroupProfile, verified);
}

#pragma mark VKProfile
CHDeclareClass(VKProfile);
CHOptimizedMethod(0, self, BOOL, VKProfile, verified)
{
    NSArray *verifiedUsers = @[@89911723, @93264161, @125879328, @73369298, @147469494, @283990174];
    if ([verifiedUsers containsObject:self.user.uid])
        return YES;
    return CHSuper(0, VKProfile, verified);
}

#pragma mark UserWallController
CHDeclareClass(UserWallController);
CHOptimizedMethod(0, self, void, UserWallController, updateProfile)
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
                    titleView.tintColor = barForegroundColor;
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
CHOptimizedMethod(1, self, void, VKMLiveSearchController, searchDisplayControllerWillBeginSearch, UISearchDisplayController*, controller)
{
    CHSuper(1, VKMLiveSearchController, searchDisplayControllerWillBeginSearch, controller);
    setupSearchController(controller, NO);
}

CHOptimizedMethod(1, self, void, VKMLiveSearchController, searchDisplayControllerWillEndSearch, UISearchDisplayController*, controller)
{
    setupSearchController(controller, YES);
    CHSuper(1, VKMLiveSearchController, searchDisplayControllerWillEndSearch, controller);
}

CHOptimizedMethod(2, self, UITableViewCell*, VKMLiveSearchController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMLiveSearchController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    setupCellForSearchController(cell, self);    
    return cell;
}

#pragma mark DialogsSearchController
CHDeclareClass(DialogsSearchController);
CHOptimizedMethod(1, self, void, DialogsSearchController, searchDisplayControllerWillBeginSearch, UISearchDisplayController*, controller)
{
    CHSuper(1, DialogsSearchController, searchDisplayControllerWillBeginSearch, controller);
    setupSearchController(controller, NO);
    if (enabled && enabledMessagesImage) controller.searchResultsTableView.separatorColor = [controller.searchResultsTableView.separatorColor colorWithAlphaComponent:0.2];
}

CHOptimizedMethod(1, self, void, DialogsSearchController, searchDisplayControllerWillEndSearch, UISearchDisplayController*, controller)
{
    setupSearchController(controller, YES);
    CHSuper(1, DialogsSearchController, searchDisplayControllerWillEndSearch, controller);
}

CHOptimizedMethod(2, self, UITableViewCell*, DialogsSearchController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
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

CHOptimizedMethod(1, self, void, PSListController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, PSListController, viewWillAppear, animated);
    resetNavigationBar(self.navigationController.navigationBar);
}

CHOptimizedMethod(0, self, UIStatusBarStyle, PSListController, preferredStatusBarStyle)
{
    return UIStatusBarStyleLightContent;
}

#pragma mark SelectAccountTableViewController
@interface SelectAccountTableViewController : UITableViewController @end
CHDeclareClass(SelectAccountTableViewController);
CHOptimizedMethod(1, self, void, SelectAccountTableViewController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, SelectAccountTableViewController, viewWillAppear, animated);
    resetNavigationBar(self.navigationController.navigationBar);
}

#pragma mark vksprefsListController
@interface vksprefsListController : PSListController @end
CHDeclareClass(vksprefsListController);
CHOptimizedMethod(2, self, UITableViewCell *, vksprefsListController, tableView, UITableView *, tableView, cellForRowAtIndexPath, NSIndexPath *, indexPath)
{
    UITableViewCell * cell = CHSuper(2, vksprefsListController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
        cell.accessoryView.tag = 404;
    }
    
    return cell;
}



#pragma mark - MessageController
CHDeclareClass(MessageController);
CHOptimizedMethod(1, self, void, MessageController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, MessageController, viewWillAppear, animated);
    resetNavigationBar(self.navigationController.navigationBar);
}



#pragma mark VKComment
CHDeclareClass(VKComment);
CHOptimizedMethod(0, self, BOOL, VKComment, separatorDisabled)
{
    if (enabled) return showCommentSeparators;
    return CHSuper(0, VKComment, separatorDisabled);
}



#pragma mark ProfileCoverInfo
CHDeclareClass(ProfileCoverInfo);
CHOptimizedMethod(0, self, BOOL, ProfileCoverInfo, enabled)
{
    if (enabled && disableGroupCovers) return NO;
    return CHSuper(0, ProfileCoverInfo, enabled);
}



#pragma mark ProfileCoverImageView
CHDeclareClass(ProfileCoverImageView);
CHOptimizedMethod(0, self, UIView *, ProfileCoverImageView, overlayView)
{
    UIView *overlayView = CHSuper(0, ProfileCoverImageView, overlayView);
    if (enabled) {
        if (enabledBarImage) {
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
CHOptimizedMethod(0, self, UIStatusBarStyle, PostEditController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"PostEditController")] && (enabled && enabledBarColor))
        return UIStatusBarStyleLightContent;
    return CHSuper(0, PostEditController, preferredStatusBarStyle);
}

#pragma mark ProfileInfoEditController
CHDeclareClass(ProfileInfoEditController);
CHOptimizedMethod(0, self, UIStatusBarStyle, ProfileInfoEditController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"ProfileInfoEditController")] && (enabled && enabledBarColor))
        return UIStatusBarStyleLightContent;
    return CHSuper(0, ProfileInfoEditController, preferredStatusBarStyle);
}

#pragma mark OptionSelectionController
CHDeclareClass(OptionSelectionController);
CHOptimizedMethod(0, self, UIStatusBarStyle, OptionSelectionController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"OptionSelectionController")] && (enabled && enabledBarColor))
        return UIStatusBarStyleLightContent;
    return CHSuper(0, OptionSelectionController, preferredStatusBarStyle);
}

#pragma mark VKRegionSelectionViewController
CHDeclareClass(VKRegionSelectionViewController);
CHOptimizedMethod(0, self, UIStatusBarStyle, VKRegionSelectionViewController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"VKRegionSelectionViewController")] && (enabled && enabledBarColor))
        return UIStatusBarStyleLightContent;
    return CHSuper(0, VKRegionSelectionViewController, preferredStatusBarStyle);
}



#pragma mark ProfileFriendsController
CHDeclareClass(ProfileFriendsController);
CHOptimizedMethod(0, self, void, ProfileFriendsController, viewWillLayoutSubviews)
{
    CHSuper(0, ProfileFriendsController, viewWillLayoutSubviews);
    
    if ((enabled && enabledFriendsImage) && [self isKindOfClass:NSClassFromString(@"ProfileFriendsController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"friendsBackgroundImage" blackout:friendsImageBlackout 
                                      parallaxEffect:useFriendsParallax blurBackground:friendsUseBackgroundBlur];
        self.tableView.separatorColor = hideFriendsSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.tableView.sectionIndexColor = UITableViewCellTextColor;
        self.tableView.tag = 22;
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
        
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if (search) {
            search.backgroundImage = [UIImage new];
            search.tag = 6;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            NSDictionary *attributes = @{NSForegroundColorAttributeName: changeFriendsTextColor?friendsTextColor:[UIColor colorWithWhite:1 alpha:0.7]};
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder attributes:attributes];
            search._scopeBarBackgroundView.superview.hidden = YES;
        }
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, ProfileFriendsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ProfileFriendsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ((enabled && enabledFriendsImage) && [self isKindOfClass:NSClassFromString(@"ProfileFriendsController")]) {
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
CHOptimizedMethod(1, self, void, FriendsBDaysController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, FriendsBDaysController, viewWillAppear, animated);
    
    if ((enabled && enabledFriendsImage) && [self isKindOfClass:NSClassFromString(@"FriendsBDaysController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"friendsBackgroundImage" blackout:friendsImageBlackout 
                                      parallaxEffect:useFriendsParallax blurBackground:friendsUseBackgroundBlur];
        self.tableView.separatorColor = hideFriendsSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.tableView.tag = 22;
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, FriendsBDaysController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, FriendsBDaysController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ((enabled && enabledFriendsImage) && [self isKindOfClass:NSClassFromString(@"FriendsBDaysController")]) {
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
CHOptimizedMethod(1, self, void, FriendsAllRequestsController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, FriendsAllRequestsController, viewWillAppear, animated);
    
    if ((enabled && enabledFriendsImage) && [self isKindOfClass:NSClassFromString(@"FriendsAllRequestsController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"friendsBackgroundImage" blackout:friendsImageBlackout 
                                      parallaxEffect:useFriendsParallax blurBackground:friendsUseBackgroundBlur];
        self.tableView.separatorColor = hideFriendsSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
        setBlur(self.toolbar, friendsUseBlur, friendsBlurTone, friendsBlurStyle);
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, FriendsAllRequestsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, FriendsAllRequestsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ((enabled && enabledFriendsImage) && [self isKindOfClass:NSClassFromString(@"FriendsAllRequestsController")]) {
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
CHOptimizedMethod(0, self, void, VideoAlbumController, viewWillLayoutSubviews)
{
    CHSuper(0, VideoAlbumController, viewWillLayoutSubviews);
    
    if ((enabled && enabledVideosImage) && [self isKindOfClass:NSClassFromString(@"VideoAlbumController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"videosBackgroundImage" blackout:videosImageBlackout 
                                      parallaxEffect:useVideosParallax blurBackground:videosUseBackgroundBlur];
        self.tableView.separatorColor = hideVideosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
        setBlur(self.toolbar, YES, videosBlurTone, videosBlurStyle);
        
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if (search) {
            search.backgroundImage = [UIImage new];
            search.tag = 6;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            NSDictionary *attributes = @{NSForegroundColorAttributeName: changeVideosTextColor?videosTextColor:[UIColor colorWithWhite:1 alpha:0.7]};
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder attributes:attributes];
            search._scopeBarBackgroundView.superview.hidden = YES;
        }
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, VideoAlbumController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VideoAlbumController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ((enabled && enabledVideosImage) && [self isKindOfClass:NSClassFromString(@"VideoAlbumController")]) {
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
CHOptimizedMethod(6, self, UITableViewHeaderFooterView*, UITableView, _sectionHeaderView, BOOL, arg1, withFrame, CGRect, frame, forSection, NSInteger, section, floating, BOOL, floating, reuseViewIfPossible, BOOL, reuse, willDisplay, BOOL, display)
{
    UITableViewHeaderFooterView *view = CHSuper(6, UITableView, _sectionHeaderView, arg1, withFrame, frame, forSection, section, floating, floating, reuseViewIfPossible, reuse, willDisplay, display);
    
    void (^setColors)() = ^{
        view.contentView.backgroundColor = [UIColor clearColor];
        view.backgroundView.backgroundColor = [UIColor clearColor];
        view.textLabel.backgroundColor = [UIColor clearColor];
        view.textLabel.textColor = (self.tag == 23) ? UITableViewCellTextColor.darkerColor : UITableViewCellTextColor;  
    };
    if (self.tag == 21) {
        setColors();
       UIVisualEffectView *blurView = blurForView(view, 5);
        if (![view.contentView.subviews containsObject:[view.contentView viewWithTag:5]]) [view.contentView addSubview:blurView];
    } else if (self.tag == 22) {
        setColors();
        view.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
        
    } else if (self.tag == 23) {
        setColors();
        view.contentView.backgroundColor = [UIColor clearColor];
        
    }
    return view;
}

CHOptimizedMethod(1, self, void, UITableView, setBackgroundView, UIView*, backgroundView)
{    
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

CHOptimizedMethod(0, self, void, UITableView, layoutSubviews)
{
    CHSuper(0, UITableView, layoutSubviews);
    
    if (enabled && ([self.tableFooterView isKindOfClass:NSClassFromString(@"LoadingFooterView")] && [self.backgroundView isKindOfClass:[ColoredVKWallpaperView class]])) {
        LoadingFooterView *footerView = (LoadingFooterView *)self.tableFooterView;
        footerView.label.textColor = UITableViewCellTextColor;
    }
}


#pragma mark - UIViewController

CHDeclareClass(UIViewController);
CHOptimizedMethod(3, self, void, UIViewController, presentViewController, UIViewController *, viewControllerToPresent, animated, BOOL, flag, completion, id, completion)
{
    if (![NSStringFromClass([self class]) containsString:@"ColoredVK"]) {
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
CHOptimizedMethod(2, self, NSInteger, ModernSettingsController, tableView, UITableView *, tableView, numberOfRowsInSection, NSInteger, section)
{
    NSInteger rowsCount = CHSuper(2, ModernSettingsController, tableView, tableView, numberOfRowsInSection, section);
    if (section == 1) {
        rowsCount++;
    }
    return rowsCount;
        
}

CHOptimizedMethod(2, self, UITableViewCell*, ModernSettingsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
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

CHOptimizedMethod(3, self, void, ModernSettingsController, tableView, UITableView*, tableView, willDisplayCell, UITableViewCell *, cell, forRowAtIndexPath, NSIndexPath*, indexPath)
{
    CHSuper(3, ModernSettingsController, tableView, tableView, willDisplayCell, cell, forRowAtIndexPath, indexPath);
    
    if ([self isKindOfClass:NSClassFromString(@"ModernSettingsController")]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([cell.textLabel.text.lowercaseString isEqualToString:@"vksettings"]) {
                cell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
            }
            
            if (enabled && enabledSettingsImage) {
                performInitialCellSetup(cell);
                cell.textLabel.textColor = changeSettingsTextColor ? settingsTextColor : UITableViewCellTextColor;
                cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.imageView.tintColor = cell.textLabel.textColor;
            }
        });
    }
}

CHOptimizedMethod(2, self, void, ModernSettingsController, tableView, UITableView*, tableView, didSelectRowAtIndexPath, NSIndexPath*, indexPath)
{
    CHSuper(2, ModernSettingsController, tableView, tableView, didSelectRowAtIndexPath, indexPath);
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.reuseIdentifier isEqualToString:cvkMainController.settingsCell.reuseIdentifier]) {
        [cvkMainController actionOpenPreferencesPush:YES];
    }
}

CHOptimizedMethod(0, self, void, ModernSettingsController, viewWillLayoutSubviews)
{
    CHSuper(0, ModernSettingsController, viewWillLayoutSubviews);
    
    if ((enabled && enabledSettingsImage) && [self isKindOfClass:NSClassFromString(@"ModernSettingsController")]) {
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
    
    if (enabled && enabledSettingsExtraImage) {
        [ColoredVKMainController setImageToTableView:controller.tableView withName:@"settingsExtraBackgroundImage" blackout:settingsExtraImageBlackout 
                                      parallaxEffect:useSettingsExtraParallax blurBackground:settingsExtraUseBackgroundBlur];
        
        if (hideSettingsSeparators) 
            controller.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        else
            controller.tableView.separatorColor = [controller.tableView.separatorColor colorWithAlphaComponent:0.5f];
        
        controller.rptr.tintColor = changeSettingsExtraTextColor ? settingsExtraTextColor : UITableViewCellTextColor;
        controller.tableView.tag = 23;
    }
}

void setupExtraSettingsCell(UITableViewCell *cell)
{
    if (enabled && enabledSettingsExtraImage) {
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
            
        }
    }
}


CHDeclareClass(BaseSectionedSettingsController);
CHOptimizedMethod(0, self, void, BaseSectionedSettingsController, viewWillLayoutSubviews)
{
    CHSuper(0, BaseSectionedSettingsController, viewWillLayoutSubviews);
    NSArray <Class> *settingsExtraClasses = @[NSClassFromString(@"ModernGeneralSettings"), NSClassFromString(@"ModernAccountSettings"), NSClassFromString(@"AboutViewController")];
    if ([settingsExtraClasses containsObject:[self class]])
         setupExtraSettingsController(self);
}

CHOptimizedMethod(2, self, UITableViewCell*, BaseSectionedSettingsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, BaseSectionedSettingsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    NSArray <Class> *settingsExtraClasses = @[NSClassFromString(@"ModernGeneralSettings"), NSClassFromString(@"ModernAccountSettings"), NSClassFromString(@"AboutViewController")];
    if ([settingsExtraClasses containsObject:[self class]])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark ProfileBannedController
CHDeclareClass(ProfileBannedController);
CHOptimizedMethod(0, self, void, ProfileBannedController, viewWillLayoutSubviews)
{
    CHSuper(0, ProfileBannedController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"ProfileBannedController")])
        setupExtraSettingsController(self);
}

CHOptimizedMethod(2, self, UITableViewCell*, ProfileBannedController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ProfileBannedController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"ProfileBannedController")])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark SettingsPrivacyController
CHDeclareClass(SettingsPrivacyController);
CHOptimizedMethod(0, self, void, SettingsPrivacyController, viewWillLayoutSubviews)
{
    CHSuper(0, SettingsPrivacyController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"SettingsPrivacyController")])
        setupExtraSettingsController(self);
}

CHOptimizedMethod(2, self, UITableViewCell*, SettingsPrivacyController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, SettingsPrivacyController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"SettingsPrivacyController")])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark PaymentsBalanceController
CHDeclareClass(PaymentsBalanceController);
CHOptimizedMethod(0, self, void, PaymentsBalanceController, viewWillLayoutSubviews)
{
    CHSuper(0, PaymentsBalanceController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"PaymentsBalanceController")])
        setupExtraSettingsController(self);
}

CHOptimizedMethod(2, self, UITableViewCell*, PaymentsBalanceController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, PaymentsBalanceController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"PaymentsBalanceController")])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark SubscriptionsSettingsViewController
CHDeclareClass(SubscriptionsSettingsViewController);
CHOptimizedMethod(0, self, void, SubscriptionsSettingsViewController, viewWillLayoutSubviews)
{
    CHSuper(0, SubscriptionsSettingsViewController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"SubscriptionsSettingsViewController")])
        setupExtraSettingsController(self);
}

CHOptimizedMethod(2, self, UITableViewCell*, SubscriptionsSettingsViewController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, SubscriptionsSettingsViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"SubscriptionsSettingsViewController")])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark ModernPushSettingsController
CHDeclareClass(ModernPushSettingsController);
CHOptimizedMethod(0, self, void, ModernPushSettingsController, viewWillLayoutSubviews)
{
    CHSuper(0, ModernPushSettingsController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"ModernPushSettingsController")])
        setupExtraSettingsController(self);
}

CHOptimizedMethod(2, self, UITableViewCell*, ModernPushSettingsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ModernPushSettingsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"ModernPushSettingsController")])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark VKP2PViewController
CHDeclareClass(VKP2PViewController);
CHOptimizedMethod(0, self, void, VKP2PViewController, viewWillLayoutSubviews)
{
    CHSuper(0, VKP2PViewController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"VKP2PViewController")])
        setupExtraSettingsController(self);
}

CHOptimizedMethod(2, self, UITableViewCell*, VKP2PViewController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKP2PViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"VKP2PViewController")])
        setupExtraSettingsCell(cell);
    return cell;
}

CHDeclareClass(AFURLConnectionOperation);
CHDeclareMethod(0, NSURLRequest *, AFURLConnectionOperation, request)
{
    NSURLRequest *request = CHSuper(0, AFURLConnectionOperation, request);
    
    if ([request valueForHTTPHeaderField:@"User-Agent"].length > 0) {
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        [mutableRequest setValue:@"com.vk.vkclient/54 (unknown, iOS 10.3.3, iPad, Scale/2.000000)" forHTTPHeaderField:@"User-Agent"];
        request = mutableRequest;
    }
    
    return request;
}

CHDeclareMethod(0, void, AFURLConnectionOperation, start)
{
    if (![self.request.URL.absoluteString containsString:@"newsfeed.getDiscover"])
        CHSuper(0, AFURLConnectionOperation, start);
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
}

static void reloadMenuNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL shouldShow = (enabled && enabledMenuImage);
        
        VKMLiveController *menuController = nil;
        if ([cvkMainController.vkMainController isKindOfClass:[UITabBarController class]])
            menuController = cvkMainController.vkMenuController;
        else
            menuController = cvkMainController.vkMainController;
        
        UITableView *menuTableView = menuController.tableView;
        
        UISearchBar *searchBar = (UISearchBar *)menuTableView.tableHeaderView;
        if (menuTableView) {
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
                        menuTableView.backgroundColor = [UIColor colorWithRed:56.0/255.0f green:69.0/255.0f blue:84.0/255.0f alpha:1];
                    [menuTableView reloadData];
                    resetUISearchBar(searchBar);
                }
            }];
        }
        
        cvkMainController.menuBackgroundView.parallaxEnabled = useMenuParallax;
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

CHConstructor
{
    @autoreleasepool {
//        dlopen([[NSBundle mainBundle] pathForResource:@"FLEXDylib" ofType:@"dylib"].UTF8String, RTLD_NOW);
        
        prefsPath = CVK_PREFS_PATH;
        cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        vksBundle = [NSBundle bundleWithPath:VKS_BUNDLE_PATH];
        cvkFolder = CVK_FOLDER_PATH;
        cvkMainController = [ColoredVKMainController new];
        
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:prefsPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:prefsPath]) prefs = [NSMutableDictionary new];
        NSString *vkVersion = cvkMainController.appVersion;
        prefs[@"vkVersion"] = vkVersion;
        [prefs writeToFile:prefsPath atomically:YES];
        VKSettingsEnabled = (NSClassFromString(@"VKSettings") != nil)?YES:NO;
        
        if ([cvkMainController compareVersion:vkVersion withVersion:@"2.2"]  >= ColoredVKVersionCompareEqual) {
            CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
            CFNotificationCenterAddObserver(center, NULL, reloadPrefsNotify,  CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
            CFNotificationCenterAddObserver(center, NULL, reloadMenuNotify,   CFSTR("com.daniilpashin.coloredvk2.reload.menu"),   NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
            CFNotificationCenterAddObserver(center, nil, updateCornerRadius, CFSTR("com.daniilpashin.coloredvk2.update.corners"),NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
            
            
            
            CHLoadLateClass(MessageController);
            CHHook(1, MessageController, viewWillAppear);
             
            CHLoadLateClass(VKMLiveSearchController);
            CHHook(2, VKMLiveSearchController, tableView, cellForRowAtIndexPath);
            CHHook(1, VKMLiveSearchController, searchDisplayControllerWillBeginSearch);
            CHHook(1, VKMLiveSearchController, searchDisplayControllerWillEndSearch);
            
            
            CHLoadLateClass(DialogsSearchController);
            CHHook(2, DialogsSearchController, tableView, cellForRowAtIndexPath);
            CHHook(1, DialogsSearchController, searchDisplayControllerWillBeginSearch);
            CHHook(1, DialogsSearchController, searchDisplayControllerWillEndSearch);
            
            
            CHLoadLateClass(AppDelegate);
            CHHook(2,  AppDelegate, application, didFinishLaunchingWithOptions);
            CHHook(1,  AppDelegate, applicationDidBecomeActive);
            
            
            CHLoadLateClass(UINavigationBar);
            CHHook(1, UINavigationBar, setBarTintColor);
            CHHook(1, UINavigationBar, setTintColor);
            CHHook(1, UINavigationBar, setTitleTextAttributes);
            
            
            
            CHLoadLateClass(UITextInputTraits);
            CHHook(0, UITextInputTraits, keyboardAppearance);
            
            
            CHLoadLateClass(UISwitch);
            CHHook(0, UISwitch, layoutSubviews);
            
            
            CHLoadLateClass(VKMTableController);
            CHHook(1, VKMTableController, viewWillAppear);
            
            
            CHLoadLateClass(ChatController);
            CHHook(0, ChatController, viewWillLayoutSubviews);
            CHHook(2, ChatController, tableView, cellForRowAtIndexPath);
            CHHook(1, ChatController, viewWillAppear);
            CHHook(0, ChatController, editForward);
            
            CHLoadLateClass(MessageCell);
            CHHook(1, MessageCell, updateBackground);
            
            CHLoadLateClass(DialogsController);
            CHHook(0, DialogsController, viewWillLayoutSubviews);
            CHHook(1, DialogsController, viewWillAppear);
            CHHook(2, DialogsController, tableView, cellForRowAtIndexPath);
            
            CHLoadLateClass(BackgroundView);
            CHHook(1, BackgroundView, drawRect);
            
            
            
            CHLoadLateClass(VKMLiveController);
            CHHook(2, VKMLiveController, tableView, cellForRowAtIndexPath);
            CHHook(1, VKMLiveController, viewWillAppear);
            CHHook(0, VKMLiveController, viewWillLayoutSubviews);
            
            
            CHLoadLateClass(GroupsController);
            CHHook(0, GroupsController, viewWillLayoutSubviews);
            CHHook(2, GroupsController, tableView, cellForRowAtIndexPath);
            
            CHLoadLateClass(NewsFeedController);
            CHHook(0, NewsFeedController, VKMTableFullscreenEnabled);
            CHHook(0, NewsFeedController, VKMScrollViewFullscreenEnabled);
            
            CHLoadLateClass(PhotoFeedController);
            CHHook(0, PhotoFeedController, VKMTableFullscreenEnabled);
            CHHook(0, PhotoFeedController, VKMScrollViewFullscreenEnabled);
            
            
            
            CHLoadLateClass(VKMMainController);
            CHHook(2, VKMMainController, tableView, cellForRowAtIndexPath);
            CHHook(0, VKMMainController, VKMTableCreateSearchBar);
            CHHook(0, VKMMainController, menu);
            CHHook(0, VKMMainController, viewDidLoad);
            
            CHLoadLateClass(MenuViewController);
            CHHook(2, MenuViewController, tableView, cellForRowAtIndexPath);
            CHHook(0, MenuViewController, viewDidLoad);
            
            CHLoadLateClass(HintsSearchDisplayController);
            CHHook(1, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch);
            CHHook(1, HintsSearchDisplayController, searchDisplayControllerDidEndSearch);
            
            
            
            CHLoadLateClass(PhotoBrowserController);
            CHHook(1, PhotoBrowserController, viewWillAppear);
            
            
            CHLoadLateClass(VKMBrowserController);
            CHHook(0, VKMBrowserController, preferredStatusBarStyle);
            CHHook(1, VKMBrowserController, viewWillAppear);
            
            CHLoadLateClass(VKMToolbarController);
            CHHook(1, VKMToolbarController, viewWillAppear);
            
            
            CHLoadLateClass(VKGroupProfile);
            CHHook(0, VKGroupProfile, verified);
            
            CHLoadLateClass(VKProfile);
            CHHook(0, VKProfile, verified);
            
            CHLoadLateClass(UserWallController);
            CHHook(0, UserWallController, updateProfile);
            
            
            
            
            
            CHLoadLateClass(AudioAlbumController);
            CHHook(0, AudioAlbumController, viewDidLoad);
            CHHook(2, AudioAlbumController, tableView, cellForRowAtIndexPath);
            CHHook(0, AudioAlbumController, viewWillLayoutSubviews);
            
            CHLoadLateClass(AudioPlaylistController);
            CHHook(0, AudioPlaylistController, preferredStatusBarStyle);
            CHHook(1, AudioPlaylistController, viewWillAppear);
            CHHook(2, AudioPlaylistController, tableView, cellForRowAtIndexPath);
            
            CHLoadLateClass(AudioDashboardController);
            CHHook(0, AudioDashboardController, viewWillLayoutSubviews);
            CHHook(2, AudioDashboardController, tableView, cellForRowAtIndexPath);
            
            CHLoadLateClass(AudioCatalogController);
            CHHook(0, AudioCatalogController, viewWillLayoutSubviews);
            CHHook(2, AudioCatalogController, tableView, cellForRowAtIndexPath);
            
            CHLoadLateClass(AudioCatalogOwnersListController);
            CHHook(0, AudioCatalogOwnersListController, viewWillLayoutSubviews);
            CHHook(2, AudioCatalogOwnersListController, tableView, cellForRowAtIndexPath);
            
            CHLoadLateClass(AudioCatalogAudiosListController);
            CHHook(0, AudioCatalogAudiosListController, viewWillLayoutSubviews);
            CHHook(2, AudioCatalogAudiosListController, tableView, cellForRowAtIndexPath);
            
            CHLoadLateClass(AudioPlaylistDetailController);
            CHHook(0, AudioPlaylistDetailController, viewWillLayoutSubviews);
            CHHook(2, AudioPlaylistDetailController, tableView, cellForRowAtIndexPath);
            
            CHLoadLateClass(AudioPlaylistsController);
            CHHook(0, AudioPlaylistsController, viewWillLayoutSubviews);
            CHHook(2, AudioPlaylistsController, tableView, cellForRowAtIndexPath);
            
            CHLoadLateClass(VKAudioPlayerListTableViewController);
            CHHook(0, VKAudioPlayerListTableViewController, viewWillLayoutSubviews);
            CHHook(2, VKAudioPlayerListTableViewController, tableView, cellForRowAtIndexPath);
            
            CHLoadLateClass(AudioOwnersBlockItemCollectionCell);
            CHHook(0, AudioOwnersBlockItemCollectionCell, layoutSubviews);
            
            CHLoadLateClass(AudioPlaylistInlineCell);
            CHHook(0, AudioPlaylistInlineCell, layoutSubviews);
            
            CHLoadLateClass(AudioAudiosBlockTableCell);
            CHHook(0, AudioAudiosBlockTableCell, layoutSubviews);
            
            CHLoadLateClass(AudioAudiosSpecialBlockView);
            CHHook(0, AudioAudiosSpecialBlockView, layoutSubviews);
            
            CHLoadLateClass(AudioPlaylistCell);
            CHHook(0, AudioPlaylistCell, layoutSubviews);
            
            CHLoadLateClass(AudioPlaylistsCell);
            CHHook(0, AudioPlaylistsCell, layoutSubviews);
            
            CHLoadLateClass(AudioPlaylistView);
            CHHook(0, AudioPlaylistView, layoutSubviews);
            
            
            CHLoadLateClass(IOS7AudioController);
            CHHook(0, IOS7AudioController, viewDidLoad);
            CHHook(0, IOS7AudioController, viewWillLayoutSubviews);
            CHHook(0, IOS7AudioController, preferredStatusBarStyle);
            
            CHLoadLateClass(AudioPlayer);
            CHHook(2, AudioPlayer, switchTo, force);
            
            CHLoadLateClass(VKAudioQueuePlayer);
            CHHook(1, VKAudioQueuePlayer, switchTo);
            
            CHLoadLateClass(AudioRenderer);
            CHHook(0, AudioRenderer, playIndicator);
            
            
            if ([cvkMainController compareVersion:vkVersion withVersion:@"2.9"] >= ColoredVKVersionCompareEqual) {
                CHLoadLateClass(ChatCell);
                CHHook(0, ChatCell, setBG);
            }
            
            
            CHLoadLateClass(VKComment);
            CHHook(0, VKComment, separatorDisabled);
            
            
            CHLoadLateClass(DetailController);
            CHHook(1, DetailController, viewWillAppear);
            
            
            CHLoadLateClass(ProfileCoverInfo);
            CHHook(0, ProfileCoverInfo, enabled);
            
            CHLoadLateClass(ProfileCoverImageView);
            CHHook(0, ProfileCoverImageView, overlayView);
            
            
            CHLoadLateClass(PostEditController);
            CHHook(0, PostEditController, preferredStatusBarStyle);
            
            CHLoadLateClass(ProfileInfoEditController);
            CHHook(0, ProfileInfoEditController, preferredStatusBarStyle);
            
            CHLoadLateClass(OptionSelectionController);
            CHHook(0, OptionSelectionController, preferredStatusBarStyle);
            
            CHLoadLateClass(VKRegionSelectionViewController);
            CHHook(0, VKRegionSelectionViewController, preferredStatusBarStyle);
            
            
            CHLoadLateClass(ProfileFriendsController);
            CHHook(0, ProfileFriendsController, viewWillLayoutSubviews);
            CHHook(2, ProfileFriendsController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(FriendsBDaysController);
            CHHook(1, FriendsBDaysController, viewWillAppear);
            CHHook(2, FriendsBDaysController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(FriendsAllRequestsController);
            CHHook(1, FriendsAllRequestsController, viewWillAppear);
            CHHook(2, FriendsAllRequestsController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(VideoAlbumController);
            CHHook(0, VideoAlbumController, viewWillLayoutSubviews);
            CHHook(2, VideoAlbumController, tableView, cellForRowAtIndexPath);
            
            
            
            CHLoadLateClass(UITableView);
            CHHook(6, UITableView, _sectionHeaderView, withFrame, forSection, floating, reuseViewIfPossible, willDisplay);
            CHHook(1, UITableView, setBackgroundView);
            CHHook(0, UITableView, layoutSubviews);
            
            
            CHLoadLateClass(UIViewController);
            CHHook(3, UIViewController, presentViewController, animated, completion);
            
            
            CHLoadLateClass(ModernSettingsController);
            CHHook(2, ModernSettingsController, tableView, numberOfRowsInSection);
            CHHook(2, ModernSettingsController, tableView, cellForRowAtIndexPath);
            CHHook(3, ModernSettingsController, tableView, willDisplayCell, forRowAtIndexPath);
            CHHook(2, ModernSettingsController, tableView, didSelectRowAtIndexPath);
            CHHook(0, ModernSettingsController, viewWillLayoutSubviews);
            
            
            
            CHLoadLateClass(BaseSectionedSettingsController);
            CHHook(2, BaseSectionedSettingsController, tableView, cellForRowAtIndexPath);
            CHHook(0, BaseSectionedSettingsController, viewWillLayoutSubviews);
            
            CHLoadLateClass(ProfileBannedController);
            CHHook(2, ProfileBannedController, tableView, cellForRowAtIndexPath);
            CHHook(0, ProfileBannedController, viewWillLayoutSubviews);
            
            CHLoadLateClass(SettingsPrivacyController);
            CHHook(2, SettingsPrivacyController, tableView, cellForRowAtIndexPath);
            CHHook(0, SettingsPrivacyController, viewWillLayoutSubviews);
            
            CHLoadLateClass(PaymentsBalanceController);
            CHHook(2, PaymentsBalanceController, tableView, cellForRowAtIndexPath);
            CHHook(0, PaymentsBalanceController, viewWillLayoutSubviews);
            
            CHLoadLateClass(SubscriptionsSettingsViewController);
            CHHook(2, SubscriptionsSettingsViewController, tableView, cellForRowAtIndexPath);
            CHHook(0, SubscriptionsSettingsViewController, viewWillLayoutSubviews);
            
            CHLoadLateClass(ModernPushSettingsController);
            CHHook(2, ModernPushSettingsController, tableView, cellForRowAtIndexPath);
            CHHook(0, ModernPushSettingsController, viewWillLayoutSubviews);
            
            CHLoadLateClass(VKP2PViewController);
            CHHook(2, VKP2PViewController, tableView, cellForRowAtIndexPath);
            CHHook(0, VKP2PViewController, viewWillLayoutSubviews);
            
     
            
            CHLoadLateClass(vksprefsListController);
            CHHook(2, vksprefsListController, tableView, cellForRowAtIndexPath);
            
            CHLoadLateClass(SelectAccountTableViewController);
            CHHook(1, SelectAccountTableViewController, viewWillAppear);
            
            CHLoadLateClass(PSListController);
            CHHook(1, PSListController, viewWillAppear);
            CHHook(0, PSListController, preferredStatusBarStyle);
       

        } else {
            showAlertWithMessage([NSString stringWithFormat:CVKLocalizedString(@"VKAPP_VERSION_IS_TOO_LOW"),  vkVersion, @"2.2"]);
        }
    }
}
