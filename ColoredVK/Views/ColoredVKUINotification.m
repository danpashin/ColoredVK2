//
//  ColoredVKUINotification.m
//  ColoredVK
//
//  Created by Даниил on 13.04.18.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "ColoredVKUINotification.h"
#import "ColoredVKNightScheme.h"
#import "ColoredVKShadowView.h"

static CGFloat const kCVKUINotificationHeight = 100.0f;

@interface ColoredVKUINotification ()
@property (assign, nonatomic) BOOL dismissed;
@property (strong, nonatomic) NSTimer *dismissTimer;
@property (copy, nonatomic) void (^tapHandler)(void);

@property (weak, nonatomic) NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) NSLayoutConstraint *heightConstraint;

@property (strong, nonatomic) UIStackView *mainStackView;
@property (strong, nonatomic) UIStackView *titleStackView;

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIVisualEffectView *blurView;
@property (strong, nonatomic) ColoredVKShadowView *shadowView;

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UIImageView *iconView;


@end

@implementation ColoredVKUINotification

+ (void)showWithSubtitle:(NSString *)subtitle
{
    [self showWithTitle:kPackageName subtitle:subtitle tapHandler:nil];
}

+ (void)showWithSubtitle:(NSString *)subtitle tapHandler:(void (^)(void))tapHandler
{
    [self showWithTitle:kPackageName subtitle:subtitle tapHandler:tapHandler];
}

+ (void)showWithTitle:(NSString *)title subtitle:(NSString *)subtitle
{
    [self showWithTitle:title subtitle:subtitle tapHandler:nil];
}

+ (void)showWithTitle:(NSString *)title subtitle:(NSString *)subtitle tapHandler:(void (^)(void))tapHandler
{
    [self removeAllNotifications];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        ColoredVKUINotification *notification = [[ColoredVKUINotification alloc] initWithTitle:title subtitle:subtitle tapHandler:tapHandler];
        [notification show];
    });
}

+ (void)removeAllNotifications
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        for (ColoredVKUINotification *subview in window.subviews) {
            if ([subview isKindOfClass:[ColoredVKUINotification class]]) {
                [subview dismiss];
            }
        }
    });
}

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle tapHandler:(void (^)(void))tapHandler
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect frame = CGRectMake(0, 0, screenSize.width, kCVKUINotificationHeight);
    self = [super initWithFrame:frame];
    if (self) {
        if (tapHandler)
            self.tapHandler = [tapHandler copy];
        
        CGFloat widthMultiplier = IS_IPAD ? 0.6f : 0.95f;
        self.contentView = [[UIView alloc] init];
        self.contentView.frame = CGRectMake(0, 0, widthMultiplier * MIN(screenSize.width, screenSize.height), 0.8f * CGRectGetHeight(frame));
        [self addSubview:self.contentView];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
        [self.contentView addGestureRecognizer:panRecognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized)];
        [self.contentView addGestureRecognizer:tapRecognizer];
        
        
        self.shadowView = [ColoredVKShadowView shadowWithFrame:self.contentView.bounds size:10.0f cornerRadius:14.0f offset:2.0f];
        [self.contentView addSubview:self.shadowView];
        
        UIBlurEffectStyle blurStyle = [ColoredVKNightScheme sharedScheme].enabled ? UIBlurEffectStyleDark : UIBlurEffectStyleLight;
        self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:blurStyle]];
        self.blurView.frame = self.contentView.bounds;
        self.blurView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.4f];
        self.blurView.layer.cornerRadius = self.shadowView.cornerRadius;
        self.blurView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.blurView];
        
        
        self.mainStackView = [[UIStackView alloc] initWithFrame:self.contentView.bounds];
        self.mainStackView.axis = UILayoutConstraintAxisVertical;
        self.mainStackView.spacing = 4.0f;
        [self.blurView.contentView addSubview:self.mainStackView];
        
        
        self.titleStackView = [[UIStackView alloc] initWithFrame:self.mainStackView.bounds];
        self.titleStackView.axis = UILayoutConstraintAxisHorizontal;
        self.titleStackView.spacing = 8.0f;
        [self.mainStackView addArrangedSubview:self.titleStackView];
        
        self.iconView = [[UIImageView alloc] init];
        self.iconView.image = CVKImage(@"Icon");
        self.iconView.layer.masksToBounds = YES;
        self.iconView.layer.cornerRadius = 6.0f;
        [self.titleStackView addArrangedSubview:self.iconView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.text = title;
        self.titleLabel.textColor = [UIColor colorWithWhite:0.0f alpha:0.9f];
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        [self.titleStackView addArrangedSubview:self.titleLabel];
        
        
        self.detailLabel = [[UILabel alloc] init];
        self.detailLabel.text = subtitle;
        self.detailLabel.textColor = [UIColor darkGrayColor];
        self.detailLabel.numberOfLines = 2;
        self.detailLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        [self.mainStackView addArrangedSubview:self.detailLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDismiss) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)show
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    });
}


- (void)dismiss
{
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated
{
    self.dismissed = YES;
    if (self.dismissTimer)
        [self.dismissTimer invalidate];
    
    if (animated) {
        [self moveToYposition:-self.heightConstraint.constant completion:^{
            [self removeFromSuperview];
        }];
    } else {
        self.topConstraint.constant = -self.heightConstraint.constant;
        [self removeFromSuperview];
    }
}

- (void)dismissAfterDelay:(NSTimeInterval)delay
{
    if (self.dismissTimer)
        [self.dismissTimer invalidate];
    
    self.dismissTimer = [NSTimer timerWithTimeInterval:delay target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.dismissTimer forMode:NSRunLoopCommonModes];
}

- (void)notificationDismiss
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissAnimated:NO];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark Private
#pragma mark -

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.dismissed || !self.window)
        return;
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self.leadingAnchor constraintEqualToAnchor:self.superview.leadingAnchor].active = YES;
    [self.trailingAnchor constraintEqualToAnchor:self.superview.trailingAnchor].active = YES;
    self.heightConstraint = [self.heightAnchor constraintEqualToConstant:CGRectGetHeight(self.frame)];
    self.heightConstraint.active = YES;
    self.topConstraint = [self.topAnchor constraintEqualToAnchor:self.superview.topAnchor constant:-self.heightConstraint.constant];
    self.topConstraint.active = YES;
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.contentView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [self.contentView.widthAnchor constraintEqualToConstant:CGRectGetWidth(self.contentView.frame)].active = YES;
    [self.contentView.heightAnchor constraintEqualToConstant:CGRectGetHeight(self.contentView.frame)].active = YES;
    
    
    NSDictionary *shadowMetrics = @{@"size":@(-self.shadowView.size)};
    self.shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.shadowView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-size-[view]-size-|" options:0 
                                                                                      metrics:shadowMetrics views:@{@"view":self.shadowView}]];
    [self.shadowView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-size-[view]-size-|" options:0 
                                                                                      metrics:shadowMetrics views:@{@"view":self.shadowView}]];
    
    
    self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.blurView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 
                                                                                    metrics:nil views:@{@"view":self.blurView}]];
    [self.blurView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 
                                                                                    metrics:nil views:@{@"view":self.blurView}]];
    
    self.mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainStackView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]-|" options:0 
                                                                                         metrics:nil views:@{@"view":self.mainStackView}]];
    [self.mainStackView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 
                                                                                         metrics:nil views:@{@"view":self.mainStackView}]];
    
    self.titleStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titleStackView.heightAnchor constraintEqualToConstant:28.0f].active = YES;
    
    self.iconView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.iconView.widthAnchor constraintEqualToConstant:28.0f].active = YES;
    [self.iconView.centerYAnchor constraintEqualToAnchor:self.titleStackView.centerYAnchor].active = YES;
    self.iconView.hidden = !self.iconView.image;
    
    [self moveToYposition:0.0f completion:nil];
    [self dismissAfterDelay:5.0f];
}

- (void)moveToYposition:(CGFloat)yPosition completion:( void(^)(void) )completion
{
    @synchronized(self) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __block CGRect selfFrame = self.frame;
            selfFrame.origin.y = yPosition;
            
            [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseOut animations:^{
                self.frame = selfFrame;
            } completion:^(BOOL finished) {
                self.topConstraint.constant = yPosition;
                if (completion)
                    completion();
            }];
        });
    }
}

- (void)panRecognized:(UIPanGestureRecognizer *)panRecognizer
{
    if (self.dismissed)
        return;
    
    if ((panRecognizer.state == UIGestureRecognizerStateBegan) && self.dismissTimer) {
        [self.dismissTimer invalidate];
    } else if (panRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint panPoint = [panRecognizer translationInView:self.superview];        
        if (panPoint.y < 0) {
            self.topConstraint.constant += panPoint.y;
            if (fabs(panPoint.y) < self.heightConstraint.constant/2) {
                [self dismiss];
            }
        } else if (panPoint.y == 0) {
            self.topConstraint.constant = 0;
        }
    } else if (panRecognizer.state == UIGestureRecognizerStateEnded) {
        [self moveToYposition:0 completion:nil];
    }
}

- (void)tapRecognized
{
    [self dismiss];
    
    if (self.tapHandler)
        self.tapHandler();
}

@end
