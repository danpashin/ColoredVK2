//
//  ColoredVKPassChangeController.h
//  ColoredVK2
//
//  Created by Даниил on 09/02/2018.
//

#import "ColoredVKScrollViewController.h"

@interface ColoredVKPassChangeController : ColoredVKScrollViewController

+ (instancetype)allocFromStoryboard;

- (void)showFromViewController:(UIViewController *)viewController;

@end
