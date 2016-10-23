//
//  ColoredVKInstaller.m
//  ColoredVK
//
//  Created by Даниил on 11/09/16.
//
//

#import "ColoredVKInstaller.h"

#define PRODUCT_ID @"org.thebigboss.coloredvk2"

#import <MobileGestalt/MobileGestalt.h>
#import "PrefixHeader.h"
#import "NSData+AES.h"

@interface ColoredVKInstaller()
@property (strong, nonatomic) UIAlertController *alertController;
@property (strong, nonatomic) UIAlertAction *cancelAction;
@property (strong, nonatomic) UIAlertAction *exitAction;
@property (strong, nonatomic) NSBlockOperation *operation;
@property (assign, nonatomic) BOOL fromPrefs;
@end

@implementation ColoredVKInstaller
- (void)startWithUserInfo:(NSDictionary*)userInfo
{
    [self startWithUserInfo:userInfo completionBlock:^(BOOL disableTweak){}];
}
- (void)startWithCompletionBlock:( void(^)(BOOL disableTweak) )block
{
    [self startWithUserInfo:nil completionBlock:block];
}

- (void)startWithUserInfo:(NSDictionary*)userInfo completionBlock:( void(^)(BOOL disableTweak) )block 
{
    if (userInfo && userInfo[@"fromPreferences"]) self.fromPrefs = [userInfo[@"fromPreferences"] boolValue];
    else self.fromPrefs = NO;
    NSBlockOperation *startOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSString *licencePath = CVK_PREFS_PATH;
        licencePath = [licencePath stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:licencePath]) {
            if (block) block(YES);
            [self performSelector:@selector(beginDownload) withObject:nil afterDelay:2.0];
        }
        else {
            NSString *udid = [UIDevice currentDevice].identifierForVendor.UUIDString;
#ifdef COMPILE_FOR_JAIL
            udid = [NSString stringWithFormat:@"%@", MGCopyAnswer(kMGUniqueDeviceID)];            
#endif
            if (udid.length > 10) {
                NSData *decryptedData = [[NSData dataWithContentsOfFile:licencePath] AES128DecryptedDataWithKey:@"BE7555818BC236315C987C1D9B17F"];
                NSDictionary *dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
                if (![dict[@"UDID"] isEqualToString:udid]) {
                    if (block) block(YES);
                    [self performSelector:@selector(beginDownload) withObject:nil afterDelay:2.0];
                } else { if (block) block(NO); }
            
            } else { if (block) block(NO); }
        }
    }];
    startOperation.queuePriority = NSOperationQueuePriorityHigh;
    [startOperation start];
}

- (void)beginDownload
{        
    self.alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK" message:@"Downloading licence..." preferredStyle:UIAlertControllerStyleAlert];
    self.cancelAction = [UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.operation cancel];
    }];
    self.exitAction = [UIAlertAction actionWithTitle:@"Exit to apply changes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (!self.fromPrefs) [self actionExit];
    }];
    self.exitAction.enabled = NO;
    [self.alertController addAction:self.cancelAction];
    [self.alertController addAction:self.exitAction];
    
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:self.alertController animated:YES completion:nil];
    
    
    self.operation = [NSBlockOperation blockOperationWithBlock:^{        
        NSString *udid = [UIDevice currentDevice].identifierForVendor.UUIDString;
#ifdef COMPILE_FOR_JAIL
        udid = [NSString stringWithFormat:@"%@", MGCopyAnswer(kMGUniqueDeviceID)];
#endif
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://danpashin.ru/api/v1.1/"]];
        request.HTTPMethod = @"POST";
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        request.HTTPBody = [[NSString stringWithFormat:@"udid=%@&package=%@&version=%@", udid, PRODUCT_ID, kColoredVKVersion] dataUsingEncoding:NSUTF8StringEncoding];    
        
        NSHTTPURLResponse *response;
        NSError *error = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (!error) {
            int status = [response.allHeaderFields[@"Status"] intValue];
            switch (status) {
                case 200:
                    if (!response.allHeaderFields[@"Error-Description"]) {
                        NSString *licencePath = CVK_PREFS_PATH;
                        licencePath = [licencePath stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"];
                        
                        NSError *writingError = nil;
                        NSData *encrypterdData = [[NSKeyedArchiver archivedDataWithRootObject:@{@"UDID":udid}] AES128EncryptedDataWithKey:@"BE7555818BC236315C987C1D9B17F"];
                        [encrypterdData writeToFile:licencePath options:NSDataWritingAtomic error:&writingError];
                        
                        if (!writingError) {
                            self.alertController.message = @"Licence was downloaded successfully";
                            self.exitAction.enabled = YES;
                            self.cancelAction.enabled = NO;
                        } else {
                            self.alertController.message = [NSString stringWithFormat:@"Error: %@", writingError.localizedDescription];
                        }
                    }
                    break;
                case 403:
                    self.alertController.message = [NSString stringWithFormat:@"Error while downloading licence:\n%@", response.allHeaderFields[@"Error-Description"]];
                    break;
            }
        } else {
            self.alertController.message = [NSString stringWithFormat:@"Error while downloading licence:\n%@", error.localizedDescription];
        }
    }];
    self.operation.queuePriority = NSOperationQueuePriorityHigh;
    [self.operation start];
}

- (void) actionExit
{
    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
    [NSThread sleepForTimeInterval:0.5];
    exit(0);
}
@end
