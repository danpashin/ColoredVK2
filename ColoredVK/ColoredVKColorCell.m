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
        [self updateColorCellForIdentifier:specifier.identifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateColorCell:) name:@"com.daniilpashin.coloredvk.prefs.colorUpdate" object:nil];
    }
    return self;
}

- (void)updateColorCell:(NSNotification *)notification
{
    NSString *identifier = notification.userInfo[@"CVKColorCellIdentifier"];
	if (identifier == self.specifier.identifier) [self updateColorCellForIdentifier:identifier];
}

- (void)updateColorCellForIdentifier:(NSString *)identifier
{	
    UIView *colorPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    colorPreview.backgroundColor = [UIColor savedColorForIdentifier:identifier]; 
    colorPreview.layer.borderColor = [UIColor darkerColorForColor:colorPreview.backgroundColor].CGColor;
    colorPreview.layer.borderWidth = 1.0f; 
    colorPreview.layer.cornerRadius = colorPreview.frame.size.height / 2;
    
    self.opaque = YES;
    self.contentView.opaque = YES;
    colorPreview.opaque = YES;
	
	self.accessoryView = colorPreview;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end