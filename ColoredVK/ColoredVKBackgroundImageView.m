//
//  ColoredVKBackgroundImageView.m
//  ColoredVK
//
//  Created by Даниил on 07/11/16.
//
//

#import "ColoredVKBackgroundImageView.h"
#import "PrefixHeader.h"

const NSInteger PARALLAX_EFFECT_VALUE = 14; 

@implementation ColoredVKBackgroundImageView

+ (instancetype)viewWithFrame:(CGRect)frame imageName:(NSString *)name
{
    return [[self alloc] initWithFrame:frame imageName:name blackout:0 flip:NO parallaxEffect:NO];
}

+ (instancetype)viewWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout
{
    return [[self alloc] initWithFrame:frame imageName:name blackout:blackout flip:NO parallaxEffect:NO];
}

+ (instancetype)viewWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip
{
    return [[self alloc] initWithFrame:frame imageName:name blackout:blackout flip:flip parallaxEffect:NO];
}

+ (instancetype)viewWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect 
{
    return [[self alloc] initWithFrame:frame imageName:name blackout:blackout flip:NO parallaxEffect:parallaxEffect];
}

- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip parallaxEffect:(BOOL)parallaxEffect
{    
    self = [super initWithFrame:frame];
    if (self) {
        self.tag = 23;
        self.backgroundColor = [UIColor blackColor];
        _name = name;
        _blackout = blackout;
        
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
        self.imageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", CVK_FOLDER_PATH, name]];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = YES;
        if (flip) self.imageView.transform = CGAffineTransformMakeRotation(180 * M_PI/180);
        [self addSubview:self.imageView];
        
        self.frontView = [[UIView alloc] initWithFrame:frame];
        self.frontView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:blackout];
        [self.imageView addSubview:self.frontView];
        
        self.parallaxEnabled = parallaxEffect;
    }
    
    return self;
}

- (void)setParallaxEnabled:(BOOL)parallaxEnabled
{
    _parallaxEnabled = parallaxEnabled;
    
    if (parallaxEnabled && (self.imageView.motionEffects.count == 0)) {
        UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        verticalMotionEffect.minimumRelativeValue = @(-PARALLAX_EFFECT_VALUE);
        verticalMotionEffect.maximumRelativeValue = @(PARALLAX_EFFECT_VALUE);
        [self.imageView addMotionEffect:verticalMotionEffect];
        UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        horizontalMotionEffect.minimumRelativeValue = @(-PARALLAX_EFFECT_VALUE);
        horizontalMotionEffect.maximumRelativeValue = @(PARALLAX_EFFECT_VALUE);
        [self.imageView addMotionEffect:horizontalMotionEffect];
    } else {
        for (UIMotionEffect *effect in self.imageView.motionEffects) [self.imageView removeMotionEffect:effect];
    }
}

- (void)updateViewForKey:(NSString *)key
{
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:CVK_PREFS_PATH];
    _blackout = [prefs[key] floatValue];
    
    [self updateView];
}

- (void)updateView
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", CVK_FOLDER_PATH, self.name]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                self.imageView.image = image;
                self.frontView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:self.blackout];
            } completion:nil];
        });
    });
}

- (void)addToView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![view.subviews containsObject:[view viewWithTag:self.tag]] && view) {
            [view addSubview:self];
            
            [self updateConstraints];
        }
    });
}

- (void)addToBack:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![view.subviews containsObject:[view viewWithTag:self.tag]] && view) {
            [view addSubview:self];
            [view sendSubviewToBack:self];
            
            [self updateConstraints];
        }
    });
}

- (void)addToFront:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![view.subviews containsObject:[view viewWithTag:self.tag]] && view) {
            [view addSubview:self];
            [view bringSubviewToFront:self];
            
            [self updateConstraints];
        }
    });
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.superview) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                               metrics:nil views:@{@"view":self}]];
        [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                               metrics:nil views:@{@"view":self}]];
        
        
        NSDictionary *views = @{@"imageView":self.imageView, @"frontView":self.frontView};
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:views]];
        self.frontView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.imageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[frontView]|" options:0 metrics:nil views:views]];
        [self.imageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[frontView]|" options:0 metrics:nil views:views]];
    }
}

- (void)removeFromView:(UIView *)superview
{
    if (superview && [superview.subviews containsObject:[superview viewWithTag:self.tag]]) {
        [self removeFromSuperview];
    }
}

@end
