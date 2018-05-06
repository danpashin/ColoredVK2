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

- (void)commonInit NS_REQUIRES_SUPER;
@end


@interface LHAcvitityIndicator ()
@property (strong, nonatomic) CAShapeLayer *layerFirst;
@property (strong, nonatomic) CAShapeLayer *layerSecond;
@property (strong, nonatomic) CAShapeLayer *thridLayer;
@property (assign, nonatomic) BOOL shouldStop;
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
    __block UIView *localView = view;
    __block typeof(self) localSelf = self;
    
    [self performBlockOnMainThread:^{
        if (!localView)
            localView = [UIApplication sharedApplication].keyWindow;
        
        NSInteger tag = 771177892;
        UIView *tagView = [localView viewWithTag:tag];
        if (tagView && [tagView isKindOfClass:[self class]]) {
            localView = tagView;
            return;
        }
        
        localSelf = [self initWithAttachedView:localView mode:LHProgressHUDModeNormal subMode:LHProgressHUDSubModeAnimating animated:YES];
        localSelf.tag = tag;
    }];
    
    return localSelf;
}

- (void)commonInit
{
    [super commonInit];
    
    ColoredVKNightThemeColorScheme *nightScheme = [ColoredVKNightThemeColorScheme sharedScheme];
    self.centerBackgroundView.blurStyle = nightScheme.enabled ? LHBlurEffectStyleDark : LHBlurEffectStyleExtraLight;
    self.centerBackgroundView.backgroundColor = [UIColor colorWithWhite:nightScheme.enabled ? 0.0f : 1.0f alpha:0.7f];
    self.centerBackgroundView.layer.cornerRadius = 10.0f;
    self.infoColor = [UIColor colorWithWhite:nightScheme.enabled ? 1.0f : 0.0f alpha:0.5f];
    self.spinnerColor = [UIColor colorWithWhite:0.55f alpha:1.0f];
    self.textLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSpinner) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startSpinner) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)stopSpinner
{
    [self performBlockOnMainThread:^{
        if ([self.lhSpinner isKindOfClass:[LHAcvitityIndicator class]]) {
            LHAcvitityIndicator *activityIndicator = (LHAcvitityIndicator *)self.lhSpinner;
            activityIndicator.shouldStop = YES;
            [activityIndicator.layerFirst removeAllAnimations];
            [activityIndicator.layerSecond removeAllAnimations];
            [activityIndicator.thridLayer removeAllAnimations];
        }
    }];
}

- (void)startSpinner
{
    [self performBlockOnMainThread:^{
        if (self.subMode == LHProgressHUDSubModeAnimating && [self.lhSpinner isKindOfClass:[LHAcvitityIndicator class]]) {
            [(LHAcvitityIndicator *)self.lhSpinner startAnimating];
        }
    }];
}

- (void)showSuccess
{
    [self performBlockOnMainThread:^{
        [super showSuccessWithStatus:@"" animated:YES];
        [super hideAfterDelay:1.5f];
    }];
}

- (void)showSuccessWithStatus:(NSString *)status
{
    [self performBlockOnMainThread:^{
        [super showSuccessWithStatus:status animated:YES];
        [super hideAfterDelay:1.5f];
    }];
}

- (void)showFailure
{
    [self performBlockOnMainThread:^{
        [super showFailureWithStatus:@"" animated:YES];
        [super hideAfterDelay:1.5f];
    }];
}

- (void)showFailureWithStatus:(NSString *)status
{
    [self performBlockOnMainThread:^{
        [super showFailureWithStatus:status animated:YES];
        [super hideAfterDelay:2.8f];
    }];
}

- (void)hide
{
    [self performBlockOnMainThread:^{
        [self stopSpinner];
        [super hide];
    }];
}

- (void)hideAfterDelay:(CGFloat)delay
{
    [self performBlockOnMainThread:^{
        [super hideAfterDelay:delay];
    }];
}

- (void)performBlockOnMainThread:( void(^_Nonnull)(void) )block
{
    [NSThread isMainThread] ? block() : dispatch_sync(dispatch_get_main_queue(), block);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
