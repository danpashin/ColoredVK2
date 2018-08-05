//
//  TweakFunctions.m
//  ColoredVK
//
//  Created by Даниил on 10.12.17.
//

#import "Tweak.h"
#import <mach-o/dyld.h>
#import "ColoredVKSwiftMenuController.h"
#import "ColoredVKSwiftMenuButton.h"

void reloadPrefsNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
void reloadMenuNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
void updateNightTheme(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);

CVK_CONSTRUCTOR
{
    @autoreleasepool {
        REGISTER_CORE_OBSERVER(reloadPrefsNotify, kPackageNotificationReloadPrefs);
        REGISTER_CORE_OBSERVER(reloadMenuNotify, kPackageNotificationReloadMenu);
        REGISTER_CORE_OBSERVER(updateNightTheme, kPackageNotificationUpdateNightTheme);
    }
}

void setupBlur(UIView *bar, UIColor *color, UIBlurEffectStyle style)
{
    [NSObject cvk_runBlockOnMainThread:^{
        NSInteger blurViewTag = 1054326;
        
        if (UIAccessibilityIsReduceTransparencyEnabled())
            return;
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:style];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        blurEffectView.tag = blurViewTag;
        blurEffectView.backgroundColor = color;
        
        UIView *borderView = [UIView new];
        borderView.backgroundColor = [UIColor whiteColor];
        borderView.alpha = 0.15f;
        [blurEffectView.contentView addSubview:borderView];
        
        NSString *verticalFormat = @"";
        if ([bar isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navbar = (UINavigationBar *)bar;
            UIView *backgroundView = navbar._backgroundView;
            
            if (![backgroundView.subviews containsObject:[backgroundView viewWithTag:blurViewTag]]) {
                verticalFormat = @"V:[view(0.5)]|";
                blurEffectView.effect = nil;
                blurEffectView.frame = backgroundView.bounds;
                borderView.frame = CGRectMake(0.0f, blurEffectView.frame.size.height - 0.5f, blurEffectView.frame.size.width, 0.5f);
                [backgroundView insertSubview:blurEffectView atIndex:0];
                
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    blurEffectView.effect = blurEffect;
                    [navbar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
                    navbar.shadowImage = [UIImage new];
                } completion:nil];
            }
        } else if  ([bar isKindOfClass:[UIToolbar class]]) {
            UIToolbar *toolBar = (UIToolbar *)bar;
            
            if (![toolBar.subviews containsObject:[toolBar viewWithTag:blurViewTag]]) {
                verticalFormat = @"V:|[view(0.5)]";
                toolBar.barTintColor = [UIColor clearColor];
                blurEffectView.frame = CGRectMake(0, 0, toolBar.frame.size.width, toolBar.frame.size.height);
                borderView.frame = CGRectMake(0, 0, toolBar.frame.size.width, 0.5);
                
                [toolBar insertSubview:blurEffectView atIndex:0];
                [toolBar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
            }
        } else if  ([bar isKindOfClass:[UITabBar class]]) {
            UITabBar *tabbar = (UITabBar *)bar;
            
            if (![tabbar.subviews containsObject:[tabbar viewWithTag:blurViewTag]]) {
                verticalFormat = @"V:|[view(0.5)]";
                blurEffectView.frame = CGRectMake(0, 0, tabbar.frame.size.width, tabbar.frame.size.height);
                borderView.frame = CGRectMake(0, 0, tabbar.frame.size.width, 0.5);
                
                [tabbar insertSubview:blurEffectView atIndex:0];
                
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    tabbar._backgroundView.alpha = 0.0f;
                } completion:nil];
            }
        } else if  ([bar isKindOfClass:[UIView class]]) {
            
            if (![bar.subviews containsObject:[bar viewWithTag:blurViewTag]]) {
                verticalFormat = @"V:|[view(0.5)]";
                blurEffectView.frame = CGRectMake(0, 0, bar.frame.size.width, bar.frame.size.height);
                borderView.frame = CGRectMake(0, 0, bar.frame.size.width, 0.5);
                
                [bar insertSubview:blurEffectView atIndex:0];
            }
        }
        
        if (verticalFormat.length > 2) {
            borderView.translatesAutoresizingMaskIntoConstraints = NO;
            [blurEffectView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalFormat options:0 metrics:nil views:@{@"view":borderView}]];
            [blurEffectView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"  options:0 metrics:nil views:@{@"view":borderView}]];
        }
    }];
}

void removeBlur(UIView *bar, void(^completion)(void))
{
    [NSObject cvk_runBlockOnMainThread:^{
        NSInteger blurViewTag = 1054326;
        if ([bar isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navbar = (UINavigationBar *)bar;
            UIView *backgroundView = navbar._backgroundView;
            UIView *blurView = [backgroundView viewWithTag:blurViewTag];
            
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                [navbar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
                blurView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [blurView removeFromSuperview];
                if (completion)
                    completion();
            }];
        } else if ([bar isKindOfClass:[UIToolbar class]]) {
            UIToolbar *toolBar = (UIToolbar *)bar;
            if ([toolBar.subviews containsObject:[toolBar viewWithTag:blurViewTag]])
                [[toolBar viewWithTag:blurViewTag] removeFromSuperview];
            
            if (completion)
                completion();
        } else if ([bar isKindOfClass:[UITabBar class]]) {
            UITabBar *tabbar = (UITabBar *)bar;
            UIVisualEffectView *effectView = [bar viewWithTag:blurViewTag];
            if (!effectView) {
                if (completion)
                    completion();
                
                return;
            }
            
            effectView.backgroundColor = tabbar.barTintColor;
            effectView.tag = 0;
            [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                tabbar._backgroundView.alpha = 1.0f;
            } completion:^(BOOL finishedOne) {
                [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    effectView.effect = nil;
                    effectView.alpha = 0;
                } completion:^(BOOL finishedTwo) {
                    [effectView removeFromSuperview];
                    
                    if (completion)
                        completion();
                }];
                
            }];
        } else if ([bar isKindOfClass:[UIView class]]) {
            if ([bar.subviews containsObject:[bar viewWithTag:blurViewTag]])
                [[bar viewWithTag:blurViewTag] removeFromSuperview];
            
            if (completion)
                completion();
        }
    }];
}

void setToolBar(UIToolbar *toolbar)
{
    if (enabled && [toolbar respondsToSelector:@selector(setBarTintColor:)]) {
        if (enableNightTheme) {
            toolbar.barTintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
            toolbar.tintColor = cvkMainController.nightThemeScheme.textColor;
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
                            [btn setTitleColor:toolBarForegroundColor.cvk_darkerColor forState:UIControlStateDisabled];
                            [btn setTitleColor:toolBarForegroundColor forState:UIControlStateNormal];
                            BOOL btnToExclude = NO;
                            NSMutableArray <NSString *> *btnsWithActionsToExclude = [NSMutableArray arrayWithObject:@"actionToggleEmoji:"];
                            if (isNew3XClient) {
                                [btnsWithActionsToExclude addObject:@"send:"];
                                [btnsWithActionsToExclude addObject:@"actionSendInline:"];
                            }
                            
                            for (NSString *action in [btn actionsForTarget:btn.allTargets.allObjects[0] forControlEvent:UIControlEventTouchUpInside]) {
                                if ([btnsWithActionsToExclude containsObject:action]) btnToExclude = YES;
                            }
                            if (!btnToExclude && btn.currentImage)
                                [btn setImage:[[btn imageForState:UIControlStateNormal] cvk_imageWithTintColor:toolBarForegroundColor] forState:UIControlStateNormal];
                        }
                    }
                    
                }
                
            }
        } 
    } else removeBlur(toolbar, nil);
}

UIVisualEffectView *blurForView(UIView *view, NSInteger tag)
{
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    blurEffectView.frame = view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurEffectView.tag = tag;
    
    return blurEffectView;
}

void setupAudioPlayer(UIView *hostView, UIColor *color)
{
    if (enabled && enableNightTheme)
        return;
    
    if (!color) color = audioPlayerTintColor;
    for (UIView *view in hostView.subviews) {
        view.backgroundColor = [UIColor clearColor];
        if ([view respondsToSelector:@selector(setTextColor:)]) ((UILabel *)view).textColor = color;
        if ([view respondsToSelector:@selector(setImage:forState:)]) 
            [(UIButton*)view setImage:[[(UIButton*)view imageForState:UIControlStateNormal] cvk_imageWithTintColor:color] forState:UIControlStateNormal];
    }
}

#pragma GCC diagnostic push 
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
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
        
        if ([cell isKindOfClass:objc_lookUpClass("SourceCell")] || [cell isKindOfClass:objc_lookUpClass("UserCell")]) {
            SourceCell *sourceCell = (SourceCell *)cell;
            sourceCell.last.textColor = UITableViewCellTextColor;
            sourceCell.last.backgroundColor = UITableViewCellBackgroundColor;
            sourceCell.first.textColor = UITableViewCellTextColor;
            sourceCell.first.backgroundColor = UITableViewCellBackgroundColor;
        } else if ([cell isKindOfClass:objc_lookUpClass("NewDialogCell")]) {
            NewDialogCell *dialogCell = (NewDialogCell *)cell;
            dialogCell.backgroundView = nil;
            if (!dialogCell.dialog.head.read_state && dialogCell.unread.hidden)
                dialogCell.contentView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
            else
                dialogCell.contentView.backgroundColor = UITableViewCellBackgroundColor;
            
            dialogCell.name.textColor = UITableViewCellTextColor;
            dialogCell.time.textColor = UITableViewCellTextColor;
            dialogCell.attach.textColor = [UIColor colorWithWhite:0.95f alpha:0.9f];
            if ([dialogCell respondsToSelector:@selector(dialogText)])
                dialogCell.dialogText.textColor = [UIColor colorWithWhite:0.95f alpha:0.9f];
            if ([dialogCell respondsToSelector:@selector(text)])
                dialogCell.text.textColor = [UIColor colorWithWhite:0.95f alpha:0.9f];
            
        } else if ([cell isKindOfClass:objc_lookUpClass("GroupCell")]) {
            GroupCell *groupCell = (GroupCell *)cell;
            groupCell.name.textColor = UITableViewCellTextColor;
            groupCell.name.backgroundColor = UITableViewCellBackgroundColor;
            groupCell.status.textColor = UITableViewCellDetailedTextColor;
            groupCell.status.backgroundColor = UITableViewCellBackgroundColor;
        } else if ([cell isKindOfClass:objc_lookUpClass("VideoCell")]) {
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
        backView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
        cell.selectedBackgroundView = backView;
    }
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
                controller.searchBar.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
            };
            [UIView animateWithDuration:0.1f delay:0.0f options:0.0f animations:^{ removeAllBlur(); } completion:^(BOOL finished) { removeAllBlur(); }];
        } else {
            controller.searchResultsTableView.tag = 21;
            UIViewController *parentController = controller.searchContentsController.parentViewController;
            if ([parentController isKindOfClass:objc_lookUpClass("VKMNavigationController")]) {
                VKMNavigationController *navigation = (VKMNavigationController *)parentController;
                if (navigation.childViewControllers.count>0) {
                    if ([navigation.childViewControllers.firstObject isKindOfClass:objc_lookUpClass("VKSelectorContainerControllerDropdown")]) {
                        VKSelectorContainerControllerDropdown *dropdown = (VKSelectorContainerControllerDropdown *)navigation.childViewControllers.firstObject;
                        VKMTableController *tableController = (VKMTableController *)dropdown.currentViewController;
                        if ([tableController respondsToSelector:@selector(tableView)] && [tableController.tableView.backgroundView isKindOfClass:[ColoredVKWallpaperView class]]) {
                            ColoredVKWallpaperView *backView = (ColoredVKWallpaperView*)tableController.tableView.backgroundView;
                            controller.searchResultsTableView.backgroundView = [backView copy];
                        }
                    } else if ([navigation.childViewControllers.firstObject respondsToSelector:@selector(tableView)]) {
                        VKMTableController *tableController = (VKMTableController*)navigation.childViewControllers.firstObject;
                        if ([tableController.tableView.backgroundView isKindOfClass:[ColoredVKWallpaperView class]]) {
                            ColoredVKWallpaperView *backView = (ColoredVKWallpaperView*)tableController.tableView.backgroundView;
                            controller.searchResultsTableView.backgroundView = [backView copy];
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
#pragma GCC diagnostic pop

void resetUISearchBar(UISearchBar *searchBar)
{
    [NSObject cvk_runBlockOnMainThread:^{
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
    }];
}

void performInitialCellSetup(UITableViewCell *cell)
{
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    UIView *backView = [UIView new];
    backView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    cell.selectedBackgroundView = backView;
}

void resetNavigationBar(UINavigationBar *navBar)
{
    [NSObject cvk_runBlockOnMainThread:^{
        removeBlur(navBar, nil);
        navBar._backgroundView.alpha = 1.0;
        [cvkMainController.navBarImageView removeFromSuperview];
        navBar.barTintColor = kNavigationBarBarTintColor;
        for (UIView *subview in navBar._backgroundView.subviews) {
            if ([subview isKindOfClass:[UIVisualEffectView class]]) subview.hidden = NO;
        }
    }];
}

void actionChangeCornerRadius(UIWindow *window)
{
    [NSObject cvk_runBlockOnMainThread:^{
        UIWindow *localWindowVar = window;
        if (!localWindowVar) {
            localWindowVar = [UIApplication sharedApplication].windows.lastObject;
            localWindowVar.layer.masksToBounds = YES;
        }
        
        CGFloat cornerRaduis = enabled ? appCornerRadius : 0.0f;
        
        CABasicAnimation *cornerAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        cornerAnimation.fromValue = @(localWindowVar.layer.cornerRadius);
        cornerAnimation.toValue = @(cornerRaduis);
        cornerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        cornerAnimation.duration = 0.3f;
        
        localWindowVar.layer.cornerRadius = cornerRaduis;
        [localWindowVar.layer addAnimation:cornerAnimation forKey:@"cornerAnimation"];
    }];
}

#pragma mark -
#pragma mark Exception
NSMutableArray <NSDictionary *> *handleCallStack(NSArray<NSString *> *callStackSymbols, NSArray<NSNumber *> *callStackReturnAddresses)
{
    NSMutableArray <NSDictionary *> *callStack = [NSMutableArray array];
    for (NSString *symbol in callStackSymbols) {
        NSUInteger index = [callStackSymbols indexOfObject:symbol];
        NSNumber *address = @0;
        
        if (index <= callStackReturnAddresses.count - 1) {
            address = callStackReturnAddresses[index];
        }
        
        [callStack addObject:@{@"symbol":symbol, @"address":address}];
    }
    
    return callStack;
}

void uncaughtExceptionHandler(NSException *exception)
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    NSString *stringDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSMutableArray <NSString *> *systemLibs = [NSMutableArray array];
    NSMutableArray <NSString *> *usrLibs = [NSMutableArray array];
    NSMutableArray <NSString *> *tweakLibs = [NSMutableArray array];
    NSMutableArray <NSString *> *otherLibs = [NSMutableArray array];
    
    for (uint32_t i=0; i<_dyld_image_count(); i++) {
        const char *libName = _dyld_get_image_name(i);
        if (strstr(libName, "/System/Library/") != NULL) {
            [systemLibs addObject:@(libName)];
        } else if (strstr(libName, "/usr/lib/") != NULL) {
            [usrLibs addObject:@(libName)];
        } else if (strstr(libName, "/Library/TweakInject/") != NULL || strstr(libName, "/Library/MobileSubstrate/") != NULL) {
            [tweakLibs addObject:@(libName)];
        } else {
            [otherLibs addObject:@(libName)];
        }
    }
    
    NSMutableArray *callStack = handleCallStack(exception.callStackSymbols, exception.callStackReturnAddresses);
    
    NSDictionary *crash = @{@"reason": exception.reason,
                            @"call_stack":callStack, @"date":stringDate, 
                            @"loaded_libraries":@{@"system":systemLibs, @"usr":usrLibs, @"tweaks":tweakLibs, @"other":otherLibs}, 
                            @"current_thread":[NSThread currentThread].description
                            };
    NSData *crashData = [NSKeyedArchiver archivedDataWithRootObject:crash];
    cvk_writeData(crashData, CVK_CRASH_PATH, nil);
}
#pragma mark -


void setupUISearchBar(UISearchBar *searchBar)
{
    if (![searchBar isKindOfClass:[UISearchBar class]])
        return;
    
    [NSObject cvk_runBlockOnMainThread:^{
        UIView *barBackground = searchBar.subviews[0].subviews[0];
        if (menuSelectionStyle == CVKCellSelectionStyleBlurred) {
            searchBar.backgroundColor = [UIColor clearColor];
            if (![barBackground.subviews containsObject: [barBackground viewWithTag:102] ]) [barBackground addSubview:blurForView(barBackground, 102)];
        } else if (menuSelectionStyle == CVKCellSelectionStyleTransparent) {
            if ([barBackground.subviews containsObject: [barBackground viewWithTag:102]]) [[barBackground viewWithTag:102] removeFromSuperview];
            searchBar.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
        } else {
            if ([barBackground.subviews containsObject: [barBackground viewWithTag:102]]) [[barBackground viewWithTag:102] removeFromSuperview];
            searchBar.backgroundColor = [UIColor clearColor];
        }
        
        UIView *subviews = searchBar.subviews.lastObject;
        UITextField *barTextField = subviews.subviews[1];
        if ([barTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
            barTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:barTextField.placeholder  
                                                                                 attributes:@{NSForegroundColorAttributeName:changeMenuTextColor?menuTextColor:[UIColor colorWithWhite:1 alpha:0.5f]}];
        }
    }];
}

void setupTabbar()
{
    UITabBarController *controller = (UITabBarController *)cvkMainController.vkMainController;
    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBar *tabbar = controller.tabBar;
        
        UIColor *barTintColor = nil;
        UIColor *tintColor = nil;
        UIColor *unselectedItemTintColor = nil;
        
        if (enabled && enableNightTheme) {
            barTintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
            tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
            unselectedItemTintColor = cvkMainController.nightThemeScheme.buttonColor;
        } else if (enabled && enabledTabbarColor) {
            barTintColor = tabbarBackgroundColor;
            tintColor = tabbarSelForegroundColor;
            unselectedItemTintColor = tabbarForegroundColor;
        } else {
            barTintColor = [UIColor cvk_defaultColorForIdentifier:@"TabbarBackgroundColor"];
            tintColor = [UIColor cvk_defaultColorForIdentifier:@"TabbarSelForegroundColor"];
            unselectedItemTintColor = [UIColor cvk_defaultColorForIdentifier:@"TabbarForegroundColor"];
        }
        
        [NSObject cvk_runBlockOnMainThread:^{
            UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction;
            [UIView transitionWithView:tabbar duration:0.3f options:options animations:^{
                tabbar.barTintColor = barTintColor;
                tabbar.tintColor = tintColor;
                
                if (ios_available(10.0))
                    tabbar.unselectedItemTintColor = unselectedItemTintColor;
            } completion:nil];
        }];
    }
}

void resetTabBar()
{
    if ([cvkMainController.vkMainController isKindOfClass:[UITabBarController class]]) {
        UITabBar *tabbar = ((UITabBarController *)cvkMainController.vkMainController).tabBar;
        removeBlur(tabbar, ^{
            setupTabbar();
        });
    }
}

void setupHeaderFooterView(UITableViewHeaderFooterView *view, UITableView *tableView)
{
    if (![view isKindOfClass:[UITableViewHeaderFooterView class]] || ![tableView isKindOfClass:[UITableView class]])
        return;
    
    if (enabled && enableNightTheme) {
        view.contentView.backgroundColor = [UIColor clearColor];
        view.backgroundView.backgroundColor = [UIColor clearColor];
        return;
    }
    
    if (tableView.tag != 21 && tableView.tag != 22 && tableView.tag != 24)
        return;
    
    view.contentView.backgroundColor = [UIColor clearColor];
    view.backgroundView.backgroundColor = [UIColor clearColor];
    view.textLabel.backgroundColor = [UIColor clearColor];
    view.textLabel.textColor = (tableView.tag == 24) ? UITableViewCellTextColor.cvk_darkerColor : UITableViewCellTextColor;
    view.detailTextLabel.textColor = (tableView.tag == 24) ? UITableViewCellTextColor.cvk_darkerColor : UITableViewCellTextColor;

    if (tableView.tag == 21 && ![view.contentView.subviews containsObject:[view.contentView viewWithTag:5]]) {
        [view.contentView addSubview:blurForView(view, 5)];
    } else if (tableView.tag == 22) {
        view.contentView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
    }
}

void setupExtraSettingsController(VKMTableController *controller)
{
    if (![controller isKindOfClass:objc_lookUpClass("VKMTableController")])
        return;
    
    if (enabled && !enableNightTheme && enabledSettingsExtraImage) {
        [cvkMainController setImageToTableView:controller.tableView name:@"settingsExtraBackgroundImage" blackout:settingsExtraImageBlackout 
                                parallaxEffect:useSettingsExtraParallax blur:settingsExtraUseBackgroundBlur];
        
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
        if ([cell isKindOfClass:objc_lookUpClass("SourceCell")]) {
            SourceCell *sourceCell = (SourceCell *)cell;
            sourceCell.last.textColor = textColor;
            sourceCell.last.backgroundColor = UITableViewCellBackgroundColor;
            sourceCell.first.textColor = textColor;
            sourceCell.first.backgroundColor = UITableViewCellBackgroundColor;
        }
        else if ([cell isKindOfClass:objc_lookUpClass("VKMRendererCell")]) {
            for (UIView *subview in cell.contentView.subviews) {
                if ([subview isKindOfClass:[UILabel class]]) {
                    ((UILabel *)subview).textColor = textColor;
                }
            }
        } else if ([cell isKindOfClass:objc_lookUpClass("CommunityCommentsCell")]) {
            CommunityCommentsCell *commentsCell =  (CommunityCommentsCell *)cell;
            commentsCell.titleLabel.textColor = textColor;
            commentsCell.titleLabel.backgroundColor = UITableViewCellBackgroundColor;
            commentsCell.subtitleLabel.textColor = textColor;
            commentsCell.subtitleLabel.backgroundColor = UITableViewCellBackgroundColor;
        }
    }
}



void hideFastButtonForController(VKMBrowserController *browserController)
{
    if (showFastDownloadButton) {
        NSString *title = [browserController.webView stringByEvaluatingJavaScriptFromString:@"document.title"].lowercaseString;
        if (!([title containsString:@"jpg"] || [title containsString:@"jpeg"] || [title containsString:@"png"])) {
            browserController.navigationItem.rightBarButtonItem = nil;
        }
    }
}

void reloadPrefsNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    reloadPrefs(^{
        if ([cvkMainController.vkMainController respondsToSelector:@selector(dialogsController)]) {
            DialogsController *dialogsController = (DialogsController *)cvkMainController.vkMainController.dialogsController;
            if ([dialogsController respondsToSelector:@selector(tableView)]) {
                [dialogsController.tableView reloadData];
            }
        }
        
        setupTabbar();
        updateNavBarColor();
    });
}

void reloadMenu(void(^completion)(void))
{
    reloadPrefs(^{
        updateNavBarColor();
        
        BOOL shouldShow = (enabled && !enableNightTheme && enabledMenuImage);
        
        VKMLiveController *menuController = nil;
        if ([cvkMainController.vkMainController isKindOfClass:[UITabBarController class]]) {
            menuController = cvkMainController.vkMenuController;
            [cvkMainController.menuBackgroundView updateViewWithBlackout:menuImageBlackout];
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
        
        if (shouldShow) {
            if (menuTableView) {
                setupUISearchBar(searchBar);
                [menuTableView reloadData];
                menuTableView.backgroundColor = [UIColor clearColor];
                menuTableView.backgroundView = nil;
            }
            
            [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                cvkMainController.menuBackgroundView.alpha = 1.0f;
            } completion:nil];
        } else {
            [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                cvkMainController.menuBackgroundView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                if (menuTableView) {
                    if (isNew3XClient)
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
        
        if (completion)
            completion();
    });
}

void reloadMenuNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    reloadMenu(nil);
}

void updateNightTheme(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    reloadMenu(^{
        resetTabBar();
        void (^resetController)(id rootController, SEL controllerSelector) = ^(id rootController, SEL controllerSelector) {
            if ([rootController respondsToSelector:controllerSelector]) {
                VKMTableController *controller = [rootController cvk_executeSelector:controllerSelector];
                if ([controller respondsToSelector:@selector(VKMScrollViewReset)]) {
                    [controller VKMScrollViewReset];
                    [controller VKMScrollViewReloadData];
                }
                
                UIColor *backgroundColor = [UIColor colorWithRed:235/255.0f green:237/255.0f blue:240/255.0f alpha:1.0f];
                if ([controller respondsToSelector:@selector(tableView)]) {
                    controller.tableView.backgroundColor = backgroundColor;
                    controller.tableView.separatorColor = backgroundColor;
                    controller.tableView.backgroundView = nil;
                }
                if ([controller respondsToSelector:@selector(collectionView)]) {
                    UICollectionView *collectionView = [rootController cvk_executeSelector:@selector(collectionView)];
                    collectionView.backgroundColor = backgroundColor;
                }
            }
        };
        
        if ([cvkMainController.vkMainController respondsToSelector:@selector(newsController)])
            resetController(cvkMainController.vkMainController.newsController, @selector(currentViewController));
        
        if ([cvkMainController.vkMainController respondsToSelector:@selector(feedbackController)]) 
            resetController(cvkMainController.vkMainController.feedbackController, @selector(currentViewController));
        
        resetController(cvkMainController.vkMainController, @selector(discoverController));
        resetController(cvkMainController.vkMainController, @selector(dialogsController));
        
        if (!enabled || !enabledMenuImage)
            resetController(cvkMainController.vkMainController, @selector(menuController));
    });
}

void setupNewSearchBar(VKSearchBar *searchBar, UIColor *tintColor, UIColor *blurTone, UIBlurEffectStyle blurStyle)
{
    if (![searchBar isKindOfClass:objc_lookUpClass("VKSearchBar")])
        return;
    
    objc_setAssociatedObject(searchBar, "cvk_customized", @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(searchBar, "cvk_blurColor", blurTone, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(searchBar, "cvk_blurStyle", @(blurStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    searchBar.backgroundView.backgroundColor = [UIColor clearColor];
    searchBar.segmentedControl.tintColor = enabledBarColor ? barForegroundColor : tintColor;
    searchBar.placeholderLabel.textColor = tintColor;
    searchBar.textField.textColor = tintColor;
    searchBar.textField.tintColor = tintColor;
    searchBar.textFieldBackground.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
    searchBar.separator.hidden = YES;
    searchBar.segmentedControl.layer.borderColor = tintColor.CGColor;
}

void resetNewSearchBar(VKSearchBar *searchBar)
{
    removeBlur(searchBar.backgroundView, nil);
    searchBar.backgroundView.backgroundColor = searchBar.config.backgroundColor;
    searchBar.placeholderLabel.textColor = searchBar.config.placeholderTextColor;
    searchBar.textFieldBackground.backgroundColor = searchBar.config.textfieldBackgroundColor;
    searchBar.textField.textColor = searchBar.config.textfieldTextColor;
    searchBar.textField.tintColor = searchBar.config.textfieldTintColor;
    searchBar.segmentedControl.tintColor = searchBar.config.segmentTintColor;
    searchBar.textFieldBackground.tintColor = searchBar.config.textfieldBackgroundColor;
    searchBar.separator.hidden = NO;
    searchBar.segmentedControl.layer.borderColor = searchBar.config.segmentBorderColor.CGColor;
}

void setupNewDialogsSearchController(DialogsSearchResultsController *controller)
{
    if (![controller respondsToSelector:@selector(tableView)])
        return;
    
    if (enabled && !enableNightTheme && enabledMessagesListImage) {
        if ([controller.parentViewController isKindOfClass:objc_lookUpClass("DialogsController")]) {
            DialogsController *dialogsController = (DialogsController *)controller.parentViewController;
            if ([dialogsController.tableView.backgroundView isKindOfClass:[ColoredVKWallpaperView class]]) {
                controller.tableView.backgroundView = [dialogsController.tableView.backgroundView copy];
                controller.tableView.separatorColor = dialogsController.tableView.separatorColor;
            }
        }
    }
}

void updateControllerBlurInfo(UIViewController *controller)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL shouldAddBlur = NO;
        UIColor *blurColor = [UIColor clearColor];
        UIBlurEffectStyle blurStyle = 0;
        if (enabled) {
            NSString *selfName = CLASS_NAME(controller);
            NSString *modelName = [controller respondsToSelector:@selector(model)] ? CLASS_NAME((__bridge id)[controller cvk_executeSelector:@selector(model)]) : @"";
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
        
        objc_setAssociatedObject(controller, "cvkShouldAddBlur", @(shouldAddBlur), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(controller, "cvkBlurColor", blurColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(controller, "cvkBlurStyle", @(blurStyle), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    });
}

void updateNavBarColor(void)
{
    UIViewController *rootViewController = [UIApplication sharedApplication].windows.firstObject.rootViewController;
    
    [rootViewController.childViewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UINavigationController class]]) {
            UINavigationBar *navigationBar = ((UINavigationController *)obj).navigationBar;
            [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                navigationBar.barTintColor = kNavigationBarBarTintColor;
                navigationBar.tintColor = [UIColor whiteColor];
                navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
                [navigationBar layoutIfNeeded];
            } completion:nil];
            *stop = YES;
        }
    }];
}

void setupNewAppMenuCell(UITableViewCell *cell)
{
    cell.contentView.backgroundColor = [UIColor clearColor];
    if (enabled && enableNightTheme) {
        cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = cvkMainController.nightThemeScheme.buttonColor;
        cell.textLabel.textColor = cvkMainController.nightThemeScheme.textColor;
    } else if (enabled && enabledMenuImage) {
        cell.backgroundColor = [UIColor clearColor];
        
        cell.textLabel.textColor = changeMenuTextColor?menuTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = changeMenuTextColor?menuTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = changeMenuTextColor?menuTextColor:[UIColor colorWithWhite:1.0f alpha:0.8f];
        
        if ([cell isKindOfClass:objc_lookUpClass("MenuBirthdayCell")]) {
            MenuBirthdayCell *birthdayCell = (MenuBirthdayCell *)cell;
            birthdayCell.name.textColor = cell.textLabel.textColor;
            birthdayCell.status.textColor = cell.textLabel.textColor;
        }
    } else {
        if (isNew3XClient) {
            cell.imageView.tintColor = [UIColor colorWithRed:0.667f green:0.682f blue:0.702f alpha:1.0f];
            cell.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor colorWithRed:0.18f green:0.188f blue:0.2f alpha:1.0f];
        } else {
            cell.imageView.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
            cell.backgroundColor = kMenuCellBackgroundColor;
            cell.textLabel.textColor = kMenuCellTextColor;
        }
    }
}

void setupQuickMenuController(void)
{
    VKMMainController *vkMainController = cvkMainController.vkMainController;
    __weak typeof(vkMainController) weakVkMainController = vkMainController;
    if (enableQuickAccessMenu && [vkMainController isKindOfClass:[UITabBarController class]]) {
        UITabBar *tabbar = ((UITabBarController *)vkMainController).tabBar;
        
        ColoredVKSwiftMenuController *swiftController = [[ColoredVKSwiftMenuController alloc] initWithParentViewController:vkMainController];
        __weak typeof(swiftController) weakSwiftController = swiftController;
        
        if (enableQuickAccessMenuForceTouch)
            [swiftController registerForceTouchForView:tabbar];
        
        if (enableQuickAccessMenuLongPress)
            [swiftController registerLongPressForView:tabbar];
        
        
        ColoredVKSwiftMenuButton *presentPrefsItem = [ColoredVKSwiftMenuButton new];
        presentPrefsItem.icon = CVKImage(@"prefs/SettingsIcon");
        presentPrefsItem.selectedTintColor = CVKMainColor;
        presentPrefsItem.canHighlight = NO;
        presentPrefsItem.selectHandler = ^(ColoredVKSwiftMenuButton * _Nonnull menuButton) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSwiftController dismissViewControllerAnimated:YES completion:^{
                    if ([weakVkMainController respondsToSelector:@selector(currentNavigationController)]) {
                        UINavigationController *navController = weakVkMainController.currentNavigationController;
                        [navController pushViewController:cvkMainController.safePreferencesController animated:YES];
                    }
                }];
            });
        };
        
        ColoredVKSwiftMenuButton *enableTweakItem = [ColoredVKSwiftMenuButton new];
        enableTweakItem.selected = enabled;
        enableTweakItem.selectedTitle = @"Твик включен";
        enableTweakItem.unselectedTitle = @"Твик выключен";
        enableTweakItem.icon = CVKImage(@"prefs/PowerIcon");
        enableTweakItem.selectedTintColor = CVKMainColor;
        enableTweakItem.selectHandler = ^(ColoredVKSwiftMenuButton * _Nonnull menuButton) {
            NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:CVK_PREFS_PATH];
            
            prefs[@"enabled"] = @(menuButton.selected);
            
            cvk_writePrefs(prefs, kPackageNotificationUpdateNightTheme);
        };
        
        ColoredVKSwiftMenuButton *nightThemeItem = [ColoredVKSwiftMenuButton new];
        nightThemeItem.selected = enableNightTheme;
        nightThemeItem.selectedTintColor = CVKMainColor;
        nightThemeItem.icon = CVKImage(@"prefs/MoonIcon");
        nightThemeItem.selectedTitle = @"Ночная тема включена";
        nightThemeItem.unselectedTitle = @"Ночная тема выключена";
        nightThemeItem.selectHandler = ^(ColoredVKSwiftMenuButton * _Nonnull menuButton) {
            NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:CVK_PREFS_PATH];
            prefs[@"nightThemeType"] = @(-1);
            
            cvk_writePrefs(prefs, kPackageNotificationUpdateNightTheme);
        };
        
        ColoredVKSwiftMenuItemsGroup *group = [[ColoredVKSwiftMenuItemsGroup alloc] initWithButtons:@[presentPrefsItem, enableTweakItem, nightThemeItem]];
        group.name = @"COLOREDVK 2";
        [swiftController.itemsGroups addObject:group];
    }
}
