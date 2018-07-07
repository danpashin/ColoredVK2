//
//  ColoredVKTextView.h
//  ColoredVK2
//
//  Created by Даниил on 20.06.17.
//
//

#import "ColoredVKWindowController.h"

@interface ColoredVKSimpleAlertController : ColoredVKWindowController

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UIScrollView *scrollView;

@property (assign, nonatomic) CGFloat prefferedWidth;

- (void)show;

@end
