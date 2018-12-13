//
//  MenuSwizzle.m
//  ColoredVK2
//
//  Created by Даниил on 07.07.18.
//
#import "Tweak.h"


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

CHDeclareMethod(1, void, VKMMainController, traitCollectionDidChange, UITraitCollection *, previousTraitCollection)
{
    CHSuper(1, VKMMainController, traitCollectionDidChange, previousTraitCollection);
    
    setupQuickMenuController();
    setupTabbar();
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
    
    if (!vksBundle)
        vksBundle = [NSBundle bundleWithPath:VKS_BUNDLE_PATH];
    
    if (enabled && !enableNightTheme)
        tableView.separatorColor = hideMenuSeparators ? [UIColor clearColor] : menuSeparatorColor;    
    else
        tableView.separatorColor = kMenuCellSeparatorColor;
    
    if (enabled && enableNightTheme) {
        cell.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        tableView.backgroundColor = cell.backgroundColor;
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
        
        if (objc_lookUpClass("VKSettings")  && (menuSelectionStyle != CVKCellSelectionStyleNone)) {
            if ([cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)]) 
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
            (objc_lookUpClass("VKSettings") && [cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)])) {
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
    
    if ([cell.textLabel.text isEqualToString:@"ColoredVK 2"]) {
        cell = cvkMainController.menuCell;
    }
    
    VAAppearance *vaappearance = [objc_lookUpClass("VAAppearance") appearance];
    
    if (enabled && hideMenuSeparators) tableView.separatorColor = [UIColor clearColor]; 
    else if (enabled && !hideMenuSeparators) tableView.separatorColor = menuSeparatorColor; 
    else if (vaappearance.style == 0) tableView.separatorColor = [UIColor colorWithRed:215/255.0f green:216/255.0f blue:217/255.0f alpha:1.0f];
    
    setupNewAppMenuCell(cell);
    
    if (enabled && enabledMenuImage && !enableNightTheme) {
        UIView *selectedBackView = [UIView new];
        if (menuSelectionStyle == CVKCellSelectionStyleTransparent) selectedBackView.backgroundColor = menuSelectionColor;
        else if (menuSelectionStyle == CVKCellSelectionStyleBlurred) {
            selectedBackView.backgroundColor = [UIColor clearColor];
            if (![selectedBackView.subviews containsObject: [selectedBackView viewWithTag:100] ]) [selectedBackView addSubview:blurForView(selectedBackView, 100)];
            
        } else selectedBackView.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = selectedBackView;
    } else if (!enabled) {
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
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:cvkMainController.menuCell.reuseIdentifier]) {
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
        
        MenuItem *cvkItem = [[objc_lookUpClass("MenuItem") alloc] initWithType:1204 imageName:@"vkapp/VKMenuIconAlt" 
                                                                         title:@"ColoredVK 2" statId:@""];
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
