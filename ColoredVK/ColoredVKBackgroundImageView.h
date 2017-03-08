//
//  ColoredVKBackgroundImageView.h
//  ColoredVK
//
//  Created by Даниил on 07/11/16.
//
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT const NSInteger PARALLAX_EFFECT_VALUE;

@interface ColoredVKBackgroundImageView : UIView
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
- (void)addToView:(UIView *)view;
- (void)addToBack:(UIView *)view;
- (void)addToFront:(UIView *)view;
- (void)removeFromView:(UIView *)superview;
@end
