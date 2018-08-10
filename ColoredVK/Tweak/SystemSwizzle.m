//
//  SystemSwizzle.m
//  ColoredVK
//
//  Created by Даниил on 23.03.18.
//

#import "Tweak.h"
#import <dlfcn.h>
#import "ColoredVKSwitch.h"

@interface PSListController : UIViewController
@end
@interface SelectAccountTableViewController : UITableViewController
@end

CVK_CONSTRUCTOR
{
    @autoreleasepool {
        dlopen("/System/Library/PrivateFrameworks/Preferences.framework/Preferences", RTLD_LAZY);
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIWindowDidBecomeVisibleNotification object:nil 
                                                           queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                                                               actionChangeCornerRadius(nil);
                                                           }];
    }
}


#pragma mark - AppDelegate
CHDeclareClass(AppDelegate);
CHDeclareMethod(2, BOOL, AppDelegate, application, UIApplication*, application, didFinishLaunchingWithOptions, NSDictionary *, options)
{
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
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
    
    actionChangeCornerRadius(nil);
    
    if (cvkMainController.audioCover) {
        [cvkMainController.audioCover updateColorScheme];
    }
}



#pragma mark UINavigationBar
CHDeclareClass(UINavigationBar);
CHDeclareMethod(1, void, UINavigationBar, setBarTintColor, UIColor*, barTintColor)
{
    if (enabled) {
        if (enableNightTheme) {
            barTintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        }
        else if (enabledBarImage && self.tag != 26) {
            barTintColor = cvkMainController.navBarImageView ? [UIColor colorWithPatternImage:cvkMainController.navBarImageView.imageView.image] : barBackgroundColor;
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
    
    if (enabled) {
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
        Class cvkSwitchClass = objc_lookUpClass("ColoredVKSwitch");
        if (enabled && enableNightTheme) {
            self.tintColor = [UIColor clearColor];
            self.onTintColor = cvkMainController.nightThemeScheme.switchOnTintColor;
            self.thumbTintColor = cvkMainController.nightThemeScheme.switchThumbTintColor;
            self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            self.layer.cornerRadius = 16.0f;
        } else if (enabled && changeSwitchColor) {
            self.tintColor = switchesTintColor;
            self.onTintColor = switchesOnTintColor;
            if (![self isKindOfClass:cvkSwitchClass]) {
                self.thumbTintColor = nil;
                self.backgroundColor = nil;
            }
        } else if (![self isKindOfClass:cvkSwitchClass])  {
            self.tintColor = nil;
            self.onTintColor = nil;
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
        
        if (![self.delegate isKindOfClass:objc_lookUpClass("VKAPPlacesViewController")])
            backgroundView.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
    
    if ([self.backgroundView isKindOfClass:[ColoredVKWallpaperView class]] && [backgroundView isKindOfClass:objc_lookUpClass("TeaserView")]) {
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

CHDeclareMethod(1, void, UITableView, willMoveToWindow, UIWindow *, window)
{
    CHSuper(1, UITableView, willMoveToWindow, window);
    
    if (window) {
        self.backgroundColor = self.backgroundColor;
        self.separatorColor = self.separatorColor;
    }
}

CHDeclareMethod(1, void, UITableView, setSeparatorColor, UIColor *, separatorColor)
{
    if (enabled && enableNightTheme)
        separatorColor = cvkMainController.nightThemeScheme.backgroundColor;
    
    CHSuper(1, UITableView, setSeparatorColor, separatorColor);
}

CHDeclareMethod(1, void, UITableView, setBackgroundColor, UIColor *, backgroundColor)
{
    if (enabled && enableNightTheme)
        backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    
    CHSuper(1, UITableView, setBackgroundColor, backgroundColor);
}

CHDeclareClass(LoadingFooterView);
CHDeclareMethod(0, void, LoadingFooterView, layoutSubviews)
{
    CHSuper(0, LoadingFooterView, layoutSubviews);
    
    if (enabled && !enableNightTheme && [self.superview isKindOfClass:[UITableView class]]) {
        if ([((UITableView *)self.superview).backgroundView isKindOfClass:[ColoredVKWallpaperView class]]) {
            self.label.textColor = UITableViewCellTextColor;
            self.anim.color = UITableViewCellTextColor;
        }
    }
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


#pragma mark -
#pragma mark VKSettings
#pragma mark -

#pragma mark PSListController
CHDeclareClass(PSListController);
CHDeclareMethod(1, void, PSListController, viewWillAppear, BOOL, animated)
{
    resetNavigationBar(self.navigationController.navigationBar);
    resetTabBar();
    
    CHSuper(1, PSListController, viewWillAppear, animated);
}

#pragma mark SelectAccountTableViewController
CHDeclareClass(SelectAccountTableViewController);
CHDeclareMethod(1, void, SelectAccountTableViewController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, SelectAccountTableViewController, viewWillAppear, animated);
    resetNavigationBar(self.navigationController.navigationBar);
    resetTabBar();
}


CHDeclareClass(UITabBarItem);
CHDeclareMethod(1, void, UITabBarItem, setImage, UIImage *, image)
{
    if (ios_available(10.0)) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        UIColor *itemTintColor = (enabled && enabledTabbarColor) ? (enableNightTheme ? cvkMainController.nightThemeScheme.buttonColor : tabbarForegroundColor) : [UIColor cvk_defaultColorForIdentifier:@"TabbarForegroundColor"];
        image = [image cvk_imageWithTintColor:itemTintColor];
    }
    
    CHSuper(1, UITabBarItem, setImage, image);
}

CHDeclareMethod(1, void, UITabBarItem, setSelectedImage, UIImage *, selectedImage)
{
    selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    CHSuper(1, UITabBarItem, setSelectedImage, selectedImage);
}



static UIStatusBarStyle preferredStatusBarStyle_method(id self, SEL __cmd)
{
    if (enabled && (enabledBarColor || enableNightTheme || enabledBarImage)
        && ![self isKindOfClass:objc_lookUpClass("SFSafariViewController")]
        && ![self isKindOfClass:objc_lookUpClass("_UIRemoteViewControllerConnectionInfo")]
        && ![self isKindOfClass:objc_lookUpClass("SFBrowserRemoteViewController")]
        && ![self isKindOfClass:objc_lookUpClass("VKAudioPlayerViewController")]
        ) {
        return UIStatusBarStyleLightContent;
    } 
    else if ([self respondsToSelector:@selector(orig_preferredStatusBarStyle)]) {
        return [self orig_preferredStatusBarStyle];
    }
    
    return UIStatusBarStyleDefault;
}

CVK_CONSTRUCTOR
{
    sc_hookAllClassesInBackground(@selector(preferredStatusBarStyle), (IMP)&preferredStatusBarStyle_method);
}
