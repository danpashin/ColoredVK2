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
- (UIView *)imageLayerWithFrame:(CGRect)frame withImageName:(NSString *)name blackout:(CGFloat)blackout;
- (UIView *)imageLayerWithFrame:(CGRect)frame withImageName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip;
//- (UIView *)imageLayerWithFrame:(CGRect)frame withImageName:(NSString *)name blackout:(CGFloat)blackout blur:(BOOL)blur;
- (UIView *)imageLayerWithFrame:(CGRect)frame withImageName:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect;
- (UIView *)imageLayerWithFrame:(CGRect)frame withImageName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip /*blur:(BOOL)blur*/ parallaxEffect:(BOOL)parallaxEffect;
@end
