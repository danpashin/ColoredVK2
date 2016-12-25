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
#import "NSData+AES.h"
#import "NSDate+DateTools.h"

@interface ColoredVKInstaller()
@property (strong, nonatomic) UIAlertController *alertController;
@property (strong, nonatomic) UIAlertAction *loginAction;
@property (strong, nonatomic) UIAlertAction *cancelAction;
@property (strong, nonatomic) NSString *login;
@property (strong, nonatomic) NSString *password;
@property (copy, nonatomic, nullable) void(^exitBlock)(UIAlertAction *action);
@property (copy, nonatomic, nullable) NSString *udid;
@end

@implementation ColoredVKInstaller
- (void)startWithCompletionBlock:( void(^)(BOOL disableTweak) )block 
{
    self.udid = [UIDevice currentDevice].identifierForVendor.UUIDString;
#ifdef COMPILE_FOR_JAIL
    self.udid = [NSString stringWithFormat:@"%@", MGCopyAnswer(kMGUniqueDeviceID)];
#endif
    NSBlockOperation *startOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSString *licencePath = CVK_PREFS_PATH;
        licencePath = [licencePath stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:licencePath]) {
//            NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
//            if ([prefs[@"trial"] boolValue]) {
//                NSDateFormatter *dateFormatter = [NSDateFormatter new];
//                dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
//                NSString *date = @"2016-11-30T12:00:00+03:00";
//                if ([dateFormatter dateFromString:date].daysAgo <= 7) block(NO);
//                else {
//                    if (block) block(YES);
//                    [self performSelector:@selector(beginDownload) withObject:nil afterDelay:2.0];
//                }
//            } else {
                if (block) block(YES);
                [self performSelector:@selector(beginDownload) withObject:nil afterDelay:1.0];
        }
        else {
            if (self.udid.length > 6) {
                NSData *decryptedData = [[NSData dataWithContentsOfFile:licencePath] AES128DecryptedDataWithKey:@"BE7555818BC236315C987C1D9B17F"];
                NSDictionary *dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
                if (![dict[@"UDID"] isEqualToString:self.udid]) {
                    if (block) block(YES);
                    [self performSelector:@selector(beginDownload) withObject:nil afterDelay:1.0];
                } else if (block) block(NO);
            } else if (block) block(NO);
        }
    }];
    startOperation.queuePriority = NSOperationQueuePriorityHigh;
    [startOperation start];
}

- (void)beginDownload
{
    self.exitBlock = ^(UIAlertAction *action) {
        [UIApplication.sharedApplication performSelector:@selector(suspend)];
        [NSThread sleepForTimeInterval:0.5];
        exit(0);
    };
    self.alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK 2" message:@"Downloading licence..." preferredStyle:UIAlertControllerStyleAlert];
    self.cancelAction = [UIAlertAction actionWithTitle:CVKLocalizedString(@"CLOSE_APP") style:UIAlertActionStyleDefault handler:self.exitBlock];
    [self.alertController addAction:self.cancelAction];
#ifndef COMPILE_FOR_JAIL
    [self.alertController addAction:[UIAlertAction actionWithTitle:@"Tester?" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.alertController = nil;
        [self performSelectorOnMainThread:@selector(actionLogin) withObject:nil waitUntilDone:NO];
    }]];
//    [self.alertController addAction:[UIAlertAction actionWithTitle:@"Trial" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
//        [prefs setValue:@YES forKey:@"trial"];
//        [prefs writeToFile:CVK_PREFS_PATH atomically:YES];
//        self.exitBlock(nil);
//    }]];
#endif
    if ([self.alertController respondsToSelector:@selector(setPreferredAction:)]) self.alertController.preferredAction = self.cancelAction;
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:self.alertController animated:YES completion:nil];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *stringURL = [NSString stringWithFormat:@"http://danpashin.ru/api/v%@/", API_VERSION];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
        request.HTTPMethod = @"POST";
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        NSString *parameters = [NSString stringWithFormat:@"udid=%@&package=org.thebigboss.coloredvk2&version=%@", self.udid, kColoredVKVersion];
        if (self.login && self.password) parameters = [NSString stringWithFormat:@"%@&login=%@&password=%@", parameters, self.login, self.password.md5String];
        request.HTTPBody = [parameters dataUsingEncoding:NSUTF8StringEncoding];    
        
        NSHTTPURLResponse *response;
        NSError *error = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (!error) {
            if (response.allHeaderFields[@"Status"] && ([response.allHeaderFields[@"Status"] intValue] == 200)) {
                NSString *licencePath = [CVK_PREFS_PATH stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"];
                
                NSError *writingError = nil;
                NSData *encrypterdData = [[NSKeyedArchiver archivedDataWithRootObject:@{@"UDID":self.udid}] AES128EncryptedDataWithKey:@"BE7555818BC236315C987C1D9B17F"];
                [encrypterdData writeToFile:licencePath options:NSDataWritingAtomic error:&writingError];
                
                if (!writingError) {
                    [self.alertController dismissViewControllerAnimated:YES completion:nil];
                    self.alertController = nil;
                    self.exitBlock(nil);
                } else {
                    self.alertController.message = [NSString stringWithFormat:@"%@\n%@", CVKLocalizedString(@"ERROR"), writingError.localizedDescription];
                }

            } else self.alertController.message = [NSString stringWithFormat:CVKLocalizedString(@"ERROR_DOWNLOADING_LICENCE"), response.allHeaderFields[@"Error-Description"], self.udid];
        } else self.alertController.message = [NSString stringWithFormat:CVKLocalizedString(@"ERROR_DOWNLOADING_LICENCE"), error.localizedDescription, self.udid];
    }];
}

- (void)actionLogin
{
    self.alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK 2" message:@"Log In" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [self.alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = UIKitLocalizedString(@"Name");
        textField.tag = 10;
        [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    [self.alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = UIKitLocalizedString(@"Password");
        textField.tag = 11;
        textField.secureTextEntry = YES;
        [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:textField];
    }];     
    
    
    self.cancelAction = [UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        self.alertController = nil;
        self.login = nil;
        self.password = nil;
        [self performSelectorOnMainThread:@selector(beginDownload) withObject:nil waitUntilDone:NO];
    }];
    [self.alertController addAction:self.cancelAction];
    
    self.loginAction = [UIAlertAction actionWithTitle:UIKitLocalizedString(@"Login") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.alertController = nil;
        [self performSelectorOnMainThread:@selector(beginDownload) withObject:nil waitUntilDone:NO];
    }];
    self.loginAction.enabled = NO;
    [self.alertController addAction:self.loginAction];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:self.alertController animated:YES completion:nil];
}

- (void)textFieldChanged:(NSNotification *)notification
{
    if (notification && [notification.object isKindOfClass:UITextField.class]) {
        UITextField *textField = notification.object;
        if (textField.tag == 10) self.login = textField.text;
        else if (textField.tag == 11) self.password = textField.text;
        
        if ((self.login.length > 0) && (self.password.length > 0)) self.loginAction.enabled = YES;
        else self.loginAction.enabled = NO;
    }
}
@end
