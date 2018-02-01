//
//  ColoredVKPassResetController.h
//  ColoredVK2
//
//  Created by Даниил on 31/01/2018.
//

#import <UIKit/UIKit.h>
#import "ColoredVKScrollViewController.h"

@interface ColoredVKPassResetController : ColoredVKScrollViewController

@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *login;
@property (strong, nonatomic) NSString *email;

@end
