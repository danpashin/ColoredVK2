//
//  ColoredVKAuthPageController.h
//  ColoredVK2
//
//  Created by Даниил on 01.01.18.
//

#import <UIKit/UIKit.h>
#import "ColoredVKScrollViewController.h"

@interface ColoredVKAuthPageController : ColoredVKScrollViewController

@property (copy, nonatomic) void(^completionBlock)(void);

- (void)showFromController:(UIViewController *)viewController;

@end
