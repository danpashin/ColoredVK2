//
//  ColoredVKPasswordViewController.m
//  ColoredVK
//
//  Created by Даниил on 16.04.17.
//
//

#import "ColoredVKPasswordViewController.h"
#import "ColoredVKPasswordCell.h"
#import "ColoredVKHUD.h"
#import "PrefixHeader.h"
#import "ColoredVKNewInstaller.h"
#import "ColoredVKCrypto.h"
#import "ColoredVKNetworkController.h"

@interface ColoredVKPasswordViewController () <UITableViewDelegate, UITableViewDataSource, ColoredVKPasswordCellDelegate>

@property (strong, nonatomic) NSBundle *cvkBundle;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *cells;
@property (weak, nonatomic) ColoredVKPasswordCell *currentPassCell;
@property (weak, nonatomic) ColoredVKPasswordCell *passNewCell;
@property (weak, nonatomic) ColoredVKPasswordCell *confirmCell;
@property (weak, nonatomic) ColoredVKHUD *hud;

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
    self.tableView.separatorColor = self.tableView.backgroundColor;
    self.tableView.allowsSelection = NO;
    [self.view addSubview:self.tableView];
    
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]-|" options:0 metrics:nil views:@{@"view":self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"   options:0 metrics:nil views:@{@"view":self.tableView}]];
    
    
        
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, footerView.frame.size.width - 20, footerView.frame.size.height)];
    label.text = CVKLocalizedStringFromTableInBundle(@"PASSWORD_WARNING", nil, self.cvkBundle);
    label.numberOfLines = 0;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    label.textColor = [UIColor colorWithRed:0.427 green:0.427 blue:0.447 alpha:1.0];
    [footerView addSubview:label];
    
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [footerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":label}]];
    [footerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view":label}]];

    self.tableView.tableFooterView = footerView;
    
    self.currentPassCell = [ColoredVKPasswordCell cellForViewController:self];
    self.currentPassCell.label.text = CVKLocalizedStringFromTableInBundle(@"CURRENT", nil, self.cvkBundle);
    self.currentPassCell.textField.placeholder = CVKLocalizedStringFromTableInBundle(@"PASSWORD", nil, self.cvkBundle);
    self.currentPassCell.delegate = self;
    
    self.passNewCell = [ColoredVKPasswordCell cellForViewController:self];
    self.passNewCell.label.text = CVKLocalizedStringFromTableInBundle(@"NEW", nil, self.cvkBundle);
    self.passNewCell.textField.placeholder = CVKLocalizedStringFromTableInBundle(@"PASSWORD", nil, self.cvkBundle);
    self.passNewCell.delegate = self;
    
    self.confirmCell = [ColoredVKPasswordCell cellForViewController:self];
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
    
    NSString *currentPass = AES256EncryptStringForAPI(self.currentPassCell.textField.text);
    NSString *newPass = AES256EncryptStringForAPI(self.passNewCell.textField.text);
    
    self.hud = [ColoredVKHUD showHUDForView:self.view];
    
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    
    NSString *url = [NSString stringWithFormat:@"%@/changePassword.php", kPackageAPIURL];
    [newInstaller.networkController sendJSONRequestWithMethod:@"POST" stringURL:url parameters:@{@"login": newInstaller.userName, @"password":currentPass, 
                                                                                                 @"new_password": newPass, @"user_id":newInstaller.userID} 
                                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
                                                          if (!json[@"error"]) {
                                                              if (json[@"status"]) {
                                                                  [self.hud showSuccessWithStatus:json[@"status"]];
                                                                  
                                                                  self.hud.didHiddenBlock = ^{
                                                                      [self dismiss];
                                                                  };
                                                                  
                                                              } else [self.hud showFailureWithStatus:@"Unknown error (-3)"];
                                                          } else [self.hud showFailureWithStatus:json[@"error"]];
                                                      } 
                                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                          [self.hud showFailureWithStatus:error.localizedDescription];
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
