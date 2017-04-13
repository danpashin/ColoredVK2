

typedef NS_ENUM(NSUInteger, _UIBackdropViewStyle) {
    _UIBackdropViewStyleNone = -2,
    _UIBackdropViewStyleLight = 0,
    _UIBackdropViewStyleDark,
    _UIBackdropViewStyleBlur
};


@class _UIBackdropViewSettings;
@interface _UIBackdropView : UIView

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)arg1;
- (instancetype)initWithFrame:(CGRect)arg1 autosizesToFitSuperview:(BOOL)arg2 settings:(_UIBackdropViewSettings *)arg3;
- (instancetype)initWithFrame:(CGRect)arg1 privateStyle:(int)arg2;
- (instancetype)initWithFrame:(CGRect)arg1 settings:(_UIBackdropViewSettings *)arg2;
- (instancetype)initWithFrame:(CGRect)arg1 style:(_UIBackdropViewStyle)arg2;
- (instancetype)initWithPrivateStyle:(int)arg1;
- (instancetype)initWithSettings:(_UIBackdropViewSettings *)arg1;
- (instancetype)initWithStyle:(_UIBackdropViewStyle)arg1;

- (void)prepareForTransitionToSettings:(_UIBackdropViewSettings *)arg1;
- (void)settingsDidChange:(_UIBackdropViewSettings *)arg1;
- (void)transitionComplete;
- (void)transitionIncrementallyToPrivateStyle:(int)arg1 weighting:(float)arg2;
- (void)transitionIncrementallyToSettings:(_UIBackdropViewSettings *)arg1 weighting:(float)arg2;
- (void)transitionIncrementallyToStyle:(_UIBackdropViewStyle)arg1 weighting:(float)arg2;
- (void)transitionToColor:(UIColor *)arg1;
- (void)transitionToPrivateStyle:(int)arg1;
- (void)transitionToSettings:(_UIBackdropViewSettings *)arg1;
- (void)transitionToStyle:(_UIBackdropViewStyle)arg1;

@end



@interface _UIBackdropViewSettings : NSObject
+ (UIColor *)darkeningTintColor;
+ (instancetype)settingsForPrivateStyle:(int)arg1;
+ (instancetype)settingsForStyle:(int)arg1;
- (instancetype)initWithDefaultValues;
- (instancetype)initWithDefaultValuesForGraphicsQuality:(int)arg1;
@end
