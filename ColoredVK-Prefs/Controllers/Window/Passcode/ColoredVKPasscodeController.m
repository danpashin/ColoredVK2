//
//  ColoredVKPasscodeController.m
//  ColoredVK2
//
//  Created by Даниил on 28.03.18.
//

#import "ColoredVKPasscodeController.h"
#import "ColoredVKAlertController.h"

#import "ColoredVKNightScheme.h"
#import "_UIBackdropView.h"
#import "ColoredVKNewInstaller.h"

@interface ColoredVKPasscodeController ()

@end

@implementation ColoredVKPasscodeController
@dynamic contentView;

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (IS_IPAD)
        return UIInterfaceOrientationMaskAll;
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if ([ColoredVKNightScheme sharedScheme].enabled)
        return UIStatusBarStyleLightContent;
    
    return UIStatusBarStyleDefault;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        self.backgroundStyle = ColoredVKWindowBackgroundStyleCustom;
        self.statusBarNeedsHidden = NO;
        self.hideByTouch = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL nightSchemeEnabled = [ColoredVKNightScheme sharedScheme].enabled;
    
    _UIBackdropViewStyle backgroundStyle = nightSchemeEnabled ? _UIBackdropViewStyleDark : _UIBackdropViewSettingsUltraLight;
    _UIBackdropView *backgroundView = [[_UIBackdropView alloc] initWithStyle:backgroundStyle];
    self.backgroundView = backgroundView;
    
    self.contentView = [ColoredVKPasscodeView loadNib];
    self.contentView.titleText = CVKLocalizedString(@"ENTER_PASSCODE");
    self.contentView.delegate = self;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.contentView.bottomRightButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.contentView.bottomRightButton setTitle:UIKitLocalizedString(@"Cancel") forState:UIControlStateNormal];
    [self.contentView.bottomRightButton setTitle:@"" forState:UIControlStateSelected];
    [self.contentView.bottomRightButton setTitleColor:CVKAltColor forState:UIControlStateNormal];
    
    UIImage *backspace = CVKImageInBundle(@"BackspaceIcon", self.cvkBundle);
    backspace = [backspace imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.contentView.bottomRightButton.imageView.tintColor = CVKAltColor;
    [self.contentView.bottomRightButton setImage:backspace forState:UIControlStateSelected];
    
    
    if (nightSchemeEnabled) {
        self.contentView.tintColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
    } else {
        self.contentView.tintColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    }
    
    [self setupConstraints];
}

- (void)setupConstraints
{
    UILayoutGuide *guide = self.view.layoutMarginsGuide;
    if (@available(iOS 11.0, *)) {
        guide = self.view.safeAreaLayoutGuide;
    }
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView.topAnchor constraintEqualToAnchor:guide.topAnchor].active = YES;
    [self.contentView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
    [self.contentView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor].active = YES;
    [self.contentView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor].active = YES; 
}

+ (void)performFeedbackWithType:(UINotificationFeedbackType)type
{
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
            [generator prepare];
            [generator notificationOccurred:type];
        });
    }
}

- (void)performFeedbackWithType:(UINotificationFeedbackType)type
{
    [self.class performFeedbackWithType:type];
}

#pragma mark -
#pragma mark ColoredVKPasscodeViewDelegate
#pragma mark -

- (void)passcodeView:(ColoredVKPasscodeView *)passcodeView didUpdatedPasscode:(NSString *)passcode
{
    
}

- (void)passcodeView:(ColoredVKPasscodeView *)passcodeView didTapBottomButton:(UIButton *)button
{
    
}

- (void)passcodeView:(ColoredVKPasscodeView *)passcodeView didTapForgotButton:(UIButton *)button
{
    ColoredVKAlertController *alert = [ColoredVKAlertController alertControllerWithTitle:button.titleLabel.text
                                                                                 message:CVKLocalizedString(@"FORGOT_PASSCODE_DETAIL_MESSAGE")];
    [alert addCancelAction];
    [alert addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"LOG_OUT_OF_ACCOUNT_ALERT") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        ColoredVKUserModel *user = [ColoredVKNewInstaller sharedInstaller].user;
        [user logoutWithCompletionBlock:^{
            [self hide];
        }];
    }]];
    [alert present];
}

@end
