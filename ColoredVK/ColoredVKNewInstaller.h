//
//  ColoredVKNewInstaller.h
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

#import "ColoredVKNetworkController.h"
#import "ColoredVKUserModel.h"
#import "ColoredVKApplicationModel.h"

@interface ColoredVKNewInstaller : NSObject

FOUNDATION_EXPORT void(^installerCompletionBlock)(BOOL purchased);

+ (instancetype)sharedInstaller;

@property (strong, nonatomic, readonly) ColoredVKNetworkController *networkController;
@property (strong, nonatomic, readonly) ColoredVKUserModel *user;
@property (strong, nonatomic, readonly) ColoredVKApplicationModel *application;

@property (copy, nonatomic, readonly) NSString *deviceModel;

@property (strong, nonatomic) NSNumber *vkUserID;
@property (copy, nonatomic, readonly) NSString *sellerName;

@property (assign, nonatomic, readonly) BOOL jailed;
@property (assign, nonatomic, readonly) BOOL shouldOpenPrefs;

- (void)checkStatus;
- (void)actionPurchase;

@end
