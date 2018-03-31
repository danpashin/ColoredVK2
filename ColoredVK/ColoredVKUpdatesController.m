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
        _showErrorAlert = NO;
        _checkedAutomatically = NO;
    }
    return self;
}

- (void)checkUpdates
{
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    NSString *stringURL = [NSString stringWithFormat:@"%@/checkUpdates.php", kPackageAPIURL];
    NSMutableDictionary *parameters = [@{@"userVers": kPackageVersion, @"ios_version":[UIDevice currentDevice].systemVersion, 
                                         @"vk_version":[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                         @"appTeamIdentifier": newInstaller.application.teamIdentifier, @"sellerName": newInstaller.application.sellerName, 
                                         @"checkedAutomatically":@(self.checkedAutomatically)} mutableCopy];
    
#ifndef COMPILE_FOR_JAIL
    parameters[@"getIPA"] = @1;
#endif
    
    ColoredVKNetwork *network = [ColoredVKNetwork sharedNetwork];
    [network sendJSONRequestWithMethod:@"GET" stringURL:stringURL parameters:parameters success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
        
        NSMutableDictionary *tweakPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:CVK_PREFS_PATH];
        if (!json[apiErrorKey]) {
            NSString *newVersion = json[apiNewVersionKey];
            NSString *skippedVersion = tweakPrefs[@"skippedVersion"];
            
            if (![skippedVersion isEqualToString:newVersion] || self.showErrorAlert) {
                NSMutableArray <UIAlertAction *> *alertActions = [NSMutableArray array];
                NSString *updateAlertQuestion = [NSString stringWithFormat:CVKLocalizedString(@"UPGRADE_IS_AVAILABLE_ALERT_MESSAGE"), newVersion, json[apiChangelogKey]];
                
                [alertActions addObject:[UIAlertAction actionWithTitle:CVKLocalizedString(@"REMIND_LATER_BUTTON_TITLE") style:UIAlertActionStyleDefault 
                                                               handler:^(UIAlertAction *action){}]];
                [alertActions addObject:[UIAlertAction actionWithTitle:CVKLocalizedString(@"SKIP_THIS_VERSION_BUTTON_TITLE") style:UIAlertActionStyleDefault 
                                                               handler:^(UIAlertAction *action) {
                                                                   [tweakPrefs setValue:newVersion forKey:@"skippedVersion"];
                                                                   [tweakPrefs writeToFile:CVK_PREFS_PATH atomically:YES];
                                                               }]];
                [alertActions addObject:[UIAlertAction actionWithTitle:CVKLocalizedString(@"UPADTE_BUTTON_TITLE") style:UIAlertActionStyleCancel 
                                                               handler:^(UIAlertAction *action) {
                                                                   NSURL *url = [NSURL URLWithString:json[apiDownloadURLKey]];
                                                                   UIApplication *application = [UIApplication sharedApplication];
                                                                   if ([application canOpenURL:url]) [application openURL:url];
                                                               }]];
                
                [self showAlertWithMessage:updateAlertQuestion actions:alertActions];
            }
        } else {
            if (self.showErrorAlert) {
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:UIKitLocalizedString(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
                [self showAlertWithMessage:json[apiErrorKey] actions:@[cancelAction]];
            }
        }
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        [tweakPrefs setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:prefsLastCheckKey];
        [tweakPrefs writeToFile:CVK_PREFS_PATH atomically:YES];
        
        if (self.checkCompletionHandler)
            self.checkCompletionHandler(self);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if (self.showErrorAlert) {
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:UIKitLocalizedString(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
            [self showAlertWithMessage:error.localizedDescription actions:@[cancelAction]];
        }
    }];
}

- (void)showAlertWithMessage:(NSString *)message actions:(NSArray <UIAlertAction *> *)actions
{
    if (actions.count == 0)
        return;
    
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:kPackageName  message:message 
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
    for (UIAlertAction *action in actions) {
        [alertController addAction:action];
    }
    [alertController present];
}

- (BOOL)shouldCheckUpdates
{
#ifdef COMPILE_APP
    return NO;
#else
    @autoreleasepool {
        NSMutableDictionary *tweakPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:CVK_PREFS_PATH];
        BOOL shouldCheckUpdates = tweakPrefs[prefsCheckUpdatesKey] ? [tweakPrefs[prefsCheckUpdatesKey] boolValue] : YES;
        NSTimeInterval updatesInterval = tweakPrefs[prefsUpdatesCheckIntervalKey] ? [tweakPrefs[prefsUpdatesCheckIntervalKey] doubleValue] : 1.0;
        NSString *lastCheckForUpdates = tweakPrefs[prefsLastCheckKey];
        BOOL beta = [kPackageVersion containsString:@"beta"];
        
        if (shouldCheckUpdates || beta) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
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
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    
    return prefs[prefsLastCheckKey] ? [dateFormatter dateFromString:prefs[prefsLastCheckKey]].timeAgoSinceNow : CVKLocalizedString(@"NEVER");
}

@end
