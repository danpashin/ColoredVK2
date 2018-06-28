//
//  ColoredVKSwitchPrefsCell.m
//  ColoredVK2
//
//  Created by Даниил on 27.06.18.
//

#import "ColoredVKSwitchPrefsCell.h"
#import "ColoredVKNightScheme.h"
#import <objc/runtime.h>
#import "ColoredVKPrefs.h"
#import "ColoredVKNewInstaller.h"

@interface ColoredVKSwitchPrefsCell ()
@property (assign, nonatomic) BOOL switchPrefsLoaded;
@end

@implementation ColoredVKSwitchPrefsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {
        self.switchView = [UISwitch new];
        self.switchView.tag = 228;
        self.switchView.layer.cornerRadius = 16.0f;
        [self.switchView addTarget:self action:@selector(switchTriggered:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = self.switchView;
        
        if (![ColoredVKNightScheme sharedScheme].enabled) {
            self.switchView.backgroundColor = [UIColor colorWithRed:234/255.0f green:234/255.0f blue:239/255.0f alpha:1.0f];
            self.switchView.thumbTintColor = [UIColor whiteColor];
        }
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
    
    ColoredVKPrefs *prefsController = self.cellTarget;
    BOOL userChangedSwitchColor = NO;
    
    if ([prefsController isKindOfClass:[ColoredVKPrefs class]] && [ColoredVKNewInstaller sharedInstaller].application.isVKApp)
        userChangedSwitchColor = ([prefsController.cachedPrefs[@"enabled"] boolValue] && [prefsController.cachedPrefs[@"changeSwitchColor"] boolValue]);
    
    if (!userChangedSwitchColor) {
        self.switchView.onTintColor = CVKMainColor;
        self.switchView.tintColor = [UIColor clearColor];
    }
}

@end
