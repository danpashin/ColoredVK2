//
//  ColoredVKUserModel.h
//  ColoredVK2
//
//  Created by Даниил on 01.01.18.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ColoredVKUserAccountStatus)
{
    ColoredVKUserAccountStatusFree = 0,
    ColoredVKUserAccountStatusPaid,
    ColoredVKUserAccountStatusBanned
};

@interface ColoredVKUserModel : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSNumber *userID;
@property (strong, nonatomic) NSString *accessToken;

@property (assign, nonatomic) ColoredVKUserAccountStatus accountStatus;
@property (assign, nonatomic) BOOL authenticated;

- (void)clearUser;

@end
