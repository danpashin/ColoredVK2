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
#import <dlfcn.h>

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
        heading.font = [UIFont systemFontOfSize:42.0];
        heading.text = @"ColoredVK 2";
        heading.backgroundColor = [UIColor clearColor];
        heading.textColor = [UIColor colorWithRed:90.0/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1];
        heading.textAlignment = NSTextAlignmentCenter;
        [self addSubview:heading];
        
        UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectZero];
        subtitle.font = [UIFont systemFontOfSize:14.0];
        subtitle.text = @"Change your VK App sense!";
        subtitle.backgroundColor = [UIColor clearColor];
        subtitle.textColor = @"348AC7".hexColorValue;
        subtitle.textAlignment = heading.textAlignment;
        [self addSubview:subtitle];
        
        heading.translatesAutoresizingMaskIntoConstraints = NO;
        subtitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[heading]-(-10)-[subtitle]-20-|" options:0 metrics:nil views:@{@"heading":heading, @"subtitle":subtitle}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[heading]|" options:0 metrics:nil views:@{@"heading":heading}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subtitle]|" options:0 metrics:nil views:@{@"subtitle":subtitle}]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            heading.textColor = [UIColor colorWithGradientStyle:UIGradientStyleTopToBottom withFrame:heading.bounds andColors:@[@"26D0CE".hexColorValue, @"1A2980".hexColorValue]];
        });
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        tap.numberOfTapsRequired = 5;
        [self addGestureRecognizer:tap];
    }
    
    return self;
}

- (void)tapRecognized:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) dlopen(@"/var/mobile/FLEXDylib.dylib".UTF8String, RTLD_NOW);
}
@end
