//
//  ColoredVKWallpaperView.m
//  ColoredVK
//
//  Created by Даниил on 07/11/16.
//
//

#import "ColoredVKWallpaperView.h"
#import "PrefixHeader.h"

const NSInteger PARALLAX_EFFECT_VALUE = 20;
const NSTimeInterval ANIMATION_DURANTION = 0.2;

@interface ColoredVKWallpaperView ()

@property (strong, nonatomic) UIView *frontView;
@property (strong, nonatomic) _UIBackdropView *blurView;

@end

@implementation ColoredVKWallpaperView

@synthesize blurStyle = _blurStyle;

+ (instancetype)viewWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout
{
    return [[self alloc] initWithFrame:frame imageName:name blackout:blackout enableParallax:NO blurBackground:NO];
}

- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout 
               enableParallax:(BOOL)enableParallax blurBackground:(BOOL)blurBackground
{
    CGRect bounds = (![name isEqualToString:@"barImage"]) ? [UIScreen mainScreen].bounds : frame;
    
    self = [super initWithFrame:bounds];
    if (self) {
        self.tag = 23;
        self.backgroundColor = [UIColor blackColor];
        _name = name;
        
        
        _imageView = [[UIImageView alloc] init];
        self.imageView.backgroundColor = [UIColor blackColor];
        if ([name isEqualToString:@"barImage"])
            self.imageView.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
        else
            self.imageView.frame = CGRectMake(-20, -20, bounds.size.width + 40, bounds.size.height + 40);
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = YES;
        [self addSubview:_imageView];
        
        _blurView = [[_UIBackdropView alloc] initWithStyle:self.blurStyle];
        self.blurView.frame = bounds;
        [self addSubview:self.blurView];
        
        self.frontView = [[UIView alloc] initWithFrame:bounds];
        [self addSubview:self.frontView];
        
        self.blackout = blackout;
        self.parallaxEnabled = enableParallax;
        self.blurBackground = blurBackground;
        
        [self updateImage];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame imageName:@"" blackout:0.0f enableParallax:NO blurBackground:NO];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithFrame:CGRectZero imageName:@"" blackout:0.0f enableParallax:NO blurBackground:NO];
}

- (void)setParallaxEnabled:(BOOL)parallaxEnabled
{
    _parallaxEnabled = parallaxEnabled;
    
    if (parallaxEnabled && (self.imageView.motionEffects.count == 0)) {
        UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                            type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        verticalMotionEffect.minimumRelativeValue = @(-PARALLAX_EFFECT_VALUE);
        verticalMotionEffect.maximumRelativeValue = @(PARALLAX_EFFECT_VALUE);
        [self.imageView addMotionEffect:verticalMotionEffect];
        UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" 
                                                                                                              type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalMotionEffect.minimumRelativeValue = @(-PARALLAX_EFFECT_VALUE);
        horizontalMotionEffect.maximumRelativeValue = @(PARALLAX_EFFECT_VALUE);
        [self.imageView addMotionEffect:horizontalMotionEffect];
    } else {
        for (UIMotionEffect *effect in [self.imageView.motionEffects copy]) [self.imageView removeMotionEffect:effect];
    }
}

- (void)setFlip:(BOOL)flip
{
    [self setFlip:flip animated:NO];
}

- (void)setFlip:(BOOL)flip animated:(BOOL)animated
{
    _flip = flip;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat flipDegree = flip ? 180.0f : 0.0f;
        void (^flipBlock)(void) = ^{
            self.imageView.transform = CGAffineTransformMakeRotation((CGFloat)(flipDegree * M_PI/180.0f));
        };
        
        if (animated) [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction 
                                       animations:flipBlock completion:nil];
        else          flipBlock();
    });
}

- (void)setBlackout:(CGFloat)blackout
{
    [self setBlackout:blackout animated:NO];
}

- (void)setBlackout:(CGFloat)blackout animated:(BOOL)animated
{
    _blackout = blackout;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        void (^blackoutBlock)(void) = ^{
            self.frontView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:blackout];
        };
        
        if (animated) [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction 
                                       animations:blackoutBlock completion:nil];
        else          blackoutBlock();
    });
}

- (void)setBlurBackground:(BOOL)blurBackground
{
    [self setBlurBackground:blurBackground animated:NO];
}

- (void)setBlurBackground:(BOOL)blurBackground animated:(BOOL)animated
{
    _blurBackground = blurBackground;
    
    if (UIAccessibilityIsReduceTransparencyEnabled()) {
        self.blurView.alpha = 0.0f;
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        void (^blurBlock)(void) = ^{
            self.blurView.alpha = self.blurBackground ? 1.0f : 0.0f;
            self.blurView.backgroundColor = self.blurTone;
            [self.blurView transitionToStyle:self.blurStyle];
        };
        
        if (animated) [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction 
                                       animations:blurBlock completion:nil];
        else          blurBlock();
    });
}

- (void)setBlurStyle:(_UIBackdropViewStyle)blurStyle
{
    _blurStyle = blurStyle;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.blurView transitionToStyle:blurStyle];
    });
}

- (_UIBackdropViewStyle)blurStyle
{
    if (!_blurStyle) {
        _blurStyle = _UIBackdropViewStyleBlur;
    }
    return _blurStyle;
}

- (void)updateViewWithBlackout:(CGFloat)blackout
{
    [self setBlackout:blackout animated:YES];
    [self updateImage];
}

- (void)updateImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", CVK_FOLDER_PATH, self.name]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                self.imageView.image = image;
            } completion:nil];
        });
    });
}


#pragma mark -

- (void)addToView:(UIView *)view animated:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![view.subviews containsObject:[view viewWithTag:self.tag]] && view) {
            void (^block)(void) = ^{
                self.alpha = 0;
                [view addSubview:self];
                [self setupConstraints];
                self.alpha = 1;
            };
            if (animated)
                [UIView transitionWithView:view duration:ANIMATION_DURANTION options:UIViewAnimationOptionAllowUserInteraction 
                                animations:block completion:nil];
            else
                block();
            
            if ([view isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
                for (UIView *subview in view.subviews) {
                    if ([subview isKindOfClass:[UIVisualEffectView class]]) subview.hidden = YES;
                }
            }
            
        }
    });
}

- (void)addToBack:(UIView *)view animated:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![view.subviews containsObject:[view viewWithTag:self.tag]] && view) {
            void (^block)(void) = ^{
                self.alpha = 0;
                [view addSubview:self];
                [view sendSubviewToBack:self];
                [self setupConstraints];
                self.alpha = 1;
            };
            if (animated)
                [UIView transitionWithView:view duration:ANIMATION_DURANTION options:UIViewAnimationOptionAllowUserInteraction 
                                animations:block completion:nil];
            else
                block();
        }
    });
}

- (void)addToFront:(UIView *)view animated:(BOOL)animated
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![view.subviews containsObject:[view viewWithTag:self.tag]] && view) {
            void (^block)(void) = ^{
                self.alpha = 0;
                [view addSubview:self];
                [view bringSubviewToFront:self];
                [self setupConstraints];
                self.alpha = 1;
            };
            if (animated)
                [UIView transitionWithView:view duration:ANIMATION_DURANTION options:UIViewAnimationOptionAllowUserInteraction
                                          animations:block completion:nil];
            else
                block();
        }
    });
}

- (void)setupConstraints
{
    if (self.superview) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self}]];
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":self}]];
    }
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:@{@"imageView":self.imageView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:@{@"imageView":self.imageView}]];
    
    self.frontView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[frontView]|" options:0 metrics:nil views:@{@"frontView":self.frontView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[frontView]|" options:0 metrics:nil views:@{@"frontView":self.frontView}]];
    
    self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurView]|" options:0 metrics:nil views:@{@"blurView":self.blurView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|" options:0 metrics:nil views:@{@"blurView":self.blurView}]];
}

- (void)removeFromSuperview
{
    if ([self.superview isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
        for (UIView *subview in self.superview.subviews) {
            if ([subview isKindOfClass:[UIVisualEffectView class]]) subview.hidden = NO;
        }
    }
    
    [super removeFromSuperview];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, imageName '%@', blackout %.2f, parallax '%@'>", [self class], self, 
            self.name, self.blackout, self.parallaxEnabled ? @"Enabled": @"Disabled"];
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    ColoredVKWallpaperView *copy = [[[self class] alloc] initWithFrame:self.frame imageName:[self.name copy] blackout:self.blackout
                                                        enableParallax:self.parallaxEnabled blurBackground:self.blurBackground];
    return copy;
}

@end
