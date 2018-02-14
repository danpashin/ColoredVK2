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
        } else if ([self.contentView.subviews.firstObject isKindOfClass:[UIControl class]]) {
            UIControl *control = self.contentView.subviews.firstObject;
            control.tintColor = CVKMainColor;
            
            if ([self.specifier propertyForKey:@"enabled"]) {
                control.enabled = [[self.specifier propertyForKey:@"enabled"] boolValue];
            }
            
            if ([control isKindOfClass:[UISegmentedControl class]]) {
                control.layer.cornerRadius = CGRectGetHeight(control.bounds) / 2;
                control.layer.borderWidth = 1.0f;
                control.layer.borderColor = control.tintColor.CGColor;
                control.layer.masksToBounds = YES;
            }
        }
        
        if ([self.accessoryView isKindOfClass:[UISwitch class]]) {
            self.accessoryView.tag = 228;
            
            NSNumber *userChangedColor = objc_getAssociatedObject(self, "change_switch_color");
            if (!userChangedColor)
                userChangedColor = @NO;
            
            NSNumber *enableNightTheme = objc_getAssociatedObject(self, "enableNightTheme");
            if (!enableNightTheme)
                enableNightTheme = @NO;
            
//            dispatch_async(dispatch_get_main_queue(), ^{
                UISwitch *switchView = (UISwitch *)self.accessoryView;
                if (!enableNightTheme.boolValue) {
                    switchView.backgroundColor = [UIColor colorWithRed:234/255.0f green:234/255.0f blue:239/255.0f alpha:1.0f];
                    switchView.thumbTintColor = [UIColor whiteColor];
                }
                switchView.layer.cornerRadius = 16.0f;
                
                if (!userChangedColor.boolValue) {
                    switchView.onTintColor = CVKMainColor;
                    switchView.tintColor = [UIColor clearColor];
                }
//            });
            
        }
    }
}

@end
