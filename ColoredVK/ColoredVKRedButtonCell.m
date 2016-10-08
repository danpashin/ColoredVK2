//
//  ColoredVKResetCell.m
//  ColoredVK
//
//  Created by Даниил on 08/10/16.
//
//

#import "ColoredVKRedButtonCell.h"

@implementation ColoredVKRedButtonCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.textColor = [UIColor colorWithRed:255/255.0f green:0/255.0f blue:0/255.0f alpha:1.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.center = self.contentView.center;
}
@end
