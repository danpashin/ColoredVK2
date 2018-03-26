//
//  ColoredVKPasscodeView.h
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import <UIKit/UIKit.h>

@class ColoredVKPasscodeView;
@protocol ColoredVKPasscodeViewDelegate <NSObject>

@optional
- (void)passcodeView:(ColoredVKPasscodeView *)passcodeView didUpdatedPasscode:(NSString *)passcode;
- (void)passcodeViewRequestedDismiss:(ColoredVKPasscodeView *)passcodeView;
- (void)passcodeViewRequestedBiometric:(ColoredVKPasscodeView *)passcodeView;

@end


@interface ColoredVKPasscodeView : UIView

@property (assign, nonatomic) IBInspectable NSUInteger maxDigits;
@property (assign, nonatomic) BOOL supportsTouchID;
@property (assign, nonatomic) BOOL supportsFaceID;

@property (strong, nonatomic) IBInspectable IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSMutableString *passcode;
@property (assign, nonatomic) BOOL invalidPasscode;

@property (weak, nonatomic) id <ColoredVKPasscodeViewDelegate> delegate;

@end
