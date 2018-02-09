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

@interface UINavigationBar ()
@property (nonatomic, readonly, strong) UIView *_backgroundView;
@end

@interface MXParallaxHeader ()
- (void)adjustScrollViewTopInset:(CGFloat)top;
@end

@interface ColoredVKAccountController () <UITableViewDelegate, UITableViewDataSource, ColoredVKUserInfoViewDelegate>

@property (assign, nonatomic) BOOL controllerIsShown;
@property (assign, nonatomic) BOOL userAuthorized;
@property (strong, nonatomic) NSBundle *cvkBundle;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet ColoredVKUserInfoView *infoHeaderView;
@property (strong, nonatomic) UINavigationController *superNavController;

@property (assign, nonatomic) ColoredVKUserAccountStatus accountStatus;

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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    
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
    if (!self.userAuthorized)
        return 2;
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.userAuthorized && section == 0)
        return 2;
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (self.userAuthorized) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"accountStatusCell" forIndexPath:indexPath];
            cell.textLabel.text = @"Статус аккаунта";
            if (self.accountStatus == ColoredVKUserAccountStatusPaid) {
                cell.detailTextLabel.text = @"Оплачен";
                if (!cell.accessoryView) {
                    UIView *contentAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 30)];
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(14, 0, 30, 30)];
                    imageView.image = [UIImage imageNamed:@"TickIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
                    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    imageView.tintColor = [UIColor colorWithRed:102/255.0f green:179/255.0f blue:46/255.0f alpha:1.0f];
                    [contentAccessoryView addSubview:imageView];
                    cell.accessoryView = contentAccessoryView;
                } else {
                    cell.accessoryView.hidden = NO;
                }
            } else {
                cell.detailTextLabel.text = @"Бесплатный";
                cell.accessoryView.hidden = YES;
            }
        } else if (indexPath.section == 0 && indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"aboutStatusCell" forIndexPath:indexPath];
            cell.textLabel.text = @"Подробнее о статусах";
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"changePasswordCell" forIndexPath:indexPath];
            cell.textLabel.text = @"Изменить пароль";
        } else if (indexPath.section == 2 && indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"logoutCell" forIndexPath:indexPath];
            cell.textLabel.text = @"Выйти из аккаунта";
        }
    } else {
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"signinCell" forIndexPath:indexPath];
            cell.textLabel.text = @"Войдите в свой аккаунт";
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"signupCell" forIndexPath:indexPath];
            cell.textLabel.text = @"Зарегистрировать";
        }
    }
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    cell.layoutMargins = UIEdgeInsetsMake(0, 18, 0, 18);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 56.0f;
    }
    
    return 56.0f;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Управление аккаунтом";
    }
    
    if (section == 1) {
        return self.userAuthorized ? @"Настройки безопасности" : @"Нет аккаунта?";
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([cell.reuseIdentifier isEqualToString:@"signinCell"]) {
            [self actionSignIn];
        } else if ([cell.reuseIdentifier isEqualToString:@"signupCell"]) {
            [self actionSignUp];
        } else if ([cell.reuseIdentifier isEqualToString:@"logoutCell"]) {
            [self actionLogout];
        } else if ([cell.reuseIdentifier isEqualToString:@"changePasswordCell"]) {
            [self actionChangePassword];
        }
    });
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)updateAccountInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
        self.userAuthorized = newInstaller.user.authenticated;
        self.infoHeaderView.username = newInstaller.user.name;
        self.infoHeaderView.email = newInstaller.user.email;
        self.accountStatus = newInstaller.user.accountStatus;
        [self updateAvatar];
        
        [self.tableView reloadData];
    });
}

- (void)updateAvatar
{
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    NSNumber *vkUserID = newInstaller.vkUserID;
    
    if (vkUserID) {
        [self.infoHeaderView loadVKAvatarForUserID:vkUserID];
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
    [[ColoredVKNewInstaller sharedInstaller] logoutWithСompletionBlock:^{
        [weakSelf updateAccountInfo];
    }];
}

- (void)actionChangePassword
{
    ColoredVKPassChangeController *passController = [ColoredVKPassChangeController allocFromStoryboard];
    [passController showFromViewController:self];
}

@end
