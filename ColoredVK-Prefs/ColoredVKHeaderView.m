//
//  ColoredVKHeader.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKHeaderView.h"
#import "UIColor+ColoredVK.h"
#import "NSString+ColoredVK.h"

@implementation ColoredVKHeaderView

+ (instancetype)headerForView:(UIView *)rootView
{
    return [[self alloc] initWithFrame:CGRectMake(0, 0, rootView.frame.size.width, 140)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        UILabel *heading = [[UILabel alloc] initWithFrame:CGRectZero];
        heading.font = [UIFont systemFontOfSize:42.0];
        heading.text = @"ColoredVK 2";
        heading.backgroundColor = [UIColor clearColor];
        heading.textColor = [UIColor colorWithRed:90.0/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1];
        heading.textAlignment = NSTextAlignmentCenter;
        [self addSubview:heading];
        
        UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectZero];
        subtitle.font = [UIFont systemFontOfSize:14.0];
        subtitle.text = @"Customize your VK App!";
        subtitle.backgroundColor = [UIColor clearColor];
        subtitle.textColor = [UIColor grayColor];
        subtitle.textAlignment = heading.textAlignment;
        [self addSubview:subtitle];
        
        heading.translatesAutoresizingMaskIntoConstraints = NO;
        subtitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[heading]-[subtitle]-20-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil views:NSDictionaryOfVariableBindings(heading, subtitle)]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[heading]-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil views:NSDictionaryOfVariableBindings(heading)]];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[subtitle]-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil views:NSDictionaryOfVariableBindings(subtitle)]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            heading.textColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom withFrame:heading.bounds andColors:@[@"26D0CE".hexColorValue, @"1A2980".hexColorValue]];
            subtitle.textColor = @"348AC7".hexColorValue;
        });
    }
    
    return self;
}
@end
