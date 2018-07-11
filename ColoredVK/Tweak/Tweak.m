//
//  Tweak.m
//  ColoredVK
//
//  Created by Даниил on 21.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/


#import "Tweak.h"
#import "ColoredVKBarDownloadButton.h"

#pragma mark VKMController
CHDeclareClass(VKMController);
CHDeclareMethod(0, void, VKMController, VKMNavigationBarUpdate)
{
    CHSuper(0, VKMController, VKMNavigationBarUpdate);
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (enabled) {
        if (!enableNightTheme && enabledBarImage) {
            [NSObject cvk_runBlockOnMainThread:^{
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
            }];
        }
        else if (enabledBarColor) {
            [cvkMainController.navBarImageView removeFromSuperview];
        }
    } else [cvkMainController.navBarImageView removeFromSuperview];  
}

#pragma mark VKMLiveController 
CHDeclareClass(VKMLiveController);

CHDeclareMethod(0, UIStatusBarStyle, VKMLiveController, preferredStatusBarStyle)
{
    if (enabledGroupsListImage && [self.model.description containsString:@"GroupsSearchModel"])
        return UIStatusBarStyleLightContent;
    
    return CHSuper(0, VKMLiveController, preferredStatusBarStyle);
}

CHDeclareMethod(1, void, VKMLiveController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMLiveController, viewWillAppear, animated);
    
    if (enabled && !enableNightTheme && [self isKindOfClass:objc_lookUpClass("VKMLiveController")]) {
        NSArray <NSString *> *audioModelNames = @[@"AudioRecommendationsModel", @"AudioCatalogPlaylistsListModel", @"AudioCatalogExtendedPlaylistsListModel"];
        if (enabledAudioImage && [audioModelNames containsObject:CLASS_NAME(self.model)]) {
           UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
            if ([search isKindOfClass:[UISearchBar class]] && [search respondsToSelector:@selector(setBackgroundImage:)]) {
                search.backgroundImage = [UIImage new];
                search.tag = 4;
                search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
                NSDictionary *attributes = @{NSForegroundColorAttributeName:changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1 alpha:0.7f]};
                NSString *placeholder = (search.searchBarTextField.placeholder.length > 0) ? search.searchBarTextField.placeholder : @"";
                search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:attributes];
                search._scopeBarBackgroundView.superview.hidden = YES;
            }
        }
        
        if (enabledGroupsListImage && [self.model.description containsString:@"GroupsSearchModel"]) {
            self.tableView.separatorColor = [self.tableView.separatorColor colorWithAlphaComponent:0.2f];
            [cvkMainController setImageToTableView:self.tableView name:@"groupsListBackgroundImage" blackout:groupsListImageBlackout 
                                    parallaxEffect:useGroupsListParallax blur:groupsListUseBackgroundBlur];
        }
    }
}

CHDeclareMethod(0, void, VKMLiveController, viewWillLayoutSubviews)
{
    CHSuper(0, VKMLiveController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && [self isKindOfClass:objc_lookUpClass("VKMLiveController")]) {
        NSArray <NSString *> *audioModelNames = @[@"AudioRecommendationsModel", @"AudioCatalogPlaylistsListModel", @"AudioCatalogExtendedPlaylistsListModel"];
        if (enabledAudioImage && [audioModelNames containsObject:CLASS_NAME(self.model)]) {
            [cvkMainController setImageToTableView:self.tableView name:@"audioBackgroundImage" blackout:audioImageBlackout 
                                    parallaxEffect:useAudioParallax blur:audiosUseBackgroundBlur];
            self.tableView.separatorColor = [self.tableView.separatorColor colorWithAlphaComponent:0.2f];
            self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
            if (audiosUseBlur)
                setupBlur(self.navigationController.navigationBar, audiosBlurTone, audiosBlurStyle);
            else
                removeBlur(self.navigationController.navigationBar, nil);
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, VKMLiveController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMLiveController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && [self isKindOfClass:objc_lookUpClass("VKMLiveController")]) {
        NSArray <NSString *> *audioModelNames = @[@"AudioRecommendationsModel", @"AudioCatalogPlaylistsListModel", @"AudioCatalogExtendedPlaylistsListModel"];
        if (enabledAudioImage && [audioModelNames containsObject:CLASS_NAME(self.model)]) {
            performInitialCellSetup(cell);
            
            cell.textLabel.textColor = changeAudiosTextColor ? audiosTextColor : UITableViewCellTextColor;
            cell.detailTextLabel.textColor = changeAudiosTextColor ? audiosTextColor.cvk_darkerColor : UITableViewCellDetailedTextColor;
        }
        
        if (enabledGroupsListImage && [self.model.description containsString:@"GroupsSearchModel"]) {
            GroupCell *groupCell = (GroupCell *)cell;
            
            performInitialCellSetup(groupCell);
            
            UIColor *textColor = changeGroupsListTextColor ? groupsListTextColor : UITableViewCellTextColor;
            groupCell.status.textColor = textColor.cvk_darkerColor;
            groupCell.name.textColor = textColor;
            groupCell.status.backgroundColor = [UIColor clearColor];
            groupCell.name.backgroundColor = [UIColor clearColor];
        }
    }
    return cell;
}

#pragma mark VKMController
// Настройка бара навигации
CHDeclareClass(VKMController);
CHDeclareMethod(1, void, VKMController, viewWillAppear, BOOL, animated)
{
    if ([self isKindOfClass:objc_lookUpClass("VKMTableController")] ||
        [self isKindOfClass:objc_lookUpClass("DialogsController")] || 
        [self isKindOfClass:objc_lookUpClass("ChatController")] || 
        [self isKindOfClass:objc_lookUpClass("VKWebAppContainerController")])
        updateControllerBlurInfo(self);
    
    CHSuper(1, VKMController, viewWillAppear, animated);
}

CHDeclareMethod(1, void, VKMController, viewDidAppear, BOOL, animated)
{
    if ([self isKindOfClass:objc_lookUpClass("VKMTableController")] || 
        [self isKindOfClass:objc_lookUpClass("DialogsController")] || 
        [self isKindOfClass:objc_lookUpClass("ChatController")] || 
        [self isKindOfClass:objc_lookUpClass("VKWebAppContainerController")])
        {
        
        [NSObject cvk_runBlockOnMainThread:^{
            UIColor *blurColor = objc_getAssociatedObject(self, "cvkBlurColor");
            if (!blurColor)
                blurColor = [UIColor clearColor];
            
            __block NSNumber *shouldAddBlur = objc_getAssociatedObject(self, "cvkShouldAddBlur");
            if (!shouldAddBlur) 
                shouldAddBlur = @NO;
            
            NSNumber *blurStyle = objc_getAssociatedObject(self, "cvkBlurStyle");
            if (!blurStyle)
                blurStyle = @0;
            
            if (enabled && enableNightTheme) {
                shouldAddBlur = @NO;
                
                if ([self respondsToSelector:@selector(tableView)]) {
                    UITableView *tableView = objc_msgSend(self, @selector(tableView));
                    if ([tableView.tableHeaderView isKindOfClass:[UISearchBar class]]) {
                        UISearchBar *searchBar = (UISearchBar *)tableView.tableHeaderView;
                        
                        searchBar.barTintColor = cvkMainController.nightThemeScheme.foregroundColor;
                        searchBar.translucent = NO;
                        [searchBar setBackgroundImage:[UIImage cvk_imageWithColor:cvkMainController.nightThemeScheme.foregroundColor] 
                                       forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
                        searchBar.searchBarTextField.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
                        searchBar.scopeBarBackgroundImage = [UIImage cvk_imageWithColor:cvkMainController.nightThemeScheme.foregroundColor];
                    }
                }
            }
            
            if (shouldAddBlur.boolValue)
                setupBlur(self.navigationController.navigationBar, blurColor, blurStyle.integerValue);
            else
                removeBlur(self.navigationController.navigationBar, nil);
            
            if ([cvkMainController.vkMainController isKindOfClass:[UITabBarController class]]) {
                if (shouldAddBlur.boolValue)
                    setupBlur(((UITabBarController *)cvkMainController.vkMainController).tabBar, blurColor, blurStyle.integerValue);
                else
                    removeBlur(((UITabBarController *)cvkMainController.vkMainController).tabBar, nil);
            }
        }];
    }
    
    CHSuper(1, VKMController, viewDidAppear, animated);
}



#pragma mark VKMToolbarController
    // Настройка тулбара
CHDeclareClass(VKMToolbarController);
CHDeclareMethod(1, void, VKMToolbarController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMToolbarController, viewWillAppear, animated);
    if ([self respondsToSelector:@selector(toolbar)]) {
        setToolBar(self.toolbar);
        if (!enableNightTheme && enabled && enabledToolBarColor) {
            self.segment.tintColor = toolBarForegroundColor;
        }
        
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
        
        if (shouldAddBlur)
            setupBlur(self.toolbar, blurColor, blurStyle);
        else
            removeBlur(self.toolbar, nil);
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




#pragma mark PhotoBrowserController
CHDeclareClass(PhotoBrowserController);
CHDeclareMethod(1, void, PhotoBrowserController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, PhotoBrowserController, viewWillAppear, animated);
    if ([self isKindOfClass:objc_lookUpClass("PhotoBrowserController")]) {
        if (showFastDownloadButton) {
            ColoredVKBarDownloadButton *saveButton = [ColoredVKBarDownloadButton button];
            __weak typeof(self) weakSelf = self;
            saveButton.urlBlock = ^NSString*() {
                NSString *imageSource = @"";
                
                NSInteger pageIndex = (NSInteger)(weakSelf.paging.contentOffset.x / weakSelf.paging.frame.size.width);
                __kindof VKPhoto *photo = [weakSelf photoForPage:pageIndex];
                
                NSInteger maxVariantIndex = 0;
                for (VKImageVariant *variant in photo.variants.allValues) {
                    if (variant.type > maxVariantIndex) {
                        maxVariantIndex = variant.type;
                        imageSource = variant.src;
                    }
                }
                
                return imageSource;
            };
            saveButton.rootViewController = self;
            NSMutableArray *buttons = [self.navigationItem.rightBarButtonItems mutableCopy];
            if (buttons.count < 2) [buttons addObject:saveButton];
            self.navigationItem.rightBarButtonItems = buttons;
        }
    }
}


#pragma mark VKMBrowserController
CHDeclareClass(VKMBrowserController);

CHDeclareMethod(0, UIStatusBarStyle, VKMBrowserController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:objc_lookUpClass("VKMBrowserController")] && enabled && (enabledBarColor || enableNightTheme))
        return UIStatusBarStyleLightContent;
    else return CHSuper(0, VKMBrowserController, preferredStatusBarStyle);
}

CHDeclareMethod(0, void, VKMBrowserController, viewDidLoad)
{
    CHSuper(0, VKMBrowserController, viewDidLoad);
    if ([self isKindOfClass:objc_lookUpClass("VKMBrowserController")] && showFastDownloadButton) {
        self.navigationItem.rightBarButtonItem = [ColoredVKBarDownloadButton buttonWithURL:self.target.url.absoluteString rootController:self];
    }
}

CHDeclareMethod(1, void, VKMBrowserController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMBrowserController, viewWillAppear, animated);
    if ([self isKindOfClass:objc_lookUpClass("VKMBrowserController")]) {
        
        if (enabled && enableNightTheme) {
            self.webScrollView.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            self.webView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
            [self.safariButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        else if (enabled && enabledBarColor && !enableNightTheme) {
            if ([self respondsToSelector:@selector(headerTitle)])
                self.headerTitle.textColor = barForegroundColor;
        }
        resetNavigationBar(self.navigationController.navigationBar);
        resetTabBar();
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


#pragma mark UserWallController
CHDeclareClass(UserWallController);
CHDeclareMethod(0, void, UserWallController, updateProfile)
{
    CHSuper(0, UserWallController, updateProfile);
    
    [NSObject cvk_runBlockOnMainThread:^{
        if (!self.profile.item)
            return;
        
        NSDictionary <NSString *, NSString *> *users = @{@"89911723": @"vkapp/DeveloperNavIcon", @"125879328": @"vkapp/id125879328_NavIcon"};
        NSString *stringID = [NSString stringWithFormat:@"%@", self.profile.item.user.uid];
        
        if (users[stringID]) {
            CGRect navBarFrame = self.navigationController.navigationBar.bounds;
            UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
            titleView.center = CGPointMake(CGRectGetMidX(navBarFrame), CGRectGetMidY(navBarFrame));
            
            NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
            titleView.image = [UIImage imageNamed:users[stringID] inBundle:cvkBundle compatibleWithTraitCollection:nil];
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
    }];
}

#pragma GCC diagnostic push 
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
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
#pragma GCC diagnostic pop



#pragma mark ProfileInfoEditController
CHDeclareClass(ProfileInfoEditController);
CHDeclareMethod(0, UIStatusBarStyle, ProfileInfoEditController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:objc_lookUpClass("ProfileInfoEditController")] && enabled && (enabledBarColor || enableNightTheme))
        return UIStatusBarStyleLightContent;
    return CHSuper(0, ProfileInfoEditController, preferredStatusBarStyle);
}

#pragma mark OptionSelectionController
CHDeclareClass(OptionSelectionController);
CHDeclareMethod(0, UIStatusBarStyle, OptionSelectionController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:objc_lookUpClass("OptionSelectionController")] && enabled && (enabledBarColor || enableNightTheme))
        return UIStatusBarStyleLightContent;
    return CHSuper(0, OptionSelectionController, preferredStatusBarStyle);
}

CHDeclareMethod(1, void, OptionSelectionController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, OptionSelectionController, viewWillAppear, animated);
    if ([self isKindOfClass:objc_lookUpClass("OptionSelectionController")]) {
        resetNavigationBar(self.navigationController.navigationBar);
        resetTabBar();
    }
}

#pragma mark VKRegionSelectionViewController
CHDeclareClass(VKRegionSelectionViewController);
CHDeclareMethod(0, UIStatusBarStyle, VKRegionSelectionViewController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:objc_lookUpClass("VKRegionSelectionViewController")] && enabled && (enabledBarColor || enableNightTheme))
        return UIStatusBarStyleLightContent;
    return CHSuper(0, VKRegionSelectionViewController, preferredStatusBarStyle);
}

#pragma mark ProfileFriendsController
CHDeclareClass(ProfileFriendsController);
CHDeclareMethod(0, void, ProfileFriendsController, viewWillLayoutSubviews)
{
    CHSuper(0, ProfileFriendsController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledFriendsImage && [self isKindOfClass:objc_lookUpClass("ProfileFriendsController")]) {
        [cvkMainController setImageToTableView:self.tableView name:@"friendsBackgroundImage" blackout:friendsImageBlackout 
                                parallaxEffect:useFriendsParallax blur:friendsUseBackgroundBlur];
        self.tableView.separatorColor = hideFriendsSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.tableView.sectionIndexColor = UITableViewCellTextColor;
        self.tableView.tag = 22;
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        
        UIColor *textColor = changeFriendsTextColor?friendsTextColor:[UIColor colorWithWhite:1.0f alpha:0.7f];
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if ([search isKindOfClass:objc_lookUpClass("VKSearchBar")]) {
            setupNewSearchBar((VKSearchBar *)search, textColor, friendsBlurTone, friendsBlurStyle);
        } else if ([search isKindOfClass:[UISearchBar class]] && [search respondsToSelector:@selector(setBackgroundImage:)]) {
            search.backgroundImage = [UIImage new];
            search.tag = 6;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder
                                                                                              attributes:@{NSForegroundColorAttributeName:textColor}];
            search._scopeBarBackgroundView.superview.hidden = YES;
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, ProfileFriendsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ProfileFriendsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledFriendsImage && [self isKindOfClass:objc_lookUpClass("ProfileFriendsController")]) {
        performInitialCellSetup(cell);
            
        if ([cell isKindOfClass:objc_lookUpClass("SourceCell")]) {
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
    
    if (enabled && !enableNightTheme && enabledFriendsImage && [self isKindOfClass:objc_lookUpClass("FriendsBDaysController")]) {
        [cvkMainController setImageToTableView:self.tableView name:@"friendsBackgroundImage" blackout:friendsImageBlackout 
                                parallaxEffect:useFriendsParallax blur:friendsUseBackgroundBlur];
        self.tableView.separatorColor = hideFriendsSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.tableView.tag = 22;
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
}

CHDeclareMethod(2, UITableViewCell*, FriendsBDaysController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, FriendsBDaysController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledFriendsImage && [self isKindOfClass:objc_lookUpClass("FriendsBDaysController")]) {
        performInitialCellSetup(cell);
        
        FriendBdayCell *sourceCell = (FriendBdayCell *)cell;
        sourceCell.name.textColor = changeFriendsTextColor?friendsTextColor:UITableViewCellTextColor;
        sourceCell.name.backgroundColor = UITableViewCellBackgroundColor;
        sourceCell.status.textColor = changeFriendsTextColor?friendsTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
        sourceCell.status.backgroundColor = UITableViewCellBackgroundColor;
    }
    
    return cell;
}


#pragma mark FriendsAllRequestsController
CHDeclareClass(FriendsAllRequestsController);
CHDeclareMethod(1, void, FriendsAllRequestsController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, FriendsAllRequestsController, viewWillAppear, animated);
    
    if (enabled && !enableNightTheme && enabledFriendsImage && [self isKindOfClass:objc_lookUpClass("FriendsAllRequestsController")]) {
        [cvkMainController setImageToTableView:self.tableView name:@"friendsBackgroundImage" blackout:friendsImageBlackout 
                                parallaxEffect:useFriendsParallax blur:friendsUseBackgroundBlur];
        self.tableView.separatorColor = hideFriendsSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        if ([self respondsToSelector:@selector(toolbar)]) {
            friendsUseBlur ? setupBlur(self.toolbar, friendsBlurTone, friendsBlurStyle) : removeBlur(self.toolbar, nil);
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, FriendsAllRequestsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, FriendsAllRequestsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledFriendsImage && [self isKindOfClass:objc_lookUpClass("FriendsAllRequestsController")]) {
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
    
    if (enabled && !enableNightTheme && enabledVideosImage && [self isKindOfClass:objc_lookUpClass("VideoAlbumController")]) {
        [cvkMainController setImageToTableView:self.tableView name:@"videosBackgroundImage" blackout:videosImageBlackout 
                                parallaxEffect:useVideosParallax blur:videosUseBackgroundBlur];
        self.tableView.separatorColor = hideVideosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        setupBlur(self.toolbar, videosBlurTone, videosBlurStyle);
        
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        UIColor *textColor =  changeVideosTextColor ? videosTextColor : [UIColor colorWithWhite:1.0f alpha:0.7f];
        
        if ([search isKindOfClass:objc_lookUpClass("VKSearchBar")]) {
            setupNewSearchBar((VKSearchBar *)search, textColor, videosBlurTone, videosBlurStyle);
        } else if ([search isKindOfClass:[UISearchBar class]] && [search respondsToSelector:@selector(setBackgroundImage:)]) {
            search.backgroundImage = [UIImage new];
            search.tag = 6;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder 
                                                                                              attributes:@{NSForegroundColorAttributeName:textColor}];
            search._scopeBarBackgroundView.superview.hidden = YES;
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, VideoAlbumController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VideoAlbumController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledVideosImage && [self isKindOfClass:objc_lookUpClass("VideoAlbumController")]) {
        performInitialCellSetup(cell);
        
        if ([cell isKindOfClass:objc_lookUpClass("VideoCell")]) {
            VideoCell *videoCell = (VideoCell *)cell;
            videoCell.videoTitleLabel.textColor = changeVideosTextColor?videosTextColor:UITableViewCellTextColor;
            videoCell.videoTitleLabel.backgroundColor = UITableViewCellBackgroundColor;
            videoCell.authorLabel.textColor = changeVideosTextColor?videosTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
            videoCell.authorLabel.backgroundColor = UITableViewCellBackgroundColor;
            videoCell.viewCountLabel.textColor = changeVideosTextColor?videosTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
            videoCell.viewCountLabel.backgroundColor = UITableViewCellBackgroundColor;
        }
        
    }
    
    return cell;
}

CHDeclareClass(DiscoverFeedController);
CHDeclareMethod(1, void, DiscoverFeedController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DiscoverFeedController, viewWillAppear, animated);
    
    if ([self isKindOfClass:objc_lookUpClass("DiscoverFeedController")]) {
        resetTabBar();
        
        if ([self respondsToSelector:@selector(topGradientBackgroundView)]) {
            self.topGradientBackgroundView.hidden = (enabled && enableNightTheme);
        }
    }
}

CHDeclareClass(VKSearchBar);
CHDeclareMethod(2, void, VKSearchBar, setActive, BOOL, active, animated, BOOL, animated)
{
    CHSuper(2, VKSearchBar, setActive, active, animated, animated);
    NSNumber *customized = objc_getAssociatedObject(self, "cvk_customized");
    if (!customized)
        customized = @NO;
    
    if (!enableNightTheme) {
        if (enabled && customized.boolValue) {
            if (active) {
                UIColor *blurColor = objc_getAssociatedObject(self, "cvk_blurColor");            
                NSNumber *blurStyle = objc_getAssociatedObject(self, "cvk_blurStyle");
                if (!blurStyle)
                    blurStyle = @(UIBlurEffectStyleLight);
                setupBlur(self.backgroundView, blurColor, blurStyle.integerValue);
            } else {
                removeBlur(self.backgroundView, nil);
            }
        } else {
            resetNewSearchBar(self);
        }
    }
}

CHDeclareMethod(0, void, VKSearchBar, layoutSubviews)
{
    CHSuper(0, VKSearchBar, layoutSubviews);
    
    NSNumber *customized = objc_getAssociatedObject(self, "cvk_customized");
    if (!customized)
        customized = @NO;
    
    [NSObject cvk_runBlockOnMainThread:^{
        if (!enableNightTheme && (!customized.boolValue || !enabled)) {
            resetNewSearchBar(self);
        }
    }];
}

CHDeclareClass(TitleMenuCell);
CHDeclareMethod(0, void, TitleMenuCell, layoutSubviews)
{
    CHSuper(0, TitleMenuCell, layoutSubviews);
    
    if ([self isKindOfClass:objc_lookUpClass("TitleMenuCell")]) {
        setupNewAppMenuCell(self);
    }
}

CHDeclareClass(DiscoverFeedTitleView);
CHDeclareMethod(0, void, DiscoverFeedTitleView, layoutSubviews)
{
    CHSuper(0, DiscoverFeedTitleView, layoutSubviews);
    
    if (enabled && enabledBarColor && !enableNightTheme) {
        self.toolbar.barTintColor = barBackgroundColor;
        self.toolbar.tintColor = barForegroundColor;
    }
}

CHDeclareClass(DiscoverSearchResultsController);
CHDeclareMethod(0, void, DiscoverSearchResultsController, viewDidLoad)
{
    CHSuper(0, DiscoverSearchResultsController, viewDidLoad);
    
    if (enabled && enabledBarColor && !enableNightTheme) {
        self.toolbar.barTintColor = barBackgroundColor;
        self.toolbar.tintColor = barForegroundColor;
        self.segmentedControl.tintColor = barForegroundColor;
    }
}

CVK_CONSTRUCTOR
{
    @autoreleasepool {
        cvkMainController = [ColoredVKMainController new];
        cvkMainController.nightThemeScheme = [ColoredVKNightScheme sharedScheme];
        
        ColoredVKApplicationModel *application = [ColoredVKNewInstaller sharedInstaller].application;
        isNew3XClient = ([application compareAppVersionWithVersion:@"3.0"] >= ColoredVKVersionCompareEqual);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            BOOL prefsExist = [[NSFileManager defaultManager] fileExistsAtPath:CVK_PREFS_PATH];
            NSMutableDictionary *prefs = prefsExist ? [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH] : [NSMutableDictionary new];
            prefs[@"vkVersion"] = application.detailedVersion;
            cvk_writePrefs(prefs, nil);
        });
    }
}
