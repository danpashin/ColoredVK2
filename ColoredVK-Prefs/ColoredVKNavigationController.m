//
//  ColoredVKNavigationController.m
//  ColoredVK2
//
//  Created by Даниил on 29/01/2018.
//

#import "ColoredVKNavigationController.h"

@interface ColoredVKNavigationController () <UINavigationBarDelegate>

@end

@implementation ColoredVKNavigationController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    if (self.viewControllers.count < navigationBar.items.count) {
        return YES;
    }
    
    BOOL shouldPop = YES;
    if ([self.topViewController respondsToSelector:@selector(controllerShouldPop)]) {
        shouldPop = self.topViewController.controllerShouldPop;
    }
    
    if (shouldPop) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self popViewControllerAnimated:YES];
        });
    }
    
    return NO;
}

@end

