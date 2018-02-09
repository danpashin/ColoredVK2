//
//  ColoredVKUserModel.m
//  ColoredVK2
//
//  Created by Даниил on 01.01.18.
//

#import "ColoredVKUserModel.h"

@implementation ColoredVKUserModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self clearUser];
    }
    return self;
}

- (void)clearUser
{
    self.name = nil;
    self.email = nil;
    self.userID = nil;
    self.accountStatus = ColoredVKUserAccountStatusFree;
}

@end
