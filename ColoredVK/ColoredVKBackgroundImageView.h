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
- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout;
- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip;
- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect;
- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip parallaxEffect:(BOOL)parallaxEffect;
@property (strong, nonatomic, readonly) NSString *name;
@property (assign, nonatomic, readonly) CGFloat blackout;
@end
