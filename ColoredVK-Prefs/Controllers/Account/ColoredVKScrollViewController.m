//
//  ColoredVKScrollViewController.m
//  ColoredVK2
//
//  Created by Даниил on 01/02/2018.
//

#import "ColoredVKScrollViewController.h"

@interface ColoredVKScrollViewController ()
@end

@implementation ColoredVKScrollViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)loadView
{
    [super loadView];
    
    self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) 
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (SYSTEM_VERSION_IS_LESS_THAN(10.3.3)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.scrollView.contentInset = UIEdgeInsetsZero;
            self.scrollView.contentOffset = CGPointZero;
        });
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    if (height == 480.0f) {
        [self.scrollView setContentOffset:CGPointMake(0, 32) animated:YES];
    }
}

- (void)keyboardWillHide
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)controllerShouldPop
{
    return YES;
}

@end
