//
//  ColoredVKAuthPageController.m
//  ColoredVK2
//
//  Created by Даниил on 01.01.18.
//

#import "ColoredVKAuthPageController.h"
#import "ColoredVKTextField.h"
#import "ColoredVKNewInstaller.h"
#import "ColoredVKAccountRestoreController.h"

@interface ColoredVKAuthPageController () <ColoredVKTextFieldDelegate>

@property (strong, nonatomic) IBOutlet ColoredVKTextField *loginTextField;
@property (strong, nonatomic) IBOutlet ColoredVKTextField *passTextField;
@property (strong, nonatomic) IBOutlet UIImageView *navBackgroundView;
@property (strong, nonatomic) IBOutlet UIButton *forgotPassFooterButton;

@end

@implementation ColoredVKAuthPageController

+ (id)new
{
    NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ColoredVKAuth" bundle:cvkBundle];
    UINavigationController *navigation = [storyboard instantiateInitialViewController];
    
    return navigation.viewControllers.firstObject;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CVKLocalizedString(@"ACTION_LOG_IN")
                                                                             style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(actionSignin)];
    
    self.loginTextField.delegate = self;
    self.passTextField.delegate = self;
    
    self.navigationItem.title = CVKLocalizedString(@"COLOREDVK_AUTH");
    self.navigationItem.backBarButtonItem.title = @"";
    self.loginTextField.placeholder = CVKLocalizedString(@"USERNAME");
    self.passTextField.placeholder = CVKLocalizedString(@"PASSWORD");
    
    NSString *forgotPassString = CVKLocalizedString(@"FORGOT_PASSWORD");
    [self.forgotPassFooterButton setTitle:forgotPassString forState:UIControlStateNormal];
}


#pragma mark -
#pragma mark ColoredVKTextFieldDelegate
#pragma mark -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newStringLength = [textField.text stringByReplacingCharactersInRange:range withString:string].length;
    if ([textField isEqual:self.loginTextField]) {
        self.loginTextField.error = (newStringLength == 0);
    }
    
    if ([textField isEqual:self.passTextField]) {
        self.passTextField.error = (newStringLength == 0);
        
        if (newStringLength > 20) {
            self.passTextField.error = YES;
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.loginTextField]) {
        [self hideKeyboard];
        [self.passTextField becomeFirstResponder];
    }
    
    if ([textField isEqual:self.passTextField]) {
        [self actionSignin];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0 && [textField respondsToSelector:@selector(error)]) {
        ((ColoredVKTextField *)textField).error = YES;
    }
}

- (BOOL)textFieldShouldRemoveWhiteSpaces:(ColoredVKTextField *)textField
{
    return YES;
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)actionSignin
{
    [self hideKeyboard];
    
    if (self.loginTextField.error || self.loginTextField.text.length == 0) {
        [self.loginTextField shake];
        return;
    }
    
    if (self.passTextField.error || self.passTextField.text.length == 0) {
        [self.passTextField shake];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [[ColoredVKNewInstaller sharedInstaller].user authWithUsername:self.loginTextField.text password:self.passTextField.text completionBlock:^{
        if (weakSelf.completionBlock)
            weakSelf.completionBlock();
        
        if ([ColoredVKNewInstaller sharedInstaller].user.authenticated) {
            [weakSelf dismiss];
        }
    }];
}

- (void)showFromController:(UIViewController *)viewController
{
    UINavigationController *nav = self.navigationController;
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    if (!IS_IPAD)
        nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [viewController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)dismiss
{
    [self hideKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)hideKeyboard
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loginTextField endEditing:YES];
        [self.passTextField endEditing:YES];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self hideKeyboard];
    [super prepareForSegue:segue sender:sender];
    
    UIViewController *destination = segue.destinationViewController;
    if ([destination isKindOfClass:[ColoredVKAccountRestoreController class]]) {
        ColoredVKAccountRestoreController *restoreController = (ColoredVKAccountRestoreController *)destination;
        restoreController.login = self.loginTextField.text;
    }
}

@end
