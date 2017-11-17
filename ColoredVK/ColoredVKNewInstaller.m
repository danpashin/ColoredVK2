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

@property (strong, nonatomic) UIWindow *hudWindow;
@property (weak, nonatomic) ColoredVKHUD *hud;

@end


@implementation ColoredVKNewInstaller
/*******    STATIC VARIABLES    ******/
void(^installerCompletionBlock)(BOOL purchased);
struct utsname systemInfo;
NSString *key;
BOOL _innerUserAuthorized = NO;



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
        
        _userName = licenceValueForKey(@"Login");
        _sellerName = @"theux";
        _appTeamIdentifier = @"";
        _appTeamName = @"";
        
        [self createFolders];
        [self updateAppInfo];
    }
    return self;
}

- (void)createFolders
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:CVK_FOLDER_PATH])  [fileManager createDirectoryAtPath:CVK_FOLDER_PATH withIntermediateDirectories:NO attributes:nil error:nil];
    if (![fileManager fileExistsAtPath:CVK_CACHE_PATH]) [fileManager createDirectoryAtPath:CVK_CACHE_PATH  withIntermediateDirectories:NO attributes:nil error:nil];
    if (![fileManager fileExistsAtPath:CVK_CACHE_PATH])  [fileManager createDirectoryAtPath:CVK_CACHE_PATH withIntermediateDirectories:NO attributes:nil error:nil];
    if (![fileManager fileExistsAtPath:CVK_BACKUP_PATH])  [fileManager createDirectoryAtPath:CVK_BACKUP_PATH withIntermediateDirectories:NO attributes:nil error:nil];
}

- (void)updateAppInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{        
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
            }
            [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
        }
        
        if (NSClassFromString(@"Activation") != nil) {
            _sellerName = @"iapps";
        }
        
        ColoredVKUpdatesController *updatesController = [ColoredVKUpdatesController new];
        if (updatesController.shouldCheckUpdates)
            [updatesController checkUpdates];
    });
}

- (void)checkStatus
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:kDRMLicencePath]) {
        writeFreeLicence();
    } else {
        NSData *decryptedData = AES256Decrypt([NSData dataWithContentsOfFile:kDRMLicencePath], kDRMLicenceKey);
        NSDictionary *dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
        if ([dict isKindOfClass:[NSDictionary class]] && (dict.allKeys.count>0)) {
            if (dict[@"Device"]) {
                if (![dict[@"Device"] isEqualToString:@(systemInfo.machine)]) {
                    writeFreeLicence();
                } else {
                    if ([dict[@"purchased"] boolValue] && [dict[@"activated"] boolValue]) {                        
                        if (installerCompletionBlock) {
                            _innerUserAuthorized = YES;
                            installerCompletionBlock(YES);
                        }
                    }
                    
                }
            } else {
                writeFreeLicence();
            }
        } else {
            writeFreeLicence();
        }
    }
}

- (void)actionPurchase
{
    if (self.userID) {
        ColoredVKWebViewController *webController = [ColoredVKWebViewController new];
        webController.url = [NSURL URLWithString:kPackagePurchaseLink];
        
        NSError *requestError = nil;
        NSDictionary *params = @{@"user_id" :self.userID, @"profile_team_id": self.appTeamIdentifier, @"profile_team_name": self.appTeamName, @"from": self.sellerName};
        NSURLRequest *request = [self.networkController requestWithMethod:@"POST" URLString:webController.url.absoluteString parameters:params error:&requestError];
        
        if (!requestError) {
            webController.request = request;
            [webController present];
        } else {
            [self showAlertWithTitle:nil text:[NSString stringWithFormat:@"Error while creating purchase reuest:\n%@", requestError.localizedDescription] buttons:nil];
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

- (BOOL)userAuthorized
{
    return _innerUserAuthorized;
}


#pragma mark -
#pragma mark Backend
#pragma mark -
- (void)updateAccountInfo:( void(^)(void) )completionBlock
{
    if (_innerUserAuthorized) {
        if (self.tweakPurchased && self.tweakActivated) {
            self.api_activated = self.tweakActivated;
            self.api_purchased = self.tweakPurchased;
            if (completionBlock)
                completionBlock();
            
//            return;
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


void writeFreeLicence()
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *dict = @{@"purchased":@NO, @"activated":@NO, @"Device":@(systemInfo.machine)};
        NSData *encrypterdData = AES256Encrypt([NSKeyedArchiver archivedDataWithRootObject:dict], kDRMLicenceKey);
        
        NSError *writingError = nil;
        [encrypterdData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:&writingError];
    });
}


- (void)actionLoginWithUsername:(NSString *)userName password:(NSString *)password completionBlock:( void(^)(void) )completionBlock
{
    [self showHudWithText:CVKLocalizedString(@"PLEASE_WAIT")];
    
    NSString *userPassword = AES256EncryptStringForAPI(password);
    _userName = userName;
    
    NSString *device = [NSString stringWithFormat:@"%@ (%@)(%@)", @(systemInfo.machine), [UIDevice currentDevice].name, [UIDevice currentDevice].systemVersion];    
    NSDictionary *parameters = @{@"login": userName, @"password": userPassword, @"action": @"login", 
                                 @"version": kDRMPackageVersion, @"device": device, @"key": key
                                 };
    download(parameters, YES, completionBlock);
}


- (void)actionLogoutWithPassword:(NSString *)password completionBlock:( void(^)(void) )completionBlock;
{
    [self showHudWithText:CVKLocalizedString(@"PLEASE_WAIT")];
    
    NSString *userPassword = AES256EncryptStringForAPI(password);
    
    __weak typeof(self) weakSelf = self;
    void (^newCompletionBlock)(NSError *error) = ^(NSError *error){
        [weakSelf hideHud];
        
        if (error)
            [weakSelf showAlertWithTitle:nil text:[NSString stringWithFormat:@"%@\n(Code %@)", error.localizedDescription, @(error.code)] buttons:nil];
        
        if (completionBlock)
            completionBlock();
    };
    
    NSString *device = [NSString stringWithFormat:@"%@ (%@)(%@)", @(systemInfo.machine), [UIDevice currentDevice].name, [UIDevice currentDevice].systemVersion];
    NSDictionary *parameters = @{@"login": self.userName, @"password": userPassword, @"action": @"logout", 
                                 @"version": kDRMPackageVersion, @"device": device, @"key": key
                                 };
    
    [self.networkController sendJSONRequestWithMethod:@"POST" stringURL:kDRMRemoteServerURL parameters:parameters 
                                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
                                                  if (!json[@"error"]) {
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
                                                              
                                                              if (!writingError) {
                                                                  _innerUserAuthorized = NO;
                                                                  newCompletionBlock(nil);
                                                              } else 
                                                                  newCompletionBlock([NSError errorWithDomain:NSCocoaErrorDomain code:106 userInfo:@{NSLocalizedDescriptionKey:@"Unknown error"}]);
                                                          } else 
                                                              newCompletionBlock([NSError errorWithDomain:NSCocoaErrorDomain code:105 userInfo:@{NSLocalizedDescriptionKey:@"Unknown error"}]);
                                                          
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

static void download(id parameters,BOOL isAuthorisation, void(^completionBlock)(void))
{
    void (^showAlertBlock)(NSError *error) = ^(NSError *error) {
        
        ColoredVKNewInstaller *installer = [ColoredVKNewInstaller sharedInstaller];
        [installer hideHud];
        
        if (error) {
            writeFreeLicence();
            [installer showAlertWithTitle:nil text:[NSString stringWithFormat:@"%@\n(Code %@)", error.localizedDescription, @(error.code)] buttons:nil];
        }
        
        if (completionBlock)
            completionBlock();
    };
    
    ColoredVKNetworkController *networkController = [ColoredVKNewInstaller sharedInstaller].networkController;
    [networkController sendJSONRequestWithMethod:@"POST" stringURL:kDRMRemoteServerURL parameters:parameters
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
                                          if (!json[@"error"]) {
                                              if ([json[@"key"] isEqualToString:key]) {
                                                  NSMutableDictionary *dict = @{@"Device":@(systemInfo.machine)}.mutableCopy;
                                                  
                                                  dict[@"Login"] = [ColoredVKNewInstaller sharedInstaller].userName;
                                                  
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
                                                      _innerUserAuthorized = YES;
                                                      showAlertBlock(nil);
                                                      CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
                                                      
                                                      BOOL purchased = ([json[@"activated"] boolValue] && [json[@"purchased"] boolValue]);
                                                      
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
