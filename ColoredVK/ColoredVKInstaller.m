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

@interface ColoredVKInstaller()
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
            if (udid.length > 6) {
                NSData *decryptedData = [[NSData dataWithContentsOfFile:licencePath] AES128DecryptedDataWithKey:@"BE7555818BC236315C987C1D9B17F"];
                NSDictionary *dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
                if (![dict[@"UDID"] isEqualToString:udid]) {
                    if (block) block(YES);
                    [self performSelector:@selector(beginDownload) withObject:nil afterDelay:2.0];
                } else if (block) block(NO);
            
            } else if (block) block(NO);
        }
    }];
    startOperation.queuePriority = NSOperationQueuePriorityHigh;
    [startOperation start];
}

- (void)beginDownload
{
    void(^exitBlock)(UIAlertAction *action) = ^(UIAlertAction *action) {
        [[UIApplication sharedApplication] performSelector:@selector(suspend)];
        [NSThread sleepForTimeInterval:0.5];
        exit(0); 
    };
    UIAlertController __block *alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK" message:@"Downloading licence..." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction __block *cancelAction = [UIAlertAction actionWithTitle:@"Exit" style:UIAlertActionStyleDefault handler:exitBlock];
    [alertController addAction:cancelAction];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSString *stringURL = @"http://danpashin.ru/api/v1.1/non-jail.php";
        NSString *udid = [UIDevice currentDevice].identifierForVendor.UUIDString;
#ifdef COMPILE_FOR_JAIL
        stringURL = @"http://danpashin.ru/api/v1.1/";
        udid = [NSString stringWithFormat:@"%@", MGCopyAnswer(kMGUniqueDeviceID)];
#endif
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
        request.HTTPMethod = @"POST";
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        request.HTTPBody = [[NSString stringWithFormat:@"udid=%@&package=org.thebigboss.coloredvk2&version=%@", udid, kColoredVKVersion] dataUsingEncoding:NSUTF8StringEncoding];    
        
        NSHTTPURLResponse *response;
        NSError *error = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (!error) {
            switch ([response.allHeaderFields[@"Status"] intValue]) {
                case 200:
                    if (!response.allHeaderFields[@"Error-Description"]) {
                        NSString *licencePath = CVK_PREFS_PATH;
                        licencePath = [licencePath stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"];
                        
                        NSError *writingError = nil;
                        NSData *encrypterdData = [[NSKeyedArchiver archivedDataWithRootObject:@{@"UDID":udid}] AES128EncryptedDataWithKey:@"BE7555818BC236315C987C1D9B17F"];
                        [encrypterdData writeToFile:licencePath options:NSDataWritingAtomic error:&writingError];
                        
                        if (!writingError) {
                            alertController.message = @"Licence was downloaded successfully";
                            cancelAction = [UIAlertAction actionWithTitle:@"Apply changes" style:UIAlertActionStyleDefault handler:exitBlock];
                        } else {
                            alertController.message = [NSString stringWithFormat:@"Error: %@", writingError.localizedDescription];
                        }
                    }
                    break;
                case 403:
                    alertController.message = [NSString stringWithFormat:@"Error while downloading licence:\n%@\nYour udid is\n%@", response.allHeaderFields[@"Error-Description"], udid];
                    break;
            }
        } else {
            alertController.message = [NSString stringWithFormat:@"Error while downloading licence:\n%@\nYour udid is\n%@", error.localizedDescription, udid];
        }
    }];
}
@end
