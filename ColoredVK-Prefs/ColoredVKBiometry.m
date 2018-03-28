//
//  ColoredVKBiometry.m
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import "ColoredVKBiometry.h"
#import "PrefixHeader.h"

#import <LocalAuthentication/LocalAuthentication.h>
#import <AudioToolbox/AudioServices.h>

@interface ColoredVKBiometry ()

@property (strong, nonatomic) LAContext *authContext;

@property (strong, nonatomic) NSString *passcode;
@property (nonatomic, copy) void (^successBlock)(void);
@property (nonatomic, copy) void (^failureBlock)(void);

@end

@implementation ColoredVKBiometry

+ (void)authenticateWithPasscode:(NSString *)passcode success:( void(^)(void) )successBlock failure:( void(^)(void) )failureBlock
{
    ColoredVKBiometry *biometry = [ColoredVKBiometry new];
    biometry.successBlock = [successBlock copy];
    biometry.failureBlock = [failureBlock copy];
    biometry.passcode = passcode;
    [biometry show];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.authContext = [LAContext new];
        
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
    
    if (self.supportsTouchID || self.supportsFaceID) {
        self.contentView.bottomLeftButton.alpha = 0.8f;
        
        NSString *imageName = self.supportsTouchID ? @"prefs/FingerprintIcon" : @"prefs/FaceIcon";
        UIImage *image = [UIImage imageNamed:imageName inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.contentView.bottomLeftButton setImage:image forState:UIControlStateNormal];
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self actionAuthenticate];
    });
}


#pragma mark -
#pragma mark Actions
#pragma mark -

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

- (void)passcodeView:(ColoredVKPasscodeView *)passcodeView didTapBottomButton:(UIButton *)button
{
    if ([button isEqual:passcodeView.bottomRightButton]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.failureBlock)
                self.failureBlock();
        });
        
        [self hide];
    } else if ([button isEqual:passcodeView.bottomLeftButton]) {
        [self actionAuthenticate];
    }
}

@end
