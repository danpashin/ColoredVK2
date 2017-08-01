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

@interface ColoredVKNewInstaller : NSObject

FOUNDATION_EXPORT void(^installerCompletionBlock)(BOOL purchased);
FOUNDATION_EXPORT void installerActionLogin(NSString *login, NSString *password, void(^completionBlock)());
FOUNDATION_EXPORT void installerActionLogout(NSString *password, void(^completionBlock)());

+ (instancetype)sharedInstaller;

@property (strong, nonatomic, readonly) NSString *userLogin;
@property (strong, nonatomic, readonly) NSNumber *userID;
@property (strong, nonatomic, readonly) NSString *token;
@property (assign, nonatomic, readonly, getter=isTweakPurchased) BOOL tweakPurchased;
@property (assign, nonatomic, readonly, getter=isTweakActivated) BOOL tweakActivated;
@property (assign, nonatomic) BOOL api_purchased;
@property (assign, nonatomic) BOOL api_activated;
@property (assign, nonatomic) BOOL api_banned;

- (void)checkStatusAndShowAlert:(BOOL)showAlert;
- (void)actionPurchase;
- (void)updateAccountInfo:( void(^)() )completionBlock;

@end
