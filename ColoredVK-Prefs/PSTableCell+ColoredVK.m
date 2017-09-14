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
            BOOL userChangedColor = ([userPrefs[@"enabled"] boolValue] && [userPrefs[@"changeSwitchColor"] boolValue]);
            if (![[NSBundle mainBundle].executablePath.lastPathComponent.lowercaseString isEqualToString:@"vkclient"])
                userChangedColor = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UISwitch *switchView = (UISwitch *)self.accessoryView;
                switchView.backgroundColor = [UIColor colorWithRed:234/255.0f green:234/255.0f blue:239/255.0f alpha:1.0f];
                switchView.layer.cornerRadius = 16.0f;
                switchView.thumbTintColor = [UIColor whiteColor];
                
                if (!userChangedColor) {
                    switchView.onTintColor = CVKMainColor;
                    switchView.tintColor = [UIColor clearColor];
                }
            });
            
        }
    }
}

- (void)updateColors
{
   if ([self.cellTarget isKindOfClass:[ColoredVKPrefs class]]) {
       if (self.backgroundView) {
           if (self.backgroundView.layer.sublayers.count > 0) {
               CAShapeLayer *shapeLayer = (CAShapeLayer *)self.backgroundView.layer.sublayers.firstObject;
               if ([shapeLayer isKindOfClass:[CAShapeLayer class]]) {
                   if (self.selected || self.highlighted)
                       shapeLayer.fillColor = @"#dddddd".hexColorValue.CGColor;
                   else
                       shapeLayer.fillColor = [UIColor whiteColor].CGColor;
               }
           }
       }
   }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    [self updateColors];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    [self updateColors];
}

@end
