//
//  ColoredVKHUD.h
//  ColoredVK
//
//  Created by Даниил on 21/01/2017.
//
//

#import "LHProgressHUD.h"

@interface ColoredVKHUD : LHProgressHUD

@property (assign, nonatomic) BOOL dismissByTap;
@property (nonatomic, copy) void (^executionBlock)(ColoredVKHUD *parentHud);

+ (instancetype)showHUD;
+ (instancetype)showHUDForView:(UIView *)view;

- (void)showSuccess;
- (void)showFailure;
- (void)showFailureWithStatus:(NSString *)status;
- (void)showSuccessWithStatus:(NSString *)status;

- (void)hide;
- (void)hideAfterDelay:(CGFloat)delay;
- (void)hideAfterDelay:(CGFloat)delay hiddenBlock:(void (^)(void))hiddenBlock;

@end
