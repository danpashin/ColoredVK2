//
//  ColoredVKPasscodeView.h
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import <UIKit/UIKit.h>

@class ColoredVKPasscodeView;
@protocol ColoredVKPasscodeViewDelegate <NSObject>

@required
- (void)passcodeView:(ColoredVKPasscodeView *)passcodeView didUpdatedPasscode:(NSString *)passcode;
- (void)passcodeView:(ColoredVKPasscodeView *)passcodeView didTapBottomButton:(UIButton *)button;
- (void)passcodeView:(ColoredVKPasscodeView *)passcodeView didTapForgotButton:(UIButton *)button;

@end


@interface ColoredVKPasscodeView : UIView

+ (ColoredVKPasscodeView *)loadNib;

@property (assign, nonatomic) IBInspectable NSUInteger maxDigits;

@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) IBOutlet UIButton *bottomRightButton;
@property (strong, nonatomic) IBOutlet UIButton *bottomLeftButton;
@property (strong, nonatomic) IBOutlet UIButton *forgotPassButton;

@property (strong, nonatomic) NSMutableString *passcode;

@property (weak, nonatomic) id <ColoredVKPasscodeViewDelegate> delegate;

- (void)invalidate;
- (void)invalidateWithError:(BOOL)withError;

@end
