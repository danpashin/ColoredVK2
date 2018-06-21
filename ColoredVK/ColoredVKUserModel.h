//
//  ColoredVKUserModel.h
//  ColoredVK2
//
//  Created by Даниил on 01.01.18.
//

#import <Foundation/NSObject.h>

typedef NS_ENUM(NSUInteger, ColoredVKUserAccountStatus)
{
    ColoredVKUserAccountStatusFree = 0,
    ColoredVKUserAccountStatusPaid,
    ColoredVKUserAccountStatusBanned
};

@interface ColoredVKUserModel : NSObject

@property (assign, nonatomic) ColoredVKUserAccountStatus accountStatus;
@property (assign, nonatomic) BOOL authenticated;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSNumber *userID;
@property (strong, nonatomic) NSString *accessToken;

- (void)clearUser;
- (void)actionPurchase;

- (void)updateAccountInfo:( void(^)(void) )completionBlock;
- (void)logoutWithСompletionBlock:( void(^)(void) )completionBlock;
- (void)authWithUsername:(NSString *)login password:(NSString *)password completionBlock:( void(^)(void) )completionBlock;

@end
