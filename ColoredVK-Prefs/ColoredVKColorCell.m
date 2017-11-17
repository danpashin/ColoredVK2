//
//  ColoredVKColorCell.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKColorCell.h"
#import "PrefixHeader.h"

@implementation ColoredVKColorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateColorView:) name:@"com.daniilpashin.coloredvk2.prefs.colorUpdate" object:nil];
        [self updateColorViewForIdentifier:specifier.identifier];
    }
    return self;
}

- (void)updateColorView:(NSNotification *)notification
{
    NSString *identifier = notification.userInfo[@"identifier"];
	if (identifier == self.specifier.identifier) [self updateColorViewForIdentifier:identifier];
}

- (void)updateColorViewForIdentifier:(NSString *)identifier
{
    UIView *colorPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26.0f, 26.0f)];
    colorPreview.backgroundColor = [UIColor savedColorForIdentifier:identifier];
    
    CGFloat red = 0, green = 0, blue = 0, colorAlpha = 1.0f;
    [colorPreview.backgroundColor getRed:&red green:&green blue:&blue alpha:&colorAlpha];
    if (colorAlpha == 0.0f)
        colorPreview.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
    
    colorPreview.layer.cornerRadius = colorPreview.frame.size.height / 2.0f;
    colorPreview.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:colorPreview.frame cornerRadius:colorPreview.layer.cornerRadius].CGPath;
    colorPreview.layer.shadowRadius = 2.5f;
    colorPreview.layer.shadowOffset = CGSizeZero;
    colorPreview.layer.shadowColor = [UIColor blackColor].CGColor;
    colorPreview.layer.shadowOpacity = 0.15f;
    
    self.accessoryView = colorPreview;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
