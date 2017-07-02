//
//  ColoredVKUpdatesController.m
//  ColoredVK2
//
//  Created by Даниил on 02.07.17.
//
//

#import "ColoredVKUpdatesController.h"
#import <UIKit/UIKit.h>
#import "PrefixHeader.h"
#import "NSDate+DateTools.h"

@interface ColoredVKUpdatesController ()

@property (copy, nonatomic) NSString *prefsPath;

@end

@implementation ColoredVKUpdatesController

NSString *const apiErrorKey = @"error";
NSString *const apiChangelogKey = @"changelog";
NSString *const apiNewVersionKey = @"version";
NSString *const apiDownloadURLKey = @"url";

NSString *const prefsLastCheckKey = @"lastCheckForUpdates";
NSString *const prefsUpdatesCheckIntervalKey = @"updatesInterval";
NSString *const prefsCheckUpdatesKey = @"checkUpdates";

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showErrorAlert = NO;
        self.prefsPath = CVK_PREFS_PATH;
    }
    return self;
}

- (void)checkUpdates
{    
    NSString *stringURL = [NSString stringWithFormat:@"%@/checkUpdates.php?userVers=%@&product=%@", kPackageAPIURL, kPackageVersion, kPackageIdentifier];
#ifndef COMPILE_FOR_JAIL
    stringURL = [stringURL stringByAppendingString:@"&getIPA=1"];
#endif
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSMutableDictionary *tweakPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:self.prefsPath];
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (!response[apiErrorKey]) {
                NSString *newVersion = response[apiNewVersionKey];
                NSString *skippedVersion = tweakPrefs[@"skippedVersion"];
                if (![skippedVersion isEqualToString:newVersion] || self.showErrorAlert) {
                    NSMutableArray <UIAlertAction *> *alertActions = [NSMutableArray array];
                    NSString *updateAlertQuestion = [NSString stringWithFormat:CVKLocalizedString(@"UPGRADE_IS_AVAILABLE_ALERT_MESSAGE"), newVersion, response[apiChangelogKey]];
                    
                    [alertActions addObject:[UIAlertAction actionWithTitle:CVKLocalizedString(@"REMIND_LATER_BUTTON_TITLE") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
                    [alertActions addObject:[UIAlertAction actionWithTitle:CVKLocalizedString(@"SKIP_THIS_VERSION_BUTTON_TITLE") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [tweakPrefs setValue:newVersion forKey:@"skippedVersion"];
                        [tweakPrefs writeToFile:self.prefsPath atomically:YES];
                    }]];
                    [alertActions addObject:[UIAlertAction actionWithTitle:CVKLocalizedString(@"UPADTE_BUTTON_TITLE") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        NSURL *url = [NSURL URLWithString:response[apiDownloadURLKey]];
                        UIApplication *application = [UIApplication sharedApplication];
                        if ([application canOpenURL:url]) [application openURL:url];
                    }]];
                                        
                    [self showAlertWithMessage:updateAlertQuestion actions:alertActions];
                }
            } else {
                if (self.showErrorAlert)
                    [self showAlertWithMessage:response[apiErrorKey]
                                       actions:@[[UIAlertAction actionWithTitle:UIKitLocalizedString(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]]];
            }
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
            [tweakPrefs setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:prefsLastCheckKey];
            [tweakPrefs writeToFile:self.prefsPath atomically:YES];
            
            if (self.checkCompletionHandler) self.checkCompletionHandler(self);
        } else {
            if (self.showErrorAlert)
                [self showAlertWithMessage:connectionError.localizedDescription
                                   actions:@[[UIAlertAction actionWithTitle:UIKitLocalizedString(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]]];
        }
    }];
}

- (void)showAlertWithMessage:(NSString *)message actions:(NSArray <UIAlertAction *> *)actions
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (actions.count > 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kPackageName message:message preferredStyle:UIAlertControllerStyleAlert];
            for (UIAlertAction *action in actions) {
                [alertController addAction:action];
            }
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        }
    });
}

- (BOOL)shouldCheckUpdates
{
    NSMutableDictionary *tweakPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:self.prefsPath];
    BOOL shouldCheckUpdates = tweakPrefs[prefsCheckUpdatesKey] ? [tweakPrefs[prefsCheckUpdatesKey] boolValue] : YES;
    NSTimeInterval updatesInterval = tweakPrefs[prefsUpdatesCheckIntervalKey] ? [tweakPrefs[prefsUpdatesCheckIntervalKey] doubleValue] : 1.0;
    NSString *lastCheckForUpdates = tweakPrefs[prefsLastCheckKey];
    BOOL beta = [kPackageVersion containsString:@"beta"];
    
    if (shouldCheckUpdates || beta) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        NSInteger daysAgo = [dateFormatter dateFromString:lastCheckForUpdates].daysAgo;
        
        BOOL allDaysPast = beta ? (daysAgo >= 1) : (daysAgo >= updatesInterval);
        if (!lastCheckForUpdates || allDaysPast)
            return YES;
    }
    
    return NO;
}

- (NSString *)localizedLastCheckForUpdates
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    
    return prefs[prefsLastCheckKey]?[dateFormatter dateFromString:prefs[prefsLastCheckKey]].timeAgoSinceNow : CVKLocalizedString(@"NEVER");
}

@end
