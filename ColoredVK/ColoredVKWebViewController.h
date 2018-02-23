//
//  ColoredVKWebViewController.h
//  ColoredVK 2
//
//  Created by Даниил on 22.07.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

#import <UIKit/UIViewController.h>

@interface ColoredVKWebViewController : UIViewController

@property (strong, nonatomic) NSURLRequest *request;

- (void)present;
- (void)presentFromController:(UIViewController *)controller;

@end
