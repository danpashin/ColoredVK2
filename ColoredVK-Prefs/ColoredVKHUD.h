//
//  ColoredVKHUD.h
//  ColoredVK
//
//  Created by Даниил on 21/01/2017.
//
//

#import "LHProgressHUD.h"

@interface ColoredVKHUD : LHProgressHUD

@property (strong, nonatomic) NSOperation *operation;
@property (nonatomic, copy) void (^executionBlock)(ColoredVKHUD *parentHud);

+ (instancetype)showHUD;
+ (instancetype)showHUDForView:(UIView *)view;
+ (instancetype)showHUDForOperation:(NSOperation *)operation;
+ (instancetype)showHUDForOperation:(NSOperation *)operation andView:(UIView *)view;

- (void)showSuccess;
- (void)showFailure;
- (void)showFailureWithStatus:(NSString *)status;
- (void)showSuccessWithStatus:(NSString *)status;

@end
