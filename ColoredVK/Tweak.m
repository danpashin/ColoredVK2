//
//  ColoredVK.mm
//  ColoredVK
//
//  Created by Даниил on 21.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MobileGestalt/MobileGestalt.h>
#import <sys/utsname.h>
#import "CaptainHook/CaptainHook.h"
#import "NSData+AES.h"

#import "ColoredVKInstaller.h"
#import "PrefixHeader.h"
#import "UIBarButtonItem+BlocksKit.h"
#import "NSDate+DateTools.h"
#import <dlfcn.h>
#import "ColoredVKBackgroundImageView.h"
#import "ColoredVKAudioLyricsView.h"
#import "ColoredVKAudioCoverView.h"
#import "ColoredVKMainController.h"
#import "Tweak.h"



typedef NS_ENUM(NSInteger, CVKKeyboardStyle) {
    CVKKeyboardStyleWhite = 0,
    CVKKeyboardStyleBlack
};

NSTimeInterval updatesInterval;

BOOL tweakEnabled = NO;
BOOL VKSettingsEnabled;

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
BOOL enabledMessagesImage;
BOOL enabledMessagesListImage;
BOOL enabledGroupsListImage;
BOOL enabledAudioImage;
BOOL changeAudioPlayerAppearance;

CGFloat menuImageBlackout;
CGFloat chatImageBlackout;
CGFloat chatListImageBlackout;
CGFloat groupsListImageBlackout;
CGFloat audioImageBlackout;

BOOL useMessagesBlur;
BOOL useMessagesListBlur;
BOOL useGroupsListBlur;
BOOL useAudioBlur;

BOOL useMenuParallax;
BOOL useMessagesListParallax;
BOOL useMessagesParallax;
BOOL useGroupsListParallax;
BOOL useAudioParallax;

BOOL hideMessagesNavBarItems; 

BOOL hideMenuSearch;
BOOL changeSwitchColor;
BOOL changeSBColors;
BOOL enabledBlackTheme;
BOOL blackThemeWasEnabled;
BOOL shouldCheckUpdates;

UITableView *menuTableView;
UITableView *newsFeedTableView;

UIColor *menuSeparatorColor;
UIColor *barBackgroundColor;
UIColor *barForegroundColor;
UIColor *toolBarBackgroundColor;
UIColor *toolBarForegroundColor;
UIColor *SBBackgroundColor;
UIColor *SBForegroundColor;
UIColor *switchesTintColor;
UIColor *switchesOnTintColor;


CVKCellSelectionStyle menuSelectionStyle;
CVKKeyboardStyle keyboardStyle;
ColoredVKAudioLyricsView *cvkLyricsView;
UIColor *audioTintColor;
NSString *userToken;
ColoredVKAudioCoverView *cvkCoverView;
ColoredVKMainController *cvkMainController;


#pragma mark Static methods
static void checkUpdates()
{
    NSString *stringURL = [NSString stringWithFormat:@"http://danpashin.ru/api/v%@/checkUpdates.php?userVers=%@&product=com.daniilpashin.coloredvk2", API_VERSION, kColoredVKVersion];
#ifndef COMPILE_FOR_JAIL
    stringURL = [stringURL stringByAppendingString:@"&getIPA=1"];
#endif
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest 
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (!connectionError) {
                                   NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsPath];
                                   NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   if (!responseDict[@"error"]) {
                                       NSString *version = responseDict[@"version"];
                                       if (![prefs[@"skippedVersion"] isEqualToString:version]) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               NSString *message = [NSString stringWithFormat:CVKLocalizedString(@"YOUR_COPY_OF_TWEAK_NEEDS_TO_BE_UPGRADED_ALERT_MESSAGE"), version];
                                               UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK 2" message:message preferredStyle:UIAlertControllerStyleAlert];
                                               [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"SKIP_THIS_VERSION_BUTTON_TITLE") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                                   [prefs setValue:version forKey:@"skippedVersion"];
                                                   [prefs writeToFile:prefsPath atomically:YES];
                                               }]];
                                               [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"REMIND_LATER_BUTTON_TITLE") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
                                               [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"UPADTE_BUTTON_TITLE") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                   NSURL *url = [NSURL URLWithString:responseDict[@"url"]];
                                                   if ([[UIApplication sharedApplication] canOpenURL:url]) [[UIApplication sharedApplication] openURL:url];
                                                   
                                               }]];
                                               [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
                                           });
                                       }
                                   }
                                   
                                   NSDateFormatter *dateFormatter = [NSDateFormatter new];
                                   dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
                                   [prefs setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:@"lastCheckForUpdates"];
                                   [prefs writeToFile:prefsPath atomically:YES];
                               }
                           }];
}


static void reloadPrefs()
{
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:prefsPath];
    
    enabled = [prefs[@"enabled"] boolValue];
    hideMenuSearch = [prefs[@"hideMenuSearch"] boolValue];
    
    if (prefs && tweakEnabled) {
        enabledBarColor = [prefs[@"enabledBarColor"] boolValue];
        showBar = [prefs[@"showBar"] boolValue];
        enabledToolBarColor = [prefs[@"enabledToolBarColor"] boolValue];
        enabledBarImage = [prefs[@"enabledBarImage"] boolValue];
#ifdef COMPILE_WITH_BLACK_THEME
        enabledBlackTheme = [prefs[@"enabledBlackTheme"] boolValue];
#else
        enabledBlackTheme = NO;
#endif
        shouldCheckUpdates = prefs[@"checkUpdates"]?[prefs[@"checkUpdates"] boolValue]:YES;
        changeSBColors = [prefs[@"changeSBColors"] boolValue];
        changeSwitchColor = [prefs[@"changeSwitchColor"] boolValue];
        
        
        
        enabledMenuImage = [prefs[@"enabledMenuImage"] boolValue];
        enabledMessagesImage = [prefs[@"enabledMessagesImage"] boolValue];
        enabledMessagesListImage = [prefs[@"enabledMessagesListImage"] boolValue];
        enabledGroupsListImage = [prefs[@"enabledGroupsListImage"] boolValue];
        enabledAudioImage = [prefs[@"enabledAudioImage"] boolValue];
        changeAudioPlayerAppearance = [prefs[@"changeAudioPlayerAppearance"] boolValue];
        
        hideMenuSeparators = [prefs[@"hideMenuSeparators"] boolValue];
        hideMessagesListSeparators = [prefs[@"hideMessagesListSeparators"] boolValue];
        hideGroupsListSeparators = [prefs[@"hideGroupsListSeparators"] boolValue];
        
        useMessagesBlur = [prefs[@"useMessagesBlur"] boolValue];
        useMessagesListBlur = [prefs[@"useMessagesListBlur"] boolValue];
        useGroupsListBlur = [prefs[@"useGroupsListBlur"] boolValue];
        useAudioBlur = [prefs[@"useAudioBlur"] boolValue];
        
        useMenuParallax = [prefs[@"useMenuParallax"] boolValue];
        useMessagesListParallax = [prefs[@"useMessagesListParallax"] boolValue];
        useMessagesParallax = [prefs[@"useMessagesParallax"] boolValue];
        useGroupsListParallax = [prefs[@"useGroupsListParallax"] boolValue];
        useAudioParallax = [prefs[@"useAudioParallax"] boolValue];
        
        menuImageBlackout = [prefs[@"menuImageBlackout"] floatValue];
        chatImageBlackout = [prefs[@"chatImageBlackout"] floatValue];
        chatListImageBlackout = [prefs[@"chatListImageBlackout"] floatValue];
        groupsListImageBlackout = [prefs[@"groupsListImageBlackout"] floatValue];
        audioImageBlackout = [prefs[@"audioImageBlackout"] floatValue];
        
        hideMessagesNavBarItems = [prefs[@"hideMessagesNavBarItems"] boolValue];
        
        
        
        updatesInterval = prefs[@"updatesInterval"]?[prefs[@"updatesInterval"] doubleValue]:1.0;
        menuSelectionStyle = prefs[@"menuSelectionStyle"]?[prefs[@"menuSelectionStyle"] integerValue]:CVKCellSelectionStyleTransparent;
        keyboardStyle = prefs[@"keyboardStyle"]?[prefs[@"keyboardStyle"] intValue]:CVKKeyboardStyleBlack;
        
        menuSeparatorColor = prefs[@"MenuSeparatorColor"]?[UIColor colorFromString:prefs[@"MenuSeparatorColor"]]:[UIColor defaultColorForIdentifier:@"MenuSeparatorColor"];
        barBackgroundColor = prefs[@"BarBackgroundColor"]?[UIColor colorFromString:prefs[@"BarBackgroundColor"]]:[UIColor defaultColorForIdentifier:@"BarBackgroundColor"];
        barForegroundColor = prefs[@"BarForegroundColor"]?[UIColor colorFromString:prefs[@"BarForegroundColor"]]:[UIColor defaultColorForIdentifier:@"BarForegroundColor"];
        toolBarBackgroundColor = prefs[@"ToolBarBackgroundColor"]?[UIColor colorFromString:prefs[@"ToolBarBackgroundColor"]]:[UIColor defaultColorForIdentifier:@"ToolBarBackgroundColor"];
        toolBarForegroundColor = prefs[@"ToolBarForegroundColor"]?[UIColor colorFromString:prefs[@"ToolBarForegroundColor"]]:[UIColor defaultColorForIdentifier:@"ToolBarForegroundColor"];
        SBBackgroundColor = prefs[@"SBBackgroundColor"]?[UIColor colorFromString:prefs[@"SBBackgroundColor"]]:[UIColor defaultColorForIdentifier:@"SBBackgroundColor"];
        SBForegroundColor = prefs[@"SBForegroundColor"]?[UIColor colorFromString:prefs[@"SBForegroundColor"]]:[UIColor defaultColorForIdentifier:@"SBForegroundColor"];
        switchesTintColor = prefs[@"switchesTintColor"]?[UIColor colorFromString:prefs[@"switchesTintColor"]]:[UIColor defaultColorForIdentifier:@"switchesTintColor"];
        switchesOnTintColor = prefs[@"switchesOnTintColor"]?[UIColor colorFromString:prefs[@"switchesOnTintColor"]]:[UIColor defaultColorForIdentifier:@"switchesOnTintColor"];
        
        
        id theStatusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
        if (theStatusBar != nil) {
            if (enabled && (!enabledBlackTheme && changeSBColors)) {
                [theStatusBar performSelector:@selector(setForegroundColor:) withObject:SBForegroundColor ];
                [theStatusBar performSelector:@selector(setBackgroundColor:) withObject:SBBackgroundColor ];
            } else if (enabled && enabledBlackTheme) {
                [theStatusBar performSelector:@selector(setForegroundColor:) withObject:[UIColor lightGrayColor] ];
                [theStatusBar performSelector:@selector(setBackgroundColor:) withObject:[UIColor darkBlackColor] ];
                
                blackThemeWasEnabled = YES;  
            } else {
                [theStatusBar performSelector:@selector(setForegroundColor:) withObject:nil];
                [theStatusBar performSelector:@selector(setBackgroundColor:) withObject:nil];
            }
        }
            
        if (blackThemeWasEnabled && !enabledBlackTheme) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ blackThemeWasEnabled = NO; });
    }
}


static void showAlertWithMessage(NSString *message)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK 2" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    });
}


static void setBlur(id bar, BOOL set)
{
    if (set) {
        if ([bar isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navbar = bar;
            
            navbar.barTintColor = [UIColor clearColor];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            blurEffectView.frame = CGRectMake(0, -20, navbar.frame.size.width, navbar.frame.size.height + 20);
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            blurEffectView.tag = 10;
            blurEffectView.layer.backgroundColor =  [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
            blurEffectView.userInteractionEnabled = NO;
            
            UIView *borderView = [UIView new];
            borderView.frame = CGRectMake(0, navbar.frame.size.height + 19, navbar.frame.size.width, 1);
            borderView.backgroundColor = [UIColor whiteColor];
            borderView.alpha = 0.1;
            [blurEffectView addSubview:borderView];
            
            if (![navbar.subviews containsObject:[navbar viewWithTag:10]]) {                        
                [navbar addSubview:blurEffectView];
                [navbar sendSubviewToBack:blurEffectView];
                [navbar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            }
        } 
        else if  ([bar isKindOfClass:[UIToolbar class]]) {
            UIToolbar *toolBar = bar;
            
            toolBar.barTintColor = [UIColor clearColor];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            blurEffectView.frame = CGRectMake(0, 0, toolBar.frame.size.width, toolBar.frame.size.height);
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            blurEffectView.tag = 10;
            blurEffectView.userInteractionEnabled = NO;
            
            UIView *borderView = [UIView new];
            borderView.frame = CGRectMake(0, 0, toolBar.frame.size.width, 1);
            borderView.backgroundColor = [UIColor whiteColor];
            borderView.alpha = 0.1;
            [blurEffectView addSubview:borderView];
            
            if (![toolBar.subviews containsObject:[toolBar viewWithTag:10]]) {                        
                [toolBar addSubview:blurEffectView];
                [toolBar sendSubviewToBack:blurEffectView];
                [toolBar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
            }
        }
    } else {
        if ([bar isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navbar = bar;
            if ([navbar.subviews containsObject:[navbar viewWithTag:10]]) {
                [[navbar viewWithTag:10] removeFromSuperview];        
                [navbar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            }
        } else if  ([bar isKindOfClass:[UIToolbar class]]) {
            UIToolbar *toolBar = bar;
            if ([toolBar.subviews containsObject:[toolBar viewWithTag:10]]) [[toolBar viewWithTag:10] removeFromSuperview];
        }
    }
}

static void setSearchBar(UISearchBar *searchBar, BOOL reset)
{
    if (reset) {
        for (UIView *field in searchBar.subviews.lastObject.subviews) 
            if ([field isKindOfClass:UITextField.class]) { field.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1]; break; }
    } else {
        for (UIView *field in searchBar.subviews.lastObject.subviews) {
            if ([field isKindOfClass:UITextField.class]) field.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
            else if (![field isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) field.hidden = NO;
            if (enabledBlackTheme && [field isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) field.hidden = YES;
        }
    }
}

static NSArray *getInfoForActionController()
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[cvkBunlde pathForResource:@"AdvancedInfo" ofType:@"plist" inDirectory:@"plists"]];
    if (dict) {
        NSArray *arr = dict[@"ImagesDLInfo"];
        if (arr) return arr;
        else return @[];
    } else return @[];
}


static void setNavigationBar(UINavigationBar *navBar)
{
    if (enabled) {
        if (enabledBlackTheme) {
            setBlur(navBar, NO);
            navBar.barTintColor = [UIColor darkBlackColor];
            navBar.tintColor = [UIColor lightGrayColor];
            navBar.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor lightGrayColor] };
        }  else if (enabledBarColor) {
                if (enabledBarImage) navBar.barTintColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[cvkFolder stringByAppendingString:@"/barImage.png"]]];
                else navBar.barTintColor = barBackgroundColor;
                navBar.tintColor = barForegroundColor;
                navBar.titleTextAttributes = @{ NSForegroundColorAttributeName : barForegroundColor };
            }
    }
}

static void setToolBar(UIToolbar *toolbar)
{
    if (enabled && [toolbar respondsToSelector:@selector(setBarTintColor:)]) {
        if (enabledBlackTheme) {
            
            setBlur(toolbar, NO);
            toolbar.translucent = NO;
            NSArray *controllersToChange = @[@"UIView", @"RootView"];
            if ([controllersToChange containsObject:CLASS_NAME(toolbar.superview)]) {
                toolbar.tintColor = [UIColor lightGrayColor];
                toolbar.barTintColor = [UIColor darkBlackColor];
                for (UIView *subview in toolbar.subviews) {
                    if (![@"_UIToolbarBackground" isEqualToString:CLASS_NAME(subview)]) {
                        if ([subview respondsToSelector:@selector(setBackgroundColor:)]) subview.backgroundColor = [UIColor clearColor];
                    }
                }
            }
            for (id view in toolbar.subviews) {
                if ([view isKindOfClass:UITextView.class]) {
                    UITextView *textView = view;
                    textView.backgroundColor = [UIColor lightBlackColor];
                    textView.textColor = [UIColor lightGrayColor];
                }
            }
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
                            [btn setTitleColor:[UIColor darkerColorForColor:toolBarForegroundColor] forState:UIControlStateDisabled];
                            [btn setTitleColor:toolBarForegroundColor forState:UIControlStateNormal];
                            BOOL btnToExclude = NO;
                            NSArray *btnsWithActionsToExclude = @[@"actionToggleEmoji:"];
                            for (NSString *action in [btn actionsForTarget:btn.allTargets.allObjects[0] forControlEvent:UIControlEventTouchUpInside]) {
                                if ([btnsWithActionsToExclude containsObject:action]) btnToExclude = YES;
                            }
                            if (!btnToExclude && btn.currentImage) [btn setImage:[[btn imageForState:UIControlStateNormal] imageWithTintColor:toolBarForegroundColor] forState:UIControlStateNormal];
                        }
                    }
                    
                }
                
            }
        } 
    } else setBlur(toolbar, NO);
}



#pragma mark - AppDelegate
CHDeclareClass(AppDelegate);
CHOptimizedMethod(2, self, BOOL, AppDelegate, application, UIApplication*, application, didFinishLaunchingWithOptions, NSDictionary *, options)
{
    [cvkBunlde load];
    reloadPrefs();
    
    CHSuper(2, AppDelegate, application, application, didFinishLaunchingWithOptions, options);
    
    [[ColoredVKInstaller alloc] startWithCompletionBlock:^(BOOL disableTweak) {
        if (!disableTweak) {
            tweakEnabled = YES;
            reloadPrefs();
        }
    }];
    if (shouldCheckUpdates) {
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        if (!prefs[@"lastCheckForUpdates"] || ([dateFormatter dateFromString:prefs[@"lastCheckForUpdates"]].daysAgo >= updatesInterval)) checkUpdates();
    }
    
    return YES;
}



#pragma mark UINavigationBar
CHDeclareClass(UINavigationBar);
CHOptimizedMethod(0, self, void, UINavigationBar, layoutSubviews)
{
    CHSuper(0, UINavigationBar, layoutSubviews);
    setNavigationBar(self);
}

CHOptimizedMethod(0, self, void, UINavigationBar, setNeedsLayout)
{
    CHSuper(0, UINavigationBar, setNeedsLayout);
    setNavigationBar(self);
}



#pragma mark UIToolbar
CHDeclareClass(UIToolbar);
CHOptimizedMethod(0, self, void, UIToolbar, layoutSubviews)
{
    CHSuper(0, UIToolbar, layoutSubviews);
    setToolBar(self);
}

CHOptimizedMethod(0, self, void, UIToolbar, setNeedsLayout)
{
    CHSuper(0, UIToolbar, setNeedsLayout);
    setToolBar(self);
}


#pragma mark UITextInputTraits
CHDeclareClass(UITextInputTraits);
CHOptimizedMethod(0, self, long long, UITextInputTraits, keyboardAppearance) 
{
    if (enabled) return enabledBlackTheme?CVKKeyboardStyleBlack:keyboardStyle;
    return CHSuper(0, UITextInputTraits, keyboardAppearance);
}


#pragma mark UISwitch
CHDeclareClass(UISwitch);
CHOptimizedMethod(0, self, void, UISwitch, layoutSubviews)
{
    CHSuper(0, UISwitch, layoutSubviews);
    
    if ([self isKindOfClass:NSClassFromString(@"UISwitch")] && (self.tag != 404)) {
        
        if (enabled && enabledBlackTheme) {
            self.onTintColor = [UIColor colorWithWhite:0.2 alpha:1.0];
            self.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
            self.thumbTintColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        } else if (enabled && changeSwitchColor) {
            self.onTintColor = switchesOnTintColor;
            self.tintColor = switchesTintColor;
            self.thumbTintColor = nil;
        } else {
            self.tintColor = nil;
            self.thumbTintColor = nil;
            if ((self.tag == 405) || (self.tag == 228)) self.onTintColor = [UIColor colorWithRed:90/255.0f green:130/255.0f blue:180/255.0f alpha:1.0];
            else self.onTintColor = nil;
        }
    }
}


#pragma mark VKMLiveController 
CHDeclareClass(VKMLiveController);
CHOptimizedMethod(1, self, void, VKMLiveController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMLiveController, viewWillAppear, animated);
    
    if (enabled && [self.model.description containsString:@"AudioRecommendationsModel"]) {
       if (enabledAudioImage) {         
            UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
            search.backgroundImage = [UIImage new];
            search.tag = 4;
            for (UIView *field in search.subviews.lastObject.subviews) {
                if ([field isKindOfClass:[UITextField class]]) {
                    field.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
                    UITextField *textField = (UITextField*)field;
                    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder
                                                                                      attributes:@{NSForegroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.7]}];
                } else if (![field isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) field.hidden = YES;
            }
        }
    }
}

CHOptimizedMethod(0, self, void, VKMLiveController, viewWillLayoutSubviews)
{
    CHSuper(0, VKMLiveController, viewWillLayoutSubviews);
    
    if ([self isKindOfClass:NSClassFromString(@"VKMLiveController")]) {
        if ((enabled && (!enabledBlackTheme && enabledAudioImage)) && [self.model.description containsString:@"AudioRecommendationsModel"]) {
            [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout parallaxEffect:useAudioParallax];
            self.tableView.separatorColor = [self.tableView.separatorColor colorWithAlphaComponent:0.2];
            self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
            setBlur(self.navigationController.navigationBar, useAudioBlur);
        }
    }
}



CHOptimizedMethod(2, self, UITableViewCell*, VKMLiveController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMLiveController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && enabledBlackTheme) {
        cell.backgroundColor = [UIColor lightBlackColor];
        tableView.separatorColor = [UIColor darkBlackColor];
        tableView.backgroundColor = [UIColor darkBlackColor];
        
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:UILabel.class]) {
                UILabel *label = (UILabel *)view;
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor lightGrayColor];
                
            }
        }
        
        UIView *selectedBackView = [UIView new];
        selectedBackView.backgroundColor = [UIColor darkBlackColor];
        cell.selectedBackgroundView = selectedBackView;
    } else if (blackThemeWasEnabled) {
        tableView.separatorColor = kNewsTableViewSeparatorColor;
        tableView.backgroundColor = kNewsTableViewBackgroundColor;
        
    }
    if ([self isKindOfClass:NSClassFromString(@"VKMLiveController")] && (enabled && [self.model.description containsString:@"AudioRecommendationsModel"])) {
        if (enabledAudioImage && !enabledBlackTheme) {
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:0.9];
            cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.8 alpha:0.9];
            
            UIView *backView = [UIView new];
            backView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
            cell.selectedBackgroundView = backView;
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
    if (enabled) {        
        if (enabledBlackTheme) shouldAddBlur = NO;
        else if (useMessagesBlur && ([CLASS_NAME(self) isEqualToString:@"MultiChatController"] || [CLASS_NAME(self) isEqualToString:@"SingleUserChatController"])) shouldAddBlur = YES;
        else if (useGroupsListBlur && [CLASS_NAME(self) isEqualToString:@"GroupsController"]) shouldAddBlur = YES;
        else if (useMessagesListBlur && [CLASS_NAME(self) isEqualToString:@"DialogsController"]) shouldAddBlur = YES;
        else if (useAudioBlur && [CLASS_NAME(self) isEqualToString:@"AudioAlbumController"]) shouldAddBlur = YES;
        else if (useAudioBlur && [CLASS_NAME(self) isEqualToString:@"AudioAlbumsController"]) shouldAddBlur = YES;
        else shouldAddBlur = NO;
    } else shouldAddBlur = NO;
    
    setBlur(self.navigationController.navigationBar, shouldAddBlur);
}

#pragma mark VKMToolbarController
    // Настройка тулбара
CHDeclareClass(VKMToolbarController);
CHOptimizedMethod(1, self, void, VKMToolbarController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMToolbarController, viewWillAppear, animated);
    if ([self respondsToSelector:@selector(toolbar)]) {
        BOOL shouldAddBlur = NO;
        if (enabled) {
            if (enabledBlackTheme) shouldAddBlur = NO;
            else if (useGroupsListBlur && [CLASS_NAME(self) isEqualToString:@"GroupsController"]) shouldAddBlur = YES;
            else shouldAddBlur = NO;
        } else shouldAddBlur = NO;
        
        setBlur(self.toolbar, shouldAddBlur);
    }
}

#pragma mark NewsFeedController
CHDeclareClass(NewsFeedController);
CHOptimizedMethod(0, self, BOOL, NewsFeedController, VKMScrollViewFullscreenEnabled)
{
    if (enabled && showBar) return NO;
    return CHSuper(0, NewsFeedController, VKMScrollViewFullscreenEnabled);
}
CHOptimizedMethod(2, self, UITableViewCell*, NewsFeedController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, NewsFeedController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    newsFeedTableView = tableView;
    return cell;
}

#pragma mark PhotoFeedController
CHDeclareClass(PhotoFeedController);
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
    if (enabled && [self isKindOfClass:NSClassFromString(@"GroupsController")]) {
        if (enabledBlackTheme) {
            self.tableView.backgroundColor = [UIColor darkBlackColor];
            self.tableView.backgroundView = nil;
        } else if (enabledGroupsListImage) {
            [ColoredVKMainController setImageToTableView:self.tableView withName:@"groupsListBackgroundImage" blackout:groupsListImageBlackout parallaxEffect:useGroupsListParallax];
            self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
            self.tableView.separatorColor = (enabled && hideGroupsListSeparators)?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
            self.segment.alpha = 0.9;
            
            UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;search.backgroundImage = [UIImage new];
            search.scopeBarBackgroundImage = [UIImage new];
            search.tag = 2;
            for (UIView *field in search.subviews.lastObject.subviews){
                if ([field isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                    field.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
                    UITextField *textField = (UITextField*)field;
                    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder
                                                                                      attributes:@{NSForegroundColorAttributeName:[[UIColor whiteColor] colorWithAlphaComponent:0.7]}];
                }
            }
            
            if ([[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"] intValue] == 27) 
                for (UIView *view in self.view.subviews) if ([view isKindOfClass:UIToolbar.class] && useGroupsListBlur) {  setBlur(view, YES); break; }
        }
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, GroupsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, GroupsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"GroupsController")] && enabled) {
        if ([cell isKindOfClass:NSClassFromString(@"GroupCell")]) {
            GroupCell *groupCell = (GroupCell *)cell;
            if (enabledBlackTheme) {
                groupCell.backgroundColor = [UIColor lightBlackColor]; 
            } else if (enabledGroupsListImage) {
                groupCell.backgroundColor =  [UIColor clearColor];
                groupCell.name.textColor = [UIColor colorWithWhite:1 alpha:0.9];
                groupCell.name.backgroundColor = [UIColor clearColor];
                groupCell.status.textColor = [UIColor colorWithWhite:0.8 alpha:0.9];
                groupCell.status.backgroundColor = [UIColor clearColor];
                
                UIView *backView = [UIView new];
                backView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
                groupCell.selectedBackgroundView = backView;
            }
            return groupCell;
        } else  if ([cell isKindOfClass:NSClassFromString(@"VKMRendererCell")]) {
            if (enabledBlackTheme) {
                cell.backgroundColor = [UIColor lightBlackColor]; 
            } else if (enabledGroupsListImage) {
                cell.backgroundColor =  [UIColor clearColor];
                
                for (UIView *view in cell.contentView.subviews) {
                    if ([view isKindOfClass:NSClassFromString(@"UILabel")]) {
                        UILabel *label = (UILabel *)view;
                        label.textColor = [UIColor colorWithWhite:1 alpha:0.9];
                        label.backgroundColor = [UIColor clearColor];
                    }
                }
                
                UIView *backView = [UIView new];
                backView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
                cell.selectedBackgroundView = backView;
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
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")] && (enabled && (!enabledBlackTheme && enabledMessagesListImage)) ) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"messagesListBackgroundImage" blackout:chatListImageBlackout parallaxEffect:useMessagesListParallax];
    }
}

CHOptimizedMethod(1, self, void, DialogsController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DialogsController, viewWillAppear, animated);
    dlopen([NSBundle.mainBundle.bundlePath stringByAppendingString:@"/FLEXDylib.dylib"].UTF8String, RTLD_LAZY);
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")] && enabled) {
        if (enabledBlackTheme) {
            self.tableView.backgroundColor = [UIColor darkBlackColor];
            self.tableView.backgroundView = nil;
        } else if (enabledMessagesListImage) {
            self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
            self.tableView.separatorColor = (enabled && hideMessagesListSeparators)?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
            
            UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
            search.backgroundImage = [UIImage new];
            search.tag = 1;
            for (UIView *field in search.subviews.lastObject.subviews) {
                if ([field isKindOfClass:UITextField.class]) {
                    field.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
                    UITextField *textField = (UITextField*)field;
                    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder
                                                                                      attributes:@{NSForegroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.7]}];
                } else if (![field isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) field.hidden = YES;
            }
        }
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, DialogsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")] && enabled) {
        NewDialogCell *cell = (NewDialogCell *)CHSuper(2, DialogsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
        if (enabledBlackTheme) {
            cell.contentView.backgroundColor = [UIColor lightBlackColor]; 
        } else if (enabledMessagesListImage) {
            cell.backgroundView.hidden = YES;
            cell.backgroundColor = [UIColor clearColor];
            if (!cell.dialog.head.read_state && cell.unread.hidden) cell.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
            else cell.contentView.backgroundColor = [UIColor clearColor];
            
            cell.name.textColor = [UIColor colorWithWhite:1 alpha:0.9];
            cell.time.textColor = cell.name.textColor;
            if ([cell respondsToSelector:@selector(dialogText)]) cell.dialogText.textColor = [UIColor colorWithWhite:0.95 alpha:0.9];
            if ([cell respondsToSelector:@selector(text)]) cell.text.textColor = [UIColor colorWithWhite:0.95 alpha:0.9];
            cell.attach.textColor = [UIColor colorWithWhite:0.95 alpha:0.9];
            
            UIView *backView = [UIView new];
            backView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
            cell.selectedBackgroundView = backView;

        }
        return cell;
    }
    return CHSuper(2, DialogsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
}



#pragma mark VKMSearchController
CHDeclareClass(VKMSearchController);
CHOptimizedMethod(1, self, void, VKMSearchController, searchDisplayControllerWillEndSearch, VKMSearchController*, controller)
{
    CHSuper(1, VKMSearchController, searchDisplayControllerWillEndSearch, controller);
    if (enabled) {        
        int tag = (int)controller.searchBar.tag;
             if ((tag == 1) && enabledMessagesListImage) setSearchBar(controller.searchBar, YES);
        else if ((tag == 2) && enabledGroupsListImage) setSearchBar(controller.searchBar, YES);
        else if ((tag == 3) && enabledAudioImage) setSearchBar(controller.searchBar, YES);
        else if ((tag == 4) && enabledAudioImage) setSearchBar(controller.searchBar, YES);
    }
    
//    DialogsController - 1
//    GroupsController  - 2
//    AudioAlbumController  - 3
//    VKMLiveController - AudioRecommensationsModel  - 4
}

CHOptimizedMethod(1, self, void, VKMSearchController, searchDisplayControllerWillBeginSearch, VKMSearchController*, controller)
{
    CHSuper(1, VKMSearchController, searchDisplayControllerWillBeginSearch, controller);
    if (enabled && (controller.searchBar.tag !=0)) setSearchBar(controller.searchBar, NO);
}

#pragma mark BackgroundView
CHDeclareClass(BackgroundView);
CHOptimizedMethod(1, self, void, BackgroundView, drawRect, CGRect, rect)
{
    if (enabled) {
        self.layer.cornerRadius = self.cornerRadius;
        self.layer.masksToBounds = YES;
        if (enabledBlackTheme) self.layer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
        else if (enabledMessagesListImage) self.layer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2].CGColor;
        else CHSuper(1, BackgroundView, drawRect, rect);
    } else CHSuper(1, BackgroundView, drawRect, rect);
}


#pragma mark ChatController
CHDeclareClass(ChatController);
CHOptimizedMethod(1, self, void, ChatController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, ChatController, viewWillAppear, animated);
    if (enabled) {
        if (enabledBlackTheme) {
            for (UIView *subview in self.inputPanel.subviews) {
                if ([subview respondsToSelector:@selector(setBackgroundColor:)]) subview.backgroundColor = [UIColor clearColor];
            }
        }
        else if (useMessagesBlur) setBlur(self.inputPanel, YES);
    }
}

CHOptimizedMethod(0, self, void, ChatController, viewWillLayoutSubviews)
{
    CHSuper(0, ChatController, viewWillLayoutSubviews);
    
    if ([self isKindOfClass:NSClassFromString(@"ChatController")] && enabled) {
        if (enabledBlackTheme) {
            self.tableView.backgroundColor = [UIColor darkBlackColor];
            self.tableView.backgroundView = nil;
        } else if (enabledMessagesImage) {
            if (hideMessagesNavBarItems) {
                self.headerImage.hidden = YES;
                self.componentTitleView.hidden = YES;
            }
            self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
            [ColoredVKMainController setImageToTableView:self.tableView withName:@"messagesBackgroundImage" blackout:chatImageBlackout flip:YES parallaxEffect:useMessagesParallax];
        }
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, ChatController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ChatController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled) {
        if (enabledBlackTheme) {
//            if ([cell.contentView.subviews[0] isKindOfClass:UIImageView.class]) {
//                UIImageView *bubbleView = cell.contentView.subviews[0];
//                bubbleView.hidden = YES;
////                bubbleView.image = [UIImage coloredImage:bubbleView.image withTintColor:[UIColor redColor]];
//                bubbleView.tintColor = [UIColor redColor];
//                bubbleView.image = [bubbleView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//            }
        } else if (enabledMessagesImage) {
            for (id view in cell.contentView.subviews) { if ([view respondsToSelector:@selector(setTextColor:)]) [view setTextColor:[UIColor colorWithWhite:1 alpha:0.7]]; }
        }
        if ([CLASS_NAME(cell) isEqualToString:@"UITableViewCell"]) cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

CHOptimizedMethod(0, self, UIButton*, ChatController, editForward)
{
    UIButton *forwardButton = CHSuper(0, ChatController, editForward);
    if (enabled && (!enabledBlackTheme && useMessagesBlur)) {
        [forwardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [forwardButton setImage:[[forwardButton imageForState:UIControlStateNormal] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        for (UIView *subview in forwardButton.superview.subviews) if ([subview isKindOfClass:NSClassFromString(@"UIToolbar")]) { setBlur(subview, YES); break; }
    }
    return forwardButton;
}



#pragma mark MessageCell
CHDeclareClass(MessageCell);
CHOptimizedMethod(1, self, void, MessageCell, updateBackground, BOOL, animated)
{
    CHSuper(1, MessageCell, updateBackground, animated);
    if (enabled && (enabledMessagesImage || enabledBlackTheme)) {
        self.backgroundView = nil;
        if (!self.message.read_state) self.backgroundColor = enabledBlackTheme?[UIColor colorWithWhite:40.0/255.0f alpha:1.0]:[UIColor colorWithWhite:1 alpha:0.15];
        else self.backgroundColor = [UIColor clearColor];
    }
}




#pragma mark VKMMainController
CHDeclareClass(VKMMainController);
CHOptimizedMethod(0, self, NSArray*, VKMMainController, menu)
{
    NSArray *origMenu = CHSuper(0, VKMMainController, menu);
    NSMutableArray *tempArray = [origMenu mutableCopy];
    BOOL shouldInsert = NO;
    NSUInteger index;
    for (UITableViewCell *cell in tempArray) {
        if ([cell.textLabel.text isEqualToString:@"VKSettings"]) {
            shouldInsert = YES;
            index = [tempArray indexOfObject:cell];
            break;
        }
    }
    shouldInsert?[tempArray insertObject:cvkMainController.cvkCell atIndex:index+1]:[tempArray addObject:cvkMainController.cvkCell];
    origMenu = [tempArray copy];
    return origMenu;
}

CHOptimizedMethod(2, self, CGFloat, VKMMainController, tableView, UITableView*, tableView, heightForRowAtIndexPath, NSIndexPath*, indexPath)
{
    CGFloat height = CHSuper(2, VKMMainController, tableView, tableView, heightForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"VKMMainController")] && self.menu.count > 0) { 
        UITableViewCell *cell = self.menu[indexPath.row];
        if ([cell.textLabel.text isEqualToString:@"ColoredVK"]) height = 44;
        if ([cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)]) height = 35;
    }
    return height;
}

CHOptimizedMethod(2, self, UITableViewCell*, VKMMainController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMMainController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    menuTableView = tableView;
    
    NSDictionary *identifiers = @{@"customCell" : @228, @"cvkCell": @405};
    if ([identifiers.allKeys containsObject:cell.reuseIdentifier]) {
        UISwitch *switchView = [cell viewWithTag:[identifiers[cell.reuseIdentifier] integerValue]];
        if ([CLASS_NAME(switchView) isEqualToString:@"UISwitch"]) [switchView layoutSubviews];
    }
    
    
    if (enabled && hideMenuSeparators) tableView.separatorColor = [UIColor clearColor]; 
    else if (enabled && !hideMenuSeparators) tableView.separatorColor = menuSeparatorColor; 
    else tableView.separatorColor = kMenuCellSeparatorColor;
    
    if (enabled && enabledBlackTheme) {
        cell.backgroundColor = [UIColor lightBlackColor];
        cell.contentView.backgroundColor = [UIColor lightBlackColor];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        if ((indexPath.section == 1) && (indexPath.row == 0)) cell.backgroundColor = [UIColor darkBlackColor];
        
        UIView *selectedBackView = [UIView new];
        selectedBackView.backgroundColor = [UIColor darkBlackColor];
        cell.selectedBackgroundView = selectedBackView;
        
        if (![tableView.superview.subviews containsObject:[tableView.superview viewWithTag:23]]) {
            UIView *statusBarBack = [UIView new];
            statusBarBack.frame = CGRectMake(0, 0, tableView.frame.size.width, 20);
            statusBarBack.backgroundColor = [UIColor lightBlackColor];
            statusBarBack.tag = 23;
            [tableView.superview addSubview:statusBarBack]; 
        }
        
    } else if (enabled && enabledMenuImage) {
        cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:0.9];
        cell.imageView.image = [cell.imageView.image imageWithTintColor:[UIColor colorWithWhite:1 alpha:0.8]];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        if ((indexPath.section == 0) && (indexPath.row == 0)) [ColoredVKMainController setupUISearchBar:(UISearchBar*)tableView.tableHeaderView];
        
        if (![tableView.superview.subviews containsObject: [tableView.superview viewWithTag:23] ]) {
            UIView *backgrondView = [[ColoredVKBackgroundImageView alloc] imageLayerWithFrame:tableView.superview.frame withImageName:@"menuBackgroundImage" blackout:menuImageBlackout parallaxEffect:useMenuParallax];
            [tableView.superview insertSubview:backgrondView atIndex:0];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.backgroundView = nil;
        }        
        
        UIView *selectedBackView = [UIView new];
        if (menuSelectionStyle == CVKCellSelectionStyleTransparent) selectedBackView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        else if (menuSelectionStyle == CVKCellSelectionStyleBlurred) {
            selectedBackView.backgroundColor = [UIColor clearColor];
            if (![selectedBackView.subviews containsObject: [selectedBackView viewWithTag:100] ]) [selectedBackView addSubview:[ColoredVKMainController blurForView:selectedBackView withTag:100]];
            
        } else selectedBackView.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = selectedBackView;
        
        if (VKSettingsEnabled) {
            if ([cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)] && (menuSelectionStyle != CVKCellSelectionStyleNone)) 
                cell.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        }
        
    } else {
        cell.backgroundColor = kMenuCellBackgroundColor;
        cell.contentView.backgroundColor = kMenuCellBackgroundColor;
        cell.textLabel.textColor = kMenuCellTextColor;
        if (((indexPath.section == 1) && (indexPath.row == 0)) || (VKSettingsEnabled && [cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)])) {
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





#pragma mark  HintsSearchDisplayController
CHDeclareClass(HintsSearchDisplayController);
CHOptimizedMethod(1, self, void, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch, UISearchDisplayController*, controller)
{
    if (enabled && (enabledMenuImage && !enabledBlackTheme)) [ColoredVKMainController resetUISearchBar:controller.searchBar];
    return CHSuper(1, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch, controller);
}

CHOptimizedMethod(1, self, void, HintsSearchDisplayController, searchDisplayControllerDidEndSearch, UISearchDisplayController*, controller)
{
    if (enabled && (enabledMenuImage && !enabledBlackTheme)) [ColoredVKMainController setupUISearchBar:controller.searchBar];
    return CHSuper(1, HintsSearchDisplayController, searchDisplayControllerDidEndSearch, controller);
}



#pragma mark IOS7AudioController
CHDeclareClass(IOS7AudioController);
CHOptimizedMethod(0, self, UIStatusBarStyle, IOS7AudioController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"IOS7AudioController")] && ( enabled && (!enabledBlackTheme && (enabledBarColor || enabledAudioImage)))) return UIStatusBarStyleLightContent;
    else return CHSuper(0, IOS7AudioController, preferredStatusBarStyle);
}

static void setColorsForViewsInView(UIView *hostView)
{
    for (UIView *view in hostView.subviews) {
        view.backgroundColor = [UIColor clearColor];
        if ([view respondsToSelector:@selector(setTextColor:)]) ((UILabel *)view).textColor = audioTintColor;
        if ([view respondsToSelector:@selector(setImage:forState:)]) [(UIButton*)view setImage:[[(UIButton*)view imageForState:UIControlStateNormal] imageWithTintColor:audioTintColor] forState:UIControlStateNormal];
        if ([view isKindOfClass:MPVolumeView.class]) {
            MPVolumeSlider *slider = ((MPVolumeView*)view).volumeSlider;
            for (UIView *subview in slider.subviews) {
                if ([subview isKindOfClass:UIImageView.class]) {
                    NSString *assetName = ((UIImageView*)subview).image.imageAsset.assetName;
                    if ([assetName containsString:@"/"]) assetName = [assetName componentsSeparatedByString:@"/"].lastObject;
                    NSArray *namesToPass = @[@"volume_min", @"volume_max", @"volume_min_max"];
                    if ([namesToPass containsObject:assetName]) {
                        ((UIImageView*)subview).image = [((UIImageView*)subview).image imageWithTintColor:[UIColor darkerColorForColor:audioTintColor]];
                        ((UIImageView*)subview).image.imageAsset.assetName = @"volume_min_max";
                    }
                }
            }
        }
    }
}

CHOptimizedMethod(1, self, void, IOS7AudioController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, IOS7AudioController, viewWillAppear, animated);
    
    if (enabled && [self isKindOfClass:NSClassFromString(@"IOS7AudioController")]) {
        if (enabledBlackTheme) {
            for (UIView *view in self.view.subviews) {
                if ([view isKindOfClass:[UIImageView class]]) {
                    view.backgroundColor = [UIColor blackColor];
                } else {
                    view.backgroundColor = [UIColor colorWithWhite:30/255.0f alpha:1.0];
                    for (id subView in  view.subviews) {
                        if ([subView respondsToSelector:@selector(setBackgroundColor:)]) [subView setBackgroundColor:[UIColor clearColor]];
                        if ([subView respondsToSelector:@selector(setImage:forState:)]) {
                            [subView setImage:[[subView imageForState:UIControlStateNormal] imageWithTintColor:[UIColor buttonsTintColor]] forState:UIControlStateNormal];
                            [subView setImage:[[subView imageForState:UIControlStateSelected] imageWithTintColor:[UIColor lightGrayColor]] forState:UIControlStateSelected];
                        }
                    }
                    [self.pp setImage:[[self.pp imageForState:UIControlStateSelected] imageWithTintColor:[UIColor buttonsTintColor]] forState:UIControlStateSelected];
                }
            }
        } else if (changeAudioPlayerAppearance) {
            if (!cvkCoverView) cvkCoverView = [[ColoredVKAudioCoverView alloc] initWithFrame:self.view.frame andSeparationPoint:self.hostView.frame.origin];
            audioTintColor = cvkCoverView.tintColor?cvkCoverView.tintColor:[UIColor blackColor];
            
            UINavigationBar *navBar = self.navigationController.navigationBar;
            navBar.topItem.titleView.hidden = YES;
            navBar.shadowImage = [UIImage new];
            [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];            
            if (![navBar.subviews containsObject:[navBar viewWithTag:26]]) {
                UIView *gradientView = [UIView new];
                gradientView.frame = CGRectMake(0, -20, self.view.frame.size.width, navBar.frame.size.height+35);
                gradientView.tag = 26;
                CAGradientLayer *gradient = [CAGradientLayer layer];
                gradient.frame = gradientView.bounds;
                gradient.colors = @[ (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, (id)[UIColor clearColor].CGColor ];
                gradient.locations = @[ @0.3, @0.8];
                [gradientView.layer insertSublayer:gradient atIndex:0];
                
                [navBar addSubview:gradientView];
                [navBar sendSubviewToBack:gradientView];
            }
            setColorsForViewsInView(self.hostView);
            self.cover.hidden = YES;
            self.hostView.backgroundColor = [UIColor clearColor];
            [self.pp setImage:[[self.pp imageForState:UIControlStateSelected] imageWithTintColor:audioTintColor] forState:UIControlStateSelected];
            [self.seek setThumbImage:[[self.seek thumbImageForState:UIControlStateNormal] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
            blurEffectView.frame = self.hostView.bounds;
            blurEffectView.backgroundColor = cvkCoverView.defaultCover?[UIColor colorWithWhite:1 alpha:0.4]:cvkCoverView.backColor;
            [self.hostView addSubview:blurEffectView];
            [self.hostView sendSubviewToBack:blurEffectView];
            
            [NSNotificationCenter.defaultCenter addObserverForName:@"com.daniilpashin.coloredvk.audio.image.changed" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
                audioTintColor = cvkCoverView.defaultCover?[UIColor blackColor]:cvkCoverView.tintColor;
                
                [UIView animateWithDuration:0.3 animations:^{
                    blurEffectView.backgroundColor = cvkCoverView.defaultCover?[UIColor colorWithWhite:1 alpha:0.4]:cvkCoverView.backColor;
                    cvkLyricsView.hostView.subviews[0].backgroundColor = blurEffectView.backgroundColor;
                    [self.pp setImage:[[self.pp imageForState:UIControlStateSelected] imageWithTintColor:audioTintColor] forState:UIControlStateSelected];
                }];
                setColorsForViewsInView(self.hostView);
            }];
            
            
            cvkCoverView.contentMode = UIViewContentModeScaleAspectFill;
            [self.view addSubview:cvkCoverView];
            [self.view sendSubviewToBack:cvkCoverView];
            
            
            if (!cvkLyricsView) cvkLyricsView = [[ColoredVKAudioLyricsView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.pp.superview.frame.origin.y - 64)];
            [self.view addSubview:cvkLyricsView];
        }
    }
}

CHDeclareClass(AudioPlayer);
CHOptimizedMethod(2, self, void, AudioPlayer, switchTo, int, arg1, force, BOOL, force)
{
    if (enabled && changeAudioPlayerAppearance) {
        if (self.state == 1 && (![cvkCoverView.artist isEqualToString:self.audio.performer] || ![cvkCoverView.track isEqualToString:self.audio.title])) [cvkCoverView updateCoverForAudioPlayer:self];
        if (self.audio.lyrics_id) [cvkLyricsView updateWithLyrycsID:self.audio.lyrics_id andToken:userToken];
        else [cvkLyricsView resetState];
    }
    CHSuper(2, AudioPlayer, switchTo, arg1, force, force);
}




#pragma mark AudioAlbumController
CHDeclareClass(AudioAlbumController);
CHOptimizedMethod(1, self, void, AudioAlbumController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, AudioAlbumController, viewWillAppear, animated);
    
    if (enabled && ([self isKindOfClass:NSClassFromString(@"AudioAlbumController")] || [self isKindOfClass:NSClassFromString(@"AudioAlbumsController")])) {
        if (enabledBlackTheme) {
            self.tableView.backgroundColor = [UIColor darkBlackColor];
//            self.tableView.backgroundView = nil;
        } else if (enabledAudioImage) {
            UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
            if (!search.showsScopeBar) {
                search.backgroundImage = [UIImage new];
                search.tag = 3;
                for (UIView *field in search.subviews.lastObject.subviews) {
                    if ([field isKindOfClass:UITextField.class]) {
                        field.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
                        UITextField *textField = (UITextField*)field;
                        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder
                                                                                          attributes:@{NSForegroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.7]}];
                    } else if (![field isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) field.hidden = YES;
                }
            }
        }
    }
}
CHOptimizedMethod(0, self, void, AudioAlbumController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioAlbumController, viewWillLayoutSubviews);
    
    if ((enabled && (!enabledBlackTheme && enabledAudioImage)) && ([self isKindOfClass:NSClassFromString(@"AudioAlbumController")] || [self isKindOfClass:NSClassFromString(@"AudioAlbumsController")])) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout parallaxEffect:useAudioParallax];
        self.tableView.separatorColor = [self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, AudioAlbumController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioAlbumController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && ([self isKindOfClass:NSClassFromString(@"AudioAlbumController")] || [self isKindOfClass:NSClassFromString(@"AudioAlbumsController")])) {
        if (enabledAudioImage && !enabledBlackTheme) {
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:0.9];
            cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.8 alpha:0.9];
            
            UIView *backView = [UIView new];
            backView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
            cell.selectedBackgroundView = backView;
        }
    }
    
    return cell;
}


#pragma mark AudioPlaylistController
CHDeclareClass(AudioPlaylistController);
CHOptimizedMethod(0, self, UIStatusBarStyle, AudioPlaylistController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"AudioPlaylistController")] && ( enabled && (!enabledBlackTheme && (enabledBarColor || enabledAudioImage)))) return UIStatusBarStyleLightContent;
    else return CHSuper(0, AudioPlaylistController, preferredStatusBarStyle);
}
CHOptimizedMethod(1, self, void, AudioPlaylistController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, AudioPlaylistController, viewWillAppear, animated);
    
    if ((enabled && (!enabledBlackTheme && enabledAudioImage)) && [self isKindOfClass:NSClassFromString(@"AudioPlaylistController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout parallaxEffect:useAudioParallax];
        self.tableView.separatorColor = [self.tableView.separatorColor colorWithAlphaComponent:0.2];
        setBlur(self.navigationController.navigationBar, YES);
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, AudioPlaylistController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioPlaylistController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && [self isKindOfClass:NSClassFromString(@"AudioPlaylistController")]) {
        if (enabledAudioImage && !enabledBlackTheme) {
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:0.9];
            cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.8 alpha:0.9];
            
            UIView *backView = [UIView new];
            backView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
            cell.selectedBackgroundView = backView;
        }
    }
    
    return cell;
}






#pragma mark PhotoBrowserController
CHDeclareClass(PhotoBrowserController);
CHOptimizedMethod(1, self, void, PhotoBrowserController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, PhotoBrowserController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"PhotoBrowserController")]) {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"dlIcon" inBundle:cvkBunlde compatibleWithTraitCollection:nil]  
                                                                          style:UIBarButtonItemStylePlain 
                                                                        handler:^(id  _Nonnull sender) {
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
                                                                            VKHUD *hud = [objc_getClass("VKHUD") hud];
                                                                            BlockActionController *actionController = [objc_getClass("BlockActionController") actionSheetWithTitle:nil];
                                                                            NSArray *info = getInfoForActionController();
                                                                            for (NSDictionary *dict in info) {
                                                                                [actionController addButtonWithTitle:CVKLocalizedString(dict[@"title"]) 
                                                                                                               block:(id)^(id arg1) {
                                                                                                                   NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                                                                                                                       [ColoredVKMainController downloadImageWithSource:imageSource 
                                                                                                                                                          identificator:dict[@"identifier"]
                                                                                                                                                        completionBlock:^(BOOL success, NSString *message) {
                                                                                                                                                            success?[hud hideWithResult:success]:[hud hideWithResult:success message:message];
                                                                                                                                                            [hud performSelector:@selector(hide:) withObject:@YES afterDelay:3.0];
                                                                                                                                                        }];
                                                                                                                   }];
                                                                                                                   [hud showForOperation:operation];
                                                                                                                   [operation start];
                                                                                                               }];

                                                                            }
                                                                            [actionController setCancelButtonWithTitle:UIKitLocalizedString(@"Cancel") block:nil];
                                                                            [actionController showInViewController:self];
                                                                        }];

        NSMutableArray *buttons = [self.navigationItem.rightBarButtonItems mutableCopy];
        if (buttons.count < 2) [buttons addObject:saveButton];
        self.navigationItem.rightBarButtonItems = [buttons copy];
    }
}



#pragma mark VKMBrowserController
CHDeclareClass(VKMBrowserController);
CHOptimizedMethod(1, self, void, VKMBrowserController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMBrowserController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"VKMBrowserController")]) {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"dlIcon" inBundle:cvkBunlde compatibleWithTraitCollection:nil]  
                                                                          style:UIBarButtonItemStylePlain 
                                                                        handler:^(id  _Nonnull sender) {
                                                                            
                                                                            VKHUD *hud = [objc_getClass("VKHUD") hud];
                                                                            BlockActionController *actionController = [objc_getClass("BlockActionController") actionSheetWithTitle:nil];
                                                                            NSArray *info = getInfoForActionController();
                                                                            for (NSDictionary *dict in info) {
                                                                                [actionController addButtonWithTitle:CVKLocalizedString(dict[@"title"]) 
                                                                                                               block:(id)^(id arg1) {
                                                                                                                   NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                                                                                                                       [ColoredVKMainController downloadImageWithSource:self.target.url.absoluteString 
                                                                                                                                                          identificator:dict[@"identifier"]
                                                                                                                                                        completionBlock:^(BOOL success, NSString *message) {
                                                                                                                                                            success?[hud hideWithResult:success]:[hud hideWithResult:success message:message];
                                                                                                                                                            [hud performSelector:@selector(hide:) withObject:@YES afterDelay:3.0];
                                                                                                                                                        }];
                                                                                                                   }];
                                                                                                                   [hud showForOperation:operation];
                                                                                                                   [operation start];
                                                                                                               }];
                                                                            }
                                                                            [actionController setCancelButtonWithTitle:UIKitLocalizedString(@"Cancel") block:nil];
                                                                            [actionController showInViewController:self];
                                                                        }];
        self.navigationItem.rightBarButtonItem = saveButton;
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:self.target.url]
                                           queue:[NSOperationQueue mainQueue] 
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (![[response.MIMEType componentsSeparatedByString:@"/"].firstObject isEqualToString:@"image"]) self.navigationItem.rightBarButtonItem = nil;
                               }];
        if (enabled && enabledBarColor) {
            for (UIView *view in self.navigationItem.titleView.subviews) if ([view respondsToSelector:@selector(setTextColor:)]) ((UILabel*)view).textColor = barForegroundColor;
        }
        
        UINavigationBar *navbar = self.navigationController.navigationBar;
        if ([navbar.subviews containsObject:[navbar viewWithTag:10]]) {
            [[navbar viewWithTag:10] removeFromSuperview];        
            [navbar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        }
    }
}

#pragma mark VKProfile
CHDeclareClass(VKProfile);
CHOptimizedMethod(0, self, BOOL, VKProfile, verified)
{
    if ([self.user.uid  isEqual: @89911723]) return YES;
    return CHSuper(0, VKProfile, verified);
}


CHDeclareClass(VKSession);
CHOptimizedMethod(0, self, NSString*, VKSession, token)
{
    NSString *token = CHSuper(0, VKSession, token);
    if (token) userToken  = token;
    return token;
}






#pragma mark Static methods
static void reloadPrefsNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    reloadPrefs();
    [cvkMainController reloadSwitch];
}

static void reloadMenuNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    menuTableView.backgroundView = nil;
    menuTableView.backgroundColor = kMenuCellBackgroundColor;
    for (UIView *view in menuTableView.superview.subviews) if ((view.tag == 25) || (view.tag == 23)) [view removeFromSuperview];
    [ColoredVKMainController resetUISearchBar:(UISearchBar*)menuTableView.tableHeaderView];
    
    [menuTableView reloadData];
}

static void reloadTablesNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    [newsFeedTableView reloadData];
}

CHConstructor
{
    @autoreleasepool {
            if ([[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"] intValue] >= 27) {
                
                prefsPath = CVK_PREFS_PATH;
                cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
                vksBundle = [NSBundle bundleWithPath:VKS_BUNDLE_PATH];
                cvkFolder = CVK_FOLDER_PATH;
                cvkMainController = [ColoredVKMainController new];
                
                NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:prefsPath];
                if (![[NSFileManager defaultManager] fileExistsAtPath:prefsPath]) prefs = [NSMutableDictionary new];
                [prefs setValue:[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"vkVersion"];
                [prefs writeToFile:prefsPath atomically:YES];
                
                
                CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadPrefsNotify, CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadMenuNotify, CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadTablesNotify, CFSTR("com.daniilpashin.coloredvk.black.theme"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                
                
                
                CHLoadLateClass(VKSession);
                CHHook(0, VKSession, token);
                
                CHLoadLateClass(AppDelegate);
                CHHook(2,  AppDelegate, application, didFinishLaunchingWithOptions);
                
                
                
                CHLoadLateClass(UINavigationBar);
                if (IS_IOS_10_OR_LATER) CHHook(0, UINavigationBar, setNeedsLayout);
                else                    CHHook(0, UINavigationBar, layoutSubviews);
                
                
                CHLoadLateClass(UIToolbar);
                if (IS_IOS_10_OR_LATER) CHHook(0, UIToolbar, setNeedsLayout);
                else                    CHHook(0, UIToolbar, layoutSubviews);
                
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
                
                
                
                CHLoadLateClass(VKMSearchController);
                CHHook(1, VKMSearchController, searchDisplayControllerWillEndSearch);
                CHHook(1, VKMSearchController, searchDisplayControllerWillBeginSearch);
                
                
                CHLoadLateClass(VKMLiveController);
                CHHook(2, VKMLiveController, tableView, cellForRowAtIndexPath);
                CHHook(1, VKMLiveController, viewWillAppear);
                CHHook(0, VKMLiveController, viewWillLayoutSubviews);
                
                
                CHLoadLateClass(GroupsController);
                CHHook(0, GroupsController, viewWillLayoutSubviews);
                CHHook(2, GroupsController, tableView, cellForRowAtIndexPath);
                
                CHLoadLateClass(NewsFeedController);
                CHHook(0, NewsFeedController, VKMScrollViewFullscreenEnabled);
                CHHook(2, NewsFeedController, tableView, cellForRowAtIndexPath);
                
                CHLoadLateClass(PhotoFeedController);
                CHHook(0, PhotoFeedController, VKMScrollViewFullscreenEnabled);
                
                
                CHLoadLateClass(VKMMainController);
                CHHook(2, VKMMainController, tableView, cellForRowAtIndexPath);
                CHHook(2, VKMMainController, tableView, heightForRowAtIndexPath);
                CHHook(0, VKMMainController, VKMTableCreateSearchBar);
                CHHook(0, VKMMainController, menu);
                
                CHLoadLateClass(HintsSearchDisplayController);
                CHHook(1, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch);
                CHHook(1, HintsSearchDisplayController, searchDisplayControllerDidEndSearch);
                
                
                
                CHLoadLateClass(PhotoBrowserController);
                CHHook(1, PhotoBrowserController, viewWillAppear);
                
                
                CHLoadLateClass(VKMBrowserController);
                CHHook(1, VKMBrowserController, viewWillAppear);
                
                CHLoadLateClass(VKMToolbarController);
                CHHook(1, VKMToolbarController, viewWillAppear);
                
                
                CHLoadLateClass(VKProfile);
                CHHook(0, VKProfile, verified);
                
                
                
                CHLoadLateClass(AudioAlbumController);
                CHHook(1, AudioAlbumController, viewWillAppear);
                CHHook(2, AudioAlbumController, tableView, cellForRowAtIndexPath);
                CHHook(0, AudioAlbumController, viewWillLayoutSubviews);
                
                CHLoadLateClass(AudioPlaylistController);
                CHHook(1, AudioPlaylistController, viewWillAppear);
                CHHook(2, AudioPlaylistController, tableView, cellForRowAtIndexPath);
                CHHook(0, AudioPlaylistController, preferredStatusBarStyle);
                
                CHLoadLateClass(IOS7AudioController);
                CHHook(1, IOS7AudioController, viewWillAppear);
                CHHook(0, IOS7AudioController, preferredStatusBarStyle);
                
                CHLoadLateClass(AudioPlayer);
                CHHook(2, AudioPlayer, switchTo, force);
                
                VKSettingsEnabled = (NSClassFromString(@"VKSettings") != nil)?YES:NO;
                
            } else {
                showAlertWithMessage([NSString stringWithFormat: @"App version (%@) is too low. Please install VK App 2.5 or later or tweak will be disabled",  [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]);
            }
    }
}
