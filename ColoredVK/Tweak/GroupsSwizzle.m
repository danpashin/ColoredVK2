//
//  GroupsSwizzle.m
//  ColoredVK2
//
//  Created by Даниил on 07.07.18.
//

#import "Tweak.h"


#pragma mark GroupsController - список групп
CHDeclareClass(GroupsController);
CHDeclareMethod(0, void, GroupsController, viewDidLoad)
{
    CHSuper(0, GroupsController, viewDidLoad);
    if ([self isKindOfClass:objc_lookUpClass("GroupsController")]) {
        if (enabled && !enableNightTheme && enabledGroupsListImage) {
            [cvkMainController setImageToTableView:self.tableView name:@"groupsListBackgroundImage" blackout:groupsListImageBlackout
                                    parallaxEffect:useGroupsListParallax blur:groupsListUseBackgroundBlur];
            self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
            self.tableView.separatorColor = hideGroupsListSeparators ? [UIColor clearColor] : [self.tableView.separatorColor colorWithAlphaComponent:0.2f];
            self.segment.alpha = 0.9f;
            
            UIColor *textColor = changeGroupsListTextColor ? groupsListTextColor : [UIColor colorWithWhite:1.0f alpha:0.7f];
            UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
            if ([search isKindOfClass:objc_lookUpClass("VKSearchBar")]) {
                setupNewSearchBar((VKSearchBar *)search, textColor, groupsListBlurTone, groupsListBlurStyle);
            } else if ([search isKindOfClass:[UISearchBar class]] && [search respondsToSelector:@selector(setBackgroundImage:)]) {
                search.backgroundImage = [UIImage new];
                search.scopeBarBackgroundImage = [UIImage new];
                search.tag = 2;
                search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
                search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder 
                                                                                                  attributes:@{NSForegroundColorAttributeName:textColor}];
            }
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, GroupsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, GroupsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:objc_lookUpClass("GroupsController")] && enabled && !enableNightTheme && enabledGroupsListImage) {
        if ([cell isKindOfClass:objc_lookUpClass("GroupCell")]) {
            GroupCell *groupCell = (GroupCell *)cell;
            performInitialCellSetup(groupCell);
            groupCell.name.textColor = changeGroupsListTextColor?groupsListTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
            groupCell.name.backgroundColor = UITableViewCellBackgroundColor;
            groupCell.status.textColor = changeGroupsListTextColor?groupsListTextColor:[UIColor colorWithWhite:0.8f alpha:0.9f];
            groupCell.status.backgroundColor = UITableViewCellBackgroundColor;
        } else  if ([cell isKindOfClass:objc_lookUpClass("VKMRendererCell")]) {
            performInitialCellSetup(cell);
            
            for (UIView *view in cell.contentView.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)view;
                    label.textColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
                    label.backgroundColor = [UIColor clearColor];
                }
            }
        }
        
    }
    
    return cell;
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
CHDeclareMethod(0, void, PostEditController, viewDidLoad)
{
    CHSuper(0, PostEditController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}
