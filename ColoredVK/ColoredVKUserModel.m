//
//  ColoredVKUserModel.m
//  ColoredVK2
//
//  Created by Даниил on 01.01.18.
//

#import "ColoredVKNewInstaller.h"
#import "PrefixHeader.h"
#import "ColoredVKCrypto.h"
#import "ColoredVKHUD.h"

#define kDRMLicencePath         [CVK_PREFS_PATH stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"]
#define kDRMRemoteServerURL     [NSString stringWithFormat:@"%@/index-new.php", kPackageAPIURL]

@interface ColoredVKNewInstaller ()
extern NSString *key;

@property (weak, nonatomic) ColoredVKHUD *hud;

- (void)showHudWithText:(NSString *)text;
- (void)hideHud;
- (void)showAlertWithTitle:(NSString *)title text:(NSString *)text buttons:(NSArray <__kindof UIAlertAction *> *)buttons;
- (void)writeFreeLicence;

@end


@implementation ColoredVKUserModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self clearUser];
    }
    return self;
}

- (void)clearUser
{
    self.name = nil;
    self.email = nil;
    self.userID = nil;
    self.accountStatus = ColoredVKUserAccountStatusFree;
}

- (void)updateAccountInfo:( void(^)(void) )completionBlock
{
    if (!self.userID) {
        [self clearUser];
        if (completionBlock)
            completionBlock();
        return;
    }
    
    if ((self.accountStatus == ColoredVKUserAccountStatusPaid) && completionBlock) {
        completionBlock();
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/payment/get_info.php", kPackageAPIURL];
    NSDictionary *parameters = @{@"user_id":self.userID, @"token":self.accessToken};
    
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    [newInstaller.networkController sendJSONRequestWithMethod:@"POST" stringURL:url parameters:parameters
                                                      success:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSDictionary *json) {
                                                          if (!json[@"error"]) {
                                                              NSDictionary *response = json[@"response"];
                                                              if ([response isKindOfClass:[NSDictionary class]]) {
                                                                  self.accountStatus = ColoredVKUserAccountStatusFree;
                                                                  
                                                                  BOOL purchased = [response[@"is_purchased"] boolValue];
                                                                  if (purchased)
                                                                      self.accountStatus = ColoredVKUserAccountStatusPaid;
                                                                  
                                                                  BOOL banned = [response[@"is_banned"] boolValue];
                                                                  if (banned)
                                                                      self.accountStatus = ColoredVKUserAccountStatusBanned;
                                                                  
                                                                  if (response[@"email"])
                                                                      self.email = response[@"email"];
                                                                  else
                                                                      self.email = @"";
                                                                  
                                                                  NSData *decryptedData = decryptData([NSData dataWithContentsOfFile:kDRMLicencePath], nil);
                                                                  NSMutableDictionary *dict = [(NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData] mutableCopy];
                                                                  dict[@"purchased"] = @(purchased);
                                                                  dict[@"email"] = self.email;
                                                                  NSData *encryptedData = encryptData([NSKeyedArchiver archivedDataWithRootObject:dict], nil);
                                                                  [encryptedData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:nil];
                                                              }
                                                          }
                                                          
                                                          if (completionBlock) {
                                                              completionBlock();
                                                              
//                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.reload.prefs.menu" object:nil];
                                                          }
                                                      } failure:nil];
}


- (void)authWithUsername:(NSString *)userName password:(NSString *)password completionBlock:( void(^)(void) )completionBlock
{
    if (userName.length == 0 || password.length == 0) {
        return;
    }
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    [newInstaller showHudWithText:CVKLocalizedString(@"PLEASE_WAIT")];
    
    NSString *device = [NSString stringWithFormat:@"%@ (%@)(%@)", newInstaller.deviceModel, 
                        [UIDevice currentDevice].name, [UIDevice currentDevice].systemVersion];
    NSDictionary *parameters = @{@"login": userName, @"password": password, @"action": @"login", 
                                 @"version": kPackageVersion, @"device": device, @"key": key
                                 };
    
    void (^showAlertBlock)(NSError *error) = ^(NSError *error) {
        [newInstaller hideHud];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (error) {
                NSString *text = [NSString stringWithFormat:@"%@\n(Client code %@)", error.localizedDescription, @(error.code)];
                [newInstaller showAlertWithTitle:CVKLocalizedString(@"ERROR") text:text buttons:nil];
            }
            
            if (completionBlock)
                completionBlock();
        });
        
    };
    
    __weak typeof(self) weakSelf = self;
    [newInstaller.networkController sendJSONRequestWithMethod:@"POST" stringURL:kDRMRemoteServerURL parameters:parameters success:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSDictionary *json) {
        if (json[@"error"]) {
            NSString *errorMessages = json ? json[@"error"] : @"Unknown error";
            showAlertBlock([NSError errorWithDomain:NSCocoaErrorDomain code:101 
                                           userInfo:@{NSLocalizedDescriptionKey:errorMessages}]);
            return;
        }
        
        NSDictionary *response = json[@"response"];        
        if (!response[@"login"] || !response[@"user_id"] || !response[@"token"] || ![response[@"key"] isEqualToString:key]) {
            showAlertBlock([NSError errorWithDomain:NSCocoaErrorDomain 
                                               code:101 
                                           userInfo:@{NSLocalizedDescriptionKey:@"Cannot authenticate. Invalid response."}]);
            return;
        }
        
        NSNumber *purchased = response[@"purchased"];
        weakSelf.authenticated = YES;
        weakSelf.name = response[@"login"];
        weakSelf.userID = response[@"user_id"];
        weakSelf.accessToken = response[@"token"];
        weakSelf.email = response[@"email"] ? response[@"email"] : @"";
        weakSelf.accountStatus = purchased.boolValue ? ColoredVKUserAccountStatusPaid : ColoredVKUserAccountStatusFree;
        
        NSDictionary *dict = @{@"Device":newInstaller.deviceModel, @"Login":self.name, @"user_id":self.userID,
                               @"token":self.accessToken, @"purchased":purchased, @"email":self.email};
        NSError *writingError = nil;
        NSData *encryptedData = encryptData([NSKeyedArchiver archivedDataWithRootObject:dict], nil);
        [encryptedData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:&writingError];
        
        if (!writingError) {
            showAlertBlock(nil);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.reload.prefs.menu" object:nil];
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
            
            if (purchased.boolValue && installerCompletionBlock) 
                installerCompletionBlock(YES);
        } else 
            showAlertBlock(writingError);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        showAlertBlock(error);
    }];
}


- (void)logoutWithСompletionBlock:( void(^)(void) )completionBlock;
{
    if (!self.authenticated)
        return;
    
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    [newInstaller showHudWithText:CVKLocalizedString(@"PLEASE_WAIT")];
    
    void (^newCompletionBlock)(NSError *error) = ^(NSError *error){
        [newInstaller hideHud];
        
        if (error)
            [newInstaller showAlertWithTitle:CVKLocalizedString(@"ERROR") text:[NSString stringWithFormat:@"%@\n(Client code %@)",
                                                                                error.localizedDescription, @(error.code)] buttons:nil];
        
        if (completionBlock)
            completionBlock();
    };
    
    NSString *device = [NSString stringWithFormat:@"%@ (%@)(%@)", newInstaller.deviceModel, [UIDevice currentDevice].name, 
                        [UIDevice currentDevice].systemVersion];
    NSDictionary *parameters = @{@"login": self.name, @"token": self.accessToken, @"action": @"logout", 
                                 @"version": kPackageVersion, @"device": device, @"key": key
                                 };
    
    [newInstaller.networkController sendJSONRequestWithMethod:@"POST" stringURL:kDRMRemoteServerURL parameters:parameters 
                                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
                                                          if (!json[@"error"]) {
                                                              [newInstaller writeFreeLicence];
                                                              newCompletionBlock(nil);
                                                              self.authenticated = NO;
                                                              if (installerCompletionBlock)
                                                                  installerCompletionBlock(NO);
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.reload.prefs.menu" object:nil];
                                                          } else {
                                                              NSString *errorMessages = json ? json[@"error"] : @"Unknown error";
                                                              newCompletionBlock([NSError errorWithDomain:NSCocoaErrorDomain code:102 userInfo:@{NSLocalizedDescriptionKey:errorMessages}]);
                                                          }
                                                      } 
                                                      failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                          newCompletionBlock(error);
                                                      }];
}

@end
