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
        self.hideByTouch = YES;
        self.statusBarNeedsHidden = YES;
        self.animationDuration = 0.3;
        self.backgroundStyle = ColoredVKWindowBackgroundStyleDarkened;
        
        
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
        self.contentView.layer.shadowRadius = 4.0f;
        self.contentView.layer.shadowOpacity = 0.1f;
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
    self.backgroundView.tag = 2;
    if (self.view.subviews.count > 0 && (self.view.subviews[0].tag == 2)) [self.view.subviews[0] removeFromSuperview];
    
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
    
    self.contentView.tag = 3;
    if (self.view.subviews.count > 1 && (self.view.subviews[1].tag != 3)) [self.view.subviews[1] removeFromSuperview];
    
    [self.view insertSubview:self.contentView atIndex:1];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{    
    if ([touch.view isDescendantOfView:self.backgroundView] && self.hideByTouch) return YES;
    return NO;
}

- (void)setupDefaultContentView
{
    self.contentView = [UIView new];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentViewWantsShadow = YES;
    
    int widthFromEdge = IS_IPAD?20:6;
    self.contentView.frame = (CGRect){{widthFromEdge, 0}, {self.view.frame.size.width - widthFromEdge*2, self.view.frame.size.height - widthFromEdge*10}};
    self.contentView.center = self.view.center;
    self.contentView.layer.cornerRadius = 16;
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-fromEdge-[contentView]-fromEdge-|" options:0 metrics:@{@"fromEdge":@(widthFromEdge*4)} views:@{@"contentView":self.contentView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-fromEdge-[contentView]-fromEdge-|" options:0 metrics:@{@"fromEdge":IS_IPAD?@(widthFromEdge*3):@(widthFromEdge)}
                                                                        views:@{@"contentView":self.contentView}]];
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
        
        navigationBar.items = @[navItem];
        
        _contentViewNavigationBar = navigationBar;
    }
    
    return _contentViewNavigationBar;
}

@end
