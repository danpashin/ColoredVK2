//
//  ColoredVKAccountController.m
//  ColoredVK
//
//  Created by Даниил on 14.04.17.
//
//

#import "ColoredVKAccountController+Actions.h"

#import "ColoredVKNightScheme.h"
#import "ColoredVKPrefsCell.h"
#import "COloredVKBiometry.h"

#import <objc/runtime.h>
#import <MXParallaxHeader.h>


@interface UINavigationBar ()
@property (nonatomic, readonly, strong) UIView *_backgroundView;
@end

@interface MXParallaxHeader ()
- (void)adjustScrollViewTopInset:(CGFloat)top;
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
    self.defaultPasswordIsSet = ColoredVKBiometry.defaultPasswordIsSet;
    
    self.infoHeaderView =  ColoredVKUserInfoView.defaultNibView;
    CGRect headerFrame = self.infoHeaderView.frame;
    headerFrame.size = CGSizeMake(CGRectGetWidth(self.tableView.frame), 176.0f);
    self.infoHeaderView.frame = headerFrame;
    self.infoHeaderView.delegate = self;
    
    self.tableView.parallaxHeader.view = self.infoHeaderView;
    self.tableView.parallaxHeader.height = 130.0f;
    self.tableView.parallaxHeader.mode = MXParallaxHeaderModeFill;
    self.tableView.parallaxHeader.minimumHeight = 64.0f;
    self.tableView.separatorColor = [UIColor clearColor];
    
    [self updateJailHeaderView];
    
    CGRect accessoryViewFrame = CGRectMake(0.0f, 0.0f, 44.0f, 30.0f);
    UIView *contentAccessoryView = [[UIView alloc] initWithFrame:accessoryViewFrame];
    CGRect imageViewFrame = CGRectMake(14.0f, 0.0f, CGRectGetHeight(accessoryViewFrame), CGRectGetHeight(accessoryViewFrame));
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    imageView.image = CVKImage(@"user/CrownIcon");
    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    imageView.tintColor = [UIColor colorWithRed:255/255.0f green:156/255.0f blue:60/255.0f alpha:1.0f];
    [contentAccessoryView addSubview:imageView];
    self.statusCell.accessoryView = contentAccessoryView;
    self.statusCell.userInteractionEnabled = NO;
    
    [self updateAccountInfo];
    
    ColoredVKNightScheme *nightScheme = [ColoredVKNightScheme sharedScheme];
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
    if (ios_available(11.0)) {
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
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.user.authenticated && (section == 0  || (section == 2 && self.defaultPasswordIsSet)))
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
        } else if (indexPath.section == 2) {
            if (indexPath.row == 0) {
                cell = self.defaultPasswordIsSet ? self.changeMenuPasscodeCell : self.setMenuPasscodeCell;
            } else if (indexPath.row == 1) {
                cell = self.removeMenuPasscodeCell;
            }
        }
        else if (indexPath.section == 3 && indexPath.row == 0) {
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
        cell = [[ColoredVKPrefsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return IS_IPAD ? 48.0f : 56.0f;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CVKLocalizedStringFromTable(@"MANAGE_ACCOUNT", @"Main");
    }
    
    if (section == 1) {
        NSString *key = self.user.authenticated ? @"ACCOUNT_SECURITY" : @"NO_ACCOUNT_QUESTION";
        return CVKLocalizedString(key);
    }
    
    if (section == 2 && self.user.authenticated) {
        return CVKLocalizedString(@"MENU_ACCESS_PROTECTION");
    }
    
    return @"";
}


#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (void)tableView:(UITableView *)tableView willDisplayCell:(ColoredVKPrefsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.layoutMargins = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 18.0f);
    cell.textLabel.text = CVKLocalizedString(cell.textLabel.text);
    
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        cell.textLabel.textColor = CVKMainColor;
    }
    
    [cell renderBackgroundWithColor:nil separatorColor:nil forTableView:tableView indexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    } else if ([cell isEqual:self.setMenuPasscodeCell]) {
        [self actionSetMenuPasscode];
    } else if ([cell isEqual:self.changeMenuPasscodeCell]) {
        [self actionChangeMenuPasscode];
    } else if ([cell isEqual:self.removeMenuPasscodeCell]) {
        [self actionRemoveMenuPasscode];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

@end
