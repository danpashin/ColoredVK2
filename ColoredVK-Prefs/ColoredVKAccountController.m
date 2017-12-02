//
//  ColoredVKAccountController.m
//  ColoredVK
//
//  Created by Даниил on 14.04.17.
//
//

#import "ColoredVKAccountController.h"
#import "ColoredVKPasswordViewController.h"
#import "ColoredVKNewInstaller.h"
#import "ColoredVKAlertController.h"
#import <SafariServices/SafariServices.h>
#import "ColoredVKWebViewController.h"

@interface ColoredVKAccountController ()

@property (strong, nonatomic) PSTableCell *loginCell;

@property (assign, nonatomic) BOOL accountPaid;
@property (assign, nonatomic) BOOL accountActivated;
@property (assign, nonatomic) BOOL userLoggedIn;
@property (strong, nonatomic, getter=getAccountPaymentStatus) NSString *accountPaymentStatus;
@property (strong, nonatomic, getter=getAccountActivationStatus) NSString *accountActivationStatus;

@property (strong, nonatomic) UIButton *purchaseButton;

@end

@implementation ColoredVKAccountController

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSMutableArray *specifiers = [super.specifiers mutableCopy];
        
        if (self.userLoggedIn) {
            NSArray <NSString *> *specifiersIDToRemove = @[@"registerButton", @"registerGroup"];
            NSMutableArray <PSSpecifier *> *specifiersToRemove = [NSMutableArray array];
            
            for (PSSpecifier *specifier in specifiers) {
                if ([specifiersIDToRemove containsObject:specifier.identifier]) {
                    [specifiersToRemove addObject:specifier];
                }
            }
            
            for (PSSpecifier *specifier in specifiersToRemove) {
                [specifiers removeObject:specifier];
            }
        }
        
        if (self.accountActivated) {
            NSArray <NSString *> *specifiersIDToRemove = @[@"accountActivationFooter"];
            NSMutableArray <PSSpecifier *> *specifiersToRemove = [NSMutableArray array];
            
            for (PSSpecifier *specifier in specifiers) {
                if ([specifiersIDToRemove containsObject:specifier.identifier]) {
                    [specifiersToRemove addObject:specifier];
                }
            }
            
            for (PSSpecifier *specifier in specifiersToRemove) {
                [specifiers removeObject:specifier];
            }
        }
        
        _specifiers = [specifiers copy];
    }
    
    return _specifiers;
}

- (void)updateActivationInfo
{
    [[ColoredVKNewInstaller sharedInstaller] updateAccountInfo:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
            
            self.userLoggedIn = newInstaller.userAuthorized;
            self.accountPaid = newInstaller.api_purchased;
            self.accountActivated = newInstaller.api_activated;
            self.accountPaymentStatus = self.accountPaid ? CVKLocalizedStringFromTable(@"ACCOUNT_PAID", @"ColoredVK") : @"";
            self.accountActivationStatus = self.accountActivated ? CVKLocalizedStringFromTable(@"ACCOUNT_ACTIVATED", @"ColoredVK") : @"";
            if (self.accountPaid && !self.accountActivated)
                self.accountActivationStatus = CVKLocalizedString(@"WAIT_ACTIVATION");
            
            
            [self reloadSpecifiers];
        });
    }];
}

- (void)viewDidLoad
{
    [self resetStatus];
    [super viewDidLoad];
    
    [self updateActivationInfo];
    
    
}

- (void)resetStatus
{
    self.userLoggedIn =  NO;
    self.accountPaymentStatus = CVKLocalizedString(@"UPDATING...");
    self.accountActivationStatus = CVKLocalizedString(@"UPDATING...");
}

- (UIButton *)purchaseButton
{
    if (!_purchaseButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *title = CVKLocalizedString(@"PURCHASE");
        CGSize btnSize = [title sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
        button.frame = CGRectMake(0, 0, btnSize.width + 5, 32);
        
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:CVKMainColor forState:UIControlStateNormal];
        [button setTitleColor:CVKMainColor.darkerColor forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(actionPurchase) forControlEvents:UIControlEventTouchUpInside];
        
        _purchaseButton = button;
    }
    return _purchaseButton;
}

#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.specifier.identifier isEqualToString:@"loginCell"]) {
        PSSpecifier *specifier = cell.specifier;
        NSString *reuseIdentifier = [cell.reuseIdentifier copy];
        
        if (!self.loginCell) {
            self.loginCell = [[PSTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];
            self.loginCell.specifier = specifier;
        }
        cell = self.loginCell;
        [self.loginCell refreshCellContentsWithSpecifier:specifier];
        
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize] + 2.0f];
        if (!self.userLoggedIn) {
            cell.textLabel.text = CVKLocalizedStringFromTable(@"ENTER_ACCOUNT", @"ColoredVK");
            cell.textLabel.textColor = CVKMainColor;
            
            cell.detailTextLabel.text = CVKLocalizedStringFromTable(@"TO_UNLOCK_FULL_VERSION", @"ColoredVK");
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize] - 1.0f];
        } else {
            cell.textLabel.text = [ColoredVKNewInstaller sharedInstaller].userName;
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.detailTextLabel.text = @"";
        }
    }
    
    if ([cell.specifier.identifier isEqualToString:@"accountPaid"] && (!self.accountPaid && self.userLoggedIn)) {
        cell.accessoryView = self.purchaseButton;
    }
    
    objc_setAssociatedObject(cell, "nightThemeColorScheme", self.nightThemeColorScheme, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(cell, "app_is_vk", @(self.app_is_vk), OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(cell, "enableNightTheme", @(self.enableNightTheme), OBJC_ASSOCIATION_ASSIGN);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSSpecifier *specifier = [self specifierForIndexPath:indexPath];
    
    if ([specifier.identifier isEqualToString:@"loginCell"]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (!self.userLoggedIn) {
            [self actionLogin];
        } else {
            __weak typeof(self) weakSelf = self;
            ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *logout = [UIAlertAction actionWithTitle:CVKLocalizedString(@"ACTION_LOG_OUT") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [weakSelf actionLogout];
            }];
            [alertController addAction:logout image:@"LogoutIcon"];
            
            UIAlertAction *changePass = [UIAlertAction actionWithTitle:CVKLocalizedString(@"CHANGE_PASSWORD") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [weakSelf actionChangePassword];
            }];
            [alertController addAction:changePass image:@"LockIcon"];
            [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
            
            [alertController presentFromController:self];
        }
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)actionLogin
{
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:kPackageName message:CVKLocalizedString(@"ENTER_LOGIN_PASSWORD") 
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = CVKLocalizedString(@"USERNAME");
    
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = UIKitLocalizedString(@"Password");
        textField.secureTextEntry = YES;
    }];
    
    __weak typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"AUTHORISE") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *username = alertController.textFields[0].text;
        NSString *password = alertController.textFields[1].text;
        [[ColoredVKNewInstaller sharedInstaller] actionLoginWithUsername:username password:password completionBlock:^{
            [weakSelf updateActivationInfo];
        }];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    
    [alertController presentFromController:self];
}

- (void)actionLogout
{
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:CVKLocalizedString(@"WARNING") message:CVKLocalizedString(@"ENTER_PASS_FOR_ACTION") 
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = UIKitLocalizedString(@"Password");
        textField.secureTextEntry = YES;
    }];
    
    __weak typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"ACTION_LOG_OUT") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {        
        [[ColoredVKNewInstaller sharedInstaller] actionLogoutWithPassword:alertController.textFields[0].text completionBlock:^{
            [weakSelf resetStatus];
            [weakSelf updateActivationInfo];
        }];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    
    [alertController presentFromController:self];
}

- (void)actionChangePassword
{
    ColoredVKPasswordViewController *passController = [ColoredVKPasswordViewController new];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:passController];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)actionPurchase
{
    [[ColoredVKNewInstaller sharedInstaller] actionPurchase];
}

- (void)actionRegister
{
    NSURL *url = [NSURL URLWithString:kPackageAccountRegisterLink];
    
    if (SYSTEM_VERSION_IS_MORE_THAN(@"9.0")) {
        SFSafariViewController *sfController = [[SFSafariViewController alloc] initWithURL:url];
        [self presentViewController:sfController animated:YES completion:nil];
    } else {
        ColoredVKWebViewController *webController = [ColoredVKWebViewController new];
        webController.url = url;
        webController.request = [NSURLRequest requestWithURL:webController.url];
        [webController presentFromController:self];
    }
}

@end
