//
//  ColoredVKNavigationController.h
//  ColoredVK2
//
//  Created by Даниил on 29/01/2018.
//

#import <UIKit/UIKit.h>

@interface UIViewController ()

@property (assign, nonatomic, readonly) BOOL controllerShouldPop;

@end

@interface ColoredVKNavigationController : UINavigationController

@property (assign, nonatomic) IBInspectable BOOL supportsAllOrientations;
@property (assign, nonatomic) IBInspectable BOOL prefersLargeTitle;

@end
