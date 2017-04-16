//
//  ColoredVKPasswordViewController.m
//  ColoredVK
//
//  Created by Даниил on 16.04.17.
//
//

#import "ColoredVKPasswordViewController.h"
#import "PrefixHeader.h"
#import "ColoredVKInstaller.h"
#import "NSData+AESCrypt.h"

@interface ColoredVKPasswordViewController () <UITableViewDelegate, UITableViewDataSource, ColoredVKPasswordCellDelegate>

@end

@implementation ColoredVKPasswordViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (!self.navigationController.navigationBar.barTintColor || IS_IPAD) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    
    self.navigationController.navigationBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
    self.navigationController.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
    self.navigationController.navigationBar.topItem.rightBarButtonItem.enabled = NO;
    self.navigationController.navigationBar.topItem.title = CVKLocalizedStringFromTableInBundle(@"CHANGE_PASSWORD", @"ColoredVK", self.cvkBundle);
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = CVKTableViewSeparatorColor;
    [self.view addSubview:self.tableView];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]-|" options:0 metrics:nil views:@{@"view":self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"   options:0 metrics:nil views:@{@"view":self.tableView}]];
    
    
    
    UILabel *footerView = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.tableView.frame.size.width - 20, 40)];
    footerView.text = CVKLocalizedStringFromTableInBundle(@"PASSWORD_WARNING", nil, self.cvkBundle);
    footerView.numberOfLines = 0;
    footerView.font = [UIFont systemFontOfSize:IS_IPAD?[UIFont systemFontSize]:[UIFont smallSystemFontSize]];
    self.tableView.tableFooterView = footerView;
    
    
    self.currentPassCell = [self.cvkBundle loadNibNamed:@"ColoredVKPasswordCell" owner:self options:nil][0];
    self.currentPassCell.label.text = CVKLocalizedStringFromTableInBundle(@"CURRENT", nil, self.cvkBundle);
    self.currentPassCell.textField.placeholder = CVKLocalizedStringFromTableInBundle(@"PASSWORD", nil, self.cvkBundle);
    self.currentPassCell.delegate = self;
    
    self.passNewCell = [self.cvkBundle loadNibNamed:@"ColoredVKPasswordCell" owner:self options:nil][0];
    self.passNewCell.label.text = CVKLocalizedStringFromTableInBundle(@"NEW", nil, self.cvkBundle);
    self.passNewCell.textField.placeholder = CVKLocalizedStringFromTableInBundle(@"PASSWORD", nil, self.cvkBundle);
    self.passNewCell.delegate = self;
    
    self.confirmCell = [self.cvkBundle loadNibNamed:@"ColoredVKPasswordCell" owner:self options:nil][0];
    self.confirmCell.label.text = CVKLocalizedStringFromTableInBundle(@"CONFIRM", nil, self.cvkBundle);
    self.confirmCell.textField.placeholder = CVKLocalizedStringFromTableInBundle(@"PASSWORD", nil, self.cvkBundle);
    self.confirmCell.delegate = self;
    
    self.cells = @[self.currentPassCell, self.passNewCell, self.confirmCell];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return self.cells[indexPath.row];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)save
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    NSString *login = @"danpashin";
    NSString *currentPass = AES256EncryptString(self.currentPassCell.textField.text, kDRMAuthorizeKey).base64Encoding;
    NSString *newPass = AES256EncryptString(self.passNewCell.textField.text, kDRMAuthorizeKey).base64Encoding;
    
    self.hud = [ColoredVKHUD showHUDForView:self.view];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://danpashin.ru/api/v1.2/changePassword.php"]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    NSString *parameters = [NSString stringWithFormat:@"login=%@&password=%@&new_password=%@", login, currentPass, newPass];
    request.HTTPBody = [parameters dataUsingEncoding:NSUTF8StringEncoding];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (dict) {
                if (!dict[@"error"]) {
                    if (dict[@"status"]) {
                        [self.hud showSuccessWithStatus:dict[@"status"]];
                        
                        __weak __typeof(self) weakSelf = self;
                        self.hud.didHiddenBlock = ^{
                            [weakSelf dismiss];
                        };
                        
                    } else [self.hud showFailureWithStatus:@"Unknown error (-3)"];
                } else [self.hud showFailureWithStatus:dict[@"error"]];
            } else [self.hud showFailureWithStatus:@"Unknown error (-2)"];
            
        } else [self.hud showFailureWithStatus:connectionError.localizedDescription];
    }]; 

}

- (void)passwordCellChangedText:(ColoredVKPasswordCell *)cell
{
    NSString *currentPass = self.currentPassCell.textField.text;
    NSString *newPass = self.passNewCell.textField.text;
    NSString *confirmPass = self.confirmCell.textField.text;
    
    BOOL doneButtonEnabled = NO;
    if (currentPass.length > 0 && newPass.length > 0 && confirmPass.length > 0) {
        if ([newPass isEqualToString:confirmPass]) doneButtonEnabled = YES;
    }
    self.navigationController.navigationBar.topItem.rightBarButtonItem.enabled = doneButtonEnabled;
}
@end
