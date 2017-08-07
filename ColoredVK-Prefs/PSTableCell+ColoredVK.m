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
            UISwitch *switchView = (UISwitch *)self.accessoryView;
            switchView.tintColor = [UIColor colorWithRed:235.0/255.0f green:235.0/255.0f blue:235.0/255.0f alpha:1.0];
            switchView.onTintColor = CVKMainColor;
            switchView.tag = 404;
        }
    }
}
@end
