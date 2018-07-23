//
//  ColoredVKAccountController+Actions.m
//  ColoredVK2
//
//  Created by Даниил on 28.03.18.
//

#import "ColoredVKAccountController+Actions.h"

//  Views
#import "ColoredVKAnimatedButton.h"

//  Controllers
#import "ColoredVKAlertController.h"
#import "ColoredVKAuthPageController.h"
#import <SafariServices/SafariServices.h>
#import "ColoredVKPassChangeController.h"
#import "ColoredVKPasscodeUpdateController.h"


@implementation ColoredVKAccountController (Actions)

#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)updateAccountInfo
{
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    void (^updateBlock)(void) = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateJailHeaderView];
            self.user = newInstaller.user;
            self.infoHeaderView.username = self.user.name;
            self.infoHeaderView.email = self.user.email;
            
            BOOL accountPaid = (self.user.accountStatus == ColoredVKUserAccountStatusPaid);
            self.statusCell.detailTextLabel.text = CVKLocalizedString(accountPaid ? @"PREMIUM" : @"FREE");
            self.statusCell.accessoryView.frame = accountPaid ? CGRectMake(0.0f, 0.0f, 44.0f, 30.0f) : CGRectZero;
            self.statusCell.accessoryView.hidden = !accountPaid;
            
            [self.tableView reloadData];
        });
    };
    
    updateBlock();
    [newInstaller.user updateAccountInfo:updateBlock];
}

- (void)updateJailHeaderView
{
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    if (__deviceIsJailed && !newInstaller.user.authenticated) {
        if (self.tableView.tableHeaderView.tag == 1244)
            return;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), 80.0f)];
        headerView.tag = 1244;
        
        CGRect buttonFrame = CGRectMake(10, 10, CGRectGetWidth(headerView.bounds)-20, CGRectGetHeight(headerView.bounds));
        ColoredVKAnimatedButton *button = [[ColoredVKAnimatedButton alloc] initWithFrame:buttonFrame];
        button.layer.cornerRadius = 10.0f;
        [headerView addSubview:button];
        
        if (installerShouldOpenPrefs) {
            button.tintColor = self.infoHeaderView.backgroundColor;
            button.text = CVKLocalizedString(@"ACTIVATED_VIA_BIGBOSS");
        } else {
            button.tintColor = [UIColor colorWithRed:235/255.0f green:149/255.0f blue:50/255.0f alpha:1.0f];
            button.text = CVKLocalizedString(@"CANNOT_GET_JAIL_PURCHASE_INFO");;
            
            __weak typeof(self) weakSelf = self;
            button.selectHandler = ^{
                NSString *errorText = CVKLocalizedString(@"CANNOT_GET_JAIL_PURCHASE_INFO_DETAIL");
                ColoredVKAlertController *alert = [ColoredVKAlertController alertControllerWithTitle:@"" message:errorText];
                [alert addCancelActionWithTitle:UIKitLocalizedString(@"OK")];
                [alert presentFromController:weakSelf];
            };
        }
        
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [button.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:28.0f].active = YES;
        [button.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:8.0f].active = YES;
        [button.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:8.0f].active = YES;
        [button.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-8.0f].active = YES;
        
        self.tableView.tableHeaderView = headerView;
    } else {
        self.tableView.tableHeaderView = nil;
    }
}

- (void)actionSignIn
{
    ColoredVKAuthPageController *authController = [ColoredVKAuthPageController new];
    
    __weak typeof(self) weakSelf = self;
    authController.completionBlock = ^{
        [weakSelf updateAccountInfo];
    };
    
    [authController showFromController:self];
}

- (void)actionSignUp
{
    NSURL *url = [NSURL URLWithString:kPackageAccountRegisterLink];
    
    SFSafariViewController *sfController = [[SFSafariViewController alloc] initWithURL:url];
    [self presentViewController:sfController animated:YES completion:nil];
}

- (void)actionLogout
{
    __weak typeof(self) weakSelf = self;
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"LOG_OUT_OF_ACCOUNT_ALERT")
                                                        style:UIAlertActionStyleDestructive 
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [[ColoredVKNewInstaller sharedInstaller].user logoutWithCompletionBlock:^{
                                                              [weakSelf updateAccountInfo];
                                                          }];
                                                      }]];
    [alertController addCancelAction];
    [alertController presentFromController:self];
}

- (void)actionChangePassword
{
    ColoredVKPassChangeController *passController = [ColoredVKPassChangeController allocFromStoryboard];
    [passController showFromViewController:self];
}

- (void)actionPurchase
{
    [self.statusCardsController dismiss];
    [[ColoredVKNewInstaller sharedInstaller].user actionPurchase];
}

- (void)actionMoreAboutStatus
{
    ColoredVKCard *freeCard = [ColoredVKCard new];
    freeCard.title = CVKLocalizedString(@"FREE");
    freeCard.titleColor = [UIColor blackColor];
    freeCard.backgroundImage = CVKImageInBundle(@"DayBackground", self.cvkBundle);
    freeCard.backgroundColor = [UIColor colorWithRed:172/255.0f green:197/255.0f blue:226/255.0f alpha:1.0f];
    NSString *freeText = CVKLocalizedString(@"MORE_ABOUT_FREE_ACCOUNT");
    freeCard.attributedBody = [self attributedMoreString:freeText headerColor:[UIColor blackColor] 
                                               bodyColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
    
    ColoredVKCard *premiumCard = [ColoredVKCard new];
    premiumCard.title = CVKLocalizedString(@"PREMIUM");
    premiumCard.backgroundColor = [UIColor colorWithRed:84/255.0f green:91/255.0f blue:135/255.0f alpha:1.0f];
    premiumCard.backgroundImage = CVKImageInBundle(@"NightBackground", self.cvkBundle);
    NSString *premiumText = CVKLocalizedString(@"MORE_ABOUT_PREMIUM_ACCOUNT");
    premiumCard.attributedBody = [self attributedMoreString:premiumText headerColor:[UIColor whiteColor] 
                                                  bodyColor:[UIColor colorWithWhite:1.0f alpha:0.9f]];
    
    if (self.user.accountStatus == ColoredVKUserAccountStatusFree) {
        freeCard.detailTitle = CVKLocalizedString(@"YOUR_STATUS");
        freeCard.detailTitleColor = [UIColor colorWithRed:255/255.0f green:102/255.0f blue:0/255.0f alpha:1.0f];
        premiumCard.buttonText = CVKLocalizedString(@"BUY_PREMIUM");
        premiumCard.buttonTarget = self;
        premiumCard.buttonAction = @selector(actionPurchase);
    } else if (self.user.accountStatus == ColoredVKUserAccountStatusPaid) {
        premiumCard.detailTitle = CVKLocalizedString(@"YOUR_STATUS");
    }
    
    self.statusCardsController = [ColoredVKCardController new];
    [self.statusCardsController addCards:@[freeCard, premiumCard]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.statusCardsController 
                                                                                 animated:YES completion:nil];
}

- (NSMutableAttributedString *)attributedMoreString:(NSString *)localizedString headerColor:(UIColor *)headerColor bodyColor:(UIColor *)bodyColor
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:localizedString];
    
    NSRange divideSign = [localizedString rangeOfString:@":\n\n●"];
    if (divideSign.location != NSNotFound) {
        NSRange headerRange = NSMakeRange(0, divideSign.location);
        UIFont *headerFont = [UIFont systemFontOfSize:[UIFont labelFontSize] weight:UIFontWeightMedium];
        NSDictionary *headerAttrs = @{NSFontAttributeName: headerFont, NSForegroundColorAttributeName: headerColor};
        [attributedString addAttributes:headerAttrs range:headerRange];
        
        NSRange bodyRange = NSMakeRange(headerRange.length, localizedString.length - headerRange.length);
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:[UIFont systemFontSize]] range:bodyRange];
        [attributedString addAttribute:NSForegroundColorAttributeName value:bodyColor range:bodyRange];
        NSMutableParagraphStyle *premiumBodystyle = [NSMutableParagraphStyle new];
        premiumBodystyle.lineSpacing = 2.5f;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:premiumBodystyle range:bodyRange];
    }
    
    return attributedString;
}

- (void)actionSetMenuPasscode
{
    [ColoredVKPasscodeUpdateController setNewPasscode:^(BOOL defaultPasswordIsSet) {
        self.defaultPasswordIsSet = defaultPasswordIsSet;
        [self.tableView reloadData];
    }];
}

- (void)actionChangeMenuPasscode
{
    [ColoredVKPasscodeUpdateController updatePasscode:^(BOOL defaultPasswordIsSet) {
        self.defaultPasswordIsSet = defaultPasswordIsSet;
        [self.tableView reloadData];
    }];
}

- (void)actionRemoveMenuPasscode
{
    [ColoredVKPasscodeUpdateController removePasscode:^(BOOL defaultPasswordIsSet) {
        self.defaultPasswordIsSet = defaultPasswordIsSet;
        [self.tableView reloadData];
    }];
}

@end
