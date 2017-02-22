//
//  ColoredVKInstaller.m
//  ColoredVK
//
//  Created by Даниил on 11/09/16.
//
//

#import "ColoredVKInstaller.h"

#import <MobileGestalt/MobileGestalt.h>
#import "PrefixHeader.h"
#import "NSData+AESCrypt.h"
#import "NSDate+DateTools.h"
#import <CommonCrypto/CommonCryptor.h>
#import <sys/utsname.h>


static NSData *AES256Decrypt(NSData *data, NSString *key)
{
        // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256+1]; // room for terminator (unused)
    bzero( keyPtr, sizeof( keyPtr ) ); // fill with zeroes (for padding)
    
        // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = data.length;
    
        //See the doc: For block ciphers, the output size will always be less than or 
        //equal to the input size plus the size of one block.
        //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc( bufferSize );
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          data.bytes, dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
            //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer
    return nil;
}

NSData *AES256Encrypt(NSData *data, NSString *key)
{
        // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
        // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = data.length;
    
        //See the doc: For block ciphers, the output size will always be less than or 
        //equal to the input size plus the size of one block.
        //That's why we need to add the size of one block here
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL /* initialization vector (optional) */,
                                          data.bytes, dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
            //the returned NSData takes ownership of the buffer and will free it on deallocation
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer
    return nil;
}

NSData *AES256EncryptString(NSString *string, NSString *key)
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return AES256Encrypt(data, key);
}


@interface ColoredVKInstaller()
@end

@implementation ColoredVKInstaller

void(^installerCompletionBlock)(BOOL disableTweak);
UIAlertController *alertController;
UIAlertAction *loginAction;
UIAlertAction *continueAction;
NSString *login;
NSString *password;
NSString *udid;
NSString *key;
struct utsname systemInfo;


+ (instancetype)startInstall
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            udid = [NSString stringWithFormat:@"%@", MGCopyAnswer(CFSTR("UniqueDeviceID"))];
            key = AES256EncryptString([NSProcessInfo processInfo].globallyUniqueString, kDRMAuthorizeKey).base64Encoding;
            uname(&systemInfo);
            
            void (^downloadBlock)() = ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (installerCompletionBlock) installerCompletionBlock(YES);
                    [self beginDownload];
                });
            };
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:kDRMLicencePath]) downloadBlock();
            else {
                NSData *decryptedData = AES256Decrypt([NSData dataWithContentsOfFile:kDRMLicencePath], kDRMLicenceKey);
                NSDictionary *dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
                if ([dict isKindOfClass:[NSDictionary class]] && (dict.allKeys.count>0)) {
                    if (!dict[@"Device"] || !dict[@"key"]) downloadBlock();
                    else {                        
                        if (![dict[@"Device"] isEqualToString:@(systemInfo.machine)]) downloadBlock();
                        else {
                            if (udid.length > 6) {
                                NSString *newUDID = [NSString stringWithFormat:@"%@", MGCopyAnswer(CFSTR("UniqueDeviceID"))];
                                if (![dict[@"UDID"] isEqualToString:newUDID]) downloadBlock();
                                else if (installerCompletionBlock) installerCompletionBlock(NO);
                            } else if (installerCompletionBlock) installerCompletionBlock(NO);
                        }
                    }
                } else downloadBlock();
            }
        });
        
    }
    return self;
}

- (void)showAlertWithText:(NSString *)text
{
    alertController = [UIAlertController alertControllerWithTitle:kDRMPackageName message:text preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Login") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self performSelectorOnMainThread:@selector(actionLogin) withObject:nil waitUntilDone:NO];
    }]];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}


- (void)beginDownload
{
    BOOL isJailed = YES;
#ifndef COMPILE_FOR_JAIL
    isJailed = NO;
#endif
    if ((udid.length <= 6) && isJailed) {
        alertController = [UIAlertController alertControllerWithTitle:kDRMPackageName message:CVKLocalizedString(@"GETTING_UDID_ERROR") preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) weakSelf = self;
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"UDID";
            textField.tag = 9;
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:textField];
        }];
        
        [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"CLOSE_APP") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [UIApplication.sharedApplication performSelector:@selector(suspend)];
            [NSThread sleepForTimeInterval:0.5];
            exit(0);
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Login") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self performSelectorOnMainThread:@selector(actionLogin) withObject:nil waitUntilDone:NO];
        }]];
        continueAction = [UIAlertAction actionWithTitle:CVKLocalizedString(@"CONTINUE") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self beginDownload];
        }];
        [alertController addAction:continueAction];
        [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        
        return;
    } else if (!isJailed) {
        [self actionLogin];
        return;
    } else {
        [self showAlertWithText:@"Downloading licence..."];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kDRMRemoteServerURL]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    NSString *package = AES256EncryptString(@"org.thebigboss.coloredvk2", kDRMAuthorizeKey).base64Encoding;
    NSString *encryptedUDID = AES256EncryptString(udid, kDRMAuthorizeKey).base64Encoding;
    
    NSString *parameters = [NSString stringWithFormat:@"udid=%@&package=%@&version=%@&key=%@", encryptedUDID, package, kDRMPackageVersion, key];
    request.HTTPBody = [parameters dataUsingEncoding:NSUTF8StringEncoding];
    download(request, NO);
}

- (void)actionLogin
{
    alertController = [UIAlertController alertControllerWithTitle:kDRMPackageName message:UIKitLocalizedString(@"Login") preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = UIKitLocalizedString(@"Name");
        textField.tag = 10;
        [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:textField];
        
        if (login) textField.text = login;
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = UIKitLocalizedString(@"Password");
        textField.tag = 11;
        textField.secureTextEntry = YES;
        [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"CLOSE_APP") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [UIApplication.sharedApplication performSelector:@selector(suspend)];
        [NSThread sleepForTimeInterval:0.5];
        exit(0);
    }]];
    
    loginAction = [UIAlertAction actionWithTitle:UIKitLocalizedString(@"Login") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kDRMRemoteServerURL]];
        request.HTTPMethod = @"POST";
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        password = AES256EncryptString(password, kDRMAuthorizeKey).base64Encoding;
        NSString *device = [NSString stringWithFormat:@"%@ (%@)(%@)", @(systemInfo.machine), [UIDevice currentDevice].name, [UIDevice currentDevice].systemVersion];
        NSString *parameters = [NSString stringWithFormat:@"login=%@&password=%@&action=login&version=%@&device=%@&key=%@", login, password, kDRMPackageVersion, device, key];
        request.HTTPBody = [parameters dataUsingEncoding:NSUTF8StringEncoding];
        download(request, YES);
    }];
    loginAction.enabled = NO;
    [alertController addAction:loginAction];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

static void download(NSURLRequest *request,BOOL authorise)
{
    void (^showAlertBlock)(NSString *error) = ^(NSString *error) {
        if (authorise) [[ColoredVKInstaller alloc] showAlertWithText:[NSString stringWithFormat:CVKLocalizedString(@"ERROR_LOGIN"), error, login]];
        else            alertController.message = [NSString stringWithFormat:CVKLocalizedString(@"ERROR_DOWNLOADING_LICENCE"), error, udid];
    };
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSData *decrypted = AES256Decrypt(data, kDRMAuthorizeKey);
            NSString *decryptedString = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
            decryptedString = [decryptedString stringByReplacingOccurrencesOfString:@"\0" withString:@""];
            
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:[decryptedString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            if (responseDict && !responseDict[@"error"]) {
                if ([responseDict[@"Status"] isEqualToString:authorise?password:udid]) {
                    if ([responseDict[@"key"] isEqualToString:key]) {
                        NSString *key = [NSProcessInfo processInfo].globallyUniqueString;
                        
                        NSMutableDictionary *dict = @{@"UDID":udid, @"Device":@(systemInfo.machine), @"key":key}.mutableCopy;
                        if (authorise) [dict setValue:login forKey:@"Login"];
                        NSData *encrypterdData = AES256Encrypt([NSKeyedArchiver archivedDataWithRootObject:dict], kDRMLicenceKey);
                        
                        NSError *writingError = nil;
                        [encrypterdData writeToFile:kDRMLicencePath options:NSDataWritingAtomic error:&writingError];
                        
                        if (!writingError) {
                            [alertController dismissViewControllerAnimated:YES completion:nil];
                            if (installerCompletionBlock) installerCompletionBlock(NO);
                            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
                        }
                        else showAlertBlock([NSString stringWithFormat:@"%@\n%@", CVKLocalizedString(@"ERROR"), writingError.localizedDescription]);
                        
                    } else showAlertBlock(@"Unknown error (-0)");
                } else showAlertBlock(@"Unknown error (-1)");
                
            } else showAlertBlock(responseDict?responseDict[@"error"]:@"Unknown error (-2)");
        } else showAlertBlock(connectionError.localizedDescription);
        password = nil;
    }]; 

}

- (void)textFieldChanged:(NSNotification *)notification
{
    if (notification && [notification.object isKindOfClass:UITextField.class]) {
        UITextField *textField = notification.object;
        if (textField.tag == 9) udid = textField.text;
        else if (textField.tag == 10) login = textField.text;
        else if (textField.tag == 11) password = textField.text;
        
        if ((login.length > 0) && (password.length > 0)) loginAction.enabled = YES;
        else loginAction.enabled = NO;
        
        if (udid.length > 0) continueAction.enabled = YES;
        else continueAction.enabled = NO;
    }
}
@end
