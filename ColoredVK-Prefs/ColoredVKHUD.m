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
        _dismissByTap = NO;
        self.centerBackgroundView.blurStyle = LHBlurEffectStyleExtraLight;
        self.centerBackgroundView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.7f];
        self.centerBackgroundView.layer.cornerRadius = 10.0f;
        self.infoColor = [UIColor colorWithWhite:0.55f alpha:1.0f];
        self.spinnerColor = [UIColor colorWithWhite:0.55f alpha:1.0f];
        self.textLabel.textColor = [UIColor colorWithWhite:0.55f alpha:1.0f];
        
        ColoredVKNightThemeColorScheme *nightScheme = [ColoredVKNightThemeColorScheme sharedScheme];
        if (nightScheme.enabled) {
            self.centerBackgroundView.blurStyle = LHBlurEffectStyleDark;
            self.centerBackgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.7f];
        }
    }
    return self;
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
            [(LHAcvitityIndicator *)self.lhSpinner updateToInfo:NO];
        [super hide];
    });
}

- (void)hideAfterDelay:(CGFloat)delay
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super hideAfterDelay:delay];
    });
}

- (void)hideAfterDelay:(CGFloat)delay hiddenBlock:(void (^)(void))hiddenBlock
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super hideAfterDelay:delay hiddenBlock:hiddenBlock];
    });
}

- (void)tapRecognized:(UITapGestureRecognizer *)recognizer
{
    if (self.dismissByTap && (recognizer.state == UIGestureRecognizerStateRecognized)) {
        [super hide];
    }
}

@end
