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
@end

@implementation ColoredVKInstaller
- (void)beginDownload
{        
    self.alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK" message:@"Downloading licence..." preferredStyle:UIAlertControllerStyleAlert];
    self.cancelAction = [UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.operation cancel];
    }];
    self.exitAction = [UIAlertAction actionWithTitle:@"Exit to apply changes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] performSelector:@selector(suspend)];
        [NSThread sleepForTimeInterval:0.5];
        exit(0);
    }];
    self.exitAction.enabled = NO;
    [self.alertController addAction:self.cancelAction];
    [self.alertController addAction:self.exitAction];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.alertController animated:YES completion:nil];
    
    
    self.operation = [NSBlockOperation blockOperationWithBlock:^{        
        NSString *udid = [UIDevice currentDevice].identifierForVendor.UUIDString;
#ifdef COMPILE_FOR_JAIL
        udid = [NSString stringWithFormat:@"%@", MGCopyAnswer(kMGUniqueDeviceID)];
#endif
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://danpashin.ru/api/v1.1/index3.php"]];
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
@end
