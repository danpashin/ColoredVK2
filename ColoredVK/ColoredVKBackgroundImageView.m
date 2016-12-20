//
//  ColoredVKBackgroundImageView.m
//  ColoredVK
//
//  Created by Даниил on 07/11/16.
//
//

#import "ColoredVKBackgroundImageView.h"
#import "PrefixHeader.h"

const NSInteger PARALLAX_EFFECT_VALUE = 12; 

@implementation ColoredVKBackgroundImageView

- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout
{
    return [self initWithFrame:frame imageName:name blackout:blackout flip:NO parallaxEffect:NO];
}

- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip
{
    return [self initWithFrame:frame imageName:name blackout:blackout flip:flip parallaxEffect:NO];
}

- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect 
{
    return [self initWithFrame:frame imageName:name blackout:blackout flip:NO parallaxEffect:parallaxEffect];
}

- (instancetype)initWithFrame:(CGRect)frame imageName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip parallaxEffect:(BOOL)parallaxEffect
{    
    self = [super initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    if (self) {
        self.tag = 23;
        self.backgroundColor = [UIColor blackColor];
        _name = name;
        _blackout = blackout;
        
        UIImageView *myImageView = [UIImageView new];
        myImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        myImageView.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png", CVK_FOLDER_PATH, name]];
        myImageView.contentMode = UIViewContentModeScaleAspectFill;
        if (flip) myImageView.transform = CGAffineTransformMakeRotation(180 * M_PI/180);
        [self addSubview:myImageView];
        
        UIView *frontView = [UIView new];
        frontView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        frontView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:blackout];
        [self addSubview:frontView];
        
        if (parallaxEffect) {
            UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            verticalMotionEffect.minimumRelativeValue = @(-PARALLAX_EFFECT_VALUE);
            verticalMotionEffect.maximumRelativeValue = @(PARALLAX_EFFECT_VALUE);
            [myImageView addMotionEffect:verticalMotionEffect];
            UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            horizontalMotionEffect.minimumRelativeValue = @(-PARALLAX_EFFECT_VALUE);
            horizontalMotionEffect.maximumRelativeValue = @(PARALLAX_EFFECT_VALUE);
            [myImageView addMotionEffect:horizontalMotionEffect];
        }
    }
    
    return self;
}



@end
