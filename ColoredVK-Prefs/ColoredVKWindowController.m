//
//  ColoredVKWindowController.m
//  ColoredVK2
//
//  Created by Даниил on 11.05.17.
//
//

#import "ColoredVKWindowController.h"
#import "PrefixHeader.h"

@interface ColoredVKWindowController ()

@property (assign, nonatomic) BOOL isPresented;

@end


@implementation ColoredVKWindowController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _hideByTouch = YES;
        _statusBarNeedsHidden = YES;
        _animationDuration = 0.3;
        _backgroundStyle = ColoredVKWindowBackgroundStyleDarkened;
        
        
        _window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        self.window.rootViewController = self;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    if (self.isPresented) return self.statusBarNeedsHidden;
    
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationSlide;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.contentViewWantsShadow) {
        self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds cornerRadius:self.contentView.layer.cornerRadius].CGPath;
        self.contentView.layer.shadowRadius = 4;
        self.contentView.layer.shadowOffset = CGSizeMake(0, 3);
        self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.contentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.contentView.layer.shouldRasterize = YES;
        
        CGFloat shadowOpacity = 0.1;
        CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        shadowAnimation.fromValue = @0.0;
        shadowAnimation.toValue = @(shadowOpacity);
        shadowAnimation.duration = 1.0;
        [self.contentView.layer addAnimation:shadowAnimation forKey:@"shadowOpacity"];
        self.contentView.layer.shadowOpacity = shadowOpacity;
    }
}

- (void)show
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.view.backgroundColor = [UIColor clearColor];
        
        self.window.alpha = 0;
        [self.window makeKeyAndVisible];
        [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.window.alpha = 1;
        } completion:^(BOOL finished) {
            self.isPresented = YES;
            
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                [self setNeedsStatusBarAppearanceUpdate];
            } completion:nil];
        }];
    });
}

- (void)hide
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.window.alpha = 0;
        } completion:^(BOOL finished) {
            self.isPresented = NO;
            
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                [self setNeedsStatusBarAppearanceUpdate];
            } completion:^(BOOL finished) {
                self.window.hidden = YES;
                _window = nil;
            }];
        }];
    });
}


- (void)setBackgroundStyle:(ColoredVKWindowBackgroundStyle)backgroundStyle
{
    if ( UIAccessibilityIsReduceTransparencyEnabled() && (backgroundStyle == ColoredVKWindowBackgroundStyleBlurred))
        _backgroundStyle = ColoredVKWindowBackgroundStyleDarkened;
    else
        _backgroundStyle = backgroundStyle;

    self.backgroundView = [UIView new];
}

- (void)setBackgroundView:(UIView *)backgroundView
{
    if (self.backgroundStyle == ColoredVKWindowBackgroundStyleBlurred) {
        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    } else if (self.backgroundStyle == ColoredVKWindowBackgroundStyleDarkened) {
        _backgroundView = [UIView new];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    } else if (self.backgroundStyle == ColoredVKWindowBackgroundStyleCustom) {
        _backgroundView = backgroundView;
    }
    
    self.backgroundView.frame = self.view.bounds;
    [self.view insertSubview:self.backgroundView atIndex:0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    tap.delegate = self;
    [self.backgroundView addGestureRecognizer:tap];
    
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.backgroundView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":self.backgroundView}]];
}

- (void)setContentView:(UIView *)contentView
{
    _contentView = contentView;
    
    [self.view insertSubview:self.contentView atIndex:1];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{    
    if ([touch.view isDescendantOfView:self.backgroundView] && self.hideByTouch) return YES;
    return NO;
}

@end
