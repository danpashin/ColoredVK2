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
#import "ColoredVKPasswordViewController.h"
#import "ColoredVKNewInstaller.h"
#import "ColoredVKAuthPageController.h"
#import <SafariServices/SafariServices.h>
#import <MXParallaxHeader.h>

#import <SDWebImageManager.h>

@interface UINavigationBar ()
@property (nonatomic, readonly, strong) UIView *_backgroundView;
@end

@interface ColoredVKAccountController () <UITableViewDelegate, UITableViewDataSource, ColoredVKUserInfoViewDelegate>

@property (assign, nonatomic) BOOL controllerIsShown;

@property (assign, nonatomic) BOOL userAuthorized;
@property (strong, nonatomic) NSBundle *cvkBundle;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet ColoredVKUserInfoView *infoHeaderView;

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
    
    [self updateAccountInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.controllerIsShown = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.controllerIsShown = NO;
    
    [super viewWillDisappear:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"_backgroundView.alpha"] && ([change[NSKeyValueChangeNewKey] floatValue] != 0)) {
        UINavigationBar *navBar = object;
        navBar._backgroundView.alpha = 0.0f;
    }
}

- (void)setControllerIsShown:(BOOL)controllerIsShown
{
    _controllerIsShown = controllerIsShown;
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (controllerIsShown)
        [navBar addObserver:self forKeyPath:@"_backgroundView.alpha" options:NSKeyValueObservingOptionNew context:nil];
    else
        [navBar removeObserver:self forKeyPath:@"_backgroundView.alpha"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        navBar.tag = controllerIsShown ? 26 : 30;
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
        } else if (indexPath.section == 0 && indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"aboutStatusCell" forIndexPath:indexPath];
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"changePasswordCell" forIndexPath:indexPath];
        } else if (indexPath.section == 2 && indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"logoutCell" forIndexPath:indexPath];
        }
    } else {
        if (indexPath.section == 0 && indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"signinCell" forIndexPath:indexPath];
        } else if (indexPath.section == 1 && indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"signupCell" forIndexPath:indexPath];
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
        self.userAuthorized = newInstaller.authenticated;
        self.infoHeaderView.username = newInstaller.userName;
        self.infoHeaderView.email = nil;
        [self updateAvatar];
        
        [self.tableView reloadData];
    });
}

- (void)updateAvatar
{
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    NSNumber *vkUserID = newInstaller.vkUserID;
    
    if (vkUserID.integerValue != 0) {
        
        SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
        NSString *imageCacheKey = [NSString stringWithFormat:@"cvk_vk_user_%@", vkUserID];
        UIImage *cachedAvatar = [imageManager.imageCache imageFromCacheForKey:imageCacheKey];
        if (cachedAvatar) {
            self.infoHeaderView.avatar = cachedAvatar;
            return;
        }
        NSString *jsonURL = @"https://api.vk.com/method/users.get";
        NSDictionary *params = @{@"user_ids":vkUserID, @"fields":@"photo_100", @"v":@"5.71"};
        NSError *requestError = nil;
        NSMutableURLRequest *request = [newInstaller.networkController requestWithMethod:@"GET" URLString:jsonURL 
                                                                              parameters:params error:&requestError];
        if (!requestError) {
            [request setValue:@"VK" forHTTPHeaderField:@"User-Agent"];
            [newInstaller.networkController sendRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *rawData) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:rawData options:0 error:nil];
                if ([json isKindOfClass:[NSDictionary class]]) {
                    NSArray *array = json[@"response"];
                    if ([array isKindOfClass:[NSArray class]]) {
                        NSDictionary *responseDict = array.firstObject;
                        if ([responseDict isKindOfClass:[NSDictionary class]]) {
                            NSString *photoURL = responseDict[@"photo_100"];
                            if (photoURL) {
                                [imageManager loadImageWithURL:[NSURL URLWithString:photoURL] 
                                                       options:SDWebImageHighPriority|SDWebImageCacheMemoryOnly progress:nil 
                                                     completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                         [imageManager.imageCache storeImage:image forKey:imageCacheKey completion:nil];
                                                         self.infoHeaderView.avatar = image;
                                                     }];

                            }
                        }
                    }
                    
                    
                }
            } failure:nil];
        }
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
    ColoredVKPasswordViewController *passController = [ColoredVKPasswordViewController new];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:passController];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
