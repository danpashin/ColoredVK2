//
//  ColoredVKNewInstaller.m
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

#import "ColoredVKNewInstaller.h"

#import "ColoredVKHUD.h"
#import "ColoredVKAlertController.h"
#import "ColoredVKUpdatesModel.h"
#import "ColoredVKNetwork.h"


@interface ColoredVKNewInstaller ()
@property (weak, nonatomic) ColoredVKHUD *hud;
@end


@implementation ColoredVKNewInstaller
void(^installerCompletionBlock)(BOOL purchased);
NSString *__key;

BOOL installerShouldOpenPrefs;

@synthesize user = _user;

+ (instancetype)sharedInstaller
{
    static id instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        __key = RSAEncryptServerString([NSProcessInfo processInfo].globallyUniqueString);
        _application = [ColoredVKApplicationModel new];
        
        [self createFolders];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            ColoredVKUpdatesModel *updatesModel = [ColoredVKUpdatesModel new];
            updatesModel.checkedAutomatically = YES;
            if (updatesModel.shouldCheckUpdates)
                [updatesModel checkUpdates];
        });
    }
    return self;
}

- (void)createFolders
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        cvk_createFolder(CVK_FOLDER_PATH, nil);
        cvk_createFolder(CVK_BACKUP_PATH, nil);
    });
}

- (void)checkStatus
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
#define writeFreeLicenceAndReturn \
[self writeFreeLicence];\
return;
        
        if (__suspiciousLibsDetected)
            return;
        
        NSDictionary *dict = RSADecryptLicenceData(nil);
        if (!dict) {
            writeFreeLicenceAndReturn
        }
        
#ifndef COMPILE_APP
        if (![dict[@"Device"] isEqualToString:__deviceModel]) {
            writeFreeLicenceAndReturn
        }
#endif
        
        if ([dict[@"jailed"] boolValue]) {
            __deviceIsJailed = YES;
            NSString *licenceUdid = dict[@"udid"];
            
            if ((__udid.length != 0) && ((licenceUdid.length != 40) || !__deviceIsJailed || ![licenceUdid isEqualToString:__udid])) {
                writeFreeLicenceAndReturn
            }
            
            if (![dict[@"purchased"] boolValue]) {
                [self downloadJBLicence];
                return;
            }
            
            installerShouldOpenPrefs = YES;
            POST_NOTIFICATION(kPackageNotificationReloadPrefsMenu);
            
            if (installerCompletionBlock)
                installerCompletionBlock(YES);
            
        } else {
            
            if ([dict[@"user"] isKindOfClass:[NSData class]]) {
                self->_user = [NSKeyedUnarchiver unarchiveObjectWithData:dict[@"user"]];
            } else {
                self.user.name = dict[@"Login"];
                self.user.userID = dict[@"user_id"];
                self.user.accessToken = dict[@"token"];
                self.user.email = dict[@"email"];
            }
            
            if (self.user.name.length > 0)
                self.user.authenticated = YES;
            
            
            BOOL purchased = [dict[@"purchased"] boolValue];
            self.user.accountStatus = purchased ? ColoredVKUserAccountStatusPaid : ColoredVKUserAccountStatusFree;
            if (purchased && installerCompletionBlock)
                installerCompletionBlock(YES);
            
            if (!purchased)
                [self downloadJBLicence];
        }
#undef writeFreeLicenceAndReturn
    });
}

- (ColoredVKUserModel *)user
{
    if (!_user) {
        _user = [ColoredVKUserModel new];
    }
    return _user;
}

- (void)showAlertWithTitle:(NSString *)title text:(NSString *)text buttons:(NSArray <__kindof UIAlertAction *> *)buttons
{
    if (!title)
        title = kPackageName;
    
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:title message:text];
    if (buttons.count == 0) {
        [alertController addCancelActionWithTitle:UIKitLocalizedString(@"OK")];
    } else {
        for (UIAlertAction *action in buttons) {
            [alertController addAction:action];
        }
    }
    [alertController present];
}

- (void)showHudWithText:(NSString *)text
{
    self.hud = [ColoredVKHUD showHUD];
    self.hud.backgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    [self.hud resetWithStatus:text];
}

- (void)hideHud
{
    [self.hud hide];
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)writeFreeLicence
{
    [self.user clearUser];
    
    if (__deviceModel.length == 0)
        return;
    
    NSDictionary *dict = @{@"purchased" : @NO, @"Device" : __deviceModel, 
                           @"jailed" : @(__deviceIsJailed), @"udid" : __udid };
    RSAEncryptAndWriteLicenceData(dict, nil);
    
    [self downloadJBLicence];
}

- (void)downloadJBLicence
{
    if (!__deviceIsJailed)
        return;
    
    NSDictionary *params = @{@"udid": RSAEncryptServerString(__udid), 
                             @"package":RSAEncryptServerString(@"org.thebigboss.coloredvk2"), 
                             @"version":kPackageVersion, @"key": __key};
    NSString *url = [kPackageAPIURL stringByAppendingString:@"/auth/auth_jail.php"];
    
    ColoredVKNetwork *network = [ColoredVKNetwork sharedNetwork];
    [network sendRequestWithMethod:@"POST" url:url parameters:params success:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSData *rawData) {
        
        NSError *decryptError = nil;
        NSDictionary *json = RSADecryptServerData(rawData, httpResponse, &decryptError);
        
        if (!json || decryptError)
            return;
        
        if (!json[@"response"])
            return;
        
        NSDictionary *response = json[@"response"];
        
        if (![response[@"key"] isEqualToString:__key] || ![response[@"udid"] isEqualToString:__udid])
            return;
        
        NSDictionary *dict = @{@"Device":__deviceModel, @"udid":__udid, @"jailed":@YES, @"purchased":@YES};
        NSError *writingError = nil;
        RSAEncryptAndWriteLicenceData(dict, &writingError);
        
        if (writingError)
            return;
        
        installerShouldOpenPrefs = YES;
        POST_NOTIFICATION(kPackageNotificationReloadPrefsMenu);
        
        if (installerCompletionBlock) 
            installerCompletionBlock(YES);
    } failure:nil];
}

@end
