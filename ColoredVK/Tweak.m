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


#pragma mark VKMMainController
CHDeclareClass(VKMMainController);
CHDeclareMethod(0, NSArray*, VKMMainController, menu)
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

CHDeclareMethod(0, void, VKMMainController, viewDidLoad)
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
                                                                                       imageName:@"menuBackgroundImage" blackout:menuImageBlackout 
                                                                                  enableParallax:useMenuParallax blurBackground:menuUseBackgroundBlur];
        }
        
        if (enabled && enabledMenuImage && !enableNightTheme) {
            [cvkMainController.menuBackgroundView addToBack:self.view animated:NO];
            setupUISearchBar((UISearchBar*)self.tableView.tableHeaderView);
            self.tableView.backgroundColor = [UIColor clearColor];
        } else {
            
            UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
            self.tableView.backgroundView = backView;
            [NSObject cvk_runBlockOnMainThread:^{
                backView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
            }];
        }
    } else {
        setupTabbar();
    }
}

CHDeclareMethod(0, void, VKMMainController, viewWillLayoutSubviews)
{
    CHSuper(0, VKMMainController, viewWillLayoutSubviews);
    
    if (![self isKindOfClass:[UITabBarController class]] && enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        if ([self.tableView.tableHeaderView isKindOfClass:[UISearchBar class]]) {
            self.tableView.tableHeaderView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, VKMMainController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMMainController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    NSDictionary *identifiers = @{@"customCell" : @228, @"cvkMenuCell": @405};
    if ([identifiers.allKeys containsObject:cell.reuseIdentifier]) {
        UISwitch *switchView = [cell viewWithTag:[identifiers[cell.reuseIdentifier] integerValue]];
        if ([switchView isKindOfClass:[UISwitch class]]) [switchView layoutSubviews];
    }
    
    
    if (enabled && !enableNightTheme)
        tableView.separatorColor = hideMenuSeparators ? [UIColor clearColor] : menuSeparatorColor;    
    else
        tableView.separatorColor = kMenuCellSeparatorColor;
    
    if (enabled && enableNightTheme) {
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    else if (enabled && enabledMenuImage) {
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
        
        if (VKSettingsEnabled) {
            if (!vksBundle)
                vksBundle = [NSBundle bundleWithPath:VKS_BUNDLE_PATH];
            
            if ([cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)] && (menuSelectionStyle != CVKCellSelectionStyleNone)) 
                cell.contentView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
        }
        
        if ([cell respondsToSelector:@selector(badge)]) {
            [[cell valueForKeyPath:@"badge"] setTitleColor:changeMenuTextColor?menuTextColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
    } else {
        if ([cell respondsToSelector:@selector(badge)]) {
            [[cell valueForKeyPath:@"badge"] setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
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

CHDeclareMethod(0, id, VKMMainController, VKMTableCreateSearchBar)
{
    if (enabled && hideMenuSearch) return nil;
    return CHSuper(0, VKMMainController, VKMTableCreateSearchBar);
}



#pragma mark MenuViewController
CHDeclareClass(MenuViewController);
CHDeclareMethod(0, void, MenuViewController, viewDidLoad)
{
    CHSuper(0, MenuViewController, viewDidLoad);
    if (!cvkMainController.vkMenuController)
        cvkMainController.vkMenuController = self;
    
    if (!cvkMainController.menuBackgroundView) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        CGFloat width = (bounds.size.width > bounds.size.height)?bounds.size.height:bounds.size.width;
        CGFloat height = (bounds.size.width < bounds.size.height)?bounds.size.height:bounds.size.width;
        cvkMainController.menuBackgroundView = [[ColoredVKWallpaperView alloc] initWithFrame:CGRectMake(0, 0, width, height) 
                                                                                   imageName:@"menuBackgroundImage" blackout:menuImageBlackout 
                                                                              enableParallax:useMenuParallax blurBackground:menuUseBackgroundBlur];
    }
    
    if (enabled && enabledMenuImage) {
        [cvkMainController.menuBackgroundView addToBack:self.view animated:NO];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.tag = 24;
    }
}

CHDeclareMethod(2, UITableViewCell*, MenuViewController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, MenuViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if ([cell.textLabel.text isEqualToString:@"ColoredVK 2"] && ![cell isEqual:cvkMainController.menuCell]) {
        cell = cvkMainController.menuCell;
    }
    
    if (enabled && hideMenuSeparators) tableView.separatorColor = [UIColor clearColor]; 
    else if (enabled && !hideMenuSeparators) tableView.separatorColor = menuSeparatorColor; 
    else tableView.separatorColor = [UIColor colorWithRed:215/255.0f green:216/255.0f blue:217/255.0f alpha:1.0f];
    
    setupNewAppMenuCell(cell);
    
    if (enabled && enabledMenuImage && !enableNightTheme) {
        UIView *selectedBackView = [UIView new];
        if (menuSelectionStyle == CVKCellSelectionStyleTransparent) selectedBackView.backgroundColor = menuSelectionColor;
        else if (menuSelectionStyle == CVKCellSelectionStyleBlurred) {
            selectedBackView.backgroundColor = [UIColor clearColor];
            if (![selectedBackView.subviews containsObject: [selectedBackView viewWithTag:100] ]) [selectedBackView addSubview:blurForView(selectedBackView, 100)];
            
        } else selectedBackView.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = selectedBackView;
    } else {
        cell.selectedBackgroundView = nil;
    }
    
    return cell;
}

CHDeclareMethod(3, void, MenuViewController, tableView, UITableView *, tableView, willDisplayHeaderView, UIView *, view, forSection, NSInteger, section)
{
    CHSuper(3, MenuViewController, tableView, tableView, willDisplayHeaderView, view, forSection, section);
    if ((enabled && !enableNightTheme && enabledMenuImage) && [view isKindOfClass:objc_lookUpClass("TablePrimaryHeaderView")]) {
        ((TablePrimaryHeaderView *)view).separator.alpha = 0.3f;
    }
}

CHDeclareMethod(0, NSArray *, MenuViewController, menu)
{
    NSArray *origMenu = CHSuper(0, MenuViewController, menu);
    
    if (showMenuCell) {
        NSMutableArray *tempArray = [origMenu mutableCopy];
        [tempArray addObject:cvkMainController.menuCell];
        
        origMenu = tempArray;
    }
    
    return origMenu;
}

CHDeclareMethod(2, void, MenuViewController, tableView, UITableView *, tableView, didSelectRowAtIndexPath, NSIndexPath *, indexPath)
{
    if (indexPath.section == 1 && indexPath.row == [self.tableView numberOfRowsInSection:1]-1) {
        [self.navigationController pushViewController:cvkMainController.safePreferencesController animated:YES];
    } else {
        CHSuper(2, MenuViewController, tableView, tableView, didSelectRowAtIndexPath, indexPath);
    }
}

CHDeclareClass(MenuModel);
CHDeclareMethod(0, NSArray *, MenuModel, baseMenuItems)
{
    NSArray *items = CHSuper(0, MenuModel, baseMenuItems);
    
    if (showMenuCell) {
        NSMutableArray <MenuItem *> *tempArray = [items mutableCopy];
        
        MenuItem *cvkItem = [[objc_lookUpClass("MenuItem") alloc] initWithType:1204 imageName:@"vkapp/VKMenuIconAlt" title:@"ColoredVK 2" statId:@""];
        [tempArray addObject:cvkItem];
        
        items = tempArray;
    }
    
    return items;
}


#pragma GCC diagnostic push 
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma mark  HintsSearchDisplayController
CHDeclareClass(HintsSearchDisplayController);
CHDeclareMethod(1, void, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch, UISearchDisplayController*, controller)
{
    if (enabled && !enableNightTheme && enabledMenuImage) resetUISearchBar(controller.searchBar);
    CHSuper(1, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch, controller);
}

CHDeclareMethod(1, void, HintsSearchDisplayController, searchDisplayControllerDidEndSearch, UISearchDisplayController*, controller)
{
    if (enabled && !enableNightTheme && enabledMenuImage) setupUISearchBar(controller.searchBar);
    CHSuper(1, HintsSearchDisplayController, searchDisplayControllerDidEndSearch, controller);
}
#pragma GCC diagnostic pop


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

#pragma mark DialogsSearchController
CHDeclareClass(DialogsSearchController);
CHDeclareMethod(1, void, DialogsSearchController, searchDisplayControllerWillBeginSearch, UISearchDisplayController*, controller)
{
    CHSuper(1, DialogsSearchController, searchDisplayControllerWillBeginSearch, controller);
    setupSearchController(controller, NO);
    if (enabled && !enableNightTheme && enabledMessagesImage)
        controller.searchResultsTableView.separatorColor = [controller.searchResultsTableView.separatorColor colorWithAlphaComponent:0.2f];
}

CHDeclareMethod(1, void, DialogsSearchController, searchDisplayControllerWillEndSearch, UISearchDisplayController*, controller)
{
    setupSearchController(controller, YES);
    CHSuper(1, DialogsSearchController, searchDisplayControllerWillEndSearch, controller);
}

CHDeclareMethod(2, UITableViewCell*, DialogsSearchController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, DialogsSearchController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    setupCellForSearchController(cell, self);
    return cell;
}

#pragma GCC diagnostic pop

#pragma mark DialogsSearchResultsController
CHDeclareClass(DialogsSearchResultsController);
CHDeclareMethod(1, void, DialogsSearchResultsController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DialogsSearchResultsController, viewWillAppear, animated);
    setupNewDialogsSearchController(self);
}

CHDeclareMethod(2, UITableViewCell*, DialogsSearchResultsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, DialogsSearchResultsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledMessagesListImage) {
        performInitialCellSetup (cell);
        cell.backgroundView.hidden = YES;
        UIColor *textColor = changeMessagesListTextColor ? messagesListTextColor : UITableViewCellTextColor;
        UIColor *detailedTextColor = changeMessagesListTextColor ? messagesListTextColor : UITableViewCellTextColor;
        
        if ([cell isKindOfClass:objc_lookUpClass("SourceCell")]) {
            SourceCell *sourceCell = (SourceCell *)cell;
            sourceCell.last.textColor = detailedTextColor;
            sourceCell.last.backgroundColor = [UIColor clearColor];
            sourceCell.first.textColor =  textColor;
            sourceCell.first.backgroundColor = [UIColor clearColor];
        }
        else if ([cell isKindOfClass:objc_lookUpClass("NewDialogCell")]) {
            NewDialogCell *dialogCell = (NewDialogCell *)cell;
            dialogCell.name.textColor = textColor;
            dialogCell.name.backgroundColor = [UIColor clearColor];
            dialogCell.time.textColor = textColor;
            dialogCell.time.backgroundColor = [UIColor clearColor];
            if ([dialogCell respondsToSelector:@selector(dialogText)]) {
                dialogCell.dialogText.textColor = detailedTextColor;
                dialogCell.dialogText.backgroundColor = [UIColor clearColor];
            }
        }
    }
    return cell;
}

#pragma mark - MessageController
CHDeclareClass(MessageController);
CHDeclareMethod(1, void, MessageController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, MessageController, viewWillAppear, animated);
    resetNavigationBar(self.navigationController.navigationBar);
    resetTabBar();
}

#pragma mark VKComment
CHDeclareClass(VKComment);
CHDeclareMethod(0, BOOL, VKComment, separatorDisabled)
{
    if (enabled) return showCommentSeparators;
    return CHSuper(0, VKComment, separatorDisabled);
}

#pragma mark ProfileCoverInfo
CHDeclareClass(ProfileCoverInfo);
CHDeclareMethod(0, BOOL, ProfileCoverInfo, enabled)
{
    if (enabled && disableGroupCovers) return NO;
    return CHSuper(0, ProfileCoverInfo, enabled);
}

#pragma mark ProfileCoverImageView
CHDeclareClass(ProfileCoverImageView);
CHDeclareMethod(0, UIView *, ProfileCoverImageView, overlayView)
{
    UIView *overlayView = CHSuper(0, ProfileCoverImageView, overlayView);
    if (enabled) {
        if (enableNightTheme) {
            overlayView.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        }
        else if (enabledBarImage) {
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
CHDeclareMethod(0, UIStatusBarStyle, PostEditController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:objc_lookUpClass("PostEditController")] && enabled && (enabledBarColor || enableNightTheme))
        return UIStatusBarStyleLightContent;
    return CHSuper(0, PostEditController, preferredStatusBarStyle);
}

CHDeclareMethod(0, void, PostEditController, viewDidLoad)
{
    CHSuper(0, PostEditController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

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

#pragma mark PaymentsBalanceController
CHDeclareClass(PaymentsBalanceController);
CHDeclareMethod(0, void, PaymentsBalanceController, viewWillLayoutSubviews)
{
    CHSuper(0, PaymentsBalanceController, viewWillLayoutSubviews);
    if ([self isKindOfClass:objc_lookUpClass("PaymentsBalanceController")])
        setupExtraSettingsController(self);
}

CHDeclareMethod(2, UITableViewCell*, PaymentsBalanceController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, PaymentsBalanceController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:objc_lookUpClass("PaymentsBalanceController")])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark SubscriptionsSettingsViewController
CHDeclareClass(SubscriptionsSettingsViewController);
CHDeclareMethod(0, void, SubscriptionsSettingsViewController, viewWillLayoutSubviews)
{
    CHSuper(0, SubscriptionsSettingsViewController, viewWillLayoutSubviews);
    if ([self isKindOfClass:objc_lookUpClass("SubscriptionsSettingsViewController")])
        setupExtraSettingsController(self);
}

CHDeclareMethod(2, UITableViewCell*, SubscriptionsSettingsViewController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, SubscriptionsSettingsViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:objc_lookUpClass("SubscriptionsSettingsViewController")])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark ModernPushSettingsController
CHDeclareClass(ModernPushSettingsController);
CHDeclareMethod(0, void, ModernPushSettingsController, viewWillLayoutSubviews)
{
    CHSuper(0, ModernPushSettingsController, viewWillLayoutSubviews);
    if ([self isKindOfClass:objc_lookUpClass("ModernPushSettingsController")])
        setupExtraSettingsController(self);
}

CHDeclareMethod(2, UITableViewCell*, ModernPushSettingsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ModernPushSettingsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:objc_lookUpClass("ModernPushSettingsController")])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark VKP2PViewController
CHDeclareClass(VKP2PViewController);
CHDeclareMethod(0, void, VKP2PViewController, viewWillLayoutSubviews)
{
    CHSuper(0, VKP2PViewController, viewWillLayoutSubviews);
    if ([self isKindOfClass:objc_lookUpClass("VKP2PViewController")])
        setupExtraSettingsController(self);
}

CHDeclareMethod(2, UITableViewCell*, VKP2PViewController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKP2PViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:objc_lookUpClass("VKP2PViewController")])
        setupExtraSettingsCell(cell);
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
        VKSettingsEnabled = (objc_lookUpClass("VKSettings") != nil);
        
        BOOL prefsExist = [[NSFileManager defaultManager] fileExistsAtPath:CVK_PREFS_PATH];
        NSMutableDictionary *prefs = prefsExist ? [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH] : [NSMutableDictionary new];
        prefs[@"vkVersion"] = application.detailedVersion;
        [prefs writeToFile:CVK_PREFS_PATH atomically:YES];
    }
}
