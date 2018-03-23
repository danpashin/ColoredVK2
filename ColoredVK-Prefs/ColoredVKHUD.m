//
//  ColoredVKHUD.m
//  ColoredVK
//
//  Created by Даниил on 21/01/2017.
//
//

#import "ColoredVKHUD.h"
#import "ColoredVKNightThemeColorScheme.h"
#import "LHAcvitityIndicator.h"

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
        
    }
    return self;
}

- (void)commonInit
{
    [super commonInit];
    
    ColoredVKNightThemeColorScheme *nightScheme = [ColoredVKNightThemeColorScheme sharedScheme];
    self.centerBackgroundView.blurStyle = nightScheme.enabled ? LHBlurEffectStyleDark : LHBlurEffectStyleExtraLight;
    self.centerBackgroundView.backgroundColor = [UIColor colorWithWhite:nightScheme.enabled ? 0.0f : 1.0f alpha:0.7f];
    self.centerBackgroundView.layer.cornerRadius = 10.0f;
    self.infoColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    self.spinnerColor = [UIColor colorWithWhite:0.55f alpha:1.0f];
    self.textLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
}

- (void)showSuccess
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [super showSuccessWithStatus:@"" animated:YES];
        [super hideAfterDelay:1.5f];
    });
}

- (void)showSuccessWithStatus:(NSString *)status
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [super showSuccessWithStatus:status animated:YES];
        [super hideAfterDelay:1.5f];
    });
}

- (void)showFailure
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        [super showFailureWithStatus:@"" animated:YES];
        [super hideAfterDelay:1.5f];
    });
}

- (void)showFailureWithStatus:(NSString *)status
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super showFailureWithStatus:status animated:YES];
        [super hideAfterDelay:2.8f];
    });
}

- (void)hide
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.lhSpinner isKindOfClass:[LHAcvitityIndicator class]])
            [(LHAcvitityIndicator *)self.lhSpinner updateToSuccess:NO];
        [super hide];
    });
}

- (void)hideAfterDelay:(CGFloat)delay
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super hideAfterDelay:delay];
    });
}

@end
