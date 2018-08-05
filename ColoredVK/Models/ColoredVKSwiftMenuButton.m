//
//  ColoredVKSwiftMenuButton.m
//  ColoredVK2
//
//  Created by Даниил on 03/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "ColoredVKSwiftMenuButton.h"

@implementation ColoredVKSwiftMenuButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.unselectedTintColor = [UIColor whiteColor];
        self.canHighlight = YES;
    }
    return self;
}

@end


@implementation ColoredVKSwiftMenuItemsGroup

- (instancetype)initWithButtons:(NSArray <ColoredVKSwiftMenuButton *> *)buttons
{
    self = [super init];
    if (self) {
        _buttons = [buttons mutableCopy];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithButtons:@[]];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithButtons:@[]];
}

@end
