//
//  ColoredVKAccountController+Actions.h
//  ColoredVK2
//
//  Created by Даниил on 28.03.18.
//

#import "ColoredVKAccountController.h"

#import "ColoredVKNewInstaller.h"
#import "ColoredVKUserInfoView.h"
#import "ColoredVKCardController.h"


@interface ColoredVKAccountController (Actions)

- (void)updateAccountInfo;
- (void)updateJailHeaderView;

- (void)actionSignIn;
- (void)actionSignUp;
- (void)actionLogout;

- (void)actionChangePassword;
- (void)actionMoreAboutStatus;
- (void)actionSetupSecurity;

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
@property (strong, nonatomic) IBOutlet UITableViewCell *sectionSecurityCell;

@end
