//
//  ColoredVKSwitchPrefsCell.h
//  ColoredVK2
//
//  Created by Даниил on 27.06.18.
//

#import "ColoredVKControlPrefsCell.h"
@class ColoredVKSwitch;

@interface ColoredVKSwitchPrefsCell : ColoredVKControlPrefsCell

@property (nonatomic, strong) ColoredVKSwitch *switchView;

- (void)switchTriggered:(ColoredVKSwitch *)switchView;
- (void)updateSwitchWithSpecifier:(PSSpecifier *)specifier NS_REQUIRES_SUPER;

@end
