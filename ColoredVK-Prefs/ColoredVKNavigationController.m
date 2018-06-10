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

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup
{
    _supportsAllOrientations = NO;
    _prefersLargeTitle = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.barTintColor = [UIColor colorWithRed:65/255.0f green:125/255.0f blue:214/255.0f alpha:1.0f];
#ifndef COMPILE_APP
    self.navigationBar.translucent = NO;
#endif
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.prefersLargeTitle = self.prefersLargeTitle;
    
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

- (void)setPrefersLargeTitle:(BOOL)prefersLargeTitle
{
    _prefersLargeTitle = prefersLargeTitle;
    
    if (ios_available(11.0)) {
        self.navigationBar.prefersLargeTitles = prefersLargeTitle;
        self.navigationBar.largeTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
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
