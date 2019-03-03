//
//  ColoredVKDragDownAnimator.h
//  ColoredVK2
//
//  Created by Даниил on 03/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ColoredVKDragDownAnimator;
@protocol ColoredVKDragDownAnimatorDelegate <NSObject>

- (void)animator:(ColoredVKDragDownAnimator *)animator didRecognizeDragGesture:(UIPanGestureRecognizer *)panGesture;

- (void)animatorFinishedAnimatingDismiss:(ColoredVKDragDownAnimator *)animator;

@end


@interface ColoredVKDragDownAnimator : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (assign, nonatomic) CGFloat maxPercentThreshold;

@property (weak, nonatomic) UIViewController *viewController;
@property (strong, nonatomic, readonly) UIPanGestureRecognizer *dragDownGestureRecognizer;
@property (weak, nonatomic) id <ColoredVKDragDownAnimatorDelegate> delegate;

- (instancetype)initWithViewController:(UIViewController *)viewController;

- (CGFloat)progressForPanGesture:(UIPanGestureRecognizer *)panGesture;

@end

NS_ASSUME_NONNULL_END
