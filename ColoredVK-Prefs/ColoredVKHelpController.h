//
//  ColoredVKHelpController.h
//  ColoredVK2
//
//  Created by Даниил on 14.05.17.
//
//

#import <UIKit/UIKit.h>

@interface ColoredVKHelpController : UIViewController <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

+ (ColoredVKHelpController *)helpController;
@property (strong, nonatomic) NSString *username;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *thanksLabel;
@property (strong, nonatomic) IBOutlet UITextView *messageTextView;

@end
