//
//  ColoredVKNewInstaller.m
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

#import "ColoredVKNewInstaller.h"

#import "PrefixHeader.h"
#import "ColoredVKCrypto.h"
#import <sys/utsname.h>
#import "ColoredVKHUD.h"
#import "ColoredVKWebViewController.h"
#import "ColoredVKAlertController.h"
#import "ColoredVKUpdatesController.h"
#import <MobileGestalt.h>
#include <mach-o/dyld.h>

static NSString * _Nullable const kDRMPackage = @"org.thebigboss.coloredvk2";
#define kDRMLicencePath         [CVK_PREFS_PATH stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"]
#define kDRMRemoteServerURL     [NSString stringWithFormat:@"%@/index-new.php", kPackageAPIURL]


@interface ColoredVKNewInstaller ()


@property (strong, nonatomic) UIWindow *hudWindow;
@property (weak, nonatomic) ColoredVKHUD *hud;

@end


@implementation ColoredVKNewInstaller

void(^installerCompletionBlock)(BOOL purchased);
NSString *key;

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
        _networkController = [ColoredVKNetworkController controller];
        key = legacyEncryptServerString([NSProcessInfo processInfo].globallyUniqueString);
        _user = [ColoredVKUserModel new];
        _application = [ColoredVKApplicationModel new];
        
        struct utsname systemInfo;
        uname(&systemInfo);
        _deviceModel = @(systemInfo.machine);
        _sellerName = @"theux";
        
        _jailed = NO;
        _shouldOpenPrefs = NO;
        
        [self createFolders];
        [self checkStatus];
        [self updateAppInfo];
    }
    return self;
}

- (void)createFolders
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:CVK_FOLDER_PATH])
        [fileManager createDirectoryAtPath:CVK_FOLDER_PATH withIntermediateDirectories:NO attributes:nil error:nil];
    if (![fileManager fileExistsAtPath:CVK_CACHE_PATH])
        [fileManager createDirectoryAtPath:CVK_CACHE_PATH  withIntermediateDirectories:NO attributes:nil error:nil];
    if (![fileManager fileExistsAtPath:CVK_BACKUP_PATH])
        [fileManager createDirectoryAtPath:CVK_BACKUP_PATH withIntermediateDirectories:NO attributes:nil error:nil];
}

- (void)updateAppInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (NSClassFromString(@"Activation") != nil) {
            self->_sellerName = @"iapps";
        } else if ([self.application.teamIdentifier isEqualToString:@"FL663S8EYD"]) {
            self->_sellerName = @"ishmv";
        }
        
        ColoredVKUpdatesController *updatesController = [ColoredVKUpdatesController new];
        updatesController.checkedAutomatically = YES;
        if (updatesController.shouldCheckUpdates)
            [updatesController checkUpdates];
    });
}

- (void)checkStatus
{
#define writeFreeLicenceAndReturn \
[self writeFreeLicence];\
return;
    
#ifndef COMPILE_APP
    NSString *bundleID = [NSBundle mainBundle].bundleIdentifier.lowercaseString;
    NSUInteger maxCVKLibsCount = [bundleID containsString:@"vkclient"] ? 2 : 1;
    NSUInteger cvkLibsCount = 0;
    for (uint32_t i=0; i<_dyld_image_count(); i++) {
        if (strstr(_dyld_get_image_name(i), "ColoredVK") != nil)
            cvkLibsCount++;
    }
    
    if (cvkLibsCount != maxCVKLibsCount)
        return;
#endif
    
    if (access(kDRMLicencePath.UTF8String, F_OK) == -1) {
        writeFreeLicenceAndReturn
    }
 
    NSData *decryptedData = decryptData([NSData dataWithContentsOfFile:kDRMLicencePath], nil);
    NSDictionary *dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
    
    if (![dict isKindOfClass:[NSDictionary class]] || (dict.allKeys.count == 0)) {
        writeFreeLicenceAndReturn
    }
    
#ifndef COMPILE_APP
    if (![dict[@"Device"] isEqualToString:_deviceModel]) {
        writeFreeLicenceAndReturn
    }
#endif
        
    if ([dict[@"jailed"] boolValue]) {
        _jailed = YES;
        NSString *licenceUdid = dict[@"udid"];
        NSString *deviceUdid = CFBridgingRelease(MGCopyAnswer(kMGUniqueDeviceID));
        
        if ((licenceUdid.length != 40) || ![licenceUdid isEqualToString:deviceUdid]) {
            writeFreeLicenceAndReturn
        }
        
        if ([dict[@"purchased"] boolValue]) {
            _shouldOpenPrefs = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.reload.prefs.menu" object:nil];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), 
                                                 CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
            if (installerCompletionBlock)
                installerCompletionBlock(YES);
        }
        
    } else {
        self.user.name = dict[@"Login"];
        self.user.userID = dict[@"user_id"];
        self.user.accessToken = dict[@"token"];
        self.user.email = dict[@"email"];
        if (self.user.name.length > 0) {
            self.user.authenticated = YES;
        }
        BOOL purchased = [dict[@"purchased"] boolValue];
        if (purchased) {
            self.user.accountStatus = ColoredVKUserAccountStatusPaid;
            
            if (installerCompletionBlock)
                installerCompletionBlock(YES);
        }
    }
#undef writeFreeLicenceAndReturn
}

- (void)showAlertWithTitle:(NSString *)title text:(NSString *)text buttons:(NSArray <__kindof UIAlertAction *> *)buttons
{
    if (buttons.count == 0) {
        buttons = @[[UIAlertAction actionWithTitle:UIKitLocalizedString(@"OK") style:UIAlertActionStyleCancel 
                                           handler:^(UIAlertAction *action) {}]];
    }
    if (!title)
        title = kPackageName;
    
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:title 
                                                                                           message:text 
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
    for (UIAlertAction *action in buttons) {
        [alertController addAction:action];
    }
    [alertController present];
}

- (void)showHudWithText:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hudWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.hudWindow.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        self.hudWindow.userInteractionEnabled = NO;
        [self.hudWindow makeKeyAndVisible];
        
        self.hud = [ColoredVKHUD showHUDForView:self.hudWindow];
        [self.hud resetWithStatus:text];
        self.hud.dismissByTap = NO;
    });
}

- (void)hideHud
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hud.didHiddenBlock = ^{
            self.hudWindow = nil;
        };
        [self.hud hide];
    });
}


#pragma mark -
#pragma mark Backend
#pragma mark -

- (void)actionPurchase
{
    if (!self.user.userID) {
        [self showAlertWithTitle:CVKLocalizedString(@"WARNING") text:CVKLocalizedString(@"ENTER_ACCOUNT_FIRST") buttons:nil];
        return;
    }
    
    ColoredVKWebViewController *webController = [ColoredVKWebViewController new];
    
    NSDictionary *params = @{@"user_id" :self.user.userID, @"profile_team_id": self.application.teamIdentifier, @"from": self.sellerName};
    webController.request = [self.networkController requestWithMethod:@"POST" URLString:kPackagePurchaseLink parameters:params error:nil];
    [webController present];  
}

- (void)writeFreeLicence
{
    [self.user clearUser];
    NSString *udid = CFBridgingRelease(MGCopyAnswer(kMGUniqueDeviceID));
    
    NSDictionary *dict = @{@"purchased" : @NO, @"Device" : self.deviceModel, 
                           @"jailed" : (udid.length == 40) ? @YES : @NO, @"udid" : (udid.length == 40) ? udid : @"" };
    NSData *encryptedData = encryptData([NSKeyedArchiver archivedDataWithRootObject:dict], nil);
    [encryptedData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:nil];
    
    if (udid.length == 40) {
        _jailed = YES;
        [self downloadJBLicence];
    }
}

- (void)downloadJBLicence
{
    NSString *udid = CFBridgingRelease(MGCopyAnswer(kMGUniqueDeviceID));
    if (udid.length != 40)
        return;
    
    NSDictionary *params = @{@"udid": legacyEncryptServerString(udid), @"package":legacyEncryptServerString(kDRMPackage), 
                             @"version":kPackageVersion, @"key": key};
    [self.networkController sendJSONRequestWithMethod:@"POST" stringURL:kDRMRemoteServerURL parameters:params success:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSDictionary *json) {
        if (!json[@"response"])
            return;
        
        NSDictionary *response = json[@"response"];
        
        if (![response[@"key"] isEqualToString:key] || ![response[@"udid"] isEqualToString:udid])
            return;
        
        NSDictionary *dict = @{@"Device":self.deviceModel, @"udid":udid, @"jailed":@YES, @"purchased":@YES};
        NSError *writingError = nil;
        NSData *encryptedData = encryptData([NSKeyedArchiver archivedDataWithRootObject:dict], nil);
        [encryptedData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:&writingError];
        
        if (writingError)
            return;
        
        self->_shouldOpenPrefs = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.reload.prefs.menu" object:nil];
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), 
                                             CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
        if (installerCompletionBlock) 
            installerCompletionBlock(YES);
    } failure:nil];
}

@end
