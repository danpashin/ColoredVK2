//
//  ColoredVKHelpController.m
//  ColoredVK2
//
//  Created by Даниил on 14.05.17.
//
//

#import "ColoredVKHelpController.h"
#import "PrefixHeader.h"

@interface ColoredVKHelpController ()

@end

@implementation ColoredVKHelpController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

+ (ColoredVKHelpController *)helpController
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"ColoredVK2" bundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH]];
    if (!storyBoard) return nil;
    ColoredVKHelpController *helpController = [storyBoard instantiateInitialViewController];
    return helpController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.transitioningDelegate = self;
    self.thanksLabel.adjustsFontSizeToFitWidth = YES;
    
//    self.nameLabel.text = [NSString stringWithFormat:CVKLocalizedString(@"HI_%@"), self.username];
//    self.thanksLabel.text = CVKLocalizedString(@"THANKS_FOR_PURCHASING");
}

#pragma mark - Transition delegate
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.4;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = transitionContext.containerView;
    [containerView addSubview:toViewController.view];
    
    toViewController.view.alpha = 0.0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        toViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}


- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented 
                                                                            presentingController:(UIViewController *)presenting 
                                                                                sourceController:(UIViewController *)source
{
    return self;
}
@end
