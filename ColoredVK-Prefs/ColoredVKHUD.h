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
+ (instancetype)showHUDForOperation:(NSOperation *)operation;

- (void)showSuccess;
- (void)showFailure;

@end
