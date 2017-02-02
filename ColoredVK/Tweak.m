//
//  ColoredVK.mm
//  ColoredVK
//
//  Created by Даниил on 21.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/


#import "CaptainHook/CaptainHook.h"

#import "ColoredVKInstaller.h"
#import "PrefixHeader.h"
#import "NSDate+DateTools.h"
#import <dlfcn.h>
#import "ColoredVKBackgroundImageView.h"
#import "ColoredVKAudioLyricsView.h"
#import "ColoredVKAudioCoverView.h"
#import "ColoredVKMainController.h"
#import "Tweak.h"
#import "ColoredVKBarDownloadButton.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "ColoredVKHUD.h"



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

BOOL useMessageBubbleTintColor;
BOOL useCustomMessageReadColor;

BOOL hideCommentSeparators;

UIColor *menuSeparatorColor;
UIColor *barBackgroundColor;
UIColor *barBackColorWithImage;
UIColor *barForegroundColor;
UIColor *toolBarBackgroundColor;
UIColor *toolBarForegroundColor;
UIColor *SBBackgroundColor;
UIColor *SBForegroundColor;
UIColor *switchesTintColor;
UIColor *switchesOnTintColor;

UIColor *messageBubbleTintColor;
UIColor *messageBubbleSentTintColor;
UIColor *messageReadColor;


CVKCellSelectionStyle menuSelectionStyle;
UIKeyboardAppearance keyboardStyle;
ColoredVKAudioLyricsView *cvkLyricsView;
UIColor *audioTintColor;
NSString *userToken;
ColoredVKAudioCoverView *cvkCoverView;
ColoredVKMainController *cvkMainController;
ColoredVKBackgroundImageView *mainMenuBackgroundView;

VKMMainController *mainController;


#pragma mark Static methods
static void checkUpdates()
{
    NSString *stringURL = [NSString stringWithFormat:@"http://danpashin.ru/api/v%@/checkUpdates.php?userVers=%@&product=com.daniilpashin.coloredvk2", API_VERSION, kColoredVKVersion];
#ifndef COMPILE_FOR_JAIL
    stringURL = [stringURL stringByAppendingString:@"&getIPA=1"];
#endif
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsPath];
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (!responseDict[@"error"]) {
                NSString *version = responseDict[@"version"];
                if (![prefs[@"skippedVersion"] isEqualToString:version]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *message = [NSString stringWithFormat:CVKLocalizedString(@"UPGRADE_IS_AVAILABLE_ALERT_MESSAGE"), version];
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
    enabledMenuImage = [prefs[@"enabledMenuImage"] boolValue];
    menuImageBlackout = [prefs[@"menuImageBlackout"] floatValue];
    useMenuParallax = [prefs[@"useMenuParallax"] boolValue];
    
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
        
        hideCommentSeparators = [prefs[@"hideCommentSeparators"] boolValue];
        
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
        
        useMessagesListParallax = [prefs[@"useMessagesListParallax"] boolValue];
        useMessagesParallax = [prefs[@"useMessagesParallax"] boolValue];
        useGroupsListParallax = [prefs[@"useGroupsListParallax"] boolValue];
        useAudioParallax = [prefs[@"useAudioParallax"] boolValue];
        
        chatImageBlackout = [prefs[@"chatImageBlackout"] floatValue];
        chatListImageBlackout = [prefs[@"chatListImageBlackout"] floatValue];
        groupsListImageBlackout = [prefs[@"groupsListImageBlackout"] floatValue];
        audioImageBlackout = [prefs[@"audioImageBlackout"] floatValue];
        
        hideMessagesNavBarItems = [prefs[@"hideMessagesNavBarItems"] boolValue];
        useMessageBubbleTintColor = [prefs[@"useMessageBubbleTintColor"] boolValue];
        useCustomMessageReadColor = [prefs[@"useCustomMessageReadColor"] boolValue];
        
        
        
        updatesInterval = prefs[@"updatesInterval"]?[prefs[@"updatesInterval"] doubleValue]:1.0;
        menuSelectionStyle = prefs[@"menuSelectionStyle"]?[prefs[@"menuSelectionStyle"] integerValue]:CVKCellSelectionStyleTransparent;
        keyboardStyle = prefs[@"keyboardStyle"]?[prefs[@"keyboardStyle"] integerValue]:UIKeyboardAppearanceDefault;
        
        menuSeparatorColor =         [UIColor savedColorForIdentifier:@"MenuSeparatorColor"         fromPrefs:prefs];
        barBackgroundColor =         [UIColor savedColorForIdentifier:@"BarBackgroundColor"         fromPrefs:prefs];
        barBackColorWithImage =      [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[cvkFolder stringByAppendingString:@"/barImage.png"]]];
        barForegroundColor =         [UIColor savedColorForIdentifier:@"BarForegroundColor"         fromPrefs:prefs];
        toolBarBackgroundColor =     [UIColor savedColorForIdentifier:@"ToolBarBackgroundColor"     fromPrefs:prefs];
        toolBarForegroundColor =     [UIColor savedColorForIdentifier:@"ToolBarForegroundColor"     fromPrefs:prefs];
        SBBackgroundColor =          [UIColor savedColorForIdentifier:@"SBBackgroundColor"          fromPrefs:prefs];
        SBForegroundColor =          [UIColor savedColorForIdentifier:@"SBForegroundColor"          fromPrefs:prefs];
        switchesTintColor =          [UIColor savedColorForIdentifier:@"switchesTintColor"          fromPrefs:prefs];
        switchesOnTintColor =        [UIColor savedColorForIdentifier:@"switchesOnTintColor"        fromPrefs:prefs];
        messageBubbleTintColor =     [UIColor savedColorForIdentifier:@"messageBubbleTintColor"     fromPrefs:prefs];
        messageBubbleSentTintColor = [UIColor savedColorForIdentifier:@"messageBubbleSentTintColor" fromPrefs:prefs];
        messageReadColor =          [[UIColor savedColorForIdentifier:@"messageReadColor"           fromPrefs:prefs] colorWithAlphaComponent:0.2];
        
        
        UIStatusBar *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
        if (statusBar) {
            if (enabled && (!enabledBlackTheme && changeSBColors)) {
                statusBar.foregroundColor = SBForegroundColor;
                statusBar.backgroundColor = SBBackgroundColor;
            } else if (enabled && enabledBlackTheme) {
                statusBar.foregroundColor = [UIColor lightGrayColor];
                statusBar.backgroundColor = [UIColor darkBlackColor];
                
                blackThemeWasEnabled = YES;  
            } else {
                statusBar.foregroundColor = nil;
                statusBar.backgroundColor = nil;
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


static void setBlur(UIView *bar, BOOL set)
{
    if (set) {
        if ([bar isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navbar = (UINavigationBar *)bar;
            UIView *backgroundView = navbar._backgroundView;
            
            if (![backgroundView.subviews containsObject:[backgroundView viewWithTag:10]]) {
                navbar.barTintColor = [UIColor clearColor];
                [navbar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
                navbar.shadowImage = [UIImage new];
                
                UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
                blurEffectView.frame = backgroundView.bounds;
                blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                blurEffectView.tag = 10;
                blurEffectView.layer.backgroundColor =  [UIColor colorWithWhite:0 alpha:0.3].CGColor;
                
                UIView *borderView = [UIView new];
                borderView.frame = CGRectMake(0, blurEffectView.frame.size.height - 0.5, blurEffectView.frame.size.width, 0.5);
                borderView.backgroundColor = [UIColor whiteColor];
                borderView.alpha = 0.15;
                [blurEffectView addSubview:borderView];
                
                [backgroundView addSubview:blurEffectView];
                [backgroundView sendSubviewToBack:blurEffectView];

                borderView.translatesAutoresizingMaskIntoConstraints = NO;
                [blurEffectView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[borderView(0.5)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(borderView)]];
                [blurEffectView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[borderView]|"     options:0 metrics:nil views:NSDictionaryOfVariableBindings(borderView)]];
            }
        } 
        else if  ([bar isKindOfClass:[UIToolbar class]]) {
            UIToolbar *toolBar = (UIToolbar *)bar;
            
            toolBar.barTintColor = [UIColor clearColor];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            blurEffectView.frame = CGRectMake(0, 0, toolBar.frame.size.width, toolBar.frame.size.height);
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            blurEffectView.tag = 10;
            blurEffectView.userInteractionEnabled = NO;
            
            UIView *borderView = [UIView new];
            borderView.frame = CGRectMake(0, 0, toolBar.frame.size.width, 0.5);
            borderView.backgroundColor = [UIColor whiteColor];
            borderView.alpha = 0.15;
            [blurEffectView addSubview:borderView];
            
            if (![toolBar.subviews containsObject:[toolBar viewWithTag:10]]) {                        
                [toolBar addSubview:blurEffectView];
                [toolBar sendSubviewToBack:blurEffectView];
                [toolBar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
            }
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
                    if (![@"_UIToolbarBackground" isEqualToString:CLASS_NAME(subview)]) subview.backgroundColor = [UIColor clearColor];
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
                            [btn setTitleColor:toolBarForegroundColor.darkerColor forState:UIControlStateDisabled];
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


static void setupSearchController(UISearchDisplayController *controller, BOOL reset)
{
    BOOL shouldCustomize = NO;
    int tag = (int)controller.searchBar.tag;
    if ((tag == 1) && enabledMessagesListImage) shouldCustomize = YES;
    else if ((tag == 2) && enabledGroupsListImage) shouldCustomize = YES;
    else if ((tag == 3) && enabledAudioImage) shouldCustomize = YES;
    else if ((tag == 4) && enabledAudioImage) shouldCustomize = YES;
    else if ((tag == 5) && enabledMenuImage) shouldCustomize = YES;
    
    if (enabled && shouldCustomize) {
        if (reset) {
            void (^removeAllBlur)() = ^void() {
                [[controller.searchBar._backgroundView viewWithTag:10] removeFromSuperview];
                [[controller.searchBar._scopeBarBackgroundView.superview viewWithTag:10] removeFromSuperview];
                controller.searchBar.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            };
            [UIView animateWithDuration:0.1 delay:0 options:0 animations:^{ removeAllBlur(); } completion:^(BOOL finished) { removeAllBlur(); }];
        } else {
            UIViewController *parentController = controller.searchContentsController.parentViewController;
            if ([parentController isKindOfClass:NSClassFromString(@"VKMNavigationController")]) {
                VKMNavigationController *navigation = (VKMNavigationController *)parentController;
                if (navigation.childViewControllers.count>0) {
                    if ([navigation.childViewControllers.firstObject isKindOfClass:NSClassFromString(@"VKSelectorContainerControllerDropdown")]) {
                        VKSelectorContainerControllerDropdown *dropdown = (VKSelectorContainerControllerDropdown *)navigation.childViewControllers.firstObject;
                        VKMTableController *tableController = (VKMTableController *)dropdown.currentViewController;
                        if ([tableController respondsToSelector:@selector(tableView)] && [tableController.tableView.backgroundView isKindOfClass:[ColoredVKBackgroundImageView class]]) {
                            ColoredVKBackgroundImageView *backView = (ColoredVKBackgroundImageView*)tableController.tableView.backgroundView;
                            ColoredVKBackgroundImageView *imageView = [ColoredVKBackgroundImageView viewWithFrame:[UIScreen mainScreen].bounds imageName:backView.name blackout:backView.blackout];
                            controller.searchResultsTableView.backgroundView = imageView;
                        }
                    } else if ([navigation.childViewControllers.firstObject respondsToSelector:@selector(tableView)]) {
                        VKMTableController *tableController = (VKMTableController*)navigation.childViewControllers.firstObject;
                        ColoredVKBackgroundImageView *backView = (ColoredVKBackgroundImageView*)tableController.tableView.backgroundView;
                        ColoredVKBackgroundImageView *imageView = [ColoredVKBackgroundImageView viewWithFrame:[UIScreen mainScreen].bounds imageName:backView.name blackout:backView.blackout];
                        controller.searchResultsTableView.backgroundView = imageView;
                    }
                }
            }
            
            controller.searchBar.tintColor = [UIColor whiteColor];
            controller.searchBar.searchBarTextField.textColor = [UIColor whiteColor];
            [controller.searchBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
            
            UIView *backgroundView = (controller.searchBar)._backgroundView;
            UIVisualEffectView *barBlurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            barBlurEffectView.frame = CGRectMake(0, 0, backgroundView.superview.frame.size.width, backgroundView.superview.frame.size.height+21);
            barBlurEffectView.tag = 10;
            [backgroundView addSubview:barBlurEffectView];
            [backgroundView sendSubviewToBack:barBlurEffectView];
            
            if (controller.searchBar.scopeButtonTitles.count >= 2) {
                UIView *scopeBackgroundView = (controller.searchBar)._scopeBarBackgroundView;
                scopeBackgroundView.hidden = YES;
                UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
                blurEffectView.frame = scopeBackgroundView.superview.bounds;
                blurEffectView.tag = 10;
                [scopeBackgroundView.superview addSubview:blurEffectView];
                [scopeBackgroundView.superview sendSubviewToBack:blurEffectView];
            }
        }
    }
}


static void setupAudioPlayer(UIView *hostView, UIColor *color)
{
    if (!color) color = audioTintColor;
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

static void setupCellForSearchController(UITableViewCell *cell, id searchController)
{
    BOOL shouldCustomize = NO;
    int tag = (int)((UISearchController *)searchController).searchBar.tag;
    if ((tag == 1) && enabledMessagesListImage) shouldCustomize = YES;
    else if ((tag == 2) && enabledGroupsListImage) shouldCustomize = YES;
    else if ((tag == 3) && enabledAudioImage) shouldCustomize = YES;
    else if ((tag == 4) && enabledAudioImage) shouldCustomize = YES;
    
    
    if (enabled && shouldCustomize) {
        cell.backgroundColor = [UIColor clearColor];
        
        if ([cell isKindOfClass:NSClassFromString(@"SourceCell")] || [cell isKindOfClass:NSClassFromString(@"UserCell")]) {
            SourceCell *sourceCell = (SourceCell *)cell;
            if (enabledBlackTheme) {
                sourceCell.backgroundColor = [UIColor lightBlackColor]; 
            } else if (enabledGroupsListImage) {
                sourceCell.last.textColor = [UIColor colorWithWhite:1 alpha:0.9];
                sourceCell.last.backgroundColor = [UIColor clearColor];
                sourceCell.first.textColor = [UIColor colorWithWhite:1 alpha:0.9];
                sourceCell.first.backgroundColor = [UIColor clearColor];
            }
            cell = sourceCell;
        } else if ([cell isKindOfClass:NSClassFromString(@"NewDialogCell")]) {
            NewDialogCell *dialogCell = (NewDialogCell *)cell;
            if (enabledBlackTheme) {
                dialogCell.backgroundColor = [UIColor lightBlackColor]; 
            } else if (enabledGroupsListImage) {
                dialogCell.backgroundView = nil;
                if (!dialogCell.dialog.head.read_state && dialogCell.unread.hidden) dialogCell.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
                else dialogCell.contentView.backgroundColor = [UIColor clearColor];
                
                dialogCell.name.textColor = [UIColor colorWithWhite:1 alpha:0.9];
                dialogCell.time.textColor = dialogCell.name.textColor;
                if ([dialogCell respondsToSelector:@selector(dialogText)]) dialogCell.dialogText.textColor = [UIColor colorWithWhite:0.95 alpha:0.9];
                if ([dialogCell respondsToSelector:@selector(text)]) dialogCell.text.textColor = [UIColor colorWithWhite:0.95 alpha:0.9];
                dialogCell.attach.textColor = [UIColor colorWithWhite:0.95 alpha:0.9];
            }
            cell = dialogCell;
        } else if ([cell isKindOfClass:NSClassFromString(@"GroupCell")]) {
            GroupCell *groupCell = (GroupCell *)cell;
            if (enabledBlackTheme) {
                groupCell.backgroundColor = [UIColor lightBlackColor]; 
            } else if (enabledGroupsListImage) {
                groupCell.name.textColor = [UIColor colorWithWhite:1 alpha:0.9];
                groupCell.name.backgroundColor = [UIColor clearColor];
                groupCell.status.textColor = [UIColor colorWithWhite:0.8 alpha:0.9];
                groupCell.status.backgroundColor = [UIColor clearColor];
            }
            cell = groupCell;
        } else {
            cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:0.9];
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.8 alpha:0.9];
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        }
        
        UIView *backView = [UIView new];
        backView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        cell.selectedBackgroundView = backView;
    }
}

static void setupMessageBubbleForCell(ChatCell *cell)
{
    if (enabled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                if (enabledBlackTheme) {
                    cell.bg.image = [cell.bg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    cell.bg.tintColor = [UIColor lightBlackColor];
                } else if (useMessageBubbleTintColor) {
                    cell.bg.image = [cell.bg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    cell.bg.tintColor = cell.message.incoming?messageBubbleTintColor:messageBubbleSentTintColor;
                }
            } completion:nil];
        });
    }
}

static NSInteger VKVersion()
{
    NSString *versionString = @"";
    for (NSString *str in  [[NSString stringWithFormat:@"%@", [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]] componentsSeparatedByString:@"."]) {
        versionString = [versionString stringByAppendingString:str];
    }
    return versionString.integerValue;
}



#pragma mark - AppDelegate
CHDeclareClass(AppDelegate);
CHOptimizedMethod(2, self, BOOL, AppDelegate, application, UIApplication*, application, didFinishLaunchingWithOptions, NSDictionary *, options)
{
    [cvkBunlde load];
    reloadPrefs();
    cvkMainController.cvkCell = cvkMainController.cvkCell;
    
    CHSuper(2, AppDelegate, application, application, didFinishLaunchingWithOptions, options);
    
    [[ColoredVKInstaller sharedInstaller] install:^(BOOL disableTweak) {
        if (!disableTweak) {
            tweakEnabled = YES;
            reloadPrefs();
        }
    }];
    
    BOOL beta = [kColoredVKVersion containsString:@"beta"];
    if (shouldCheckUpdates || beta) {
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        NSInteger daysAgo = [dateFormatter dateFromString:prefs[@"lastCheckForUpdates"]].daysAgo;
        BOOL allDaysPast = beta?(daysAgo >= 1):(daysAgo >= updatesInterval);
        if (!prefs[@"lastCheckForUpdates"] || allDaysPast) checkUpdates();
    }
    
    return YES;
}



#pragma mark UINavigationBar
CHDeclareClass(UINavigationBar);
CHOptimizedMethod(1, self, void, UINavigationBar, setBarTintColor, UIColor*, barTintColor)
{
    if (enabled) {
        if (enabledBlackTheme) {
            barTintColor = [UIColor darkBlackColor];
        } else if (enabledBarColor) {
            if (enabledBarImage) barTintColor = barBackColorWithImage;
            else barTintColor = barBackgroundColor;
        }
    }
    
    CHSuper(1, UINavigationBar, setBarTintColor, barTintColor);
}

CHOptimizedMethod(1, self, void, UINavigationBar, setTintColor, UIColor*, tintColor)
{
    if (enabled) {
        if (enabledBlackTheme) {
            tintColor = [UIColor lightGrayColor];
        } else if (enabledBarColor) {
            tintColor = barForegroundColor;
        }
    }
    
    CHSuper(1, UINavigationBar, setTintColor, tintColor);
}

CHOptimizedMethod(1, self, void, UINavigationBar, setTitleTextAttributes, NSDictionary*, attributes)
{
    if (enabled) {
        if (enabledBlackTheme) {
            attributes = @{ NSForegroundColorAttributeName : [UIColor lightGrayColor] };
        } else if (enabledBarColor) {
            attributes = @{ NSForegroundColorAttributeName : barForegroundColor };
        }
    }
    
    CHSuper(1, UINavigationBar, setTitleTextAttributes, attributes);
}


#pragma mark UITextInputTraits
CHDeclareClass(UITextInputTraits);
CHOptimizedMethod(0, self, UIKeyboardAppearance, UITextInputTraits, keyboardAppearance) 
{
    if (enabled) return enabledBlackTheme?UIKeyboardAppearanceDark:keyboardStyle;
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
           search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
           search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder 
                                                                                             attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:0.7]}];
           search._scopeBarBackgroundView.superview.hidden = YES;
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
        setToolBar(self.toolbar);
        
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
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder
                                                                                              attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:0.7]}];
            NSInteger version = VKVersion();
            if ((version>=22) && (version<=25)) for (UIView *view in self.view.subviews) if ([view isKindOfClass:UIToolbar.class] && useGroupsListBlur) {  setBlur(view, YES); break; }
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
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder
                                                                                              attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:1 alpha:0.7]}];
            search._scopeBarBackgroundView.superview.hidden = YES;
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
            if (!cell.dialog.head.read_state && cell.unread.hidden) cell.contentView.backgroundColor = useCustomMessageReadColor?messageReadColor:[UIColor defaultColorForIdentifier:@"messageReadColor"];
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

#pragma mark BackgroundView
CHDeclareClass(BackgroundView);
CHOptimizedMethod(1, self, void, BackgroundView, drawRect, CGRect, rect)
{
    if (enabled) {
        self.layer.cornerRadius = self.cornerRadius;
        self.layer.masksToBounds = YES;
        if (enabledBlackTheme) self.layer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
        else if (enabledMessagesListImage) self.layer.backgroundColor = useCustomMessageReadColor?messageReadColor.CGColor:[UIColor defaultColorForIdentifier:@"messageReadColor"].CGColor;
        else CHSuper(1, BackgroundView, drawRect, rect);
    } else CHSuper(1, BackgroundView, drawRect, rect);
}

#pragma mark DetailController - тулбар
CHDeclareClass(DetailController);
CHOptimizedMethod(1, self, void, DetailController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DetailController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"DetailController")]) setToolBar(self.inputPanel);
}


#pragma mark ChatController (тулбар)
CHDeclareClass(ChatController);
CHOptimizedMethod(1, self, void, ChatController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, ChatController, viewWillAppear, animated);
    
    setToolBar(self.inputPanel);
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
                if ([self respondsToSelector:@selector(componentTitleView)]) self.componentTitleView.hidden = YES;
                else self.navigationController.navigationBar.topItem.titleView.hidden = YES;
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
        if (enabledMessagesImage) {
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
        if (!self.message.read_state) {
            if (enabledBlackTheme) self.backgroundColor = [UIColor colorWithWhite:40.0/255.0f alpha:1.0];
            else self.backgroundColor = useCustomMessageReadColor?messageReadColor:[UIColor defaultColorForIdentifier:@"messageReadColor"];
        }
        else self.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark ChatCell
CHDeclareClass(ChatCell);
CHOptimizedMethod(4, self, ChatCell*, ChatCell, initWithDelegate, id, delegate, multidialog, BOOL, multidialog, selfdialog, BOOL, selfdialog, identifier, NSString*, identifier)
{
    self = CHSuper(4, ChatCell, initWithDelegate, delegate, multidialog, multidialog, selfdialog, selfdialog, identifier, identifier);
    setupMessageBubbleForCell(self);
    return self;
}

CHOptimizedMethod(0, self, void, ChatCell, prepareForReuse)
{
    CHSuper(0, ChatCell, prepareForReuse);
    setupMessageBubbleForCell(self);
}



#pragma mark VKMMainController
CHDeclareClass(VKMMainController);
CHOptimizedMethod(0, self, NSArray*, VKMMainController, menu)
{
    NSArray *origMenu = CHSuper(0, VKMMainController, menu);
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
    if (shouldInsert) {
        if (index+1 > tempArray.count) [tempArray addObject:cvkMainController.cvkCell];
        else [tempArray insertObject:cvkMainController.cvkCell atIndex:index+1];
    } else {
        [tempArray addObject:cvkMainController.cvkCell];
    }
    origMenu = [tempArray copy];
    return origMenu;
}

CHOptimizedMethod(2, self, CGFloat, VKMMainController, tableView, UITableView*, tableView, heightForRowAtIndexPath, NSIndexPath*, indexPath)
{
    CGFloat height = CHSuper(2, VKMMainController, tableView, tableView, heightForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"VKMMainController")] && (self.menu.count > 0)) {
        UITableViewCell *cell = self.menu[indexPath.row];
        if ([cell.textLabel.text isEqualToString:@"ColoredVK"]) height = 44;
        if ([cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)]) height = 35;
    }
    return height;
}

CHOptimizedMethod(0, self, void, VKMMainController, viewDidLoad)
{
    CHSuper(0, VKMMainController, viewDidLoad);
    if (!mainController) mainController = self;
    if (!mainMenuBackgroundView) {
        mainMenuBackgroundView = [ColoredVKBackgroundImageView viewWithFrame:self.view.frame imageName:@"menuBackgroundImage" blackout:menuImageBlackout parallaxEffect:useMenuParallax];
    }
    
    if (enabled && enabledMenuImage) {
        [mainMenuBackgroundView addToView:self.view];
        [ColoredVKMainController setupUISearchBar:(UISearchBar*)self.tableView.tableHeaderView];
        self.tableView.backgroundColor = [UIColor clearColor];
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, VKMMainController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMMainController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
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
        cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];  
        
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
    CHSuper(1, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch, controller);
}

CHOptimizedMethod(1, self, void, HintsSearchDisplayController, searchDisplayControllerDidEndSearch, UISearchDisplayController*, controller)
{
    if (enabled && (enabledMenuImage && !enabledBlackTheme)) [ColoredVKMainController setupUISearchBar:controller.searchBar];
    CHSuper(1, HintsSearchDisplayController, searchDisplayControllerDidEndSearch, controller);
}



#pragma mark IOS7AudioController
CHDeclareClass(IOS7AudioController);
CHOptimizedMethod(0, self, UIStatusBarStyle, IOS7AudioController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"IOS7AudioController")] && ( enabled && (!enabledBlackTheme && (enabledBarColor || enabledAudioImage)))) return UIStatusBarStyleLightContent;
    else return CHSuper(0, IOS7AudioController, preferredStatusBarStyle);
}

CHOptimizedMethod(1, self, void, IOS7AudioController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, IOS7AudioController, viewWillAppear, animated);
    
    if (enabled && [self isKindOfClass:NSClassFromString(@"IOS7AudioController")]) {
        if (enabledBlackTheme) {
            setupAudioPlayer(self.hostView, [UIColor lightGrayColor]);
            self.cover.backgroundColor = [UIColor blackColor];
            self.hostView.backgroundColor = [UIColor colorWithWhite:30/255.0f alpha:1.0];
        } else if (changeAudioPlayerAppearance) {
            if (!cvkLyricsView) cvkLyricsView = [[ColoredVKAudioLyricsView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.hostView.frame.origin.y - 64)];
            if (!cvkCoverView) cvkCoverView = [[ColoredVKAudioCoverView alloc] initWithFrame:self.view.frame andSeparationPoint:self.hostView.frame.origin];
            audioTintColor = cvkCoverView.tintColor?cvkCoverView.tintColor:[UIColor whiteColor];
            
            UINavigationBar *navBar = self.navigationController.navigationBar;
            navBar.topItem.titleView.hidden = YES;
            navBar.shadowImage = [UIImage new];
            [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            navBar.topItem.leftBarButtonItems = @[];
            navBar.tintColor = [UIColor whiteColor];
            
            UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender) { [self done:nil]; }];
            downSwipe.maximumDuration = 0.5;
            downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
            [self.view addGestureRecognizer:downSwipe];
            
            setupAudioPlayer(self.hostView, nil);
            self.cover.hidden = YES;
            self.hostView.backgroundColor = [UIColor clearColor];
            [self.pp setImage:[[self.pp imageForState:UIControlStateSelected] imageWithTintColor:audioTintColor] forState:UIControlStateSelected];
            [self.seek setMinimumTrackImage:[[self.seek minimumTrackImageForState:UIControlStateNormal] imageWithTintColor:[UIColor colorWithRed:229/255.0f green:230/255.0f blue:231/255.0f alpha:1]] forState:UIControlStateNormal];
            [self.seek setMaximumTrackImage:[[self.seek maximumTrackImageForState:UIControlStateNormal] imageWithTintColor:[UIColor colorWithRed:200/255.0f green:201/255.0f blue:202/255.0f alpha:1]] forState:UIControlStateNormal];
            [self.seek setThumbImage:[[self.seek thumbImageForState:UIControlStateNormal] imageWithTintColor:[UIColor blackColor]] forState:UIControlStateNormal];
            
            [NSNotificationCenter.defaultCenter addObserverForName:@"com.daniilpashin.coloredvk.audio.image.changed" object:nil queue:nil usingBlock:^(NSNotification *note) {
                audioTintColor = cvkCoverView.defaultCover?[UIColor whiteColor]:cvkCoverView.tintColor;
                [UIView animateWithDuration:0.3 animations:^{
                    cvkLyricsView.hostView.subviews[0].backgroundColor = cvkCoverView.defaultCover?[UIColor clearColor]:cvkCoverView.backColor;
                    [self.pp setImage:[[self.pp imageForState:UIControlStateSelected] imageWithTintColor:audioTintColor] forState:UIControlStateSelected];
                    setupAudioPlayer(self.hostView, nil);
                }];
            }];
            
            [self.view addSubview:cvkCoverView];
            [self.view sendSubviewToBack:cvkCoverView];
            [self.view addSubview:cvkLyricsView];
        }
    }
}

#pragma mark AudioPlayer
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
CHOptimizedMethod(0, self, void, AudioAlbumController, viewDidLoad)
{
    CHSuper(0, AudioAlbumController, viewDidLoad);
    
    if (enabled && ([self isKindOfClass:NSClassFromString(@"AudioAlbumController")] || [self isKindOfClass:NSClassFromString(@"AudioAlbumsController")])) {
        if (enabledBlackTheme) {
            self.tableView.backgroundColor = [UIColor darkBlackColor];
        } else if (enabledAudioImage) {
            UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
            if (search) {
                search.backgroundImage = [UIImage new];
                search.tag = 3;
                search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
                search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder
                                                                                                  attributes:@{NSForegroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.7]}];
                search._scopeBarBackgroundView.superview.hidden = YES;
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





#pragma mark PhotoBrowserController
CHDeclareClass(PhotoBrowserController);
CHOptimizedMethod(1, self, void, PhotoBrowserController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, PhotoBrowserController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"PhotoBrowserController")]) {
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



#pragma mark VKMBrowserController
CHDeclareClass(VKMBrowserController);
CHOptimizedMethod(1, self, void, VKMBrowserController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMBrowserController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"VKMBrowserController")]) {
        ColoredVKBarDownloadButton *saveButton = [ColoredVKBarDownloadButton buttonWithURL:self.target.url.absoluteString rootController:self];
        self.navigationItem.rightBarButtonItem = saveButton;
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:self.target.url] queue:[NSOperationQueue mainQueue] 
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (![[response.MIMEType componentsSeparatedByString:@"/"].firstObject isEqualToString:@"image"]) self.navigationItem.rightBarButtonItem = nil;
                               }];
        if (enabled && enabledBarColor) {
            for (UIView *view in self.navigationItem.titleView.subviews) if ([view respondsToSelector:@selector(setTextColor:)]) ((UILabel*)view).textColor = barForegroundColor;
        }
        
        setBlur(self.navigationController.navigationBar, NO);
    }
}

#pragma mark VKProfile
CHDeclareClass(VKProfile);
CHOptimizedMethod(0, self, BOOL, VKProfile, verified)
{
    if ([self.user.uid  isEqual: @89911723]) return YES;
    return CHSuper(0, VKProfile, verified);
}


#pragma mark VKSession
CHDeclareClass(VKSession);
CHOptimizedMethod(0, self, NSString*, VKSession, token)
{
    NSString *token = CHSuper(0, VKSession, token);
    if (token) userToken  = token;
    return token;
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



@interface PSListController : UIViewController @end
CHDeclareClass(PSListController);
CHOptimizedMethod(1, self, void, PSListController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, PSListController, viewWillAppear, animated);
    self.navigationController.navigationBar._backgroundView.alpha = 1.0;
    setBlur(self.navigationController.navigationBar, NO);
}




CHDeclareClass(MessageController);
CHOptimizedMethod(1, self, void, MessageController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, MessageController, viewWillAppear, animated);
    setBlur(self.navigationController.navigationBar, NO);
}



CHDeclareClass(VKComment);
CHOptimizedMethod(0, self, BOOL, VKComment, separatorDisabled)
{
    if (enabled) return hideCommentSeparators;
    return CHSuper(0, VKComment, separatorDisabled);
}





#pragma mark Static methods
static void reloadPrefsNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    reloadPrefs();
    [cvkMainController reloadSwitch:enabled];
}

static void reloadMenuNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    for (UIView *view in mainController.view.subviews) if (view.tag == 25) { [view removeFromSuperview]; break; }
    [mainController.tableView reloadData];
    
    BOOL shouldShow = (enabled && (!enabledBlackTheme && enabledMenuImage));
    
    mainMenuBackgroundView.hidden = shouldShow?NO:YES;
    mainController.tableView.backgroundColor = shouldShow?[UIColor clearColor]:kMenuCellBackgroundColor;
    UISearchBar *searchBar = (UISearchBar *)mainController.tableView.tableHeaderView;
    shouldShow?[ColoredVKMainController setupUISearchBar:searchBar]:[ColoredVKMainController resetUISearchBar:searchBar];
    
    if (shouldShow) {
        [mainMenuBackgroundView updateViewForKey:@"menuImageBlackout"];
        [mainMenuBackgroundView addToView:mainController.view];
    }
}

CHConstructor
{
    @autoreleasepool {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{ dlopen([[NSBundle mainBundle] pathForResource:@"FLEXDylib" ofType:@"dylib"].UTF8String, RTLD_NOW); });
        
        prefsPath = CVK_PREFS_PATH;
        cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        vksBundle = [NSBundle bundleWithPath:VKS_BUNDLE_PATH];
        cvkFolder = CVK_FOLDER_PATH;
        cvkMainController = [ColoredVKMainController new];
        
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:prefsPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:prefsPath]) prefs = [NSMutableDictionary new];
        NSString *stringVersion = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        prefs[@"vkVersion"] = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        [prefs writeToFile:prefsPath atomically:YES];
        VKSettingsEnabled = (NSClassFromString(@"VKSettings") != nil)?YES:NO;
        
        
        if (VKVersion() >= 22) {
            CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
            CFNotificationCenterAddObserver(center, NULL, reloadPrefsNotify,  CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
            CFNotificationCenterAddObserver(center, NULL, reloadMenuNotify,   CFSTR("com.daniilpashin.coloredvk.reload.menu"),   NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                
                
            CHLoadLateClass(MessageController);
            CHHook(1, MessageController, viewWillAppear);
            
            CHLoadLateClass(PSListController);
            CHHook(1, PSListController, viewWillAppear);
            
            
            CHLoadLateClass(VKMLiveSearchController);
            CHHook(2, VKMLiveSearchController, tableView, cellForRowAtIndexPath);
            CHHook(1, VKMLiveSearchController, searchDisplayControllerWillBeginSearch);
            CHHook(1, VKMLiveSearchController, searchDisplayControllerWillEndSearch);
            
            
            CHLoadLateClass(DialogsSearchController);
            CHHook(2, DialogsSearchController, tableView, cellForRowAtIndexPath);
            CHHook(1, DialogsSearchController, searchDisplayControllerWillBeginSearch);
            CHHook(1, DialogsSearchController, searchDisplayControllerWillEndSearch);
            
            
            
            CHLoadLateClass(VKSession);
            CHHook(0, VKSession, token);
            
            CHLoadLateClass(AppDelegate);
            CHHook(2,  AppDelegate, application, didFinishLaunchingWithOptions);
            
            
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
            CHHook(2, VKMMainController, tableView, heightForRowAtIndexPath);
            CHHook(0, VKMMainController, VKMTableCreateSearchBar);
            CHHook(0, VKMMainController, menu);
            CHHook(0, VKMMainController, viewDidLoad);
            
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
            CHHook(0, AudioAlbumController, viewDidLoad);
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
            
            CHLoadLateClass(AudioRenderer);
            CHHook(0, AudioRenderer, playIndicator);
            
            
            CHLoadLateClass(ChatCell);
            CHHook(4, ChatCell, initWithDelegate, multidialog, selfdialog, identifier);
            CHHook(0, ChatCell, prepareForReuse);
            
            
            CHLoadLateClass(VKComment);
            CHHook(0, VKComment, separatorDisabled);
            
            CHLoadLateClass(DetailController);
            CHHook(1, DetailController, viewWillAppear);


        } else {
            showAlertWithMessage([NSString stringWithFormat:CVKLocalizedString(@"VKAPP_VERSION_IS_TOO_LOW"),  stringVersion, @"2.2"]);
        }
    }
}
