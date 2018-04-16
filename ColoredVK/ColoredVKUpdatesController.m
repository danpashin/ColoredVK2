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
#import "ColoredVKNewInstaller.h"
#import "ColoredVKAlertController.h"
#import "ColoredVKNetwork.h"
#import "ColoredVKUINotification.h"

@interface ColoredVKUpdatesController ()
@property (strong, nonatomic) NSString *version;
@property (strong, nonatomic) NSString *changelog;
@property (strong, nonatomic) NSString *downloadURL;
@end

@implementation ColoredVKUpdatesController

static NSString *const kCVKUpdateLastCheck = @"lastCheckForUpdates";
static NSString *const kCVKUpdateTimeFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";

- (void)checkUpdates
{
    
#ifdef COMPILE_FOR_JAIL
    BOOL shouldReceiveIPA = NO;
#else
    BOOL shouldReceiveIPA = YES;
#endif
    
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    NSString *stringURL = [NSString stringWithFormat:@"%@/checkUpdates.php", kPackageAPIURL];
    NSDictionary *parameters = @{@"userVers": kPackageVersion, @"ios_version":[UIDevice currentDevice].systemVersion, 
                                 @"vk_version":newInstaller.application.version,
                                 @"appTeamIdentifier": newInstaller.application.teamIdentifier, @"sellerName": newInstaller.application.sellerName, 
                                 @"checkedAutomatically":@(self.checkedAutomatically), @"getIPA":@(shouldReceiveIPA)};

    ColoredVKNetwork *network = [ColoredVKNetwork sharedNetwork];
    [network sendJSONRequestWithMethod:@"GET" stringURL:stringURL parameters:parameters success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
        NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
        if (!json[@"error"]) {
            self.version = json[@"version"];
            self.changelog = json[@"changelog"];
            self.downloadURL = json[@"url"];
            
            if (![prefs[@"skippedVersion"] isEqual:self.version] || !self.checkedAutomatically) {
                NSString *message = [NSString stringWithFormat:CVKLocalizedString(@"UPDATE_IS_AVAILABLE"), self.version];
                [ColoredVKUINotification showWithSubtitle:message tapHandler:^{
                    [self showDetailUpdateInformation];
                }];
            }
        } else if (!self.checkedAutomatically) {
            [ColoredVKUINotification showWithSubtitle:json[@"error"]];
        }
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = kCVKUpdateTimeFormat;
        prefs[kCVKUpdateLastCheck] = [dateFormatter stringFromDate:[NSDate date]];
        [prefs writeToFile:CVK_PREFS_PATH atomically:YES];
        
        if (self.checkCompletionHandler)
            self.checkCompletionHandler(self);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if (!self.checkedAutomatically) {
            [ColoredVKUINotification showWithSubtitle:error.localizedDescription];
        }
    }];
}

- (void)showDetailUpdateInformation
{
    NSString *message = [NSString stringWithFormat:CVKLocalizedString(@"UPDATE_IS_AVAILABLE_DETAIL"), self.version, self.changelog];
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:kPackageName message:message];
    [alertController addCancelActionWithTitle:CVKLocalizedString(@"REMIND_LATER")];
    
    [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"SKIP_THIS_UPDATE") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:CVK_PREFS_PATH];
        prefs[@"skippedVersion"] = self.version;
        [prefs writeToFile:CVK_PREFS_PATH atomically:YES];
    }]];
    
    if (self.downloadURL.length > 0) {
        [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"UPDATE_NOW") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSURL *url = [NSURL URLWithString:self.downloadURL];
            UIApplication *application = [UIApplication sharedApplication];
            if ([application canOpenURL:url]) [application openURL:url];
        }]];
    }
    [alertController present];
}

- (BOOL)shouldCheckUpdates
{
#ifdef COMPILE_APP
    return NO;
#else
    @autoreleasepool {
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
        BOOL shouldCheckUpdates = prefs[@"checkUpdates"] ? [prefs[@"checkUpdates"] boolValue] : YES;
        NSTimeInterval updatesInterval = prefs[@"updatesInterval"] ? [prefs[@"updatesInterval"] doubleValue] : 1.0;
        NSString *lastCheckForUpdates = prefs[kCVKUpdateLastCheck];
        BOOL beta = [kPackageVersion containsString:@"beta"];
        
        if (shouldCheckUpdates || beta) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = kCVKUpdateTimeFormat;
            NSInteger daysAgo = [dateFormatter dateFromString:lastCheckForUpdates].daysAgo;
            
            BOOL allDaysPast = beta ? (daysAgo >= 7) : (daysAgo >= updatesInterval);
            if (!lastCheckForUpdates || allDaysPast)
                return YES;
        }
        
        return NO;
    }
#endif
}

- (NSString *)localizedLastCheckForUpdates
{
    @autoreleasepool {
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
        if (prefs[kCVKUpdateLastCheck]) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = kCVKUpdateTimeFormat;
            return [dateFormatter dateFromString:prefs[kCVKUpdateLastCheck]].timeAgoSinceNow;
        }
        
        return CVKLocalizedString(@"NEVER");
    }
}

@end
