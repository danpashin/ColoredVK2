//
//  SystemSwizzle.m
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


#pragma mark - AppDelegate
CHDeclareClass(AppDelegate);
CHDeclareMethod(2, BOOL, AppDelegate, application, UIApplication*, application, didFinishLaunchingWithOptions, NSDictionary *, options)
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    [cvkBunlde load];
    reloadPrefs(nil);
    
    BOOL orig = CHSuper(2, AppDelegate, application, application, didFinishLaunchingWithOptions, options);
    
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    installerCompletionBlock = ^(BOOL purchased) {
        premiumEnabled = purchased;
        reloadPrefs(nil);
    };
    [newInstaller checkStatus];
    
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
                self.searchBarTextField.backgroundColor = barBackgroundColor.cvk_darkerColor;
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
