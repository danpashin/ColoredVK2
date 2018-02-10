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
    
    self.loginCell.textLabel.text = CVKLocalizedStringFromTableInBundle(@"LOG_INTO_YOUR_ACCOUNT", nil, self.cvkBundle);
    self.registerCell.textLabel.text = CVKLocalizedStringFromTableInBundle(@"REGISTER", nil, self.cvkBundle);
    self.statusCell.textLabel.text = CVKLocalizedStringFromTableInBundle(@"ACCOUNT_STATUS", nil, self.cvkBundle);
    self.moreAboutCell.textLabel.text = CVKLocalizedStringFromTableInBundle(@"MORE_ABOUT_STATUS", nil, self.cvkBundle);
    self.changePassCell.textLabel.text = CVKLocalizedStringFromTableInBundle(@"CHANGE_PASSWORD", nil, self.cvkBundle);
    self.logoutCell.textLabel.text = CVKLocalizedStringFromTableInBundle(@"LOG_OUT_OF_ACCOUNT", nil, self.cvkBundle);
    
    self.statusCell.userInteractionEnabled = NO;
    self.moreAboutCell.userInteractionEnabled = NO;
    self.moreAboutCell.textLabel.textColor = [UIColor lightGrayColor];
    
    CGRect accessoryViewFrame = CGRectMake(0.0f, 0.0f, 44.0f, 30.0f);
    UIView *contentAccessoryView = [[UIView alloc] initWithFrame:accessoryViewFrame];
    CGRect imageViewFrame = CGRectMake(14.0f, 0.0f, CGRectGetHeight(accessoryViewFrame), CGRectGetHeight(accessoryViewFrame));
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    imageView.image = [UIImage imageNamed:@"CrownIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.tintColor = [UIColor colorWithRed:255/255.0f green:156/255.0f blue:60/255.0f alpha:1.0f];
    [contentAccessoryView addSubview:imageView];
    self.statusCell.accessoryView = contentAccessoryView;
    
    [self updateAccountInfo];
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
    if (SYSTEM_VERSION_IS_LESS_THAN(@"10.3.3")) {
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
    if (self.user.authenticated) {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return self.statusCell;
            } else if (indexPath.row == 1) {
                return self.moreAboutCell;
            }
            
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            return self.changePassCell;
        } else if (indexPath.section == 2 && indexPath.row == 0) {
            return self.logoutCell;
        }
    } else {
        if (indexPath.section == 0 && indexPath.row == 0) {
            return self.loginCell;
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            return self.registerCell;
        }
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.layoutMargins = UIEdgeInsetsMake(0, 18, 0, 18);
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
        return CVKLocalizedStringFromTableInBundle(key, nil, self.cvkBundle);
    }
    
    return @"";
}


#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell renderBackgroundForTableView:tableView indexPath:indexPath];
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
        self.statusCell.detailTextLabel.text = CVKLocalizedStringFromTableInBundle(accountPaid ? @"PREMIUM" : @"FREE", nil, self.cvkBundle);
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
    [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedStringFromTableInBundle(@"LOG_OUT_OF_ACCOUNT_ALERT", nil, self.cvkBundle)
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

@end
