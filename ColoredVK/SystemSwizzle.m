//
//  AppLogic.m
//  ColoredVK
//
//  Created by Даниил on 23.03.18.
//

#import "Tweak.h"

@interface PSListController : UIViewController
@end
@interface vksprefsListController : PSListController
@end
@interface ColoredVKPrefs : PSListController
@end
@interface SelectAccountTableViewController : UITableViewController
@end


void reloadPrefs(void)
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
        cvkMainController.nightThemeScheme.enabled = (enabled && enableNightTheme);
        
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
    if (![NSStringFromClass([self class]) containsString:@"ColoredVK"]) {
        NSArray <Class> *classes = @[[UIAlertController class], [UIActivityViewController class]];
        
        if (([classes containsObject:[viewControllerToPresent class]]) && IS_IPAD) {
            viewControllerToPresent.modalPresentationStyle = UIModalPresentationPopover;
            viewControllerToPresent.popoverPresentationController.permittedArrowDirections = 0;
            viewControllerToPresent.popoverPresentationController.sourceView = self.view;
            viewControllerToPresent.popoverPresentationController.sourceRect = self.view.bounds;
        }
    }
    
    CHSuper(3, UIViewController, presentViewController, viewControllerToPresent, animated, flag, completion, completion);
    
}

CHDeclareMethod(1, void, UIViewController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, UIViewController, viewWillAppear, animated);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self isKindOfClass:NSClassFromString(@"PSListController")]) {
            resetNavigationBar(self.navigationController.navigationBar);
            resetTabBar();
        }
    });
}


#pragma mark -
#pragma mark VKSettings
#pragma mark -

#pragma mark PSListController
CHDeclareClass(PSListController);
//CHDeclareMethod(1, void, PSListController, viewWillAppear, BOOL, animated)
//{
//    CHSuper(1, PSListController, viewWillAppear, animated);
//    
//    CVKLogSource(@"");
//    resetNavigationBar(self.navigationController.navigationBar);
//    resetTabBar();
//}

CHDeclareMethod(0, UIStatusBarStyle, PSListController, preferredStatusBarStyle)
{
    return UIStatusBarStyleLightContent;
}

#pragma mark SelectAccountTableViewController
CHDeclareClass(SelectAccountTableViewController);
CHDeclareMethod(1, void, SelectAccountTableViewController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, SelectAccountTableViewController, viewWillAppear, animated);
    resetNavigationBar(self.navigationController.navigationBar);
    resetTabBar();
}

#pragma mark vksprefsListController
CHDeclareClass(vksprefsListController);
CHDeclareMethod(2, UITableViewCell *, vksprefsListController, tableView, UITableView *, tableView, cellForRowAtIndexPath, NSIndexPath *, indexPath)
{
    UITableViewCell * cell = CHSuper(2, vksprefsListController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
        cell.accessoryView.tag = 404;
    }
    
    return cell;
}
