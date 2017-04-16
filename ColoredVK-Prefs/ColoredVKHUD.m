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
    return [[self alloc] initHUDWithOperation:nil andView:nil];
}

+ (instancetype)showHUDForView:(UIView *)view
{
    return [[self alloc] initHUDWithOperation:nil andView:view];
}

+ (instancetype)showHUDForOperation:(NSOperation *)operation
{
    return [[self alloc] initHUDWithOperation:operation andView:nil];
}

+ (instancetype)showHUDForOperation:(NSOperation *)operation andView:(UIView *)view
{
    return [[self alloc] initHUDWithOperation:operation andView:view];
}

- (instancetype)initHUDWithOperation:(NSOperation *)operation andView:(UIView *)view
{
    if (!view) view = UIApplication.sharedApplication.keyWindow.rootViewController.view;
//    UIWindow *hudWindow = [[UIWindow alloc] initWithFrame:view.bounds]
    self = [super initWithAttachedView:view mode:LHProgressHUDModeNormal subMode:LHProgressHUDSubModeAnimating animated:YES];
    if (self) {
        self.operation = operation;
        [self setupHUD];
    }
    return self;
}

- (void)setupHUD
{
    self.centerBackgroundView.blurStyle = LHBlurEffectStyleExtraLight;
    self.centerBackgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
    self.centerBackgroundView.layer.cornerRadius = 10;
    self.infoColor = [UIColor colorWithWhite:0.55 alpha:1];
    self.spinnerColor = [UIColor colorWithWhite:0.55 alpha:1];
    self.textLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1];
}

- (void)setOperation:(NSOperation *)operation
{
    _operation = operation;
    
    if (self.operation) {
        [self.operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:nil];
        [self.operation start];
    }
}


- (void)commonInit
{
    [super commonInit];
    
    [self.lhSpinner addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)]];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([object isKindOfClass:[NSBlockOperation class]] && [keyPath isEqualToString:@"isFinished"]) {
        if ([change[@"new"] boolValue]) [self showSuccess];
    }
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
        [super hideAfterDelay:2.5];
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

- (void)dealloc
{
    [self.operation removeObserver:self forKeyPath:@"isFinished"];
}

- (void)tapRecognized:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        if (self.operation && !self.operation.isFinished) [self.operation cancel];
        [super hide];
    }
}
@end
