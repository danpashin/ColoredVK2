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
#import <SafariServices/SafariServices.h>
#import "ColoredVKHUD.h"
#import "ColoredVKWebViewController.h"
#import "ColoredVKAlertController.h"
#import "ColoredVKUpdatesController.h"



#define kDRMLicenceKey          @"1D074B10BBA106699DD7D4AED9E595FA"
#define kDRMPackage             @"org.thebigboss.coloredvk2"
#define kDRMPackageName         kPackageName
#define kDRMPackageVersion      kPackageVersion
#define kDRMLicencePath         [CVK_PREFS_PATH stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"]
#define kDRMRemoteServerURL     [NSString stringWithFormat:@"%@/index-new.php", kPackageAPIURL]



@interface ColoredVKNewInstaller ()

@property (copy, nonatomic) NSString *deviceModel;

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
        key = AES256EncryptStringForAPI([NSProcessInfo processInfo].globallyUniqueString);
        _user = [ColoredVKUser new];
        
        struct utsname systemInfo;
        uname(&systemInfo);
        _deviceModel = @(systemInfo.machine);
        
        _sellerName = @"theux";
        _appTeamIdentifier = @"";
        _appTeamName = @"";
        
        [self createFolders];
        [self checkStatus];
        [self updateAppInfo];
    }
    return self;
}

- (void)createFolders
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:CVK_FOLDER_PATH])  [fileManager createDirectoryAtPath:CVK_FOLDER_PATH withIntermediateDirectories:NO attributes:nil error:nil];
    if (![fileManager fileExistsAtPath:CVK_CACHE_PATH]) [fileManager createDirectoryAtPath:CVK_CACHE_PATH  withIntermediateDirectories:NO attributes:nil error:nil];
    if (![fileManager fileExistsAtPath:CVK_BACKUP_PATH])  [fileManager createDirectoryAtPath:CVK_BACKUP_PATH withIntermediateDirectories:NO attributes:nil error:nil];
}

- (void)updateAppInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (NSClassFromString(@"Activation") != nil) {
            _sellerName = @"iapps";
        }
        
        NSError *error = nil;
        NSURL *provisionURL = [[NSBundle mainBundle] URLForResource:@"embedded" withExtension:@"mobileprovision"];
        NSString *provisionString = [[NSString alloc] initWithContentsOfURL:provisionURL encoding:NSISOLatin1StringEncoding error:&error];
        
        if (!error) {         
            NSString *provisionDictString = @"";
            
            NSScanner *scanner = [NSScanner scannerWithString:provisionString];
            [scanner scanUpToString:@"<plist" intoString:nil];
            [scanner scanUpToString:@"</plist>" intoString:&provisionDictString];
            provisionDictString = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" stringByAppendingString:provisionDictString];
            provisionDictString = [provisionDictString stringByAppendingString:@"</plist>"];
            
            NSString *tempPath = [NSTemporaryDirectory() stringByAppendingString:@"/embedded_mobileprovision.plist"];
            [[provisionDictString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:tempPath atomically:YES];
            
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:tempPath];
            if (dict) {
                _appTeamIdentifier = ((NSArray *)dict[@"TeamIdentifier"]).firstObject;
                _appTeamName = dict[@"TeamName"];
                
                if (![_sellerName isEqualToString:@"iapps"] && [_appTeamIdentifier isEqualToString:@"FL663S8EYD"])
                    _sellerName = @"ishmv";
            }
            [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
        }
        
        ColoredVKUpdatesController *updatesController = [ColoredVKUpdatesController new];
        updatesController.checkedAutomatically = YES;
        if (updatesController.shouldCheckUpdates)
            [updatesController checkUpdates];
    });
}

- (void)checkStatus
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:kDRMLicencePath]) {
        [self writeFreeLicence];
    } else {
        NSData *decryptedData = AES256Decrypt([NSData dataWithContentsOfFile:kDRMLicencePath], kDRMLicenceKey);
        NSDictionary *dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
        if ([dict isKindOfClass:[NSDictionary class]] && (dict.allKeys.count>0)) {
            if (dict[@"Device"]) {
#ifndef COMPILE_APP
                if (![dict[@"Device"] isEqualToString:self.deviceModel]) {
                    [self writeFreeLicence];
                } else {
#endif
                    self.user.name = dict[@"Login"];
                    self.user.userID = dict[@"user_id"];
                    self.user.accessToken = dict[@"token"];
                    self.user.email = dict[@"email"];
                    if (self.user.name.length > 0) {
                        self.user.authenticated = YES;
                        
                        NSString *tokenString = [NSString stringWithFormat:@"%@", self.user.accessToken];
                        tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
                        if (tokenString.length < 20) {
                            [self forceUpdateToken];
                        }
                    }
                    BOOL purchased = [dict[@"purchased"] boolValue];
                    if (purchased) {
                        self.user.accountStatus = ColoredVKUserAccountStatusPaid;
                        
                        if (installerCompletionBlock) {
                            installerCompletionBlock(YES);
                        }
                    }
#ifndef COMPILE_APP
                }
#endif
            } else {
                [self writeFreeLicence];
            }
        } else {
            [self writeFreeLicence];
        }
    }
}

- (void)actionPurchase
{
    if (self.user.userID) {
        ColoredVKWebViewController *webController = [ColoredVKWebViewController new];
        webController.url = [NSURL URLWithString:kPackagePurchaseLink];
        
        NSError *requestError = nil;
        NSDictionary *params = @{@"user_id" :self.user.userID, @"profile_team_id": self.appTeamIdentifier, @"from": self.sellerName};
        NSURLRequest *request = [self.networkController requestWithMethod:@"POST" URLString:webController.url.absoluteString parameters:params error:&requestError];
        
        if (!requestError) {
            webController.request = request;
            [webController present];
        } else {
            [self showAlertWithTitle:nil text:[NSString stringWithFormat:@"Error while creating purchase request:\n%@", requestError.localizedDescription] buttons:nil];
        }
    } else {
        [self showAlertWithTitle:CVKLocalizedString(@"WARNING") text:CVKLocalizedString(@"ENTER_ACCOUNT_FIRST") buttons:nil];
    }
}

- (void)showAlertWithTitle:(NSString *)title text:(NSString *)text buttons:(NSArray <__kindof UIAlertAction *> *)buttons
{
    if (buttons.count == 0) {
        buttons = @[[UIAlertAction actionWithTitle:UIKitLocalizedString(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    }
    if (!title)
        title = kDRMPackageName;
    
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    for (UIAlertAction *action in buttons) {
        [alertController addAction:action];
    }
    [alertController present];
}

- (void)showHudWithText:(NSString *)text
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hudWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.hudWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        self.hudWindow.userInteractionEnabled = NO;
        [self.hudWindow makeKeyAndVisible];
        
        self.hud = [ColoredVKHUD showHUDForView:self.hudWindow];
        [self.hud resetWithStatus:text];
        self.hud.dismissByTap = NO;
        
        __weak typeof(self) weakSelf = self;
        self.hud.didHiddenBlock = ^{
            [weakSelf hideHud];
        };
    });
}

- (void)hideHud
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.hud)
            [self.hud removeFromSuperview];
        self.hud = nil;
        self.hudWindow = nil;
    });
}


#pragma mark -
#pragma mark Backend
#pragma mark -
- (void)updateAccountInfo:( void(^)(void) )completionBlock
{
    if (self.user.userID) {
        if ((self.user.accountStatus == ColoredVKUserAccountStatusPaid) && completionBlock) {
            completionBlock();
        } 
        NSString *url = [NSString stringWithFormat:@"%@/payment/get_info.php", kPackageAPIURL];
        NSDictionary *parameters = @{@"user_id":self.user.userID, @"token":self.user.accessToken};
        
        [self.networkController sendJSONRequestWithMethod:@"POST" stringURL:url parameters:parameters
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
                                                      if (!json[@"error"]) {
                                                          NSDictionary *response = json[@"response"];
                                                          if ([response isKindOfClass:[NSDictionary class]]) {
                                                              BOOL purchased = [response[@"is_purchased"] boolValue];
                                                              if (purchased)
                                                                  self.user.accountStatus = ColoredVKUserAccountStatusPaid;
                                                              
                                                              BOOL banned = [response[@"is_banned"] boolValue];
                                                              if (banned)
                                                                  self.user.accountStatus = ColoredVKUserAccountStatusBanned;
                                                              
                                                              NSData *decryptedData = AES256Decrypt([NSData dataWithContentsOfFile:kDRMLicencePath], kDRMLicenceKey);
                                                              NSMutableDictionary *dict = [(NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData] mutableCopy];
                                                              dict[@"purchased"] = @(purchased);
                                                              NSData *encrypterdData = AES256Encrypt([NSKeyedArchiver archivedDataWithRootObject:dict], kDRMLicenceKey);
                                                              [encrypterdData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:nil];
                                                          }
                                                      }
                                                      
                                                      if (completionBlock) {
                                                          completionBlock();
                                                          
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.reload.prefs.menu" object:nil];
                                                      }
                                                  } 
                                                  failure:nil];
    } else {
        [self.user clearUser];
        if (completionBlock)
            completionBlock();
    }
    
}


- (void)writeFreeLicence
{
    [self.user clearUser];
    
    NSDictionary *dict = @{@"purchased":@NO, @"Device":self.deviceModel};
    NSData *encrypterdData = AES256Encrypt([NSKeyedArchiver archivedDataWithRootObject:dict], kDRMLicenceKey);
    [encrypterdData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:nil];
}


- (void)authWithUsername:(NSString *)userName password:(NSString *)password completionBlock:( void(^)(void) )completionBlock
{
    if (userName.length == 0 || password.length == 0) {
        [self showHudWithText:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.hud showFailureWithStatus:CVKLocalizedString(@"ENTER_CORRECT_LOGIN_PASS")];
        });
        return;
    }
    [self showHudWithText:CVKLocalizedString(@"PLEASE_WAIT")];
    
    NSString *userPassword = AES256EncryptStringForAPI(password);
    
    NSString *device = [NSString stringWithFormat:@"%@ (%@)(%@)", self.deviceModel, [UIDevice currentDevice].name, [UIDevice currentDevice].systemVersion];    
    NSDictionary *parameters = @{@"login": userName, @"password": userPassword, @"action": @"login", 
                                 @"version": kDRMPackageVersion, @"device": device, @"key": key
                                 };
    
    void (^showAlertBlock)(NSError *error) = ^(NSError *error) {
        
        ColoredVKNewInstaller *installer = [ColoredVKNewInstaller sharedInstaller];
        [installer hideHud];
        
        if (error) {
            [self writeFreeLicence];
            [installer showAlertWithTitle:CVKLocalizedString(@"ERROR") text:[NSString stringWithFormat:@"%@\n(Client code %@)", error.localizedDescription, @(error.code)] buttons:nil];
        }
        
        if (completionBlock)
            completionBlock();
    };
    
    [self.networkController sendJSONRequestWithMethod:@"POST" stringURL:kDRMRemoteServerURL parameters:parameters
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
                                             if (!json[@"error"]) {
                                                 if ([json[@"key"] isEqualToString:key]) {
                                                     NSMutableDictionary *dict = @{@"Device":self.deviceModel}.mutableCopy;
                                                     
                                                     self.user.name = userName;
                                                     self.user.userID = json[@"user_id"];
                                                     self.user.email = json[@"user_email"];
                                                     self.user.accessToken = json[@"user_token"];
                                                     self.user.authenticated = YES;
                                                     
                                                     NSNumber *purchased = json[@"purchased"];
                                                     if (purchased.boolValue)
                                                         self.user.accountStatus = ColoredVKUserAccountStatusPaid;
                                                     
                                                     dict[@"Login"] = userName;
                                                     dict[@"user_id"] = self.user.userID;
                                                     dict[@"email"] = self.user.email;
                                                     dict[@"token"] = self.user.accessToken;
                                                     dict[@"purchased"] = purchased;
                                                     
                                                     
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.reload.prefs.menu" object:nil];
                                                     
                                                     NSError *writingError = nil;
                                                     NSData *encrypterdData = AES256Encrypt([NSKeyedArchiver archivedDataWithRootObject:dict], kDRMLicenceKey);
                                                     [encrypterdData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:&writingError];
                                                     
                                                     if (!writingError) {
                                                         showAlertBlock(nil);
                                                         CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
                                                         
                                                         if (purchased && installerCompletionBlock) 
                                                             installerCompletionBlock(YES);
                                                     }
                                                     else showAlertBlock(writingError);
                                                 } else showAlertBlock([NSError errorWithDomain:NSCocoaErrorDomain code:103 userInfo:@{NSLocalizedDescriptionKey:@"Unknown error"}]);
                                             } else {
                                                 NSString *errorMessages = json ? json[@"error"] : @"Unknown error";
                                                 showAlertBlock([NSError errorWithDomain:NSCocoaErrorDomain code:101 userInfo:@{NSLocalizedDescriptionKey:errorMessages}]);
                                             }
                                         } 
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                             showAlertBlock(error);
                                         }];
}


- (void)logoutWithСompletionBlock:( void(^)(void) )completionBlock;
{
    if (!self.user.authenticated)
        return;
    
    [self showHudWithText:CVKLocalizedString(@"PLEASE_WAIT")];
    
    __weak typeof(self) weakSelf = self;
    void (^newCompletionBlock)(NSError *error) = ^(NSError *error){
        [weakSelf hideHud];
        
        if (error)
            [weakSelf showAlertWithTitle:CVKLocalizedString(@"ERROR") text:[NSString stringWithFormat:@"%@\n(Client code %@)", error.localizedDescription, @(error.code)] buttons:nil];
        
        if (completionBlock)
            completionBlock();
    };
    
    NSString *device = [NSString stringWithFormat:@"%@ (%@)(%@)", self.deviceModel, [UIDevice currentDevice].name, [UIDevice currentDevice].systemVersion];
    NSDictionary *parameters = @{@"login": self.user.name, @"token": self.user.accessToken, @"action": @"logout", 
                                 @"version": kDRMPackageVersion, @"device": device, @"key": key
                                 };
    
    [self.networkController sendJSONRequestWithMethod:@"POST" stringURL:kDRMRemoteServerURL parameters:parameters 
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
                                                  if (!json[@"error"]) {
                                                      if ([json[@"key"] isEqualToString:key]) {
                                                          [self writeFreeLicence];
                                                          newCompletionBlock(nil);
                                                          self.user.authenticated = NO;
                                                        if (installerCompletionBlock)
                                                            installerCompletionBlock(NO);
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.reload.prefs.menu" object:nil];
                                                      } else 
                                                          newCompletionBlock([NSError errorWithDomain:NSCocoaErrorDomain code:104 userInfo:@{NSLocalizedDescriptionKey:@"Unknown error"}]);
                                                  } else {
                                                      NSString *errorMessages = json ? json[@"error"] : @"Unknown error";
                                                      newCompletionBlock([NSError errorWithDomain:NSCocoaErrorDomain code:102 userInfo:@{NSLocalizedDescriptionKey:errorMessages}]);
                                                  }
                                              } 
                                              failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                  newCompletionBlock(error);
                                              }];
}

- (void)forceUpdateToken
{
    if (!self.user.name)
        return;
    
    NSString *url = [NSString stringWithFormat:@"%@/updateToken.php", kPackageAPIURL];
    [self.networkController sendJSONRequestWithMethod:@"POST" stringURL:url parameters: @{@"user_login": self.user.name} 
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
                                                  if (json[@"new_token"]) {
                                                      self.user.accessToken = json[@"new_token"];
                                                      
                                                      NSData *licenceDecryptedData = AES256Decrypt([NSData dataWithContentsOfFile:kDRMLicencePath], kDRMLicenceKey);
                                                      NSMutableDictionary *licenceDict = [(NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:licenceDecryptedData] mutableCopy];
                                                      licenceDict[@"token"] = json[@"new_token"];
                                                      
                                                      NSData *licenceEncryptedData = AES256Encrypt([NSKeyedArchiver archivedDataWithRootObject:licenceDict], kDRMLicenceKey);
                                                      [licenceEncryptedData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:nil];
                                                  }
                                              } failure:nil];
}

@end
