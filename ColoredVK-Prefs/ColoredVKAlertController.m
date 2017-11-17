//
//  ColoredVKAlertController.m
//  ColoredVK2
//
//  Created by Даниил on 09.07.17.
//
//

#import "ColoredVKAlertController.h"
#import "PrefixHeader.h"

@interface UIAlertAction ()

@property (nonatomic) UIImage *image;

@end

@implementation ColoredVKAlertController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self init];
}

- (instancetype)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _shouldReconfigureTextFields = YES;
        _shouldUseCustomTintColor = YES;
        _presentInCenter = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.shouldUseCustomTintColor)
        self.view.tintColor = CVKMainColor;
}

- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
            viewToRound.layer.cornerRadius = 5.0f;
            viewToRound.layer.borderWidth = 0.5f;
            viewToRound.layer.borderColor = [UIColor colorWithWhite:0.85f alpha:1.0f].CGColor;
            viewToRound.layer.masksToBounds = YES;
        }
    });
}

- (void)present
{
    [self presentFromController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (void)presentFromController:(UIViewController *)viewController
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (IS_IPAD && self.presentInCenter) {
            self.modalPresentationStyle = UIModalPresentationPopover;
            self.popoverPresentationController.permittedArrowDirections = 0;
        }
        
        self.popoverPresentationController.sourceView = viewController.view;
        self.popoverPresentationController.sourceRect = viewController.view.bounds;
        
        [viewController presentViewController:self animated:YES completion:nil];
    });
}

- (void)addAction:(UIAlertAction *)action image:(NSString *)imageName
{
    if ([action respondsToSelector:@selector(setImage:)]) {
        UIImage *image = [UIImage imageNamed:imageName inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        action.image = image;
    }
    [super addAction:action];
}

//- (void)dealloc
//{
//    [self.view removeFromSuperview];
//}

@end
