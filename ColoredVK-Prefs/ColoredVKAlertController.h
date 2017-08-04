//
//  ColoredVKAlertController.h
//  ColoredVK2
//
//  Created by Даниил on 09.07.17.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColoredVKAlertController : UIAlertController

@property (assign, nonatomic) BOOL shouldReconfigureTextFields;
@property (assign, nonatomic) BOOL shouldUseCustomTintColor;
@property (assign, nonatomic) BOOL presentInCenter;

- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler;
- (void)addAction:(UIAlertAction *)action image:(NSString *)imageName;

- (void)present;
- (void)presentFromController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
