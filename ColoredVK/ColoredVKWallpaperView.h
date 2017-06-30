//
//  ColoredVKWallpaperView.h
//  ColoredVK
//
//  Created by Даниил on 07/11/16.
//
//

#import <UIKit/UIKit.h>


@interface ColoredVKWallpaperView : UIView

+ (instancetype)viewWithFrame:(CGRect)frame imageName:(NSString *)name;
+ (instancetype)viewWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout;
+ (instancetype)viewWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip;
+ (instancetype)viewWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect;
- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip parallaxEffect:(BOOL)parallaxEffect;

@property (strong, nonatomic, readonly) NSString *name;
@property (assign, nonatomic, readonly) CGFloat blackout;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *frontView;
@property (assign, nonatomic) BOOL parallaxEnabled;

- (void)updateViewForKey:(NSString *)key;

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

@end
