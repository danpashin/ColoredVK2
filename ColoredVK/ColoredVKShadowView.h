//
//  ColoredVKShadowView.h
//  ColoredVK2
//
//  Created by Даниил on 18.04.18.
//

#import <UIKit/UIKit.h>

@interface ColoredVKShadowView : UIImageView

+ (ColoredVKShadowView *)shadowWithFrame:(CGRect)frame size:(CGFloat)size cornerRadius:(CGFloat)cornerRadius;
+ (ColoredVKShadowView *)shadowWithFrame:(CGRect)frame size:(CGFloat)size cornerRadius:(CGFloat)cornerRadius offset:(CGFloat)offset;

@property (assign, nonatomic) CGFloat size;
@property (assign, nonatomic) CGFloat cornerRadius;
@property (assign, nonatomic) CGFloat offset;
@property (strong, nonatomic) UIColor *color;

- (instancetype)initWithFrame:(CGRect)frame size:(CGFloat)size cornerRadius:(CGFloat)cornerRadius offset:(CGFloat)offset color:(UIColor *)color;

@end
