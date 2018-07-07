//
//  ColoredVKSwitchPrefsCell.h
//  ColoredVK2
//
//  Created by Даниил on 27.06.18.
//

#import "ColoredVKControlPrefsCell.h"

@interface ColoredVKSwitchPrefsCell : ColoredVKControlPrefsCell

@property (nonatomic, strong) UISwitch *switchView;

- (void)switchTriggered:(UISwitch *)switchView;
- (void)updateSwitchWithSpecifier:(PSSpecifier *)specifier NS_REQUIRES_SUPER;

@end
