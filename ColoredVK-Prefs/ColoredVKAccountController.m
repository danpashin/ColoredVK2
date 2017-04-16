//
//  ColoredVKAccountController.m
//  ColoredVK
//
//  Created by Даниил on 14.04.17.
//
//

#import "ColoredVKAccountController.h"
#import "ColoredVKInstaller.h"
#import "ColoredVKPasswordViewController.h"


@implementation ColoredVKAccountController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)changePassword
{    
    ColoredVKPasswordViewController *passController = [ColoredVKPasswordViewController new];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:passController];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

@end
