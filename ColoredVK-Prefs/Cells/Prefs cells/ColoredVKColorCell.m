//
//  ColoredVKColorCell.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "UIColor+ColoredVK.h"
#import "ColoredVKColorCell.h"
#import "ColoredVKPrefs.h"

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
    }
    return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier
{
    [super refreshCellContentsWithSpecifier:specifier];
    
    if ([specifier propertyForKey:@"wasReloaded"]) {
        [specifier removePropertyForKey:@"wasReloaded"];
        [self updateColorForIdentifier:specifier.identifier animated:YES];
    } else if (!self.accessoryView.backgroundColor) {
        [self updateColorForIdentifier:specifier.identifier animated:NO];
    }
}

- (void)updateColorForIdentifier:(NSString *)identifier animated:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ColoredVKPrefs *prefsController = self.cellTarget;
        UIColor *savedColor = [UIColor cvk_savedColorForIdentifier:identifier fromPrefs:prefsController.cachedPrefs];
        
        CGFloat colorAlpha;
        [savedColor getRed:nil green:nil blue:nil alpha:&colorAlpha];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIColor *color = (colorAlpha != 0.0f) ? savedColor : [UIColor colorWithWhite:1.0f alpha:0.9f];
            void (^animationBlock)(void) = ^{
                self.accessoryView.backgroundColor = color;
            };
            
            if (animated) {
                [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionAllowUserInteraction
                                 animations:animationBlock completion:nil];
            } else
                animationBlock();
        });
    });
}

@end
