//
//  ColoredVKWindowController.m
//  ColoredVK2
//
//  Created by Даниил on 11.05.17.
//
//

#import "ColoredVKWindowController.h"
#import "PrefixHeader.h"
#import "ColoredVKNewInstaller.h"
#import "ColoredVKNightThemeColorScheme.h"

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
        _window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        _hideByTouch = YES;
        _statusBarNeedsHidden = YES;
        _animationDuration = 0.3;
        _backgroundStyle = ColoredVKWindowBackgroundStyleDarkened;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroundView = self.backgroundView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.contentViewWantsShadow) {
        self.contentView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds 
                                                                       cornerRadius:self.contentView.layer.cornerRadius].CGPath;
        self.contentView.layer.shadowOpacity = 0.1f;
    }
}


#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setContentViewWantsShadow:(BOOL)contentViewWantsShadow
{
    _contentViewWantsShadow = contentViewWantsShadow;
    
    self.contentView.layer.shadowRadius = 4.0f;
    self.contentView.layer.shadowOffset = CGSizeMake(0, 3);
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.contentView.layer.shouldRasterize = YES;
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
    if (self.isViewLoaded) {
        if (_backgroundView && [self.view.subviews containsObject:_backgroundView])
            [_backgroundView removeFromSuperview];
    }
    
    if (_backgroundStyle == ColoredVKWindowBackgroundStyleBlurred) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:effect];
    } 
    else if ((_backgroundStyle == ColoredVKWindowBackgroundStyleDarkened) || !backgroundView) {
        _backgroundView = self.defaultBackgroundView;
    } 
    else if (_backgroundStyle == ColoredVKWindowBackgroundStyleCustom) {
        _backgroundView = backgroundView;
    }
    
    [_backgroundView addGestureRecognizer:_closeTapRecognizer];
    _backgroundView.userInteractionEnabled = YES;
    
    if (self.isViewLoaded) {
        _backgroundView.frame = self.view.bounds;
        [self.view insertSubview:_backgroundView atIndex:0];
        
        _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 
                                                                          metrics:nil views:@{@"view":_backgroundView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0
                                                                          metrics:nil views:@{@"view":_backgroundView}]];
    } else {
        _backgroundView.frame = [UIScreen mainScreen].bounds;
    }
}

- (void)setContentView:(UIView *)contentView
{
    if (self.isViewLoaded) {
        if (self.view.subviews.count > 1 && [self.view.subviews[1] isEqual:self.contentView])
            [self.contentView removeFromSuperview];
    }
    
    _contentView = contentView;
    
    if (self.isViewLoaded && contentView) {
        [self.view insertSubview:self.contentView atIndex:1];
    }
}

- (void)setupDefaultContentView
{
    self.contentView = [UIView new];
    self.contentViewWantsShadow = YES;
    
    ColoredVKNightThemeColorScheme *nightThemeColorScheme = [ColoredVKNightThemeColorScheme sharedScheme];
    BOOL isVKApp = [ColoredVKNewInstaller sharedInstaller].application.isVKApp;
    if (isVKApp && nightThemeColorScheme.enabled)
        self.contentView.backgroundColor = nightThemeColorScheme.foregroundColor;
    else
        self.contentView.backgroundColor = [UIColor whiteColor];
    
    CGFloat widthFromEdge = IS_IPAD ? 20.0f : 6.0f;
    self.contentView.frame = (CGRect){{widthFromEdge, 0}, {self.view.frame.size.width - widthFromEdge*2, self.view.frame.size.height - widthFromEdge*10}};
    self.contentView.center = self.view.center;
    self.contentView.layer.cornerRadius = 20.0f;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILayoutGuide *guide = self.view.layoutMarginsGuide;
    CGFloat topConstant = 24.0f;
    CGFloat bottomConstant = -24.0f;
    CGFloat leftConstant = -8.0f;
    CGFloat rightConstant = 8.0f;
    
    if (@available(iOS 11.0, *)) {
        guide = self.view.safeAreaLayoutGuide;
        topConstant = 20.0f;
        bottomConstant = -20.0f;
        leftConstant = 8.0f;
        rightConstant = -8.0f;
    }
    
    if (IS_IPAD) {
        topConstant = widthFromEdge * 3.0f;
        bottomConstant = -topConstant;
        leftConstant = topConstant;
        rightConstant = -topConstant;
    }
    
    [self.contentView.topAnchor constraintEqualToAnchor:guide.topAnchor constant:topConstant].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor constant:bottomConstant].active = YES;
    [self.contentView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor constant:leftConstant].active = YES;
    [self.contentView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor constant:rightConstant].active = YES;
}


#pragma mark -
#pragma mark Getters
#pragma mark -

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

- (UIView *)backgroundView
{    
    if (!_backgroundView) {
        _backgroundView = self.defaultBackgroundView;
    }
    
    return _backgroundView;
}

- (UIView *)defaultBackgroundView
{
    UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    backView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    [backView addGestureRecognizer:self.closeTapRecognizer];
    
    return backView;
}

- (UITapGestureRecognizer *)closeTapRecognizer
{
    if (!_closeTapRecognizer) {
        _closeTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        _closeTapRecognizer.delegate = self;
    }
    return _closeTapRecognizer;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.backgroundView] && self.hideByTouch)
        return YES;
    
    return NO;
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


#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)show
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.view.backgroundColor = [UIColor clearColor];
        
        self.window.rootViewController = self;
        self.window.alpha = 0.0f;
        [self.window makeKeyAndVisible];
        [UIView animateWithDuration:self.animationDuration delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.window.alpha = 1.0f;
        } completion:^(BOOL finished) {
            self.isPresented = YES;
            
            [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                [self setNeedsStatusBarAppearanceUpdate];
            } completion:nil];
        }];
    });
}

- (void)hide
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:self.animationDuration delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.window.alpha = 0.0f;
        } completion:^(BOOL firstFinished) {
            self.isPresented = NO;
            
            [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                [self setNeedsStatusBarAppearanceUpdate];
            } completion:^(BOOL secondFinished) {
                self.window.hidden = YES;
                self->_window = nil;
            }];
        }];
    });
}

@end
