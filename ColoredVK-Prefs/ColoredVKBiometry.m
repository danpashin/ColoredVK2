//
//  ColoredVKBiometry.m
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import "ColoredVKBiometry.h"

#import "_UIBackdropView.h"
#import "PrefixHeader.h"
#import "ColoredVKPasscodeView.h"
#import "ColoredVKNightThemeColorScheme.h"

#import <dlfcn.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <AudioToolbox/AudioServices.h>

@interface ColoredVKBiometry () <ColoredVKPasscodeViewDelegate>

@property (strong, nonatomic) NSBundle *cvkBundle;
@property (strong, nonatomic) LAContext *authContext;

@property (strong, nonatomic) NSString *passcode;
@property (nonatomic, copy) void (^successBlock)(void);
@property (nonatomic, copy) void (^failureBlock)(void);

@property (strong, nonatomic) ColoredVKPasscodeView *contentView;

@end


@implementation ColoredVKBiometry

@dynamic contentView;

+ (void)authenticateWithPasscode:(NSString *)passcode success:( void(^)(void) )successBlock failure:( void(^)(void) )failureBlock
{
    ColoredVKBiometry *biometry = [ColoredVKBiometry new];
    biometry.successBlock = [successBlock copy];
    biometry.failureBlock = [failureBlock copy];
    biometry.passcode = passcode;
    [biometry show];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (IS_IPAD)
        return UIInterfaceOrientationMaskAll;
    
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if ([ColoredVKNightThemeColorScheme sharedScheme].enabled)
        return UIStatusBarStyleLightContent;
    
    return UIStatusBarStyleDefault;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        self.authContext = [LAContext new];
        self.backgroundStyle = ColoredVKWindowBackgroundStyleCustom;
        self.statusBarNeedsHidden = NO;
        self.hideByTouch = NO;
        
        _supportsTouchID = [self.authContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
        if (@available(iOS 11.0, *)) {
            _supportsFaceID = (self.authContext.biometryType == LABiometryTypeFaceID);
            _supportsTouchID = (self.supportsTouchID && (self.authContext.biometryType == LABiometryTypeTouchID));
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BOOL nightSchemeEnabled = [ColoredVKNightThemeColorScheme sharedScheme].enabled;
    
    _UIBackdropViewStyle backgroundStyle = nightSchemeEnabled ? _UIBackdropViewStyleDark : _UIBackdropViewSettingsUltraLight;
    _UIBackdropView *backgroundView = [[_UIBackdropView alloc] initWithStyle:backgroundStyle];
    self.backgroundView = backgroundView;
    
    NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    NSArray *nibViews = [cvkBundle loadNibNamed:NSStringFromClass([ColoredVKPasscodeView class]) owner:self options:nil];
    self.contentView = nibViews.firstObject;
    self.contentView.delegate = self;
    self.contentView.supportsTouchID = self.supportsTouchID;
    self.contentView.supportsFaceID = self.supportsFaceID;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    if (nightSchemeEnabled) {
        self.contentView.tintColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
    } else {
        backgroundView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
        self.contentView.tintColor = [UIColor colorWithRed:84/255.0f green:85/255.0f blue:85/255.0f alpha:1.0f];
    }
    
    
    [self setupConstrains];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self actionAuthenticate];
    });
}

- (void)setupConstrains
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

- (void)tapticFeedbackWithType:(UINotificationFeedbackType)type
{
    if (@available(iOS 10.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
            [generator prepare];
            [generator notificationOccurred:type];
        });
    }
}

- (void)dismissWithSuccess
{
    [self hide];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.successBlock)
            self.successBlock();
    });
}

#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)actionAuthenticate
{
    if (!self.supportsTouchID && !self.supportsFaceID)
        return;
    
    NSString *reson = CVKLocalizedStringInBundle(@"ACCESS_TO_ACCOUNT_SETTINGS", self.cvkBundle);
    [self.authContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reson reply:^(BOOL success, NSError * _Nullable error) {
        if (!success) {
            if (error.code == -1) {
                [self tapticFeedbackWithType:UINotificationFeedbackTypeError];
                self.contentView.invalidPasscode = YES;
            }
            return;
        }
        [self dismissWithSuccess];
    }];
}


#pragma mark -
#pragma mark ColoredVKPasscodeViewDelegate
#pragma mark -

- (void)passcodeView:(ColoredVKPasscodeView *)passcodeView didUpdatedPasscode:(NSString *)passcode
{
    if ([self.passcode isEqualToString:passcode]) {
        [self tapticFeedbackWithType:UINotificationFeedbackTypeSuccess];
         [self dismissWithSuccess];
    } else {
        [self tapticFeedbackWithType:UINotificationFeedbackTypeError];
        self.contentView.invalidPasscode = YES;
    }
}

- (void)passcodeViewRequestedDismiss:(ColoredVKPasscodeView *)passcodeView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.failureBlock)
            self.failureBlock();
    });
    
    [self hide];
}

- (void)passcodeViewRequestedBiometric:(ColoredVKPasscodeView *)passcodeView
{
    [self actionAuthenticate];
}

@end
