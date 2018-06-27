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
        
        [self updateColorForIdentifier:specifier.identifier animated:NO];
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
        [self updateColorForIdentifier:selfID animated:YES];
}

- (void)updateColorForIdentifier:(NSString *)identifier animated:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIColor *savedColor = [UIColor cvk_savedColorForIdentifier:identifier];
        CGFloat red = 0, green = 0, blue = 0, colorAlpha = 1.0f;
        [savedColor getRed:&red green:&green blue:&blue alpha:&colorAlpha];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIColor *color = (colorAlpha != 0.0f) ? savedColor : [UIColor colorWithWhite:1.0f alpha:0.9f];
            void (^animationBlock)(void) = ^{
                self.accessoryView.backgroundColor = color;
            };
            
            if (animated)
                [UIView animateWithDuration:0.5f delay:0.1f options:UIViewAnimationOptionAllowUserInteraction animations:animationBlock completion:nil];
            else
                animationBlock();
        });
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
