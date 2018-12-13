//
//  ColoredVKHeader.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKHeaderView.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface ColoredVKHeaderView ()
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *subtitle;
@end

@implementation ColoredVKHeaderView

+ (instancetype)headerForView:(UIView *)rootView
{
    return [[self alloc] initWithFrame:CGRectMake(0, 0, rootView.frame.size.width, 120)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = [[UILabel alloc] initWithFrame:CGRectZero];
        self.title.font = [UIFont systemFontOfSize:42.0f];
        self.title.text = kPackageName;
        self.title.backgroundColor = [UIColor clearColor];
        self.title.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.title];
        
        self.subtitle = [[UILabel alloc] initWithFrame:CGRectZero];
        self.subtitle.font = [UIFont systemFontOfSize:14.0f];
        self.subtitle.text = CVKLocalizedString(@"Change VK App for yourself!");
        self.subtitle.backgroundColor = [UIColor clearColor];
        self.subtitle.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.subtitle];
        
        self.title.translatesAutoresizingMaskIntoConstraints = NO;
        self.subtitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[heading]-(-10)-[subtitle]-20-|"
                                                                     options:0 metrics:nil views:@{@"heading":self.title, @"subtitle":self.subtitle}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[heading]|" options:0 metrics:nil views:@{@"heading":self.title}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subtitle]|" options:0 metrics:nil views:@{@"subtitle":self.subtitle}]];
        
        [self updateAppearance];
    }
    
    return self;
}

- (void)updateAppearance
{
    NIGHT_THEME_DISABLE_CUSTOMISATION(self.title);
    NIGHT_THEME_DISABLE_CUSTOMISATION(self.subtitle);
    
    self.title.textColor = [UIColor colorWithRed:90/255.0f green:130/255.0f blue:180/255.0f alpha:1];
    self.subtitle.textColor = [UIColor colorWithRed:52/255.0f green:138/255.0f blue:199/255.0f alpha:1.0f];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CAGradientLayer *backgroundGradientLayer = [CAGradientLayer layer];
        backgroundGradientLayer.frame = self.title.bounds;
        backgroundGradientLayer.colors = @[(id)[UIColor colorWithRed:38/255.0f green:208/255.0f blue:206/255.0f alpha:1.0f].CGColor, 
                                           (id)[UIColor colorWithRed:26/255.0f green:41/255.0f blue:128/255.0f alpha:1.0f].CGColor];
        
        UIGraphicsBeginImageContextWithOptions(backgroundGradientLayer.bounds.size, NO, [UIScreen mainScreen].scale);
        [backgroundGradientLayer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.title.textColor = [UIColor colorWithPatternImage:backgroundColorImage];
    });
}

@end
