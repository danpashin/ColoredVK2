//
//  ColoredVKPassResetController.m
//  ColoredVK2
//
//  Created by Даниил on 31/01/2018.
//

#import "ColoredVKPassResetController.h"
#import "ColoredVKTextField.h"
#import "PrefixHeader.h"
#import "ColoredVKHUD.h"
#import "ColoredVKNewInstaller.h"

@interface ColoredVKPassResetController () <ColoredVKTextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *changeButton;

@property (strong, nonatomic) IBOutlet ColoredVKTextField *passTextField;
@property (strong, nonatomic) IBOutlet ColoredVKTextField *confPassTextField;
@property (strong, nonatomic) IBOutlet UILabel *footerLabel;

@end

@implementation ColoredVKPassResetController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.passTextField.delegate = self;
    self.confPassTextField.delegate = self;
    
    self.passTextField.placeholder = CVKLocalizedStringFromTableInBundle(@"ENTER_NEW_PASSWORD", nil, self.cvkBundle);
    self.confPassTextField.placeholder = CVKLocalizedStringFromTableInBundle(@"CONFIRM_NEW_PASSWORD", nil, self.cvkBundle);
    self.footerLabel.text = CVKLocalizedStringFromTableInBundle(@"PASSWORD_WARNING", nil, self.cvkBundle);
    self.changeButton.title = CVKLocalizedStringFromTableInBundle(@"CHANGE", nil, self.cvkBundle);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.passTextField.text.length > 0) {
        [self.confPassTextField becomeFirstResponder];
    } else {
        [self.passTextField becomeFirstResponder];
    }
}

- (BOOL)controllerShouldPop
{
    [self actionPop];
   
    return NO;
}


#pragma mark -
#pragma mark ColoredVKTextFieldDelegate
#pragma mark -

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if ([textField isEqual:self.confPassTextField]) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        ((ColoredVKTextField *)textField).error = (![self.passTextField.text isEqualToString:newString]);
    }
    
    if ([textField isEqual:self.passTextField] || [textField isEqual:self.confPassTextField]) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([^A-Za-z0-9_-])" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray <NSTextCheckingResult *> *allResults = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
        if (allResults.count > 0) {
            [((ColoredVKTextField *)textField) shake];
            return NO;
        } else if ([textField isEqual:self.passTextField]) {
            ((ColoredVKTextField *)textField).error = NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.passTextField]) {
        [self.confPassTextField becomeFirstResponder];
        return NO;
    }
    
    if ([textField isEqual:self.confPassTextField]) {
        [self actionChangePass];
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

- (void)actionPop
{
    [self.passTextField endEditing:YES];
    [self.confPassTextField endEditing:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}

- (IBAction)actionChangePass
{
    if (self.passTextField.error || self.passTextField.text.length == 0) {
        [self.passTextField shake];
        return;
    }
    
    if (self.confPassTextField.error || self.confPassTextField.text.length == 0) {
        [self.confPassTextField shake];
        return;
    }
    
    ColoredVKHUD *hud = [ColoredVKHUD showHUDForView:self.view];
    
    NSString *stringURL = [NSString stringWithFormat:@"%@/pass/change.php", kPackageAPIURL];
    NSDictionary *params = @{@"login":self.login, @"email":self.email, @"new_pass":self.passTextField.text, @"token":self.token};
    [[ColoredVKNewInstaller sharedInstaller].networkController sendJSONRequestWithMethod:@"POST" stringURL:stringURL parameters:params
                                                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
                                                                                     NSLog(@"%@", json);
                                                                                     if (json[@"response"]) {
                                                                                         NSDictionary *responseDict = json[@"response"];
                                                                                         
                                                                                         NSInteger code = [responseDict[@"code"] integerValue];
                                                                                         if (code != 1) {
                                                                                             NSString *message = [NSString stringWithFormat:@"Unknow error\n(%ld)", (long)code];
                                                                                             [hud showFailureWithStatus:message];
                                                                                         } else {
                                                                                             hud.didHiddenBlock = ^{
                                                                                                 [self actionPop];
                                                                                             };
                                                                                             [hud showSuccess];
                                                                                         }
                                                                                         
                                                                                     } else {
                                                                                         NSString *message = [NSString stringWithFormat:@"%@\n(%@)", json[@"error"][@"message"], json[@"error"][@"code"]];
                                                                                         [hud showFailureWithStatus:message];
                                                                                     }
                                                                                 } 
                                                                                 failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                     [hud showFailureWithStatus:error.localizedDescription];
                                                                                 }];
}


@end
