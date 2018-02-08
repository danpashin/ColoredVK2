//
//  ColoredVKNewInstaller.h
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

#import <Foundation/Foundation.h>
#import "ColoredVKNetworkController.h"
#import "ColoredVKUser.h"

@interface ColoredVKNewInstaller : NSObject

FOUNDATION_EXPORT void(^installerCompletionBlock)(BOOL purchased);

+ (instancetype)sharedInstaller;

@property (strong, nonatomic, readonly) ColoredVKNetworkController *networkController;
@property (strong, nonatomic, readonly) ColoredVKUser *user;
@property (strong, nonatomic) NSNumber *vkUserID;

@property (copy, nonatomic, readonly) NSString *appTeamIdentifier;
@property (copy, nonatomic, readonly) NSString *appTeamName;
@property (copy, nonatomic, readonly) NSString *sellerName;

- (void)checkStatus;
- (void)actionPurchase;
- (void)updateAccountInfo:( void(^)(void) )completionBlock;

- (void)logoutWithСompletionBlock:( void(^)(void) )completionBlock;
- (void)authWithUsername:(NSString *)login password:(NSString *)password completionBlock:( void(^)(void) )completionBlock;

@end
