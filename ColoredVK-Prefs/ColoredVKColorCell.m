//
//  ColoredVKColorCell.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "UIColor+ColoredVK.h"
#import "ColoredVKColorCell.h"

@implementation ColoredVKColorCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {
        self.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 26.0f, 26.0f)];
        self.accessoryView.layer.cornerRadius = self.accessoryView.frame.size.height / 2.0f;
        self.accessoryView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.accessoryView.frame 
                                                                         cornerRadius:self.accessoryView.layer.cornerRadius].CGPath;
        self.accessoryView.layer.shadowRadius = 2.5f;
        self.accessoryView.layer.shadowOffset = CGSizeZero;
        self.accessoryView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.accessoryView.layer.shadowOpacity = 0.15f;
        
        [self updateColorForIdentifier:specifier.identifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateColorNotification:) 
                                                     name:kPackageNotificationUpdateColor object:nil];
    }
    return self;
}

- (void)updateColorNotification:(NSNotification *)notification
{
    NSString *notificationID = notification.userInfo[@"identifier"];
    NSString *selfID = self.specifier.identifier;
    
    if ((notificationID.length == 0) || (selfID.length == 0))
        return;
    
	if ([notificationID isEqualToString:selfID])
        [self updateColorForIdentifier:selfID];
}

- (void)updateColorForIdentifier:(NSString *)identifier
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIColor *color = [UIColor cvk_savedColorForIdentifier:identifier];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.accessoryView.backgroundColor = color;
            
            CGFloat red = 0, green = 0, blue = 0, colorAlpha = 1.0f;
            [color getRed:&red green:&green blue:&blue alpha:&colorAlpha];
            if (colorAlpha == 0.0f)
                self.accessoryView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
        });
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
