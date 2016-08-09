//
//  ColoredVKColorCell.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKColorCell.h"
#import "PrefixHeader.h"
#import "ColoredVKJailCheck.h"

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
	if (identifier == (self.specifier).identifier) { [self updateColorCellForIdentifier:identifier]; }
}

- (void)updateColorCellForIdentifier:(NSString *)identifier
{	
    UIView *colorPreview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    colorPreview.backgroundColor = [self savedColorForIdentifier:identifier]; 
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

- (UIColor *)savedColorForIdentifier:(NSString *)identifier 
{
    NSString *prefsPath = CVK_PREFS_PATH;
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
    
    if (prefs[identifier] == nil) {
        if      ([identifier isEqualToString:@"BarBackgroundColor"])     {  return [UIColor colorWithRed:60.00/255.0f green:112.0/255.0f blue:169.0/255.0f alpha:1];    }
        else if ([identifier isEqualToString:@"BarForegroundColor"])     {  return [UIColor whiteColor];                                                                }
        else if ([identifier isEqualToString:@"ToolBarBackgroundColor"]) {  return [UIColor colorWithRed:245.0/255.0f green:245.0/255.0f blue:248.0/255.0f alpha:1];    }
        else if ([identifier isEqualToString:@"ToolBarForegroundColor"]) {  return [UIColor colorWithRed:127.0/255.0f green:131.0/255.0f blue:137.0/255.0f alpha:1];    }
        else if ([identifier isEqualToString:@"MenuSeparatorColor"])     {  return [UIColor colorWithRed:72.00/255.0f green:86.00/255.0f blue:97.00/255.0f alpha:1];    }
        else if ([identifier isEqualToString:@"SBBackgroundColor"])      {  return [UIColor clearColor];                                                                }
        else if ([identifier isEqualToString:@"SBForegroundColor"])      {  return [UIColor whiteColor];                                                                }
        else                                                             {  return [UIColor blackColor];                                                                }    
    } else {
        return [UIColor colorFromString:prefs[identifier]];
    }
}
@end