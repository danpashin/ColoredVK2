//
//  ColoredVKSwitch.m
//  ColoredVK2
//
//  Created by Даниил on 14.07.18.
//

#import "ColoredVKSwitch.h"

@implementation ColoredVKSwitch

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupSwitch];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSwitch];
    }
    return self;
}

- (void)setupSwitch
{
    self.onTintColor = CVKMainColor;
    self.tintColor = [UIColor clearColor];
    self.thumbTintColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor colorWithRed:234/255.0f green:234/255.0f blue:239/255.0f alpha:1.0f];
    
    self.layer.cornerRadius = 16.0f;
    self.layer.masksToBounds = YES;
}

@end
