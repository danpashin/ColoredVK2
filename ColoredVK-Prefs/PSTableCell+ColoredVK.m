//
//  PSTableCell+ColoredVK.m
//  ColoredVK
//
//  Created by Даниил on 13/10/16.
//
//

#import "PSTableCell+ColoredVK.h"
#import "UIColor+ColoredVK.h"
#import "PSSpecifier.h"
#import "PrefixHeader.h"
#import "ColoredVKPrefs.h"

@implementation PSTableCell (ColoredVK)

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self.cellTarget isKindOfClass:[ColoredVKPrefs class]]) {
        if (self.specifier.properties[@"textColor"]) self.titleLabel.textColor = [UIColor colorFromString:self.specifier.properties[@"textColor"]];
        if ([self.specifier.properties[@"shouldCenter"] boolValue]) self.titleLabel.center = self.contentView.center;
        if ([self.specifier.properties[@"addDisclosureIndicator"] boolValue]) self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if ([self.accessoryView isKindOfClass:UISwitch.class]) {
            UISwitch *switchView = (UISwitch *)self.accessoryView;
            switchView.tintColor = [UIColor colorWithRed:235.0/255.0f green:235.0/255.0f blue:235.0/255.0f alpha:1.0];
            switchView.onTintColor = CVKMainColor;
            switchView.tag = 404;
        }
        
        if ((self.contentView.subviews.count > 0) && [self.contentView.subviews[0] isKindOfClass:[UISegmentedControl class]]) {
            UISegmentedControl *segmentedControl = self.contentView.subviews[0];
            segmentedControl.tintColor = CVKMainColor;
        }
    }
}
@end
