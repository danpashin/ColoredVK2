//
//  AudioSwizzle.m
//  ColoredVK
//
//  Created by Даниил on 23.03.18.
//

#import "Tweak.h"

#pragma mark IOS7AudioController
CHDeclareClass(IOS7AudioController);
CHDeclareMethod(0, UIStatusBarStyle, IOS7AudioController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:objc_lookUpClass("IOS7AudioController")] && enabled && (enabledBarColor || changeAudioPlayerAppearance || enableNightTheme)) 
        return UIStatusBarStyleLightContent;
    else return CHSuper(0, IOS7AudioController, preferredStatusBarStyle);
}

CHDeclareMethod(0, void, IOS7AudioController, viewWillLayoutSubviews)
{
    CHSuper(0, IOS7AudioController, viewWillLayoutSubviews);
    
    if ([self isKindOfClass:objc_lookUpClass("IOS7AudioController")] && enabled && changeAudioPlayerAppearance) {
        if (!cvkMainController.audioCover) {
            cvkMainController.audioCover = [[ColoredVKAudioCover alloc] init];
            [cvkMainController.audioCover updateCoverForArtist:self.actor.text title:self.song.text];
        }
        [cvkMainController.audioCover updateViewFrame:self.view.bounds andSeparationPoint:self.hostView.frame.origin];
        [cvkMainController.audioCover addToView:self.view];
    }
}

CHDeclareMethod(0, void, IOS7AudioController, viewDidLoad)
{
    CHSuper(0, IOS7AudioController, viewDidLoad);
    
    
    if ([self isKindOfClass:objc_lookUpClass("IOS7AudioController")] && enabled) {
        if (enableNightTheme) {
            self.view.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            self.cover.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            self.hostView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
            [self.pp setImage:[[self.pp imageForState:UIControlStateSelected] cvk_imageWithTintColor:cvkMainController.nightThemeScheme.buttonColor] forState:UIControlStateSelected];
            setupAudioPlayer(self.hostView, cvkMainController.nightThemeScheme.buttonColor);
        }
        if (changeAudioPlayerAppearance) {
            if (!cvkMainController.audioCover) {
                cvkMainController.audioCover = [[ColoredVKAudioCover alloc] init];
                [cvkMainController.audioCover updateCoverForArtist:self.actor.text title:self.song.text];
            }
            [cvkMainController.audioCover updateViewFrame:self.view.bounds andSeparationPoint:self.hostView.frame.origin];
            [cvkMainController.audioCover addToView:self.view];
            
            audioPlayerTintColor = cvkMainController.audioCover.color;
            
            UINavigationBar *navBar = self.navigationController.navigationBar;
            navBar.tag = 26;
            navBar.topItem.titleView.hidden = YES;
            navBar.shadowImage = [UIImage new];
            [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            navBar.tintColor = [UIColor whiteColor];
            
            if (enablePlayerGestures) {
                navBar.topItem.leftBarButtonItems = @[];
                navBar.topItem.rightBarButtonItems = @[];
                self.navigationController.navigationBar.hidden = YES;
                
                [self.view addGestureRecognizer:[cvkMainController swipeForPlayerWithDirection:UISwipeGestureRecognizerDirectionDown handler:^{
                    if ([self respondsToSelector:@selector(done:)]) {
                        [self done:nil];
                    }
                }]];
                
                [self.view addGestureRecognizer:[cvkMainController swipeForPlayerWithDirection:UISwipeGestureRecognizerDirectionLeft handler:^{
                    if ([self respondsToSelector:@selector(actionNext:)]) {
                        [self actionNext:nil];
                    }
                }]];
                
                [self.view addGestureRecognizer:[cvkMainController swipeForPlayerWithDirection:UISwipeGestureRecognizerDirectionRight handler:^{
                    if ([self respondsToSelector:@selector(actionPrev:)]) {
                        [self actionPrev:nil];
                    }
                }]];
                
                [self.view addGestureRecognizer:[cvkMainController swipeForPlayerWithDirection:UISwipeGestureRecognizerDirectionUp handler:^{
                    if ([self respondsToSelector:@selector(actionPlaylist:)]) {
                        [self actionPlaylist:nil];
                    }
                }]];
            }
            
            setupAudioPlayer(self.hostView, audioPlayerTintColor);
            self.cover.hidden = YES;
            self.hostView.backgroundColor = [UIColor clearColor];
            [self.pp setImage:[[self.pp imageForState:UIControlStateSelected] cvk_imageWithTintColor:audioPlayerTintColor] forState:UIControlStateSelected];
            
            cvkMainController.audioCover.updateCompletionBlock = ^(ColoredVKAudioCover *cover) {
                audioPlayerTintColor = cover.color;
                [self.pp setImage:[[self.pp imageForState:UIControlStateSelected] cvk_imageWithTintColor:audioPlayerTintColor] forState:UIControlStateSelected];
                setupAudioPlayer(self.hostView, audioPlayerTintColor);
            };
        }
    }
}

#pragma mark AudioPlayer
CHDeclareClass(AudioPlayer);
CHDeclareMethod(2, void, AudioPlayer, switchTo, int, arg1, force, BOOL, force)
{
    CHSuper(2, AudioPlayer, switchTo, arg1, force, force);
    if (enabled && changeAudioPlayerAppearance) {
        if (!cvkMainController.audioCover)
            cvkMainController.audioCover = [[ColoredVKAudioCover alloc] init];
        
        if (self.state == 1)
            [cvkMainController.audioCover updateCoverForArtist:self.audio.performer title:self.audio.title];
    }
}

#pragma mark VKAudioQueuePlayer
CHDeclareClass(VKAudioQueuePlayer);
CHDeclareMethod(1, void, VKAudioQueuePlayer, switchTo, int, arg1)
{
    CHSuper(1, VKAudioQueuePlayer, switchTo, arg1);
    if (enabled && changeAudioPlayerAppearance) {
        if (!cvkMainController.audioCover)
            cvkMainController.audioCover = [[ColoredVKAudioCover alloc] init];
        
        if (self.state == 1)
            [cvkMainController.audioCover updateCoverForArtist:self.performer title:self.title];
    }
}



#pragma mark AudioAlbumController
CHDeclareClass(AudioAlbumController);
CHDeclareMethod(0, void, AudioAlbumController, viewDidLoad)
{
    CHSuper(0, AudioAlbumController, viewDidLoad);
    
    if (enabled && !enableNightTheme && enabledAudioImage && ([self isKindOfClass:objc_lookUpClass("AudioAlbumController")] || [self isKindOfClass:objc_lookUpClass("AudioAlbumsController")])) {
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if ([search isKindOfClass:[UISearchBar class]] && [search respondsToSelector:@selector(setBackgroundImage:)]) {
            search.backgroundImage = [UIImage new];
            search.tag = 3;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
            NSDictionary *attributes = @{NSForegroundColorAttributeName: changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1.0f alpha:0.7f]};
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder attributes:attributes];
            search._scopeBarBackgroundView.superview.hidden = YES;
        }
    }
}
CHDeclareMethod(0, void, AudioAlbumController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioAlbumController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && ([self isKindOfClass:objc_lookUpClass("AudioAlbumController")] || [self isKindOfClass:objc_lookUpClass("AudioAlbumsController")])) {
        [cvkMainController setImageToTableView:self.tableView name:@"audioBackgroundImage" blackout:audioImageBlackout 
                                parallaxEffect:useAudioParallax blur:audiosUseBackgroundBlur];
        self.tableView.separatorColor =  hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioAlbumController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioAlbumController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && ([self isKindOfClass:objc_lookUpClass("AudioAlbumController")] || [self isKindOfClass:objc_lookUpClass("AudioAlbumsController")])) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:0.8f alpha:0.9f];
    }
    
    return cell;
}


#pragma mark AudioPlaylistController
CHDeclareClass(AudioPlaylistController);
CHDeclareMethod(0, UIStatusBarStyle, AudioPlaylistController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:objc_lookUpClass("AudioPlaylistController")] && enabled && (enabledBarColor || enabledAudioImage || enableNightTheme))
        return UIStatusBarStyleLightContent;
    else return CHSuper(0, AudioPlaylistController, preferredStatusBarStyle);
}
CHDeclareMethod(1, void, AudioPlaylistController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, AudioPlaylistController, viewWillAppear, animated);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioPlaylistController")]) {
        [cvkMainController setImageToTableView:self.tableView name:@"audioBackgroundImage" blackout:audioImageBlackout 
                                parallaxEffect:useAudioParallax blur:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioPlaylistController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioPlaylistController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioPlaylistController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:0.8f alpha:0.9f];
    }
    
    return cell;
}

#pragma mark AudioRenderer
CHDeclareClass(AudioRenderer);
CHDeclareMethod(0, UIButton*, AudioRenderer, playIndicator)
{
    UIButton *indicator = CHSuper(0, AudioRenderer, playIndicator);
    if (enabled && !enableNightTheme && enabledAudioImage) {
        [indicator setImage:[[indicator imageForState:UIControlStateNormal] cvk_imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [indicator setImage:[[indicator imageForState:UIControlStateSelected] cvk_imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateSelected];
    }
    return indicator;
}



/*
 AudioDashboardController - рутовый контроллер музыки пользователя, начиная с VK App 2.13
 */
#pragma mark AudioDashboardController
CHDeclareClass(AudioDashboardController);
CHDeclareMethod(0, void, AudioDashboardController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioDashboardController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioDashboardController")]) {
        [cvkMainController setImageToTableView:self.tableView name:@"audioBackgroundImage" blackout:audioImageBlackout 
                                parallaxEffect:useAudioParallax blur:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioDashboardController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioDashboardController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioDashboardController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
    }
    
    return cell;
}

#pragma mark AudioCatalogController
CHDeclareClass(AudioCatalogController);
CHDeclareMethod(0, void, AudioCatalogController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioCatalogController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioCatalogController")]) {
        [cvkMainController setImageToTableView:self.tableView name:@"audioBackgroundImage" blackout:audioImageBlackout 
                                parallaxEffect:useAudioParallax blur:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
}


CHDeclareMethod(2, UITableViewCell*, AudioCatalogController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioCatalogController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioCatalogController")]) {
        performInitialCellSetup(cell);
        
        void (^setupBlock)(UIView *view) = ^(UIView *view){
            if ([view isKindOfClass:objc_lookUpClass("AudioBlockCellHeaderView")]) {
                AudioBlockCellHeaderView *headerView = (AudioBlockCellHeaderView *)view;
                headerView.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
                headerView.subtitleLabel.textColor = changeAudiosTextColor?audiosTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
                [headerView.showAllButton setTitleColor:changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor forState:UIControlStateNormal];
            } else if ([view isKindOfClass:objc_lookUpClass("BlockCellHeaderView")]) {
                BlockCellHeaderView *headerView = (BlockCellHeaderView *)view;
                headerView.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
                headerView.subtitleLabel.textColor = changeAudiosTextColor?audiosTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
                [headerView.actionButton setTitleColor:changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor forState:UIControlStateNormal];
            }
        };
        
        if ([cell respondsToSelector:@selector(headerView)]) {
            setupBlock([cell valueForKey:@"headerView"]);
        } else {
            for (UIView *subview in cell.contentView.subviews) {
                setupBlock(subview);
            }
        }
    }
    
    return cell;
}

#pragma mark AudioCatalogOwnersListController
CHDeclareClass(AudioCatalogOwnersListController);
CHDeclareMethod(0, void, AudioCatalogOwnersListController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioCatalogOwnersListController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioCatalogOwnersListController")]) {
        [cvkMainController setImageToTableView:self.tableView name:@"audioBackgroundImage" blackout:audioImageBlackout 
                                parallaxEffect:useAudioParallax blur:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioCatalogOwnersListController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioCatalogOwnersListController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioCatalogOwnersListController")]) {
        performInitialCellSetup(cell);
        
        if ([cell isKindOfClass:objc_lookUpClass("GroupCell")]) {
            GroupCell *groupCell = (GroupCell *)cell;
            groupCell.name.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            groupCell.name.backgroundColor = UITableViewCellBackgroundColor;
            groupCell.status.textColor = changeAudiosTextColor?audiosTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
            groupCell.status.backgroundColor = UITableViewCellBackgroundColor;
        }
        else if ([cell isKindOfClass:objc_lookUpClass("SourceCell")]) {
            SourceCell *sourceCell = (SourceCell *)cell;
            sourceCell.first.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            sourceCell.first.backgroundColor = UITableViewCellBackgroundColor;
            sourceCell.last.textColor = changeAudiosTextColor?audiosTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
            sourceCell.last.backgroundColor = UITableViewCellBackgroundColor;
        }
    }
    
    return cell;
}


#pragma mark AudioCatalogAudiosListController
CHDeclareClass(AudioCatalogAudiosListController);
CHDeclareMethod(0, void, AudioCatalogAudiosListController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioCatalogAudiosListController, viewWillLayoutSubviews);
    
    if (enabled  && !enableNightTheme&& enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioCatalogAudiosListController")]) {
        [cvkMainController setImageToTableView:self.tableView name:@"audioBackgroundImage" blackout:audioImageBlackout 
                                parallaxEffect:useAudioParallax blur:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioCatalogAudiosListController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioCatalogAudiosListController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioCatalogAudiosListController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
    }
    
    return cell;
}



#pragma mark AudioPlaylistDetailController
CHDeclareClass(AudioPlaylistDetailController);
CHDeclareMethod(0, void, AudioPlaylistDetailController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioPlaylistDetailController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioPlaylistDetailController")]) {
        [cvkMainController setImageToTableView:self.tableView name:@"audioBackgroundImage" blackout:audioImageBlackout 
                                parallaxEffect:useAudioParallax blur:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioPlaylistDetailController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioPlaylistDetailController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioPlaylistDetailController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
    }
    
    return cell;
}

#pragma mark AudioPlaylistsController
CHDeclareClass(AudioPlaylistsController);
CHDeclareMethod(0, void, AudioPlaylistsController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioPlaylistsController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioPlaylistsController")]) {
        [cvkMainController setImageToTableView:self.tableView name:@"audioBackgroundImage" blackout:audioImageBlackout 
                                parallaxEffect:useAudioParallax blur:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
        self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if ([search isKindOfClass:[UISearchBar class]] && !enableNightTheme) {
            search.backgroundImage = [UIImage new];
            search.tag = 3;
            search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
            NSDictionary *attributes = @{NSForegroundColorAttributeName: changeAudiosTextColor?audiosTextColor:[UIColor colorWithWhite:1.0f alpha:0.7f]};
            search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder attributes:attributes];
            search._scopeBarBackgroundView.superview.hidden = YES;
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, AudioPlaylistsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioPlaylistsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioPlaylistsController")]) {
        performInitialCellSetup(cell);
    }
    
    return cell;
}

#pragma mark VKAudioPlayerListTableViewController
CHDeclareClass(VKAudioPlayerListTableViewController);
CHDeclareMethod(0, UIStatusBarStyle, VKAudioPlayerListTableViewController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:objc_lookUpClass("VKAudioPlayerListTableViewController")] && enabled && (enabledBarColor || enableNightTheme))
        return UIStatusBarStyleLightContent;
    else return CHSuper(0, VKAudioPlayerListTableViewController, preferredStatusBarStyle);
}

CHDeclareMethod(0, void, VKAudioPlayerListTableViewController, viewDidLoad)
{
    CHSuper(0, VKAudioPlayerListTableViewController, viewDidLoad);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("VKAudioPlayerListTableViewController")]) {
        self.navigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    }
}

CHDeclareMethod(0, void, VKAudioPlayerListTableViewController, viewWillLayoutSubviews)
{
    CHSuper(0, VKAudioPlayerListTableViewController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("VKAudioPlayerListTableViewController")]) {
        [cvkMainController setImageToTableView:self.tableView name:@"audioBackgroundImage" blackout:audioImageBlackout 
                                parallaxEffect:useAudioParallax blur:audiosUseBackgroundBlur];
        self.tableView.separatorColor = hideAudiosSeparators?[UIColor clearColor]:[self.tableView.separatorColor colorWithAlphaComponent:0.2f];
    }
}

CHDeclareMethod(2, UITableViewCell*, VKAudioPlayerListTableViewController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKAudioPlayerListTableViewController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("VKAudioPlayerListTableViewController")]) {
        performInitialCellSetup(cell);
        
        cell.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        cell.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
    }
    
    return cell;
}




#pragma mark AudioAudiosBlockTableCell
CHDeclareClass(AudioAudiosBlockTableCell);
CHDeclareMethod(0, void, AudioAudiosBlockTableCell, layoutSubviews)
{
    CHSuper(0, AudioAudiosBlockTableCell, layoutSubviews);
    
    if (enabled && (enabledAudioImage || enableNightTheme) && [self isKindOfClass:objc_lookUpClass("AudioAudiosBlockTableCell")]) {
        performInitialCellSetup(self);
        if (enableNightTheme) {
            self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        } else {
            self.textLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            self.detailTextLabel.textColor = changeAudiosTextColor?audiosTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
        }
        
    }
}

#pragma mark AudioPlaylistInlineCell
CHDeclareClass(AudioPlaylistInlineCell);
CHDeclareMethod(0, void, AudioPlaylistInlineCell, layoutSubviews)
{
    CHSuper(0, AudioPlaylistInlineCell, layoutSubviews);
    
    if (enabled && enabledAudioImage && !enableNightTheme && [self isKindOfClass:objc_lookUpClass("AudioPlaylistInlineCell")]) {
        self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
        self.subtitleLabel.textColor = changeAudiosTextColor?audiosTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
    }
}

#pragma mark AudioOwnersBlockItemCollectionCell
CHDeclareClass(AudioOwnersBlockItemCollectionCell);
CHDeclareMethod(0, void, AudioOwnersBlockItemCollectionCell, layoutSubviews)
{
    CHSuper(0, AudioOwnersBlockItemCollectionCell, layoutSubviews);
    
    if (enabled && !enableNightTheme && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioOwnersBlockItemCollectionCell")]) {
        self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
    }
}


#pragma mark AudioPlaylistCell
CHDeclareClass(AudioPlaylistCell);
CHDeclareMethod(0, void, AudioPlaylistCell, layoutSubviews)
{
    CHSuper(0, AudioPlaylistCell, layoutSubviews);
    
    if (enabled && (enabledAudioImage || enableNightTheme) && [self isKindOfClass:objc_lookUpClass("AudioPlaylistCell")]) {
        performInitialCellSetup(self);
        if (!enableNightTheme) {
            self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            self.artistLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            self.subtitleLabel.textColor = changeAudiosTextColor?audiosTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
        }
    }
}


#pragma mark AudioPlaylistsCell
CHDeclareClass(AudioPlaylistsCell);
CHDeclareMethod(0, void, AudioPlaylistsCell, layoutSubviews)
{
    CHSuper(0, AudioPlaylistsCell, layoutSubviews);
    
    if (enabled && (enabledAudioImage || enableNightTheme) && [self isKindOfClass:objc_lookUpClass("AudioPlaylistsCell")]) {
        performInitialCellSetup(self);
        if (enableNightTheme) {
            self.hostedView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        }
        else if (enabledAudioImage) {
            self.hostedView.backgroundColor = [UIColor clearColor];
            self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            [self.showAllButton setTitleColor:changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor forState:UIControlStateNormal];
        }
    }
}

#pragma mark AudioAudiosSpecialBlockView
CHDeclareClass(AudioAudiosSpecialBlockView);
CHDeclareMethod(0, void, AudioAudiosSpecialBlockView, layoutSubviews)
{
    CHSuper(0, AudioAudiosSpecialBlockView, layoutSubviews);
    
    if (enabled && (enabledAudioImage || enableNightTheme) && [self isKindOfClass:objc_lookUpClass("AudioAudiosSpecialBlockView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        if (!enableNightTheme) {
            self.backgroundColor = [UIColor clearColor];
            self.titleLabel.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            self.subtitleLabel.textColor = changeAudiosTextColor?audiosTextColor.cvk_darkerColor:UITableViewCellDetailedTextColor;
        }
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:objc_lookUpClass("GradientView")]) {
                subview.hidden = YES;
                break;
            }
        }
        
    }
}

#pragma mark AudioPlaylistView
CHDeclareClass(AudioPlaylistView);
CHDeclareMethod(0, void, AudioPlaylistView, layoutSubviews)
{
    CHSuper(0, AudioPlaylistView, layoutSubviews);
    
    if (enabled && enableNightTheme) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
    else if (enabled && enabledAudioImage && [self isKindOfClass:objc_lookUpClass("AudioPlaylistView")]) {
        self.backgroundColor = [UIColor clearColor];
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)subview;
                label.textColor = changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor;
            } else if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                [button setTitleColor:changeAudiosTextColor?audiosTextColor:UITableViewCellTextColor forState:UIControlStateNormal];
                
            }
        }
        
    }
}
