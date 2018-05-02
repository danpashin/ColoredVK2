//
//  ColoredVKWindowController.h
//  ColoredVK2
//
//  Created by Даниил on 11.05.17.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ColoredVKWindowBackgroundStyle) {
    ColoredVKWindowBackgroundStyleBlurred,
    ColoredVKWindowBackgroundStyleDarkened,
    ColoredVKWindowBackgroundStyleCustom
};

@interface ColoredVKWindowController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic, readonly) UIWindow *window;
@property (strong, nonatomic) UINavigationBar *contentViewNavigationBar;

@property (assign, nonatomic, readonly) BOOL presented;
/**
 *  Default ColoredVKWindowBackgroundStyleDarkened
 */
@property (assign, nonatomic) ColoredVKWindowBackgroundStyle backgroundStyle;
/**
 *  Default YES
 */
@property (assign, nonatomic) BOOL hideByTouch;
/**
 *  Default YES
 */
@property (assign, nonatomic) BOOL statusBarNeedsHidden;
/**
 *  Default NO
 */
@property (assign, nonatomic) BOOL contentViewWantsShadow;

/**
 *  Default 0.3
 */
@property (assign, nonatomic) NSTimeInterval animationDuration;

- (void)hide;
- (void)show;

- (void)setupDefaultContentView;

@end
