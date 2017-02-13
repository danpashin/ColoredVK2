//
//  ColoredVKBackupController.h
//  ColoredVK
//
//  Created by Даниил on 12/02/2017.
//
//

#import <UIKit/UIKit.h>
#import "PSListController.h"

@interface ColoredVKBackupController : PSListController

@property (readonly, nonatomic) PSSpecifier *errorMessage;
@property (strong, nonatomic) NSBundle *cvkBundle;

@end
