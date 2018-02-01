//
//  ColoredVKNewInstaller.h
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

#import <Foundation/Foundation.h>
#import "ColoredVKNetworkController.h"

@interface ColoredVKNewInstaller : NSObject

FOUNDATION_EXPORT void(^installerCompletionBlock)(BOOL purchased);

+ (instancetype)sharedInstaller;

@property (strong, nonatomic, readonly) ColoredVKNetworkController *networkController;

@property (assign, nonatomic, readonly) BOOL authenticated;
@property (assign, nonatomic, readonly) BOOL purchased;
@property (assign, nonatomic, readonly) BOOL activated;
@property (assign, nonatomic, readonly) BOOL banned;
@property (strong, nonatomic, readonly) NSNumber *userID;
@property (copy, nonatomic, readonly) NSString *userName;

@property (copy, nonatomic, readonly) NSString *appTeamIdentifier;
@property (copy, nonatomic, readonly) NSString *appTeamName;
@property (copy, nonatomic, readonly) NSString *sellerName;

- (void)checkStatus;
- (void)actionPurchase;
- (void)updateAccountInfo:( void(^)(void) )completionBlock;

- (void)logoutWithСompletionBlock:( void(^)(void) )completionBlock;
- (void)authWithUsername:(NSString *)login password:(NSString *)password completionBlock:( void(^)(void) )completionBlock;

@end
