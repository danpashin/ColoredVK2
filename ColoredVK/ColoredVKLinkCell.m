//
//  ColoredVKPrefsCell.m
//  ColoredVK
//
//  Created by Даниил on 16.07.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKLinkCell.h"

@implementation ColoredVKLinkCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.textColor = [UIColor colorWithRed:90/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1.0];
}

@end
