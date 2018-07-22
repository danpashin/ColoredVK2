//
//  ColoredVKPassChangeController.m
//  ColoredVK2
//
//  Created by Даниил on 09/02/2018.
//

#import "ColoredVKPassChangeController.h"
#import "ColoredVKNavigationController.h"
#import "ColoredVKTextField.h"
#import "ColoredVKNewInstaller.h"
#import "ColoredVKHUD.h"
#import "ColoredVKNetwork.h"

@interface ColoredVKPassChangeController () <ColoredVKTextFieldDelegate>

@property (strong, nonatomic) IBOutlet ColoredVKTextField *currentPassTextField;
@property (strong, nonatomic) IBOutlet ColoredVKTextField *passNewTextField;
@property (strong, nonatomic) IBOutlet ColoredVKTextField *passNewConfTextField;
@property (strong, nonatomic) IBOutlet UILabel *footerLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *changeButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIStackView *stackView;

@end

@implementation ColoredVKPassChangeController

+ (instancetype)allocFromStoryboard
{
    NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ColoredVKAuth" bundle:cvkBundle];
    ColoredVKPassChangeController *passController = [storyboard instantiateViewControllerWithIdentifier:@"passChangeController"];
    
    return passController;
}

- (void)showFromViewController:(UIViewController *)viewController
{
    ColoredVKNavigationController *nav = [[ColoredVKNavigationController alloc] initWithRootViewController:self];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [viewController presentViewController:nav animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.currentPassTextField.delegate = self;
    self.passNewTextField.delegate = self;
    self.passNewConfTextField.delegate = self;
    
    self.title = CVKLocalizedStringInBundle(@"CHANGE_PASSWORD_TITLE", self.cvkBundle);
    self.currentPassTextField.placeholder = CVKLocalizedStringInBundle(@"ENTER_OLD_PASSWORD", self.cvkBundle);
    self.passNewTextField.placeholder = CVKLocalizedStringInBundle(@"ENTER_NEW_PASSWORD", self.cvkBundle);
    self.passNewConfTextField.placeholder = CVKLocalizedStringInBundle(@"CONFIRM_NEW_PASSWORD", self.cvkBundle);
    self.footerLabel.text = CVKLocalizedStringInBundle(@"PASSWORD_WARNING", self.cvkBundle);
    self.changeButton.title = CVKLocalizedStringInBundle(@"CHANGE_ALT", self.cvkBundle);
    self.cancelButton.title = CVKLocalizedStringInBundle(@"CANCEL", self.cvkBundle);
    
    if (ios_available(11.0)) {
        [self.stackView setCustomSpacing:24.0f afterView:self.currentPassTextField];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.currentPassTextField becomeFirstResponder];
}


#pragma mark -
#pragma mark ColoredVKTextFieldDelegate
#pragma mark -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.passNewConfTextField]) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        ((ColoredVKTextField *)textField).error = (![self.passNewTextField.text isEqualToString:newString]);
    }
    
    if ([textField isEqual:self.currentPassTextField] || [textField isEqual:self.passNewTextField] || [textField isEqual:self.passNewConfTextField]) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([^A-Za-z0-9_-])" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray <NSTextCheckingResult *> *allResults = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
        if (allResults.count > 0) {
            [((ColoredVKTextField *)textField) shake];
            return NO;
        } else if ([textField isEqual:self.passNewTextField]) {
            ((ColoredVKTextField *)textField).error = NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.currentPassTextField]) {
        [self.passNewTextField becomeFirstResponder];
        return NO;
    }
    
    if ([textField isEqual:self.passNewTextField]) {
        [self.passNewConfTextField becomeFirstResponder];
        return NO;
    }
    
    if ([textField isEqual:self.passNewConfTextField]) {
        [self actionChange];
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldRemoveWhiteSpaces:(ColoredVKTextField *)textField
{
    return YES;
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)hideKeyboard
{
    [self.currentPassTextField endEditing:YES];
    [self.passNewTextField endEditing:YES];
    [self.passNewConfTextField endEditing:YES];
}

- (IBAction)actionCancel
{
    [self hideKeyboard];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (IBAction)actionChange
{
    if (self.currentPassTextField.text.length == 0 || self.currentPassTextField.error) {
        [self.currentPassTextField shake];
        return;
    } else if (self.passNewTextField.text.length == 0 || self.passNewTextField.error) {
        [self.passNewTextField shake];
        return;
    } else if (self.passNewConfTextField.text.length == 0 || self.passNewConfTextField.error) {
        [self.passNewConfTextField shake];
        return;
    }
    
    ColoredVKHUD *hud = [ColoredVKHUD showHUDForView:self.view];
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    
    NSString *url = [NSString stringWithFormat:@"%@/pass/change.php", kPackageAPIURL];
    NSDictionary *params = @{@"login": newInstaller.user.name, @"password":self.currentPassTextField.text, 
                             @"new_pass": self.passNewTextField.text, @"user_id":newInstaller.user.userID, 
                             @"token":newInstaller.user.accessToken, @"email":newInstaller.user.email};
    
    ColoredVKNetwork *network = [ColoredVKNetwork sharedNetwork];
    [network sendJSONRequestWithMethod:@"POST" stringURL:url parameters:params success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
        if (!json[@"error"]) {
            NSDictionary *responseDict = json[@"response"];
            if ([responseDict[@"code"] integerValue] == 1) {
                [hud showSuccessWithStatus:json[@"message"]];
                
                hud.didHiddenBlock = ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self actionCancel];
                    });
                };
                
            } else {
                NSString *message = [NSString stringWithFormat:@"Unknown error\n(%@)", responseDict[@"code"]];
                [hud showFailureWithStatus:message];
            }
        } else {
            NSDictionary *errorDict = json[@"error"];
            NSString *message = [NSString stringWithFormat:@"%@\n(%@)", errorDict[@"message"], errorDict[@"code"]];
            [hud showFailureWithStatus:message];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [hud showFailureWithStatus:error.localizedDescription];
    }];
}

@end
