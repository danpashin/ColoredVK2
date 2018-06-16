//
//  TweakFunctions.m
//  ColoredVK
//
//  Created by Даниил on 10.12.17.
//

#import "Tweak.h"

void setBlur(UIView *bar, BOOL set, UIColor *color, UIBlurEffectStyle style)
{
    [NSObject cvk_runBlockOnMainThread:^{
        NSInteger blurViewTag = 1054326;
        
        if (set && !UIAccessibilityIsReduceTransparencyEnabled()) {
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
                verticalFormat = @"V:[view(0.5)]|";
                
                if (![backgroundView.subviews containsObject:[backgroundView viewWithTag:blurViewTag]]) {
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
                verticalFormat = @"V:|[view(0.5)]";
                
                if (![toolBar.subviews containsObject:[toolBar viewWithTag:blurViewTag]]) {
                    toolBar.barTintColor = [UIColor clearColor];
                    blurEffectView.frame = CGRectMake(0, 0, toolBar.frame.size.width, toolBar.frame.size.height);
                    borderView.frame = CGRectMake(0, 0, toolBar.frame.size.width, 0.5);
                    
                    [toolBar insertSubview:blurEffectView atIndex:0];
                    [toolBar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
                }
            } else if  ([bar isKindOfClass:[UITabBar class]]) {
                UITabBar *tabbar = (UITabBar *)bar;
                verticalFormat = @"V:|[view(0.5)]";
                
                if (![tabbar.subviews containsObject:[tabbar viewWithTag:blurViewTag]]) {
                    blurEffectView.frame = CGRectMake(0, 0, tabbar.frame.size.width, tabbar.frame.size.height);
                    borderView.frame = CGRectMake(0, 0, tabbar.frame.size.width, 0.5);
                    
                    [tabbar insertSubview:blurEffectView atIndex:0];
                    
                    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                        tabbar._backgroundView.alpha = 0.0f;
                    } completion:nil];
                }
            } else if  ([bar isKindOfClass:[UIView class]]) {
                verticalFormat = @"V:|[view(0.5)]";
                
                if (![bar.subviews containsObject:[bar viewWithTag:blurViewTag]]) {
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
        } else {
            if ([bar isKindOfClass:[UINavigationBar class]]) {
                UINavigationBar *navbar = (UINavigationBar *)bar;
                UIView *backgroundView = navbar._backgroundView;
                UIView *blurView = [backgroundView viewWithTag:blurViewTag];
                
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    [navbar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
                    blurView.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    [blurView removeFromSuperview];
                }];
            } else if  ([bar isKindOfClass:[UIToolbar class]]) {
                UIToolbar *toolBar = (UIToolbar *)bar;
                if ([toolBar.subviews containsObject:[toolBar viewWithTag:blurViewTag]])
                    [[toolBar viewWithTag:blurViewTag] removeFromSuperview];
            } else if  ([bar isKindOfClass:[UITabBar class]]) {
                UITabBar *tabbar = (UITabBar *)bar;
                
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                    tabbar._backgroundView.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    if ([tabbar.subviews containsObject:[tabbar viewWithTag:blurViewTag]])
                        [[tabbar viewWithTag:blurViewTag] removeFromSuperview];
                }];
            } else if  ([bar isKindOfClass:[UIView class]]) {
                if ([bar.subviews containsObject:[bar viewWithTag:blurViewTag]])
                    [[bar viewWithTag:blurViewTag] removeFromSuperview];
            }
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
    } else setBlur(toolbar, NO, nil, 0);
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
    if (!color) color = audioPlayerTintColor;
    for (UIView *view in hostView.subviews) {
        view.backgroundColor = [UIColor clearColor];
        if ([view respondsToSelector:@selector(setTextColor:)]) ((UILabel *)view).textColor = color;
        if ([view respondsToSelector:@selector(setImage:forState:)]) 
            [(UIButton*)view setImage:[[(UIButton*)view imageForState:UIControlStateNormal] cvk_imageWithTintColor:color] forState:UIControlStateNormal];
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
            if ([parentController isKindOfClass:NSClassFromString(@"VKMNavigationController")]) {
                VKMNavigationController *navigation = (VKMNavigationController *)parentController;
                if (navigation.childViewControllers.count>0) {
                    if ([navigation.childViewControllers.firstObject isKindOfClass:NSClassFromString(@"VKSelectorContainerControllerDropdown")]) {
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
        setBlur(navBar, NO, nil, 0);
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

void uncaughtExceptionHandler(NSException *exception)
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    NSString *stringDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDictionary *crash = @{@"reason": exception.reason, @"callStackReturnAddresses": exception.callStackReturnAddresses, 
                            @"callStackSymbols":exception.callStackSymbols, @"date":stringDate};
    [crash writeToFile:CVK_CRASH_PATH atomically:YES];
}

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
            tabbar.tintColor = [UIColor cvk_defaultColorForIdentifier:@"TabbarSelForegroundColor"];
            unselectedItemTintColor = [UIColor cvk_defaultColorForIdentifier:@"TabbarForegroundColor"];
        }
        tabbar.barTintColor = barTintColor;
        tabbar.tintColor = tintColor;
        
        if (ios_available(10.0))
            tabbar.unselectedItemTintColor = unselectedItemTintColor;
        
        for (UITabBarItem *item in tabbar.items) {
            if (ios_available(10.0)) {
                item.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            } else {
                UIColor *itemTintColor = (enabled && enabledTabbarColor) ? (enableNightTheme ? cvkMainController.nightThemeScheme.buttonColor : tabbarForegroundColor) : [UIColor cvk_defaultColorForIdentifier:@"TabbarForegroundColor"];
                item.image = [item.image cvk_imageWithTintColor:itemTintColor];
            }
            item.selectedImage = [item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }
}

void resetTabBar()
{
    if ([cvkMainController.vkMainController isKindOfClass:[UITabBarController class]]) {
        UITabBar *tabbar = ((UITabBarController *)cvkMainController.vkMainController).tabBar;
        setBlur(tabbar, NO, nil, 0);
        
        setupTabbar();
    }
}

void setupHeaderFooterView(UITableViewHeaderFooterView *view, UITableView *tableView)
{
    void (^setColors)(void) = ^(void){
        if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
            view.contentView.backgroundColor = [UIColor clearColor];
            view.backgroundView.backgroundColor = [UIColor clearColor];
            view.textLabel.backgroundColor = [UIColor clearColor];
            view.textLabel.textColor = (tableView.tag == 24) ? UITableViewCellTextColor.cvk_darkerColor : UITableViewCellTextColor;
            view.detailTextLabel.textColor = (tableView.tag == 24) ? UITableViewCellTextColor.cvk_darkerColor : UITableViewCellTextColor;
        }
    };
    if (enableNightTheme) {
        if (![tableView.delegate isKindOfClass:NSClassFromString(@"ColoredVKPrefs")]) {
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
            view.contentView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
        }
    } else if (tableView.tag == 24) {
        setColors();
    }
}

void setupNewDialogCellForNightTheme(NewDialogCell *dialogCell)
{
    if (enabled && enableNightTheme && [dialogCell isKindOfClass:NSClassFromString(@"NewDialogCell")]) {
        dialogCell.contentView.backgroundColor = [UIColor clearColor];
        dialogCell.backgroundView.hidden = YES;
        
        if ([dialogCell.dialog.head respondsToSelector:@selector(read_state)]) {
            if (!dialogCell.dialog.head.read_state && dialogCell.unread.hidden)
                dialogCell.backgroundColor = cvkMainController.nightThemeScheme.unreadBackgroundColor;
            else
                dialogCell.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        }
        
        dialogCell.name.textColor = cvkMainController.nightThemeScheme.textColor;
        
        objc_setAssociatedObject(dialogCell.attach, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
        dialogCell.attach.textColor = cvkMainController.nightThemeScheme.detailTextColor;
        
        objc_setAssociatedObject(dialogCell.time, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
        dialogCell.time.textColor = cvkMainController.nightThemeScheme.detailTextColor;
        
        if ([dialogCell respondsToSelector:@selector(dialogText)]) {
            objc_setAssociatedObject(dialogCell.dialogText, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
            dialogCell.dialogText.textColor = cvkMainController.nightThemeScheme.detailTextColor;
        }
        if ([dialogCell respondsToSelector:@selector(text)]) {
            if (dialogCell.text) {
                objc_setAssociatedObject(dialogCell.text, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
                dialogCell.text.textColor = cvkMainController.nightThemeScheme.detailTextColor;
            }
        }
    }
}

void setupExtraSettingsController(VKMTableController *controller)
{
    if (![controller isKindOfClass:NSClassFromString(@"VKMTableController")])
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

NSAttributedString *attributedStringForNightTheme(NSAttributedString * text)
{
    if (enabled && enableNightTheme) {
        NSMutableAttributedString *mutableText = [[NSMutableAttributedString alloc] initWithAttributedString:text];
        [mutableText enumerateAttributesInRange:NSMakeRange(0, mutableText.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            
            void (^setColor)(BOOL isLink, BOOL forMOCTLabel, BOOL detailed) = ^(BOOL isLink, BOOL forMOCTLabel, BOOL detailed) {
                NSString *attribute = forMOCTLabel ? @"CTForegroundColor" : NSForegroundColorAttributeName;
                
                id textColor = cvkMainController.nightThemeScheme.textColor;
                if (isLink)
                    textColor = cvkMainController.nightThemeScheme.linkTextColor;
                if (detailed)
                    textColor = cvkMainController.nightThemeScheme.detailTextColor;
                
                if (forMOCTLabel) {
                    textColor = (id)((UIColor *)textColor).CGColor;
                    if (isLink) {
                        [mutableText addAttribute:@"MOCTLinkInactiveAttributeName" value:@{@"CTForegroundColor": textColor} range:range];
                        [mutableText addAttribute:@"MOCTLinkActiveAttributeName" value:@{@"CTForegroundColor": textColor} range:range];
                    }
                }
                [mutableText addAttribute:attribute value:textColor range:range];
            };
            
            if (attrs[@"MOCTLinkAttributeName"])
                setColor(YES, YES, NO);
            else if (attrs[@"VKTextLink"] || attrs[@"NSLink"])
                setColor(YES, NO, NO);
            else {
                if (attrs[@"CTForegroundColor"])
                    setColor(NO, YES, NO);
                else if (attrs[@"CVKDetailed"])
                    setColor(NO, NO, YES);
                else
                    setColor(NO, NO, NO);
            }
        }];
        return mutableText;
    }
    
    return text;
}


void setupNightSeparatorForView(UIView *view)
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
        [cvkMainController setMenuCellSwitchOn:enabled];
        
        setupTabbar();
        updateNavBarColor();
    });
}

void reloadMenuNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    reloadPrefs(^{
        updateNavBarColor();
        
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

void updateNightTheme(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    [cvkMainController.nightThemeScheme updateForType:[prefs[@"nightThemeType"] integerValue]];
    
    resetTabBar();
    
    [NSObject cvk_runBlockOnMainThread:^{
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
    }];
}

void setupNewSearchBar(VKSearchBar *searchBar, UIColor *tintColor, UIColor *blurTone, UIBlurEffectStyle blurStyle)
{
    if (![searchBar isKindOfClass:NSClassFromString(@"VKSearchBar")])
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
    setBlur(searchBar.backgroundView, NO, nil, 0);
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


void setupNightTextField(UITextField *textField)
{
    if (enabled && enableNightTheme) {
        textField.textColor = cvkMainController.nightThemeScheme.textColor;
        
        UILabel *placeholderLabel = [textField valueForKeyPath:@"_placeholderLabel"];
        if (placeholderLabel) {
            objc_setAssociatedObject(placeholderLabel, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
            placeholderLabel.textColor = cvkMainController.nightThemeScheme.detailTextColor;
        }
    }
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

void updateControllerBlurInfo(UIViewController *controller)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL shouldAddBlur = NO;
        UIColor *blurColor = [UIColor clearColor];
        UIBlurEffectStyle blurStyle = 0;
        if (enabled) {
            NSString *selfName = CLASS_NAME(controller);
            NSString *modelName = [controller respondsToSelector:@selector(model)] ? CLASS_NAME(objc_msgSend(controller, @selector(model))) : @"";
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

void setupNewMessageCellBubble(UICollectionViewCell *cell)
{
    if (!enabled)
        return;
    
    UIColor *tintColor = nil;
    if (enableNightTheme) {
        tintColor = cvkMainController.nightThemeScheme.incomingBackgroundColor;
    }
    
    if (!tintColor)
        return;
    
    if (![cell respondsToSelector:@selector(bubbleView)])
        return;
    
    UIView *bubbleView = objc_msgSend(cell, @selector(bubbleView));
    if (![bubbleView isKindOfClass:[UIView class]])
        return;
    if (![bubbleView.layer isKindOfClass:[CAShapeLayer class]])
        return;
    
    ((CAShapeLayer *)bubbleView.layer).fillColor = tintColor.CGColor;
}

void updateNavBarColor(void)
{
    UIViewController *rootViewController = [UIApplication sharedApplication].windows.firstObject.rootViewController;
    
    [rootViewController.childViewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *)obj;
            [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                navController.navigationBar.barTintColor = navController.navigationBar.barTintColor;
                [navController.navigationBar layoutIfNeeded];
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
        
        if ([cell isKindOfClass:NSClassFromString(@"MenuBirthdayCell")]) {
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
