//
//  ColoredVKBiometry.m
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import "ColoredVKBiometry.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "COloredVKNewInstaller.h"

NS_ASSUME_NONNULL_BEGIN

@interface ColoredVKBiometry ()

@property (strong, nonatomic) LAContext *authContext;

@property (copy, nonatomic) void (^successBlock)(void);
@property (copy, nonatomic) void (^failureBlock)(void);

@end

__strong NSNumber *__biometryDefaultPasswordIsSet;

@implementation ColoredVKBiometry
__strong NSString *__biometryPasscode;

+ (void)authenticateWithSuccess:( void(^)(void) )successBlock failure:( void(^_Nullable)(void) )failureBlock
{
    NSData *menuPasscodeData = [ColoredVKNewInstaller sharedInstaller].user.menuPasscode;
    if (!menuPasscodeData) {
        __biometryDefaultPasswordIsSet = @NO;
        return;
    }
    
    __biometryPasscode = [[NSString alloc] initWithData:menuPasscodeData encoding:NSUTF8StringEncoding];
    if (!__biometryPasscode || __biometryPasscode.length == 0) {
        __biometryDefaultPasswordIsSet = @NO;
        return;
    }
    
    ColoredVKBiometry *biometry = [ColoredVKBiometry new];
    biometry.successBlock = [successBlock copy];
    biometry.failureBlock = [failureBlock copy];
    [biometry show];
}

+ (BOOL)defaultPasswordIsSet
{
    if (!__biometryDefaultPasswordIsSet) {
        BOOL defaultPasswordIsSet = NO;
        NSData *menuPasscodeData = [ColoredVKNewInstaller sharedInstaller].user.menuPasscode;
        if (menuPasscodeData) {
            NSString *stringPasscode = [[NSString alloc] initWithData:menuPasscodeData encoding:NSUTF8StringEncoding];
            defaultPasswordIsSet = stringPasscode.length > 0;
        }
        
        __biometryDefaultPasswordIsSet = @(defaultPasswordIsSet);
    }
    
    return __biometryDefaultPasswordIsSet.boolValue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.authContext = [LAContext new];
        
        _supportsTouchID = [self.authContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
        if (@available(iOS 11.0, *)) {
            _supportsFaceID = (self.authContext.biometryType == LABiometryTypeFaceID);
            _supportsFaceID = (self.supportsFaceID && [self.cvkBundle objectForInfoDictionaryKey:@"NSFaceIDUsageDescription"]);
            
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
        UIImage *image = CVKImageInBundle(imageName, self.cvkBundle);
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

- (void)dismissWithSuccess
{
    [self performFeedbackWithType:UINotificationFeedbackTypeSuccess];
    
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
    
    NSString *reson = CVKLocalizedStringInBundle(@"ACCESS_TO_ENCRYPTED_MENU", self.cvkBundle);
    [self.authContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reson reply:^(BOOL success, NSError * _Nullable error) {
        if (!success) {
            if (error.code == -1) {
                [self performFeedbackWithType:UINotificationFeedbackTypeError];
                [self.contentView invalidate];
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
    if ([__biometryPasscode isEqualToString:passcode]) {
         [self dismissWithSuccess];
    } else {
        [self performFeedbackWithType:UINotificationFeedbackTypeError];
        [self.contentView invalidate];
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

- (void)dealloc
{
    __biometryPasscode = nil;
}

@end


NS_ASSUME_NONNULL_END
