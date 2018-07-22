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
#import "ColoredVKPrefsCell.h"


@interface ColoredVKAccountController (Actions)

- (void)updateAccountInfo;
- (void)updateJailHeaderView;

- (void)actionSignIn;
- (void)actionSignUp;
- (void)actionLogout;

- (void)actionChangePassword;
- (void)actionMoreAboutStatus;

- (void)actionSetMenuPasscode;
- (void)actionChangeMenuPasscode;
- (void)actionRemoveMenuPasscode;
@end


@interface ColoredVKAccountController () <ColoredVKUserInfoViewDelegate>

@property (assign, nonatomic) BOOL defaultPasswordIsSet;

@property (strong, nonatomic) NSBundle *cvkBundle;
@property (assign, nonatomic) BOOL controllerIsShown;
@property (strong, nonatomic) UINavigationController *superNavController;
@property (strong, nonatomic) ColoredVKCardController *statusCardsController;

@property (weak, nonatomic) ColoredVKUserModel *user;
@property (strong, nonatomic) ColoredVKUserInfoView *infoHeaderView;

@property (strong, nonatomic) IBOutlet ColoredVKPrefsCell *statusCell;
@property (strong, nonatomic) IBOutlet ColoredVKPrefsCell *moreAboutCell;
@property (strong, nonatomic) IBOutlet ColoredVKPrefsCell *changePassCell;
@property (strong, nonatomic) IBOutlet ColoredVKPrefsCell *logoutCell;
@property (strong, nonatomic) IBOutlet ColoredVKPrefsCell *loginCell;
@property (strong, nonatomic) IBOutlet ColoredVKPrefsCell *registerCell;

@property (strong, nonatomic) IBOutlet ColoredVKPrefsCell *setMenuPasscodeCell;
@property (strong, nonatomic) IBOutlet ColoredVKPrefsCell *changeMenuPasscodeCell;
@property (strong, nonatomic) IBOutlet ColoredVKPrefsCell *removeMenuPasscodeCell;

@end
