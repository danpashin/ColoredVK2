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



#define kDRMLicenceKey          @"1D074B10BBA106699DD7D4AED9E595FA"
#define kDRMPackage             @"org.thebigboss.coloredvk2"
#define kDRMPackageName         kPackageName
#define kDRMPackageVersion      kPackageVersion
#define kDRMLicencePath         [CVK_PREFS_PATH stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"]
#define kDRMRemoteServerURL     [NSString stringWithFormat:@"%@/index-new.php", kPackageAPIURL]





@interface ColoredVKNewInstaller ()

@property (strong, nonatomic) UIWindow *hudWindow;
@property (weak, nonatomic) ColoredVKHUD *hud;


@end


@implementation ColoredVKNewInstaller
/*******    STATIC VARIABLES    ******/
void(^installerCompletionBlock)(BOOL purchased);
struct utsname systemInfo;
NSString *key;
NSString *userLogin;
NSString *userPassword;



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
        uname(&systemInfo);
        
        [self createFolders];
    }
    return self;
}

- (void)createFolders
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
#ifdef CVK_CACHE_PATH_OLD
    if ([fileManager fileExistsAtPath:CVK_CACHE_PATH_OLD]) [fileManager removeItemAtPath:CVK_CACHE_PATH_OLD error:nil];
#endif
#ifdef CVK_CACHE_PATH_OLD1
    if ([fileManager fileExistsAtPath:CVK_CACHE_PATH_OLD1]) [fileManager removeItemAtPath:CVK_CACHE_PATH_OLD1 error:nil];
#endif
    
    if (![fileManager fileExistsAtPath:CVK_FOLDER_PATH])  [fileManager createDirectoryAtPath:CVK_FOLDER_PATH withIntermediateDirectories:NO attributes:nil error:nil];
    if (![fileManager fileExistsAtPath:CVK_CACHE_PATH]) [fileManager createDirectoryAtPath:CVK_CACHE_PATH  withIntermediateDirectories:NO attributes:nil error:nil];
    if (![fileManager fileExistsAtPath:CVK_CACHE_PATH])  [fileManager createDirectoryAtPath:CVK_CACHE_PATH withIntermediateDirectories:NO attributes:nil error:nil];
    if (![fileManager fileExistsAtPath:CVK_BACKUP_PATH])  [fileManager createDirectoryAtPath:CVK_BACKUP_PATH withIntermediateDirectories:NO attributes:nil error:nil];
}

- (void)checkStatusAndShowAlert:(BOOL)showAlert
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:kDRMLicencePath]) {
        writeFreeLicence(showAlert);
    } else {
        NSData *decryptedData = AES256Decrypt([NSData dataWithContentsOfFile:kDRMLicencePath], kDRMLicenceKey);
        NSDictionary *dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
        if ([dict isKindOfClass:[NSDictionary class]] && (dict.allKeys.count>0)) {
            if (dict[@"Device"]) {
                if (![dict[@"Device"] isEqualToString:@(systemInfo.machine)]) {
                    writeFreeLicence(showAlert);
                } else {
                    if ([dict[@"purchased"] boolValue] && [dict[@"activated"] boolValue]) {                        
                        if (installerCompletionBlock)
                            installerCompletionBlock(YES);
                    }
                    
                }
            } else {
                writeFreeLicence(showAlert);
            }
        } else {
            writeFreeLicence(showAlert);
        }
    }
}

- (void)actionPurchase
{
    if (self.userID) {        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSError *error = nil;
            NSURL *provisionURL = [[NSBundle mainBundle] URLForResource:@"embedded" withExtension:@"mobileprovision"];
            NSString *provisionString = [[NSString alloc] initWithContentsOfURL:provisionURL encoding:NSISOLatin1StringEncoding error:&error];
            
            NSString *provisionTeamID = @"";
            NSString *provisionTeamName = @"";
            
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
                    provisionTeamID = ((NSArray *)dict[@"TeamIdentifier"]).firstObject;
                    provisionTeamName = dict[@"TeamName"];
                }
                [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
            }
            
            NSString *from = @"";
            NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[NSBundle mainBundle].bundlePath error:nil];
            if ([contents containsObject:@"iappsDefender.dylib"]) {
                from = @"iapps";
            }
            
            ColoredVKWebViewController *webController = [ColoredVKWebViewController new];
            webController.url = [NSURL URLWithString:kPackagePurchaseLink];
            
            NSError *requestError = nil;
            NSDictionary *params = @{@"user_id" :self.userID, @"profile_team_id": provisionTeamID, @"profile_team_name": provisionTeamName, @"from": from};
            NSURLRequest *request = [self.networkController requestWithMethod:@"POST" URLString:webController.url.absoluteString parameters:params error:&requestError];
            
            if (!requestError) {
                webController.request = request;
                [webController present];
            } else {
                [self showAlertWithTitle:nil text:[NSString stringWithFormat:@"Unknown error:\n%@", error.localizedDescription] buttons:nil];
            }
        });
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
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
        for (UIAlertAction *action in buttons) {
            [alertController addAction:action];
        }
        [alertController present];
    });
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
    });
}

- (void)hideHud
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.hud)
            [self.hud removeFromSuperview];
        self.hudWindow = nil;
    });
}


#pragma mark -
#pragma mark Getters
#pragma mark -
- (NSString *)userLogin
{
    return licenceValueForKey(@"Login");
}

- (NSString *)token
{
    return licenceValueForKey(@"user_token");
}

- (NSNumber *)userID
{
    return licenceValueForKey(@"user_id");
}

- (BOOL)isTweakPurchased
{    
    return [licenceValueForKey(@"purchased") boolValue];
}

- (BOOL)isTweakActivated
{    
    return [licenceValueForKey(@"activated") boolValue];
}


#pragma mark -
#pragma mark Backend
#pragma mark -
- (void)updateAccountInfo:( void(^)(void) )completionBlock
{
    if (self.userID) {
        if (self.tweakPurchased && self.tweakActivated) {
            self.api_activated = self.tweakActivated;
            self.api_purchased = self.tweakPurchased;
            if (completionBlock)
                completionBlock();
            
            return;
        } 
        NSString *url = [NSString stringWithFormat:@"%@/payment/get_info.php", kPackageAPIURL];
        NSDictionary *parameters = @{@"user_id":self.userID, @"token":self.token};
        
        [self.networkController sendJSONRequestWithMethod:@"POST" stringURL:url parameters:parameters
                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
                                                      if (!json[@"error"]) {
                                                          NSDictionary *response = json[@"response"];
                                                          
                                                          self.api_banned = [response[@"is_banned"] boolValue];
                                                          self.api_purchased = [response[@"is_purchased"] boolValue];
                                                          self.api_activated = [response[@"is_activated"] boolValue];
                                                          
                                                          NSData *decryptedData = AES256Decrypt([NSData dataWithContentsOfFile:kDRMLicencePath], kDRMLicenceKey);
                                                          NSMutableDictionary *dict = [(NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData] mutableCopy];
                                                          dict[@"purchased"] = @(self.api_purchased);
                                                          dict[@"activated"] = @(self.api_activated);
                                                          NSData *encrypterdData = AES256Encrypt([NSKeyedArchiver archivedDataWithRootObject:dict], kDRMLicenceKey);
                                                          [encrypterdData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:nil];
                                                      }
                                                      
                                                      if (completionBlock) {
                                                          completionBlock();
                                                          
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.reload.prefs.menu" object:nil];
                                                      }
                                                  } 
                                                  failure:nil];
    } else {
        self.api_banned = NO;
        self.api_purchased = NO;
        self.api_activated = NO;
        if (completionBlock)
            completionBlock();
    }
    
}


void writeFreeLicence(BOOL showAlert)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSMutableDictionary *dict = @{@"isFree":@YES, @"Device":@(systemInfo.machine), @"UDID":deviceUDID}.mutableCopy;
        NSMutableDictionary *dict = @{@"purchased":@NO, @"activated":@NO, @"Device":@(systemInfo.machine)}.mutableCopy;
        NSData *encrypterdData = AES256Encrypt([NSKeyedArchiver archivedDataWithRootObject:dict], kDRMLicenceKey);
        
        NSError *writingError = nil;
        [encrypterdData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:&writingError];
        
        if (showAlert) {
            [[ColoredVKNewInstaller sharedInstaller] showAlertWithTitle:CVKLocalizedString(@"HI") text:CVKLocalizedString(@"GREETING_MESSAGE") buttons:nil];
        }
    });
}

void installerActionLogin(NSString *login, NSString *password, void(^completionBlock)(void))
{
    [[ColoredVKNewInstaller sharedInstaller] showHudWithText:CVKLocalizedString(@"PLEASE_WAIT")];
    
    userPassword = AES256EncryptStringForAPI(password);
    userLogin = login;
    
    NSString *device = [NSString stringWithFormat:@"%@ (%@)(%@)", @(systemInfo.machine), [UIDevice currentDevice].name, [UIDevice currentDevice].systemVersion];    
    NSDictionary *parameters = @{@"login": userLogin, @"password": userPassword, @"action": @"login", 
                                 @"version": kDRMPackageVersion, @"device": device, @"key": key
                                 };
    download(parameters, YES, completionBlock);
}


void installerActionLogout(NSString *password, void(^completionBlock)(void))
{
    [[ColoredVKNewInstaller sharedInstaller] showHudWithText:CVKLocalizedString(@"PLEASE_WAIT")];
    
    userLogin = [ColoredVKNewInstaller sharedInstaller].userLogin;
    userPassword = AES256EncryptStringForAPI(password);
    
    void (^newCompletionBlock)(NSError *error) = ^(NSError *error){
        ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
        
        [newInstaller hideHud];
        if (error.code == 1050)
            [newInstaller showAlertWithTitle:nil text:[NSString stringWithFormat:@"%@ (Code %@)", error.localizedDescription, @(error.code)] buttons:nil];
        
        if (completionBlock)
            completionBlock();
    };
    
    NSString *device = [NSString stringWithFormat:@"%@ (%@)(%@)", @(systemInfo.machine), [UIDevice currentDevice].name, [UIDevice currentDevice].systemVersion];
    NSDictionary *parameters = @{@"login": userLogin, @"password": userPassword, @"action": @"logout", 
                                 @"version": kDRMPackageVersion, @"device": device, @"key": key
                                 };
    
    ColoredVKNetworkController *networkController = [ColoredVKNewInstaller sharedInstaller].networkController;
    [networkController sendJSONRequestWithMethod:@"POST" stringURL:kDRMRemoteServerURL parameters:parameters 
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
                                          if (!json[@"error"]) {
                                              if ([json[@"Status"] isEqualToString:userPassword]) {
                                                  if ([json[@"key"] isEqualToString:key]) {
                                                      NSData *licenceDecryptedData = AES256Decrypt([NSData dataWithContentsOfFile:kDRMLicencePath], kDRMLicenceKey);
                                                      NSMutableDictionary *licenceDict = [(NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:licenceDecryptedData] mutableCopy];
                                                      
                                                      if ([licenceDict isKindOfClass:[NSDictionary class]] && (licenceDict.allKeys.count>0)) {
                                                          if (licenceDict[@"Login"])
                                                              [licenceDict removeObjectForKey:@"Login"];
                                                          if (licenceDict[@"user_id"])
                                                              [licenceDict removeObjectForKey:@"user_id"];
                                                          if (licenceDict[@"user_token"])
                                                              [licenceDict removeObjectForKey:@"user_token"];
                                                          if (licenceDict[@"purchased"])
                                                              [licenceDict removeObjectForKey:@"purchased"];
                                                          if (licenceDict[@"activated"])
                                                              [licenceDict removeObjectForKey:@"activated"];
                                                          
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.reload.prefs.menu" object:nil];
                                                          if (installerCompletionBlock)
                                                              installerCompletionBlock(NO);
                                                          
                                                          NSError *writingError;
                                                          NSData *licenceEncryptedData = AES256Encrypt([NSKeyedArchiver archivedDataWithRootObject:licenceDict], kDRMLicenceKey);
                                                          [licenceEncryptedData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:&writingError];
                                                          if (!writingError)  newCompletionBlock([NSError errorWithDomain:@"" code:1060 userInfo:nil]);
                                                          else newCompletionBlock([NSError errorWithDomain:@"" code:1050 userInfo:@{NSLocalizedDescriptionKey:@"Unknown error (-6)"}]);
                                                      } else newCompletionBlock([NSError errorWithDomain:@"" code:1050 userInfo:@{NSLocalizedDescriptionKey:@"Unknown error (-5)"}]);
                                                      
                                                  } else newCompletionBlock([NSError errorWithDomain:@"" code:1050 userInfo:@{NSLocalizedDescriptionKey:@"Unknown error (-0)"}]);
                                              } else newCompletionBlock([NSError errorWithDomain:@"" code:1050 userInfo:@{NSLocalizedDescriptionKey:@"Unknown error (-1)"}]);
                                          } else {
                                              NSString *errorMessages = json ? json[@"error"] : @"Unknown error (-2)";
                                              newCompletionBlock([NSError errorWithDomain:@"" code:1050 userInfo:@{NSLocalizedDescriptionKey:errorMessages}]);
                                          }
                                      } 
                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          newCompletionBlock(error);
                                      }];
}

static void download(id parameters,BOOL isAuthorisation, void(^completionBlock)(void))
{
    void (^showAlertBlock)(NSError *error) = ^(NSError *error) {
        NSString *text = [NSString stringWithFormat:@"%@ (Code %@)", error.localizedDescription, @(error.code)];
        
        if ((int)error.code == 1050) {
            writeFreeLicence(NO);
        }
        if ((int)error.code == 1060) {
            text = CVKLocalizedString(@"LICENCE_SUCCESSFULLY_INSTALLED");
        }
        if ((int)error.code == 1070) {
            text = @"";
        }
        ColoredVKNewInstaller *installer = [ColoredVKNewInstaller sharedInstaller];
        [installer hideHud];
        if ((int)text.length > 0)
            [installer showAlertWithTitle:nil text:text buttons:nil];
        
        if (completionBlock)
            completionBlock();
    };
    
    ColoredVKNetworkController *networkController = [ColoredVKNewInstaller sharedInstaller].networkController;
    [networkController sendJSONRequestWithMethod:@"POST" stringURL:kDRMRemoteServerURL parameters:parameters
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
                                          if (!json[@"error"]) {
                                              NSString *stringToCompare = userPassword; //isAuthorisation?userPassword:deviceUDID;
                                              if ([json[@"Status"] isEqualToString:stringToCompare]) {
                                                  if ([json[@"key"] isEqualToString:key]) {
//                                                      NSMutableDictionary *dict = @{@"UDID":deviceUDID, @"Device":@(systemInfo.machine)}.mutableCopy;
                                                      NSMutableDictionary *dict = @{@"Device":@(systemInfo.machine)}.mutableCopy;
                                                      
                                                      dict[@"Login"] = userLogin;
                                                      
                                                      if (json[@"user_id"])
                                                          dict[@"user_id"] = json[@"user_id"];
                                                      
                                                      if (json[@"user_token"])
                                                          dict[@"user_token"] = json[@"user_token"];
                                                      
                                                      if (json[@"purchased"])
                                                          dict[@"purchased"] = json[@"purchased"];
                                                      
                                                      if (json[@"activated"])
                                                          dict[@"activated"] = json[@"activated"];
                                                      
                                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.reload.prefs.menu" object:nil];
                                                      
                                                      NSError *writingError = nil;
                                                      NSData *encrypterdData = AES256Encrypt([NSKeyedArchiver archivedDataWithRootObject:dict], kDRMLicenceKey);
                                                      [encrypterdData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:&writingError];
                                                      
                                                      if (!writingError) {
                                                          showAlertBlock([NSError errorWithDomain:@"" code:1070 userInfo:nil]);
                                                          CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
                                                          
                                                          BOOL purchased = ([json[@"activated"] boolValue] && [json[@"purchased"] boolValue]);
                                                          
                                                          if (purchased && installerCompletionBlock) 
                                                              installerCompletionBlock(YES);
                                                      }
                                                      else showAlertBlock(writingError);
                                                  } else showAlertBlock([NSError errorWithDomain:@"" code:1050 userInfo:@{NSLocalizedDescriptionKey:@"Unknown error (-0)"}]);
                                              } else showAlertBlock([NSError errorWithDomain:@"" code:1050 userInfo:@{NSLocalizedDescriptionKey:@"Unknown error (-1)"}]);
                                          } else {
                                              NSString *errorMessages = json ? json[@"error"] : @"Unknown error (-2)";
                                              showAlertBlock([NSError errorWithDomain:@"" code:1050 userInfo:@{NSLocalizedDescriptionKey:errorMessages}]);
                                          }
                                      } 
                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          showAlertBlock(error);
                                      }];
}


id licenceValueForKey(NSString *key)
{
    NSData *decryptedData = AES256Decrypt([NSData dataWithContentsOfFile:kDRMLicencePath], kDRMLicenceKey);
    if (decryptedData.length == 0) return nil;
    NSMutableDictionary *dict = [(NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData] mutableCopy];
    if ([dict isKindOfClass:[NSDictionary class]] && (dict.allKeys.count>0))
        return dict[key];
    else
        return nil;
}

@end
