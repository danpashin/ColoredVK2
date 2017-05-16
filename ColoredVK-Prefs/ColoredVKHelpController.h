//
//  ColoredVKHelpController.h
//  ColoredVK2
//
//  Created by Даниил on 14.05.17.
//
//

#import <UIKit/UIKit.h>
#import "ColoredVKWindowController.h"

@interface ColoredVKHelpController : ColoredVKWindowController

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSNumber *userID;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *thanksLabel;
@property (strong, nonatomic) UITextView *messageTextView;
@property (strong, nonatomic) UIButton *agreeButton;

@property (assign, nonatomic) BOOL showInFirstTime;

@end
