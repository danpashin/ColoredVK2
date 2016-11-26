//
//  ColoredVKHeader.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKHeaderView.h"

@implementation ColoredVKHeaderView

+ (instancetype)headerForView:(UIView *)rootView
{
    return [[self alloc] initWithFrame:CGRectMake(0, 0, rootView.frame.size.width, 120)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        UILabel *heading = [[UILabel alloc] initWithFrame:CGRectZero];
        heading.font = [UIFont fontWithName:@"HelveticaNeue" size:35.0];
        heading.text = @"ColoredVK";
        heading.backgroundColor = UIColor.clearColor;
        heading.textColor = [UIColor colorWithRed:70.0/255.0f green:120.0/255.0f blue:177.0/255.0f alpha:1];
        heading.textAlignment = NSTextAlignmentCenter;
        [self addSubview:heading];
        
        UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectZero];
        subtitle.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
        subtitle.text = @"Customize your VK App!";
        subtitle.backgroundColor = UIColor.clearColor;
        subtitle.textColor = UIColor.grayColor;
        subtitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:subtitle];
        
        heading.translatesAutoresizingMaskIntoConstraints = NO;
        subtitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[heading]-[subtitle]-20-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil views:NSDictionaryOfVariableBindings(heading, subtitle)]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[heading]-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil views:NSDictionaryOfVariableBindings(heading)]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[subtitle]-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil views:NSDictionaryOfVariableBindings(subtitle)]];
    }
    
    return self;
}
@end
