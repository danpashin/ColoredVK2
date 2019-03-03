//
//  NavigationFuncs.m
//  ColoredVK
//
//  Created by Даниил on 03/03/2019.
//

#import "Tweak.h"

UIColor *cvk_UINavigationBar_setBarTintColor(UINavigationBar *self, SEL _cmd, UIColor *barTintColor)
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
    
    return barTintColor;
}

UIColor *cvk_UINavigationBar_setTintColor(UINavigationBar *self, SEL _cmd, UIColor *tintColor)
{
    if (enabled) {
        self.barTintColor = self.barTintColor;
        if (enableNightTheme)
            tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
        else if (enabledBarColor && self.tag != 26)
            tintColor = barForegroundColor;
    }
    
    return tintColor;
}

NSDictionary *cvk_UINavigationBar_setTitleTextAttributes(UINavigationBar *self, SEL _cmd, NSDictionary *attributes)
{
    NSDictionary *atrs = attributes != nil ? attributes : @{};
    NSMutableDictionary *mutableAttributes = [atrs mutableCopy];
    if (!mutableAttributes)
        mutableAttributes = [NSMutableDictionary dictionary];
    
    if (enabled) {
        if (enableNightTheme)
            mutableAttributes[NSForegroundColorAttributeName] = cvkMainController.nightThemeScheme.textColor;
        else if (enabledBarColor && self.tag != 26)
            mutableAttributes[NSForegroundColorAttributeName] = barForegroundColor;
    }
    
    return mutableAttributes;
}

void cvk_UINavigationBar_setFrame(UINavigationBar *self, SEL _cmd, CGRect frame)
{
    if (enabled) {
        self.tintColor = self.tintColor;
        self.titleTextAttributes = self.titleTextAttributes;
    }
}
