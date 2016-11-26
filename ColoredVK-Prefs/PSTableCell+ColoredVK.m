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

@implementation PSTableCell (ColoredVK)

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.specifier.properties[@"textColor"]) self.titleLabel.textColor = [UIColor colorFromString:self.specifier.properties[@"textColor"]];
    if ([self.specifier.properties[@"shouldCenter"] boolValue]) self.titleLabel.center = self.contentView.center;
    
    if ([self.accessoryView isKindOfClass:UISwitch.class]) {
        UISwitch *switchView = (UISwitch *)self.accessoryView;
        switchView.tintColor = [UIColor colorWithRed:235.0/255.0f green:235.0/255.0f blue:235.0/255.0f alpha:1.0];
        switchView.onTintColor = [UIColor colorWithRed:90/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1.0];
        switchView.tag = 404;
    }
    
    if ([self.contentView.subviews[0] isKindOfClass:UISegmentedControl.class]) {
        UISegmentedControl *segmentedControl = self.contentView.subviews[0];
        segmentedControl.tintColor = [UIColor colorWithRed:90/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1.0];
    }
}

- (NSString *)cellStringType
{
    if (self.type == PSGroupCell)          return @"PSGroupCell";
    if (self.type == PSLinkCell)           return @"PSLinkCell";
    if (self.type == PSLinkListCell)       return @"PSLinkListCell";
    if (self.type == PSListItemCell)       return @"PSListItemCell";
    if (self.type == PSTitleValueCell)     return @"PSTitleValueCell";
    if (self.type == PSSliderCell)         return @"PSSliderCell";
    if (self.type == PSSwitchCell)         return @"PSSwitchCell";
    if (self.type == PSStaticTextCell)     return @"PSStaticTextCell";
    if (self.type == PSEditTextCell)       return @"PSEditTextCell";
    if (self.type == PSSegmentCell)        return @"PSSegmentCell";
    if (self.type == PSGiantIconCell)      return @"PSGiantIconCell";
    if (self.type == PSGiantCell)          return @"PSGiantCell";
    if (self.type == PSSecureEditTextCell) return @"PSSecureEditTextCell";
    if (self.type == PSButtonCell)         return @"PSButtonCell";
    if (self.type == PSEditTextViewCell)   return @"PSEditTextViewCell";
    return @"Unknown";
}

@end
