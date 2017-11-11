//
//  ColoredVKHUD.m
//  ColoredVK
//
//  Created by Даниил on 21/01/2017.
//
//

#import "ColoredVKHUD.h"

@interface LHProgressHUD ()
- (instancetype)initWithAttachedView:(UIView *)view mode:(LHProgressHUDMode)mode subMode:(LHPRogressHUDSubMode)subMode animated:(BOOL)animated;
@property (strong, nonatomic) UIView *lhSpinner;
- (void)commonInit;
@end

@implementation ColoredVKHUD

+ (instancetype)showHUD
{
    return [[self alloc] initHudForView:nil];
}

+ (instancetype)showHUDForView:(UIView *)view
{
    return [[self alloc] initHudForView:view];
}

- (instancetype)initHudForView:(UIView *)view
{
    if (!view) view = UIApplication.sharedApplication.keyWindow.rootViewController.view;
    
    self = [super initWithAttachedView:view mode:LHProgressHUDModeNormal subMode:LHProgressHUDSubModeAnimating animated:YES];
    if (self) {
        [self setupHUD];
    }
    return self;
}

- (void)setupHUD
{
    self.dismissByTap = NO;
    self.centerBackgroundView.blurStyle = LHBlurEffectStyleExtraLight;
    self.centerBackgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    self.centerBackgroundView.layer.cornerRadius = 10;
    self.infoColor = [UIColor colorWithWhite:0.55 alpha:1];
    self.spinnerColor = [UIColor colorWithWhite:0.55 alpha:1];
    self.textLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1];
}

- (void)commonInit
{
    [super commonInit];
    
    [self.lhSpinner addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)]];
}

- (void)showSuccess
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [super showSuccessWithStatus:@"" animated:YES];
        [super hideAfterDelay:1.5];
    });
}

- (void)showSuccessWithStatus:(NSString *)status
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [super showSuccessWithStatus:status animated:YES];
        [super hideAfterDelay:1.5];
    });
}

- (void)showFailure
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [super showFailureWithStatus:@"" animated:YES];
        [super hideAfterDelay:1.5];
    });
}

- (void)showFailureWithStatus:(NSString *)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super showFailureWithStatus:status animated:YES];
        [super hideAfterDelay:2.5];
    });
}

- (void)tapRecognized:(UITapGestureRecognizer *)recognizer
{
    if (self.dismissByTap && (recognizer.state == UIGestureRecognizerStateRecognized)) {
        [super hide];
    }
}
@end
