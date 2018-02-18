//
//  ColoredVKAccountController.m
//  ColoredVK
//
//  Created by Даниил on 14.04.17.
//
//

#import "ColoredVKAccountController.h"

#import "PrefixHeader.h"
#import "ColoredVKUserInfoView.h"
#import "UITableViewCell+ColoredVK.h"
#import "ColoredVKPassChangeController.h"
#import "ColoredVKNewInstaller.h"
#import "ColoredVKAuthPageController.h"
#import <SafariServices/SafariServices.h>
#import <MXParallaxHeader.h>
#import "ColoredVKNavigationController.h"
#import "ColoredVKAlertController.h"
#import "ColoredVKCardController.h"
#import "ColoredVKNightThemeColorScheme.h"

@interface UINavigationBar ()
@property (nonatomic, readonly, strong) UIView *_backgroundView;
@end

@interface MXParallaxHeader ()
- (void)adjustScrollViewTopInset:(CGFloat)top;
@end

@interface ColoredVKAccountController () <ColoredVKUserInfoViewDelegate>

@property (strong, nonatomic) NSBundle *cvkBundle;
@property (assign, nonatomic) BOOL controllerIsShown;
@property (strong, nonatomic) UINavigationController *superNavController;
@property (strong, nonatomic) ColoredVKCardController *statusCardsController;

@property (weak, nonatomic) ColoredVKUserModel *user;
@property (strong, nonatomic) ColoredVKUserInfoView *infoHeaderView;

@property (strong, nonatomic) IBOutlet UITableViewCell *statusCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *moreAboutCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *changePassCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *loginCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *registerCell;

@end

@implementation ColoredVKAccountController

+ (id)new
{
    NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ColoredVKAuth" bundle:cvkBundle];
    ColoredVKAccountController *accountController = [storyboard instantiateViewControllerWithIdentifier:@"accountController"];
    accountController.cvkBundle = cvkBundle;
    
    return accountController;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *nibViews = [self.cvkBundle loadNibNamed:NSStringFromClass([ColoredVKUserInfoView class]) owner:self options:nil];
    self.infoHeaderView =  nibViews.firstObject;
    CGRect headerFrame = self.infoHeaderView.frame;
    headerFrame.size = CGSizeMake(CGRectGetWidth(self.tableView.frame), 176.0f);
    self.infoHeaderView.frame = headerFrame;
    self.infoHeaderView.delegate = self;
    
    self.tableView.parallaxHeader.view = self.infoHeaderView;
    self.tableView.parallaxHeader.height = 130.0f;
    self.tableView.parallaxHeader.mode = MXParallaxHeaderModeFill;
    self.tableView.parallaxHeader.minimumHeight = 64.0f;
    self.tableView.separatorColor = [UIColor clearColor];
    
    self.loginCell.textLabel.text = CVKLocalizedStringInBundle(@"LOG_INTO_YOUR_ACCOUNT", self.cvkBundle);
    self.registerCell.textLabel.text = CVKLocalizedStringInBundle(@"REGISTER", self.cvkBundle);
    self.statusCell.textLabel.text = CVKLocalizedStringInBundle(@"ACCOUNT_STATUS", self.cvkBundle);
    self.moreAboutCell.textLabel.text = CVKLocalizedStringInBundle(@"MORE_ABOUT_STATUS", self.cvkBundle);
    self.changePassCell.textLabel.text = CVKLocalizedStringInBundle(@"CHANGE_PASSWORD", self.cvkBundle);
    self.logoutCell.textLabel.text = CVKLocalizedStringInBundle(@"LOG_OUT_OF_ACCOUNT", self.cvkBundle);
    
    CGRect accessoryViewFrame = CGRectMake(0.0f, 0.0f, 44.0f, 30.0f);
    UIView *contentAccessoryView = [[UIView alloc] initWithFrame:accessoryViewFrame];
    CGRect imageViewFrame = CGRectMake(14.0f, 0.0f, CGRectGetHeight(accessoryViewFrame), CGRectGetHeight(accessoryViewFrame));
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    imageView.image = [UIImage imageNamed:@"CrownIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.tintColor = [UIColor colorWithRed:255/255.0f green:156/255.0f blue:60/255.0f alpha:1.0f];
    [contentAccessoryView addSubview:imageView];
    self.statusCell.accessoryView = contentAccessoryView;
    self.statusCell.userInteractionEnabled = NO;
    
    [self updateAccountInfo];
    
    ColoredVKNightThemeColorScheme *nightScheme = [ColoredVKNightThemeColorScheme sharedScheme];
    if (nightScheme.enabled) {
        self.infoHeaderView.backgroundColor = nightScheme.backgroundColor;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.superNavController = self.navigationController;
    [self.superNavController.navigationBar addObserver:self forKeyPath:@"_backgroundView.alpha" 
                                               options:NSKeyValueObservingOptionNew context:nil];
    self.controllerIsShown = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.controllerIsShown = NO;
    [self.superNavController.navigationBar removeObserver:self forKeyPath:@"_backgroundView.alpha"];
    self.superNavController = nil;
    
    [super viewWillDisappear:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change 
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"_backgroundView.alpha"] && ([change[NSKeyValueChangeNewKey] floatValue] != 0)) {
        UINavigationBar *navBar = object;
        navBar._backgroundView.alpha = 0.0f;
    }
}

- (void)setControllerIsShown:(BOOL)controllerIsShown
{
    _controllerIsShown = controllerIsShown;
    
    UINavigationBar *navBar = self.superNavController.navigationBar;    
    dispatch_async(dispatch_get_main_queue(), ^{
        navBar.tintColor = [UIColor whiteColor];
        
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            navBar._backgroundView.alpha = controllerIsShown ? 0.0f : 1.0f;
        } completion:nil];
    });
}


#pragma mark -
#pragma mark ColoredVKUserInfoViewDelegate
#pragma mark -

- (void)infoView:(ColoredVKUserInfoView *)infoView didUpdateHeight:(CGFloat)height
{
    if (@available(iOS 11.0, *)) {
        height *= 1.5;
    } else {
        height += 64.0f;
        [self.tableView.parallaxHeader adjustScrollViewTopInset:height];
    }
    
    self.tableView.parallaxHeader.height = height;
}


#pragma mark -
#pragma mark UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.user.authenticated)
        return 2;
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.user.authenticated && section == 0)
        return 2;
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (self.user.authenticated) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                cell = self.statusCell;
            } else if (indexPath.row == 1) {
                cell = self.moreAboutCell;
            }
            
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            cell = self.changePassCell;
        } else if (indexPath.section == 2 && indexPath.row == 0) {
            cell = self.logoutCell;
        }
    } else {
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell = self.loginCell;
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            cell = self.registerCell;
        }
    }
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    cell.layoutMargins = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 18.0f);
    objc_setAssociatedObject(cell, "should_change_background", @NO, OBJC_ASSOCIATION_ASSIGN);
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    return IS_IPAD ? 48.0f : 56.0f;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CVKLocalizedStringFromTableInBundle(@"MANAGE_ACCOUNT", @"Main", self.cvkBundle);
    }
    
    if (section == 1) {
        NSString *key = self.user.authenticated ? @"SECURITY_SETTINGS" : @"NO_ACCOUNT_QUESTION";
        return CVKLocalizedStringInBundle(key, self.cvkBundle);
    }
    
    return @"";
}


#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell renderBackgroundForTableView:tableView indexPath:indexPath];
    
    ColoredVKNightThemeColorScheme *nightScheme = [ColoredVKNightThemeColorScheme sharedScheme];
    if (nightScheme.enabled) {
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.renderedBackroundColor = nightScheme.foregroundColor;
        cell.renderedHighlightedColor = nightScheme.backgroundColor;
        [cell updateRenderedBackgroundWithBackgroundColor:nightScheme.foregroundColor separatorColor:nightScheme.backgroundColor];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isEqual:self.loginCell]) {
        [self actionSignIn];
    } else if ([cell isEqual:self.registerCell]) {
        [self actionSignUp];
    } else if ([cell isEqual:self.logoutCell]) {
        [self actionLogout];
    } else if ([cell isEqual:self.changePassCell]) {
        [self actionChangePassword];
    } else if ([cell isEqual:self.moreAboutCell]) {
        [self actionMoreAboutStatus];
    }
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)updateAccountInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
        self.user = newInstaller.user;
        if (newInstaller.vkUserID) {
            [self.infoHeaderView loadVKAvatarForUserID:newInstaller.vkUserID];
        }
        self.infoHeaderView.username = self.user.name;
        self.infoHeaderView.email = self.user.email;
        
        BOOL accountPaid = (self.user.accountStatus == ColoredVKUserAccountStatusPaid);
        self.statusCell.detailTextLabel.text = CVKLocalizedStringInBundle(accountPaid ? @"PREMIUM" : @"FREE", self.cvkBundle);
        self.statusCell.accessoryView.frame = accountPaid ? CGRectMake(0.0f, 0.0f, 44.0f, 30.0f) : CGRectZero;
        self.statusCell.accessoryView.hidden = !accountPaid;
        
        [self.tableView reloadData];
    });
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
    [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedStringInBundle(@"LOG_OUT_OF_ACCOUNT_ALERT", self.cvkBundle)
                                                        style:UIAlertActionStyleDestructive 
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          [[ColoredVKNewInstaller sharedInstaller] logoutWithСompletionBlock:^{
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
    [[ColoredVKNewInstaller sharedInstaller] actionPurchase];
}

- (void)actionMoreAboutStatus
{
    ColoredVKCard *freeCard = [ColoredVKCard new];
    freeCard.title = CVKLocalizedStringInBundle(@"FREE", self.cvkBundle);
    freeCard.titleColor = [UIColor blackColor];
    freeCard.backgroundImage = [UIImage imageNamed:@"DayBackground" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
    freeCard.backgroundColor = [UIColor colorWithRed:172/255.0f green:197/255.0f blue:226/255.0f alpha:1.0f];
    NSString *freeText = CVKLocalizedStringInBundle(@"MORE_ABOUT_FREE_ACCOUNT", self.cvkBundle);
    freeCard.attributedBody = [self attributedMoreString:freeText headerColor:[UIColor blackColor] 
                                                bodyColor:[UIColor colorWithWhite:0.1f alpha:1.0f]];
    
    ColoredVKCard *premiumCard = [ColoredVKCard new];
    premiumCard.title = CVKLocalizedStringInBundle(@"PREMIUM", self.cvkBundle);
    premiumCard.backgroundColor = [UIColor colorWithRed:84/255.0f green:91/255.0f blue:135/255.0f alpha:1.0f];
    premiumCard.backgroundImage = [UIImage imageNamed:@"NightBackground" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
    NSString *premiumText = CVKLocalizedStringInBundle(@"MORE_ABOUT_PREMIUM_ACCOUNT", self.cvkBundle);
    premiumCard.attributedBody = [self attributedMoreString:premiumText headerColor:[UIColor whiteColor] 
                                                  bodyColor:[UIColor colorWithWhite:1.0f alpha:0.9f]];
    
    if (self.user.accountStatus == ColoredVKUserAccountStatusFree) {
        freeCard.detailTitle = CVKLocalizedStringInBundle(@"YOUR_STATUS", self.cvkBundle);
        freeCard.detailTitleColor = [UIColor colorWithRed:255/255.0f green:102/255.0f blue:0/255.0f alpha:1.0f];
        premiumCard.buttonText = CVKLocalizedStringInBundle(@"BUY_PREMIUM", self.cvkBundle);
        premiumCard.buttonTarget = self;
        premiumCard.buttonAction = @selector(actionPurchase);
    } else if (self.user.accountStatus == ColoredVKUserAccountStatusPaid) {
        premiumCard.detailTitle = CVKLocalizedStringInBundle(@"YOUR_STATUS", self.cvkBundle);
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

@end
