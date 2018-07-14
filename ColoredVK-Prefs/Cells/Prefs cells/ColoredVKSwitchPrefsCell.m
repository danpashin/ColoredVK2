//
//  ColoredVKSwitchPrefsCell.m
//  ColoredVK2
//
//  Created by Даниил on 27.06.18.
//

#import "ColoredVKSwitchPrefsCell.h"
#import "ColoredVKNightScheme.h"
#import "ColoredVKPrefs.h"
#import "ColoredVKNewInstaller.h"
#import "UIColor+ColoredVK.h"
#import "ColoredVKSwitch.h"

@interface ColoredVKSwitchPrefsCell ()
@property (assign, nonatomic) BOOL switchPrefsLoaded;
@end

@implementation ColoredVKSwitchPrefsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {
        self.switchView = [ColoredVKSwitch new];
        [self.switchView addTarget:self action:@selector(switchTriggered:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = self.switchView;
    }
    return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier
{
    [super refreshCellContentsWithSpecifier:specifier];
    
    if (!self.switchPrefsLoaded || [specifier propertyForKey:@"wasReloaded"]) {
        [specifier removePropertyForKey:@"wasReloaded"];
        self.switchPrefsLoaded = YES;
        [self updateSwitchWithSpecifier:specifier];
    }
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

@end
