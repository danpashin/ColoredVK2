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
    ColoredVKWindowBackgroundStyleCustom,
};

@interface ColoredVKWindowController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic, readonly) UIWindow *window;
@property (strong, nonatomic) UINavigationBar *contentViewNavigationBar;

@property (assign, nonatomic) ColoredVKWindowBackgroundStyle backgroundStyle;
@property (assign, nonatomic) BOOL hideByTouch;
@property (assign, nonatomic) BOOL statusBarNeedsHidden;
@property (assign, nonatomic) BOOL contentViewWantsShadow;

@property (assign, nonatomic) NSTimeInterval animationDuration;

- (void)hide;
- (void)show;

- (void)setupDefaultContentView;

@end
