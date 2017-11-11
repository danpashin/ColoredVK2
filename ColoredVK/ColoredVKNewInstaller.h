//
//  ColoredVKNewInstaller.h
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ColoredVKHeaderView.h"
#import "ColoredVKNetworkController.h"

@interface ColoredVKNewInstaller : NSObject

FOUNDATION_EXPORT void(^installerCompletionBlock)(BOOL purchased);

+ (instancetype)sharedInstaller;

@property (strong, nonatomic, readonly) ColoredVKNetworkController *networkController;
@property (assign, nonatomic, readonly) BOOL userAuthorized;
@property (copy, nonatomic, readonly) NSString *userName;
@property (strong, nonatomic, readonly) NSNumber *userID;
@property (copy, nonatomic, readonly) NSString *token;
@property (assign, nonatomic, readonly, getter=isTweakPurchased) BOOL tweakPurchased;
@property (assign, nonatomic, readonly, getter=isTweakActivated) BOOL tweakActivated;
@property (assign, nonatomic) BOOL api_purchased;
@property (assign, nonatomic) BOOL api_activated;
@property (assign, nonatomic) BOOL api_banned;

@property (copy, nonatomic, readonly) NSString *appTeamIdentifier;
@property (copy, nonatomic, readonly) NSString *appTeamName;
@property (copy, nonatomic, readonly) NSString *sellerName;

- (void)checkStatus;
- (void)actionPurchase;
- (void)updateAccountInfo:( void(^)(void) )completionBlock;

- (void)actionLogoutWithPassword:(NSString *)password completionBlock:( void(^)(void) )completionBlock;
- (void)actionLoginWithUsername:(NSString *)login password:(NSString *)password completionBlock:( void(^)(void) )completionBlock;

@end
