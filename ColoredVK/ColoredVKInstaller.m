//
//  ColoredVKInstaller.m
//  ColoredVK
//
//  Created by Даниил on 11/09/16.
//
//

#import "ColoredVKInstaller.h"

#define PRODUCT_ID @"com.daniilpashin.coloredvk2"

#import <MobileGestalt/MobileGestalt.h>
#import "PrefixHeader.h"
#import "ColoredVKJailCheck.h"
#import "NSData+AES.h"

@interface ColoredVKInstaller()
@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) NSBlockOperation *operation;
@end

@implementation ColoredVKInstaller
- (void)beginDownload
{
    self.alertView = [[UIAlertView alloc] initWithTitle:@"ColoredVK" 
                                                message:@"Downloading licence..." 
                                               delegate:self 
                                      cancelButtonTitle:@"Cancel" 
                                      otherButtonTitles:nil];
    
    [self.alertView show];
    self.operation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://danpashin.ru/api/v1.1/"]];
        request.HTTPMethod = @"POST";
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        request.HTTPBody = [[NSString stringWithFormat:@"udid=%@&package=%@&version=%@", MGCopyAnswer(CFSTR("UniqueDeviceID")), PRODUCT_ID, kColoredVKVersion] dataUsingEncoding:NSUTF8StringEncoding];    
        
        NSHTTPURLResponse *response;
        NSError *error = nil;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if (!error) {
            int status = [response.allHeaderFields[@"Status"] intValue];
            switch (status) {
                case 200:
                    if (!response.allHeaderFields[@"Error-Description"]) {
                        NSString *licencePath =  [ColoredVKJailCheck isInjected]?CVK_NON_JAIL_PREFS_PATH:CVK_JAIL_PREFS_PATH;
                        licencePath = [licencePath stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"];
                        
                        NSError *writingError = nil;
                        NSData *encrypterdData = [[NSKeyedArchiver archivedDataWithRootObject:@{@"IS_PURCHASED":@YES}] AES128EncryptedDataWithKey:@"BE7555818BC236315C987C1D9B17F"];
                        [encrypterdData writeToFile:licencePath options:NSDataWritingAtomic error:&writingError];
                        
                        if (!writingError) {
                            self.alertView.tag = 1;
                            [self.alertView setMessage:@"Licence was downloaded successfully"];
                            [self.alertView addButtonWithTitle:@"Exit to apply changes"];
                        } else {
                            [self.alertView setMessage:[NSString stringWithFormat:@"Error: %@", writingError.localizedDescription]];
                            [self.alertView addButtonWithTitle:@"Exit"];
                        }
                    }
                    break;
                case 403:
                    [self.alertView setMessage:[NSString stringWithFormat:@"Error while downloading licence:\n%@", response.allHeaderFields[@"Error-Description"]]];
                    break;
            }
        } else {
            [self.alertView setMessage:[NSString stringWithFormat:@"Error: %@", error.localizedDescription]];
        }
    }];
    self.operation.queuePriority = NSOperationQueuePriorityHigh;
    [self.operation start];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        [alertView dismiss];
        [[UIApplication sharedApplication] performSelector:@selector(suspend)];
        [NSThread sleepForTimeInterval:0.2];
        exit(0);
    } 
    else {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [self.operation cancel];
    }
}
@end
