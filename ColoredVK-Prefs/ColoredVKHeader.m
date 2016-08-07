//
//  ColoredVKHeader.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKHeader.h"

@implementation ColoredVKHeader

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CVKHeaderCell" specifier:specifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
    
        
        UILabel *heading = [UILabel new];
        heading.frame =  CGRectMake(0, 0, self.frame.size.width, 100);
        heading.font = [UIFont fontWithName:@"HelveticaNeue" size:35.0];
        heading.text = @"ColoredVK";
        heading.backgroundColor = [UIColor clearColor];
        heading.textColor = [UIColor colorWithRed:70.0/255.0f green:120.0/255.0f blue:177.0/255.0f alpha:1];
        heading.textAlignment = NSTextAlignmentCenter;
        [self addSubview:heading];
        
        UILabel *subtitle = [UILabel new];
        subtitle.frame = CGRectMake(0, heading.frame.origin.x + heading.frame.size.height - 20, self.frame.size.width, 32);
        subtitle.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        subtitle.text = @"Colorize your VK App!";
        subtitle.backgroundColor = [UIColor clearColor];
        subtitle.textColor = [UIColor grayColor];
        subtitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:subtitle];
    }
    
    return self;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width
{ 
    return 120; 
}
@end
