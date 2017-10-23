//
//  PSTableCell+ColoredVK.m
//  ColoredVK
//
//  Created by Даниил on 13/10/16.
//
//

#import "PSTableCell+ColoredVK.h"

#import "UIColor+ColoredVK.h"
#import "PrefixHeader.h"
#import "ColoredVKPrefs.h"
#import "ColoredVKNightThemeColorScheme.h"
#import "UIColor+ColoredVK.h"

@implementation PSTableCell (ColoredVK)

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self.cellTarget isKindOfClass:[ColoredVKPrefs class]]) {
        if ([self.specifier.properties[@"shouldCenter"] boolValue]) self.titleLabel.center = self.contentView.center;
        if ([self.specifier.properties[@"addDisclosureIndicator"] boolValue]) self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (self.type == PSButtonCell) {
            if ([self.specifier.properties[@"style"] isEqualToString:@"Destructive"]) {
                self.titleLabel.textColor = [UIColor redColor];
            } else {
                self.titleLabel.textColor = CVKMainColor;
            }
        } else if ([self.contentView.subviews[0] isKindOfClass:[UIControl class]]) {
            UIControl *control = self.contentView.subviews[0];
            control.tintColor = CVKMainColor;
            
            if ([self.specifier propertyForKey:@"enabled"]) {
                control.enabled = [[self.specifier propertyForKey:@"enabled"] boolValue];
            }
        }
        
        if ([self.accessoryView isKindOfClass:[UISwitch class]]) {
            NSDictionary *userPrefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
            
            dispatch_async(dispatch_get_main_queue(), ^{
//                ColoredVKNightThemeColorScheme *nightThemeColorScheme = objc_getAssociatedObject(self, "nightThemeColorScheme");
                BOOL userChangedColor = ([userPrefs[@"enabled"] boolValue] && [userPrefs[@"changeSwitchColor"] boolValue]);
                
                NSNumber *app_is_vk = objc_getAssociatedObject(self, "app_is_vk");
                if (!app_is_vk) 
                    app_is_vk = @NO;
                
                if (!app_is_vk.boolValue)
                    userChangedColor = NO;
                
                NSNumber *enableNightTheme = objc_getAssociatedObject(self, "enableNightTheme");
                if (!enableNightTheme)
                    enableNightTheme = @NO;
                
                UISwitch *switchView = (UISwitch *)self.accessoryView;
                if (app_is_vk.boolValue && enableNightTheme.boolValue) {
                    userChangedColor = YES;
//                    switchView.backgroundColor = nightThemeColorScheme.backgroundColor;
//                    switchView.thumbTintColor = nightThemeColorScheme.navbackgroundColor;
                } else {
                    switchView.backgroundColor = [UIColor colorWithRed:234/255.0f green:234/255.0f blue:239/255.0f alpha:1.0f];
                    switchView.thumbTintColor = [UIColor whiteColor];
                }
                switchView.layer.cornerRadius = 16.0f;
                
                if (!userChangedColor) {
                    switchView.onTintColor = CVKMainColor;
                    switchView.tintColor = [UIColor clearColor];
                }
            });
            
        }
    }
}

- (void)setShapeColor:(BOOL)tapped
{
    if ([self.cellTarget isKindOfClass:[ColoredVKPrefs class]]) {
        if (self.backgroundView && (self.backgroundView.layer.sublayers.count > 0)) {
            CAShapeLayer *shapeLayer = (CAShapeLayer *)self.backgroundView.layer.sublayers.firstObject;
            if ([shapeLayer isKindOfClass:[CAShapeLayer class]]) {
                
                ColoredVKNightThemeColorScheme *nightThemeColorScheme = objc_getAssociatedObject(self, "nightThemeColorScheme");
                
                NSNumber *app_is_vk = objc_getAssociatedObject(self, "app_is_vk");
                if (!app_is_vk) 
                    app_is_vk = @NO;
                
                NSNumber *enableNightTheme = objc_getAssociatedObject(self, "enableNightTheme");
                if (!enableNightTheme)
                    enableNightTheme = @NO;
                
                if (tapped && (self.type != PSSwitchCell)) {
                    if (enableNightTheme.boolValue && app_is_vk.boolValue)
                        shapeLayer.fillColor = nightThemeColorScheme.backgroundColor.CGColor;
                    else
                        shapeLayer.fillColor = @"#dddddd".hexColorValue.CGColor;
                } else {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (enableNightTheme.boolValue && app_is_vk.boolValue)
                            shapeLayer.fillColor = nightThemeColorScheme.foregroundColor.CGColor;
                        else
                            shapeLayer.fillColor = [UIColor whiteColor].CGColor;
                    });
                }
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    [self setShapeColor:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    [self setShapeColor:highlighted];
}

@end
