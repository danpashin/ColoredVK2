//
//  ColoredVKNavigationController.m
//  ColoredVK2
//
//  Created by Даниил on 29/01/2018.
//

#import "ColoredVKNavigationController.h"
#import "ColoredVKNightThemeColorScheme.h"

@interface ColoredVKNavigationController () <UINavigationBarDelegate>

@end

@implementation ColoredVKNavigationController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (self.supportsAllOrientations)
        return UIInterfaceOrientationMaskAll;
    
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _supportsAllOrientations = NO;
        _prefersLargeTitle = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.barTintColor = [UIColor colorWithRed:65/255.0f green:125/255.0f blue:214/255.0f alpha:1.0f];
    self.navigationBar.translucent = NO;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    if (@available(iOS 11.0, *)) {
        self.navigationBar.prefersLargeTitles = self.prefersLargeTitle;
        self.navigationBar.largeTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    }
    
    [self updateNightThemeForController:self];
    [self updateNightThemeForController:self.topViewController];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    [self updateNightThemeForController:viewController];
}

- (void)updateNightThemeForController:(UIViewController *)viewController
{
    ColoredVKNightThemeColorScheme *nightScheme = [ColoredVKNightThemeColorScheme sharedScheme];
    if (nightScheme.enabled) {
        viewController.view.backgroundColor = nightScheme.backgroundColor;
    }
}


#pragma mark -
#pragma mark UINavigationBarDelegate
#pragma mark -

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
