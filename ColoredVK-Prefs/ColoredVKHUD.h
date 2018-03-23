//
//  ColoredVKHUD.h
//  ColoredVK
//
//  Created by Даниил on 21/01/2017.
//
//

#import "LHProgressHUD.h"

@interface ColoredVKHUD : LHProgressHUD

//@property (assign, nonatomic) BOOL dismissByTap;

+ (instancetype)showHUD;
+ (instancetype)showHUDForView:(UIView *)view;

- (void)showSuccess;
- (void)showFailure;
- (void)showFailureWithStatus:(NSString *)status;
- (void)showSuccessWithStatus:(NSString *)status;

- (void)hide;
- (void)hideAfterDelay:(CGFloat)delay;

@end
