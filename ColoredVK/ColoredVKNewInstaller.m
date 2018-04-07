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

#import "ColoredVKHUD.h"
#import "ColoredVKAlertController.h"
#import "ColoredVKUpdatesController.h"
#import "ColoredVKNetwork.h"

#import <sys/utsname.h>
#import <MobileGestalt.h>
#import <mach-o/dyld.h>
#import <libgen.h>

#define kDRMLicencePath         [CVK_PREFS_PATH stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"]
#define kDRMRemoteServerURL     [NSString stringWithFormat:@"%@/index-new.php", kPackageAPIURL]


@interface ColoredVKNewInstaller ()

@property (strong, nonatomic) UIWindow *hudWindow;
@property (weak, nonatomic) ColoredVKHUD *hud;

@end


@implementation ColoredVKNewInstaller

void(^installerCompletionBlock)(BOOL purchased);
NSString *__key;
NSString *__deviceModel;
NSString *__udid;

BOOL deviceIsJailed;

BOOL installerShouldOpenPrefs;


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
        __key = legacyEncryptServerString([NSProcessInfo processInfo].globallyUniqueString);
        __udid = CFBridgingRelease(MGCopyAnswer(CFSTR("re6Zb+zwFKJNlkQTUeT+/w")));
        deviceIsJailed = (__udid.length == 40);
        
        _user = [ColoredVKUserModel new];
        _application = [ColoredVKApplicationModel new];
        
        struct utsname systemInfo;
        uname(&systemInfo);
        __deviceModel = @(systemInfo.machine);
        
        deviceIsJailed = NO;
        installerShouldOpenPrefs = NO;
        
        [self createFolders];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            ColoredVKUpdatesController *updatesController = [ColoredVKUpdatesController new];
            updatesController.checkedAutomatically = YES;
            if (updatesController.shouldCheckUpdates)
                [updatesController checkUpdates];
        });
    }
    return self;
}

- (void)createFolders
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:CVK_FOLDER_PATH])
            [fileManager createDirectoryAtPath:CVK_FOLDER_PATH withIntermediateDirectories:NO attributes:nil error:nil];
        if (![fileManager fileExistsAtPath:CVK_CACHE_PATH])
            [fileManager createDirectoryAtPath:CVK_CACHE_PATH  withIntermediateDirectories:NO attributes:nil error:nil];
        
        if ([fileManager fileExistsAtPath:CVK_BACKUP_PATH])
            [fileManager removeItemAtPath:CVK_BACKUP_PATH error:nil];
    });
}

- (void)checkStatus
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
#define writeFreeLicenceAndReturn \
[self writeFreeLicence];\
return;
        
#ifndef COMPILE_APP
        char pathbuf[PATH_MAX + 1];
        uint32_t bufsize = sizeof(pathbuf);
        _NSGetExecutablePath(pathbuf, &bufsize);
        
        char *executable_name = basename(pathbuf);
        for(int i = 0; executable_name[i]; i++){
            executable_name[i] = (char)tolower(executable_name[i]);
        }
        
        int maxLibsCount = (strstr(executable_name, "vkclient") != NULL) ? 2 : 1;
        int libsCount = 0;
        for (uint32_t i=0; i<_dyld_image_count(); i++) {
            const char *imageName = _dyld_get_image_name(i);
            if (strstr(imageName, "ColoredVK2") != NULL) {
                libsCount++;
            }
            
            if (strstr(imageName, "Crack") != NULL) {
                libsCount++;
            }
            
            if (strstr(imageName, "crack") != NULL) {
                libsCount++;
            }
        }
        
        if (libsCount > maxLibsCount)
            return;
#endif
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:kDRMLicencePath]) {
            writeFreeLicenceAndReturn
        }
        
        NSData *decryptedData = decryptData([NSData dataWithContentsOfFile:kDRMLicencePath], nil);
        NSDictionary *dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
        
        if (![dict isKindOfClass:[NSDictionary class]] || (dict.allKeys.count == 0)) {
            writeFreeLicenceAndReturn
        }
        
#ifndef COMPILE_APP
        if (![dict[@"Device"] isEqualToString:__deviceModel]) {
            writeFreeLicenceAndReturn
        }
#endif
        
        if ([dict[@"jailed"] boolValue]) {
            deviceIsJailed = YES;
            NSString *licenceUdid = dict[@"udid"];
            
            if (__udid.length != 0) {
                if ((licenceUdid.length != 40) || !deviceIsJailed || ![licenceUdid isEqualToString:__udid]) {
                    writeFreeLicenceAndReturn
                }
            }
            
            if (![dict[@"purchased"] boolValue])
                return;
            
            installerShouldOpenPrefs = YES;
            POST_NOTIFICATION(kPackageNotificationReloadPrefsMenu);
            POST_CORE_NOTIFICATION(kPackageNotificationReloadMenu);
            
            if (installerCompletionBlock)
                installerCompletionBlock(YES);
            
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
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hudWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.hudWindow.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
        self.hudWindow.userInteractionEnabled = NO;
        [self.hudWindow makeKeyAndVisible];
        
        self.hud = [ColoredVKHUD showHUDForView:self.hudWindow];
        [self.hud resetWithStatus:text];
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
#pragma mark Actions
#pragma mark -

- (void)writeFreeLicence
{
    [self.user clearUser];
    
    NSDictionary *dict = @{@"purchased" : @NO, @"Device" : __deviceModel, 
                           @"jailed" : deviceIsJailed ? @YES : @NO, @"udid" : deviceIsJailed ? __udid : @"" };
    NSData *encryptedData = encryptData([NSKeyedArchiver archivedDataWithRootObject:dict], nil);
    [encryptedData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:nil];
    
    if (deviceIsJailed)
        [self downloadJBLicence];
}

- (void)downloadJBLicence
{
    if (!deviceIsJailed)
        return;
    
    NSDictionary *params = @{@"udid": legacyEncryptServerString(__udid), 
                             @"package":legacyEncryptServerString(@"org.thebigboss.coloredvk2"), 
                             @"version":kPackageVersion, @"key": __key};
    
    ColoredVKNetwork *network = [ColoredVKNetwork sharedNetwork];
    [network sendJSONRequestWithMethod:@"POST" stringURL:kDRMRemoteServerURL parameters:params success:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSDictionary *json) {
        if (!json[@"response"])
            return;
        
        NSDictionary *response = json[@"response"];
        
        if (![response[@"key"] isEqualToString:__key] || ![response[@"udid"] isEqualToString:__udid])
            return;
        
        NSDictionary *dict = @{@"Device":__deviceModel, @"udid":__udid, @"jailed":@YES, @"purchased":@YES};
        NSError *writingError = nil;
        NSData *encryptedData = encryptData([NSKeyedArchiver archivedDataWithRootObject:dict], nil);
        [encryptedData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:&writingError];
        
        if (writingError)
            return;
        
        installerShouldOpenPrefs = YES;
        POST_NOTIFICATION(kPackageNotificationReloadPrefsMenu);
        POST_CORE_NOTIFICATION(kPackageNotificationReloadMenu);
        
        if (installerCompletionBlock) 
            installerCompletionBlock(YES);
    } failure:nil];
}

@end
