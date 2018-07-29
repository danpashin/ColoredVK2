//
//  ColoredVKUserModel.m
//  ColoredVK2
//
//  Created by Даниил on 01.01.18.
//

#import "ColoredVKNewInstaller.h"
#import "ColoredVKHUD.h"
#import "ColoredVKWebViewController.h"
#import "ColoredVKNetwork.h"
#import "NSObject+ColoredVK.h"

@interface ColoredVKNewInstaller ()
extern NSString *__key;
@property (weak, nonatomic) ColoredVKHUD *hud;
- (void)showHudWithText:(NSString *)text;
- (void)hideHud;
- (void)showAlertWithTitle:(NSString *)title text:(NSString *)text buttons:(NSArray <__kindof UIAlertAction *> *)buttons;
- (void)writeFreeLicence;
@end


@implementation ColoredVKUserModel

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self clearUser];
        [self cvk_decodeObjectsWithCoder:aDecoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self cvk_encodeObjectsWithCoder:aCoder];
}

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
    self.authenticated = NO;
    self.name = nil;
    self.email = nil;
    self.userID = nil;
    self.accountStatus = ColoredVKUserAccountStatusFree;
}

- (void)actionPurchase
{
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    if (!self.userID) {
        [newInstaller showAlertWithTitle:CVKLocalizedString(@"WARNING") text:CVKLocalizedString(@"ENTER_ACCOUNT_FIRST") buttons:nil];
        return;
    }
    
    NSDictionary *params = @{@"user_id" :self.userID, @"profile_team_id": newInstaller.application.teamIdentifier};
    
    ColoredVKWebViewController *webController = [ColoredVKWebViewController new];
    webController.request = [[ColoredVKNetwork sharedNetwork] requestWithMethod:ColoredVKNetworkMethodTypePOST url:kPackagePurchaseLink 
                                                                     parameters:params error:nil];
    [webController present];
}

- (void)updateAccountInfo:( void(^)(void) )completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (!self.userID) {
            [self clearUser];
            if (completionBlock)
                completionBlock();
            return;
        }
        
        NSString *url = [NSString stringWithFormat:@"%@/payment/get_info.php", kPackageAPIURL];
        NSDictionary *params = @{@"user_id":self.userID, @"token":self.accessToken};
        
        ColoredVKNetwork *network = [ColoredVKNetwork sharedNetwork];
        [network sendRequestWithMethod:ColoredVKNetworkMethodTypePOST url:url parameters:params success:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSData *rawData) {
            NSError *decryptError = nil;
            NSDictionary *json = RSADecryptServerData(rawData, httpResponse, &decryptError);
            
            if (!json || decryptError)
                return;
            
            if (json[@"error"])
                return;
            
            NSDictionary *response = json[@"response"];
            BOOL purchased = [response[@"is_purchased"] boolValue];
            
            self.email = response[@"email"] ? response[@"email"] : @"";
            self.accountStatus = purchased ? ColoredVKUserAccountStatusPaid : ColoredVKUserAccountStatusFree;
            
            NSDictionary *licence = RSADecryptLicenceData(nil);
            NSMutableDictionary *dict = [licence mutableCopy];
            dict[@"purchased"] = @(purchased);
            dict[@"user"] = [NSKeyedArchiver archivedDataWithRootObject:self];
            RSAEncryptAndWriteLicenceData(dict, nil);
            
            POST_NOTIFICATION(kPackageNotificationReloadPrefsMenu);
            
            if (installerCompletionBlock) 
                installerCompletionBlock(purchased);
            
            if (completionBlock)
                completionBlock();
        } failure:nil];
    });
}

- (void)authWithUsername:(NSString *)userName password:(NSString *)password completionBlock:( void(^)(void) )completionBlock
{
    if (userName.length == 0 || password.length == 0) {
        return;
    }
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    [newInstaller showHudWithText:CVKLocalizedString(@"PLEASE_WAIT")];
    
    NSString *device = [NSString stringWithFormat:@"%@ (%@)(%@)", __deviceModel, 
                        [UIDevice currentDevice].name, [UIDevice currentDevice].systemVersion];
    NSDictionary *parameters = @{@"login": userName, @"password": password, @"action": @"login", 
                                 @"version": kPackageVersion, @"device": device, @"key": __key
                                 };
    NSString *url = [kPackageAPIURL stringByAppendingString:@"/auth/authenticate.php"];
    
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
    
    ColoredVKNetwork *network = [ColoredVKNetwork sharedNetwork];
    [network sendRequestWithMethod:ColoredVKNetworkMethodTypePOST url:url parameters:parameters success:^(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSData *rawData) {
        NSError *decryptError = nil;
        NSDictionary *json = RSADecryptServerData(rawData, httpResponse, &decryptError);
        
        if (!json || decryptError) {
            if (!decryptError)
                decryptError = [NSError errorWithDomain:NSCocoaErrorDomain code:100
                                               userInfo:@{NSLocalizedDescriptionKey:@"Unknown error"}];
            
            showAlertBlock(decryptError);
            return;
        }
        
        if (json[@"error"]) {
            NSString *errorMessages = json ? json[@"error"] : @"Unknown error";
            showAlertBlock([NSError errorWithDomain:NSCocoaErrorDomain code:101 
                                           userInfo:@{NSLocalizedDescriptionKey:errorMessages}]);
            return;
        }
        
        NSDictionary *response = json[@"response"];        
        if (!response[@"login"] || !response[@"user_id"] || !response[@"token"] || ![response[@"key"] isEqualToString:__key]) {
            showAlertBlock([NSError errorWithDomain:NSCocoaErrorDomain code:101 
                                           userInfo:@{NSLocalizedDescriptionKey:@"Cannot authenticate. Invalid response."}]);
            return;
        }
        
        NSNumber *purchased = response[@"purchased"];
        self.authenticated = YES;
        self.name = response[@"login"];
        self.userID = response[@"user_id"];
        self.accessToken = response[@"token"];
        self.email = response[@"email"] ? response[@"email"] : @"";
        self.accountStatus = purchased.boolValue ? ColoredVKUserAccountStatusPaid : ColoredVKUserAccountStatusFree;
        
        NSData *user = [NSKeyedArchiver archivedDataWithRootObject:self];
        NSDictionary *dict = @{@"Device":__deviceModel, @"purchased":purchased, @"user":user};
        NSError *writingError = nil;
        RSAEncryptAndWriteLicenceData(dict, nil);
        
        if (!writingError) {
            showAlertBlock(nil);
            POST_NOTIFICATION(kPackageNotificationReloadPrefsMenu);
            
            if (installerCompletionBlock) 
                installerCompletionBlock(purchased.boolValue);
        } else 
            showAlertBlock(writingError);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        showAlertBlock(error);
    }];
}

- (void)logoutWithCompletionBlock:( void(^)(void) )completionBlock
{
    if (!self.authenticated)
        return;
    
    NSString *device = [NSString stringWithFormat:@"%@ (%@)(%@)", __deviceModel, [UIDevice currentDevice].name, 
                        [UIDevice currentDevice].systemVersion];
    NSDictionary *parameters = @{@"login": self.name, @"token": self.accessToken, @"action": @"logout", 
                                 @"version": kPackageVersion, @"device": device, @"key": __key
                                 };
    NSString *url = [kPackageAPIURL stringByAppendingString:@"/auth/authenticate.php"];
    [[ColoredVKNetwork sharedNetwork] sendRequestWithMethod:ColoredVKNetworkMethodTypePOST url:url parameters:parameters success:nil failure:nil];
    
    
    [[ColoredVKNewInstaller sharedInstaller] writeFreeLicence];
    POST_NOTIFICATION(kPackageNotificationReloadPrefsMenu);
    
    if (installerCompletionBlock)
        installerCompletionBlock(NO);
    
    if (completionBlock)
        completionBlock();
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p: name: %@; authenticated %@; id: %@; status: %@>", [self class], self, self.name, @(self.authenticated), self.userID, @(self.accountStatus)];
}

@end
