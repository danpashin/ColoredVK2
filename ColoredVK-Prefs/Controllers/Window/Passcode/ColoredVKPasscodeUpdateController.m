//
//  ColoredVKPasscodeUpdateController.m
//  ColoredVK2
//
//  Created by Даниил on 21/07/2018.
//

#import "ColoredVKPasscodeUpdateController.h"
#import "COloredVKNewInstaller.h"
#import "ColoredVKBiometry.h"

typedef NS_ENUM(NSInteger, ColoredVKPasscodeUpdateControllerType) {
    ColoredVKPasscodeUpdateControllerTypeNew,
    ColoredVKPasscodeUpdateControllerTypeUpdate
};


@interface ColoredVKPasscodeUpdateController ()

@property (copy, nonatomic) NSString *passcode;
@property (assign, nonatomic) ColoredVKPasscodeUpdateControllerType type;
@property (copy, nonatomic) ColoredVKPasscodeUpdateControllerCompletion completion;

@end


@implementation ColoredVKPasscodeUpdateController
__strong NSString *__oldMenuPasscode;
BOOL __oldMenuPasscodeValid = NO;

+ (void)setNewPasscode:(ColoredVKPasscodeUpdateControllerCompletion)completion
{
    ColoredVKPasscodeUpdateController *passcodeController = [ColoredVKPasscodeUpdateController new];
    passcodeController.type = ColoredVKPasscodeUpdateControllerTypeNew;
    passcodeController.completion = [completion copy];
    [passcodeController show];
}

+ (void)updatePasscode:(ColoredVKPasscodeUpdateControllerCompletion)completion
{
    ColoredVKPasscodeUpdateController *passcodeController = [ColoredVKPasscodeUpdateController new];
    passcodeController.type = ColoredVKPasscodeUpdateControllerTypeUpdate;
    passcodeController.completion = [completion copy];
    [passcodeController show];
}

+ (void)removePasscode:(ColoredVKPasscodeUpdateControllerCompletion)completion
{
    [ColoredVKBiometry authenticateWithSuccess:^{
        __biometryDefaultPasswordIsSet = @NO;
        
        ColoredVKUserModel *userModel = [ColoredVKNewInstaller sharedInstaller].user;
        userModel.menuPasscode = nil;
        
        NSDictionary *licence = RSADecryptLicenceData(nil);
        NSMutableDictionary *dict = licence ? [licence mutableCopy] : [NSMutableDictionary dictionary];
        dict[@"user"] = [NSKeyedArchiver archivedDataWithRootObject:userModel];
        RSAEncryptAndWriteLicenceData(dict, nil);
        
        if (completion)
            completion(NO);
    } failure:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSData *passcodeData = [ColoredVKNewInstaller sharedInstaller].user.menuPasscode;
    if (passcodeData)
        __oldMenuPasscode = [[NSString alloc] initWithData:passcodeData encoding:NSUTF8StringEncoding];
    
    if (self.type == ColoredVKPasscodeUpdateControllerTypeNew) {
        self.contentView.forgotPassButton.hidden = YES;
        self.contentView.titleText = CVKLocalizedString(@"ENTER_NEW_PASSCODE");
    } else if (self.type == ColoredVKPasscodeUpdateControllerTypeUpdate) {
        self.contentView.titleText = CVKLocalizedString(@"ENTER_OLD_PASSCODE");
    }
}

- (void)verifyNewPasscode:(NSString *)passcode
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.passcode) {
            if ([self.passcode isEqualToString:passcode]) {
                [self performFeedbackWithType:UINotificationFeedbackTypeSuccess];
                [self hide];
            } else {
                self.passcode = nil;
                self.contentView.titleText = CVKLocalizedString(@"PASSCODES_DO_NOT_MATCH");
                [self.contentView invalidate];
                [self performFeedbackWithType:UINotificationFeedbackTypeError];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.contentView.titleText = CVKLocalizedString(@"ENTER_NEW_PASSCODE");
                });
            }
        } else {
            self.passcode = passcode;
            [self.contentView invalidateWithError:NO];
            self.contentView.titleText = CVKLocalizedString(@"CONFIRM_PASSCODE");
        }
    });
}

- (void)hide
{
    if (self.passcode) {
        __biometryDefaultPasswordIsSet = @YES;
        ColoredVKUserModel *userModel = [ColoredVKNewInstaller sharedInstaller].user;
        userModel.menuPasscode = [self.passcode dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *licence = RSADecryptLicenceData(nil);
        NSMutableDictionary *dict = licence ? [licence mutableCopy] : [NSMutableDictionary dictionary];
        dict[@"user"] = [NSKeyedArchiver archivedDataWithRootObject:userModel];
        RSAEncryptAndWriteLicenceData(dict, nil);
    }
    
    if (self.completion)
        self.completion(__biometryDefaultPasswordIsSet.boolValue);
    
    [super hide];
}

- (void)dealloc
{
    __oldMenuPasscodeValid = NO;
    __oldMenuPasscode = nil;
}


#pragma mark -
#pragma mark ColoredVKPasscodeViewDelegate
#pragma mark -

- (void)passcodeView:(ColoredVKPasscodeView *)passcodeView didUpdatedPasscode:(NSString *)passcode
{
    if (self.type == ColoredVKPasscodeUpdateControllerTypeNew) {
        [self verifyNewPasscode:passcode];
    } 
    else if (self.type == ColoredVKPasscodeUpdateControllerTypeUpdate) {
        
        if (!__oldMenuPasscodeValid) {
            if (![__oldMenuPasscode isEqualToString:passcode]) {
                [self.contentView invalidate];
                self.contentView.titleText = CVKLocalizedString(@"INVALID_PASSCODE");
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.contentView.titleText = CVKLocalizedString(@"ENTER_OLD_PASSCODE");
                });
            } else {
                self.contentView.forgotPassButton.hidden = YES;
                [self.contentView invalidateWithError:NO];
                self.contentView.titleText = CVKLocalizedString(@"ENTER_NEW_PASSCODE");
                __oldMenuPasscodeValid = YES;
            }
        } else {
            [self verifyNewPasscode:passcode];
        }
        
    }
}

- (void)passcodeView:(ColoredVKPasscodeView *)passcodeView didTapBottomButton:(UIButton *)button
{
    [self hide];
}

@end
