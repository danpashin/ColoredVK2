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
    UIView *colorPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    colorPreview.backgroundColor = [UIColor savedColorForIdentifier:identifier];
    colorPreview.layer.borderColor = colorPreview.backgroundColor.darkerColor.CGColor;
    colorPreview.layer.borderWidth = 1.0f; 
    colorPreview.layer.cornerRadius = colorPreview.frame.size.height / 2;
	self.accessoryView = colorPreview;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
