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
@property (strong, nonatomic) UITapGestureRecognizer *closeTapRecognizer;

@end


@implementation ColoredVKWindowController

@synthesize backgroundView = _backgroundView;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _hideByTouch = YES;
        _statusBarNeedsHidden = YES;
        _animationDuration = 0.3;
        _backgroundStyle = ColoredVKWindowBackgroundStyleDarkened;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    if (self.isPresented)
        return self.statusBarNeedsHidden;
    
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.contentViewWantsShadow) {
        self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds cornerRadius:self.contentView.layer.cornerRadius].CGPath;
        self.contentView.layer.shadowOpacity = 0.1f;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    _window.rootViewController = self;
    
    self.backgroundView = [UIView new];
    self.backgroundView.frame = self.view.bounds;
    [self.view addSubview:self.backgroundView];
    
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.backgroundView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":self.backgroundView}]];
    
    if (self.contentViewWantsShadow) {
        self.contentView.layer.shadowRadius = 4.0f;
        self.contentView.layer.shadowOffset = CGSizeMake(0, 3);
        self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.contentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.contentView.layer.shouldRasterize = YES;
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
}


- (void)setBackgroundView:(UIView *)backgroundView
{
    if (self.backgroundStyle == ColoredVKWindowBackgroundStyleBlurred) {
        _backgroundView = [[UIVisualEffectView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        ((UIVisualEffectView *)_backgroundView).effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    } else if (self.backgroundStyle == ColoredVKWindowBackgroundStyleDarkened) {
        _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    } else if (self.backgroundStyle == ColoredVKWindowBackgroundStyleCustom) {
        _backgroundView = backgroundView;
    }
    
    [self.backgroundView addGestureRecognizer:self.closeTapRecognizer];
}

- (UIView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self.backgroundView addGestureRecognizer:self.closeTapRecognizer];
    }
    
    return _backgroundView;
}

- (UITapGestureRecognizer *)closeTapRecognizer
{
    if (!_closeTapRecognizer) {
        _closeTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        _closeTapRecognizer.delegate = self;
    }
    return _closeTapRecognizer;
}

- (void)setContentView:(UIView *)contentView
{
    _contentView = contentView;
    
    if (self.view.subviews.count > 1 && [self.view.subviews[1] isEqual:self.contentView])
        [self.view.subviews[1] removeFromSuperview];
    
    [self.view insertSubview:self.contentView atIndex:1];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{    
    if ([touch.view isDescendantOfView:self.backgroundView] && self.hideByTouch)
        return YES;
    
    return NO;
}

- (void)setupDefaultContentView
{
    self.contentView = [UIView new];
    self.contentViewWantsShadow = YES;
    if (self.app_is_vk && self.enableNightTheme)
        self.contentView.backgroundColor = self.nightThemeColorScheme.foregroundColor;
    else
        self.contentView.backgroundColor = [UIColor whiteColor];
    
    int widthFromEdge = IS_IPAD?20:6;
    self.contentView.frame = (CGRect){{widthFromEdge, 0}, {self.view.frame.size.width - widthFromEdge*2, self.view.frame.size.height - widthFromEdge*10}};
    self.contentView.center = self.view.center;
    self.contentView.layer.cornerRadius = 20;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (@available(iOS 11.0, *)) {
        UILayoutGuide *guide = self.view.safeAreaLayoutGuide;
        
        [self.contentView.topAnchor constraintEqualToSystemSpacingBelowAnchor:guide.topAnchor multiplier:1.0f].active = YES;
        
        NSLayoutConstraint *bottomConstraint = [self.contentView.bottomAnchor constraintEqualToSystemSpacingBelowAnchor:guide.bottomAnchor multiplier:1.0f];
        bottomConstraint.constant = -(widthFromEdge*3);
        bottomConstraint.active = YES;
        
        NSLayoutConstraint *leftConstraint = [self.contentView.leadingAnchor constraintEqualToSystemSpacingAfterAnchor:guide.leadingAnchor multiplier:1.0f];
        leftConstraint.constant = widthFromEdge;
        leftConstraint.active = YES;
        
        NSLayoutConstraint *rightConstraint = [self.contentView.trailingAnchor constraintEqualToSystemSpacingAfterAnchor:guide.trailingAnchor multiplier:1.0];
        rightConstraint.constant = -widthFromEdge;
        rightConstraint.active = YES;
    } else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-fromEdge-[contentView]-fromEdge-|" options:0 
                                                                          metrics:@{@"fromEdge":@(widthFromEdge*4)} views:@{@"contentView":self.contentView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-fromEdge-[contentView]-fromEdge-|" options:0 
                                                                          metrics:@{@"fromEdge":IS_IPAD?@(widthFromEdge*3):@(widthFromEdge)} views:@{@"contentView":self.contentView}]];
    }
}

- (UINavigationBar *)contentViewNavigationBar
{
    if (!_contentViewNavigationBar) {
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 44)];
        [navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        navigationBar.shadowImage = [UIImage new];
        
        UINavigationItem *navItem = [[UINavigationItem alloc] init];    
        UIImage *closeImage = [UIImage imageNamed:@"CloseIcon" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil];
        closeImage = [closeImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:closeImage style:UIBarButtonItemStylePlain target:self action:@selector(hide)];
        navItem.rightBarButtonItem.accessibilityLabel = CVKLocalizedString(@"Dismiss");
        
        navigationBar.items = @[navItem];
        
        _contentViewNavigationBar = navigationBar;
    }
    
    return _contentViewNavigationBar;
}

@end
