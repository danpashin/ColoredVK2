//
//  ColoredVKSettingsController.h
//  ColoredVK
//
//  Created by Даниил on 12/02/2017.
//
//

#import <UIKit/UIKit.h>
#import "PSListController.h"

@interface ColoredVKSettingsController : PSListController

@property (readonly, nonatomic) PSSpecifier *errorMessage;
@property (strong, nonatomic, readonly) NSBundle *cvkBundle;
@property (strong, nonatomic, readonly) NSString *prefsPath;
@property (strong, nonatomic, readonly) NSString *cvkFolder;

- (void)actionBackup;
- (void)actionReset;

@end
