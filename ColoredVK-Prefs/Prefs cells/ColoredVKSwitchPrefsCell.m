//
//  ColoredVKSwitchPrefsCell.m
//  ColoredVK2
//
//  Created by Даниил on 27.06.18.
//

#import "ColoredVKSwitchPrefsCell.h"

@implementation ColoredVKSwitchPrefsCell
@dynamic accessoryView;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {
        self.switchView = [UISwitch new];
        self.switchView.tag = 228;
        self.switchView.layer.cornerRadius = 16.0f;
        [self.switchView addTarget:self action:@selector(switchTriggered:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = self.switchView;
    }
    return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier
{
    [super refreshCellContentsWithSpecifier:specifier];
    [self updateSwitchWithSpecifier:specifier];
}

#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)switchTriggered:(UISwitch *)switchView
{
    [self setPreferenceValue:@(switchView.on)];
}

- (void)updateSwitchWithSpecifier:(PSSpecifier *)specifier
{
    NSNumber *currentValue = self.currentPrefsValue;
    if ([currentValue isKindOfClass:[NSNumber class]]) {
        self.switchView.on = currentValue.boolValue;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    ColoredVKNightScheme *nightScheme = [ColoredVKNightScheme sharedScheme];
    
    NSNumber *userChangedColor = objc_getAssociatedObject(self, "change_switch_color");
    if (!userChangedColor)
        userChangedColor = @NO;
    
    if (!nightScheme.enabled) {
        self.switchView.backgroundColor = [UIColor colorWithRed:234/255.0f green:234/255.0f blue:239/255.0f alpha:1.0f];
        self.switchView.thumbTintColor = [UIColor whiteColor];
    }
    
    if (!userChangedColor.boolValue) {
        self.switchView.onTintColor = CVKMainColor;
        self.switchView.tintColor = [UIColor clearColor];
    }
}

@end
