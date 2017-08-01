//
//  ColoredVKAlertController.m
//  ColoredVK2
//
//  Created by Даниил on 09.07.17.
//
//

#import "ColoredVKAlertController.h"
#import "PrefixHeader.h"

@implementation ColoredVKAlertController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldReconfigureTextFields = YES;
        self.shouldUseCustomTintColor = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.shouldUseCustomTintColor)
        self.view.tintColor = CVKMainColor;
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField * _Nonnull textField))configurationHandler
{
    if (self.shouldReconfigureTextFields) {
        void (^newHandler)(UITextField * _Nonnull textField) = ^(UITextField * _Nonnull textField){
            [self setupTextField:textField];
            configurationHandler(textField);
        };
        [super addTextFieldWithConfigurationHandler:newHandler];
    } else {
        [super addTextFieldWithConfigurationHandler:configurationHandler];
    }
    
}

- (void)setupTextField:(UITextField *)textField
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *viewToRoundSuperView = textField.superview.superview;
        if (viewToRoundSuperView) {
            for (UIView *subview in textField.superview.superview.subviews) {
                subview.backgroundColor = [UIColor clearColor];
                if ([subview isKindOfClass:[UIVisualEffectView class]])
                    subview.hidden = YES;
            }
            UIView *viewToRound = textField.superview;
            textField.backgroundColor = [UIColor whiteColor];
            viewToRound.backgroundColor = [UIColor whiteColor];
            viewToRound.layer.cornerRadius = 4.0f;
            viewToRound.layer.borderWidth = 0.6f;
            viewToRound.layer.borderColor = [UIColor colorWithWhite:0.85f alpha:1.0f].CGColor;
            viewToRound.layer.masksToBounds = YES;
        }
    });
}

@end
