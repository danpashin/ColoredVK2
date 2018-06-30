//
//  SettingsSwizzle.m
//  ColoredVK
//
//  Created by Даниил on 23.03.18.
//

#import "Tweak.h"


#pragma mark - ModernSettingsController

CHDeclareClass(ModernSettingsController);
CHDeclareMethod(2, NSInteger, ModernSettingsController, tableView, UITableView *, tableView, numberOfRowsInSection, NSInteger, section)
{
    NSInteger rowsCount = CHSuper(2, ModernSettingsController, tableView, tableView, numberOfRowsInSection, section);
    if (section == 1) {
        rowsCount++;
    }
    return rowsCount;
}

CHDeclareMethod(2, UITableViewCell*, ModernSettingsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ModernSettingsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    return cell ? cell : cvkMainController.settingsCell;
}

CHDeclareMethod(3, void, ModernSettingsController, tableView, UITableView*, tableView, willDisplayCell, UITableViewCell *, cell, forRowAtIndexPath, NSIndexPath*, indexPath)
{
    CHSuper(3, ModernSettingsController, tableView, tableView, willDisplayCell, cell, forRowAtIndexPath, indexPath);
    
    if ([self isKindOfClass:objc_lookUpClass("ModernSettingsController")]) {
        [NSObject cvk_runBlockOnMainThread:^{
            if ([cell.textLabel.text.lowercaseString isEqualToString:@"vksettings"]) {
                cell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
            }
            
            if (enabled && !enableNightTheme && enabledSettingsImage) {
                performInitialCellSetup(cell);
                cell.textLabel.textColor = changeSettingsTextColor ? settingsTextColor : UITableViewCellTextColor;
                cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.imageView.tintColor = cell.textLabel.textColor;
            }
        }];
    }
}

CHDeclareMethod(2, void, ModernSettingsController, tableView, UITableView*, tableView, didSelectRowAtIndexPath, NSIndexPath*, indexPath)
{
    CHSuper(2, ModernSettingsController, tableView, tableView, didSelectRowAtIndexPath, indexPath);
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:cvkMainController.settingsCell.reuseIdentifier]) {
        [self.navigationController pushViewController:cvkMainController.safePreferencesController animated:YES];
    }
}

CHDeclareMethod(0, void, ModernSettingsController, viewWillLayoutSubviews)
{
    CHSuper(0, ModernSettingsController, viewWillLayoutSubviews);
    
    if (enabled && !enableNightTheme && enabledSettingsImage && [self isKindOfClass:objc_lookUpClass("ModernSettingsController")]) {
        [cvkMainController setImageToTableView:self.tableView name:@"settingsBackgroundImage" blackout:settingsImageBlackout 
                                parallaxEffect:useSettingsParallax blur:settingsUseBackgroundBlur];
        
        if (hideSettingsSeparators) 
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        else
            self.tableView.separatorColor = [self.tableView.separatorColor colorWithAlphaComponent:0.5f];
        
        [NSObject cvk_runBlockOnMainThread:^{
            UIColor *textColor = changeSettingsTextColor ? settingsTextColor : UITableViewCellTextColor;
            for (UIView *subview in self.tableView.tableHeaderView.subviews) {
                if ([subview respondsToSelector:@selector(setTextColor:)]) {
                    UILabel *label = (UILabel *)subview;
                    label.textColor = textColor;
                }
                if ([subview respondsToSelector:@selector(setTitleColor:forState:)]) {
                    UIButton *button = (UIButton *)subview;
                    [button setTitleColor:textColor forState:button.state];
                }
            }
        }];
    }
}


CHDeclareClass(BaseSectionedSettingsController);
CHDeclareMethod(0, void, BaseSectionedSettingsController, viewWillLayoutSubviews)
{
    CHSuper(0, BaseSectionedSettingsController, viewWillLayoutSubviews);
    NSArray <Class> *settingsExtraClasses = @[objc_lookUpClass("ModernGeneralSettings"), objc_lookUpClass("ModernAccountSettings"), objc_lookUpClass("AboutViewController")];
    if ([settingsExtraClasses containsObject:[self class]])
        setupExtraSettingsController(self);
}

CHDeclareMethod(2, UITableViewCell*, BaseSectionedSettingsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, BaseSectionedSettingsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    NSArray <Class> *settingsExtraClasses = @[objc_lookUpClass("ModernGeneralSettings"), objc_lookUpClass("ModernAccountSettings"), objc_lookUpClass("AboutViewController")];
    if ([settingsExtraClasses containsObject:[self class]])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark ProfileBannedController
CHDeclareClass(ProfileBannedController);
CHDeclareMethod(0, void, ProfileBannedController, viewWillLayoutSubviews)
{
    CHSuper(0, ProfileBannedController, viewWillLayoutSubviews);
    if ([self isKindOfClass:objc_lookUpClass("ProfileBannedController")])
        setupExtraSettingsController(self);
}

CHDeclareMethod(2, UITableViewCell*, ProfileBannedController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ProfileBannedController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:objc_lookUpClass("ProfileBannedController")])
        setupExtraSettingsCell(cell);
    return cell;
}

#pragma mark SettingsPrivacyController
CHDeclareClass(SettingsPrivacyController);
CHDeclareMethod(0, void, SettingsPrivacyController, viewWillLayoutSubviews)
{
    CHSuper(0, SettingsPrivacyController, viewWillLayoutSubviews);
    if ([self isKindOfClass:objc_lookUpClass("SettingsPrivacyController")])
        setupExtraSettingsController(self);
}

CHDeclareMethod(2, UITableViewCell*, SettingsPrivacyController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, SettingsPrivacyController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:objc_lookUpClass("SettingsPrivacyController")])
        setupExtraSettingsCell(cell);
    return cell;
}

