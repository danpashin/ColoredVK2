//
//  ColoredVKDragDownAnimator.m
//  ColoredVK2
//
//  Created by Даниил on 03/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "ColoredVKDragDownAnimator.h"

@interface ColoredVKDragDownAnimator ()

@property (strong, nonatomic) UIPercentDrivenInteractiveTransition *interactiveTransition;

@property (assign, nonatomic) BOOL transitionHasStarted;
@property (assign, nonatomic) BOOL transitionShouldFinish;

@end

@implementation ColoredVKDragDownAnimator
@synthesize dragDownGestureRecognizer = _dragDownGestureRecognizer;

- (instancetype)initWithViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        self.viewController = viewController;
        self.viewController.transitioningDelegate = self;
        self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
        self.maxPercentThreshold = 0.3f;
    }
    return self;
}

- (void)handleDragDownGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    const CGFloat progress = [self progressForPanGesture:gestureRecognizer];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.transitionHasStarted = YES;
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    } else  if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.transitionShouldFinish = (progress > self.maxPercentThreshold);
        [self.interactiveTransition updateInteractiveTransition:progress];
    } else  if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        self.transitionHasStarted = NO;
        [self.interactiveTransition cancelInteractiveTransition];
    } else  if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.transitionHasStarted = NO;
        
        if (self.transitionShouldFinish)
            [self.interactiveTransition finishInteractiveTransition];
        else
            [self.interactiveTransition cancelInteractiveTransition];
    }
    
    [self.delegate animator:self didRecognizeDragGesture:gestureRecognizer];
}

- (UIPanGestureRecognizer *)dragDownGestureRecognizer
{
    if (!_dragDownGestureRecognizer) {
        _dragDownGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragDownGesture:)];
    }
    return _dragDownGestureRecognizer;
}

- (CGFloat)progressForPanGesture:(UIPanGestureRecognizer *)panGesture
{
    const CGPoint translation = [panGesture translationInView:self.viewController.view];
    const CGFloat verticalMovement = translation.y / CGRectGetHeight(self.viewController.view.bounds);
    return MIN(MAX(verticalMovement, 0.0f), 1.0f);
}


#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return self.transitionHasStarted ? self.interactiveTransition : nil;
}


- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}


#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    screenBounds.origin.y = screenBounds.size.height;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        self.viewController.view.frame = screenBounds;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        
        if (!transitionContext.transitionWasCancelled && [self.delegate respondsToSelector:@selector(animatorFinishedAnimatingDismiss:)])
            [self.delegate animatorFinishedAnimatingDismiss:self];
    }];
}

@end
