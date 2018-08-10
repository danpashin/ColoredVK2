//
//  ColoredVKWallpaperView.h
//  ColoredVK
//
//  Created by Даниил on 07/11/16.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/_UIBackdropView.h>

@interface ColoredVKWallpaperView : UIView <NSCopying>

+ (instancetype)viewWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout;
- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout
               enableParallax:(BOOL)enableParallax blurBackground:(BOOL)blurBackground NS_DESIGNATED_INITIALIZER;

@property (strong, nonatomic, readonly) NSString *name;
@property (assign, nonatomic) CGFloat blackout;
@property (strong, nonatomic, readonly) UIImageView *imageView;
@property (assign, nonatomic) BOOL parallaxEnabled;
@property (assign, nonatomic) BOOL flip;
@property (assign, nonatomic) BOOL blurBackground;

@property (assign, nonatomic) _UIBackdropViewStyle blurStyle;
@property (strong, nonatomic) UIColor *blurTone;

- (void)updateViewWithBlackout:(CGFloat)blackout;
- (void)setFlip:(BOOL)flip animated:(BOOL)animated;
- (void)setBlackout:(CGFloat)blackout animated:(BOOL)animated;

/**
 *  Adds this view to parent view
 */
- (void)addToView:(UIView *)view animated:(BOOL)animated;

/**
 *  Adds this view to background of parent view
 */
- (void)addToBack:(UIView *)view animated:(BOOL)animated;

/**
 *  Adds this view to front of parent view
 */
- (void)addToFront:(UIView *)view animated:(BOOL)animated;

/**
 *  Removes this view from parent view
 */
- (void)removeFromSuperview;

- (void)setupConstraints;

@end
