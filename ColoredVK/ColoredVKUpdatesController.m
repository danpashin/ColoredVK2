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
#import "ColoredVKNetworkController.h"

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
    
    ColoredVKNetworkController *networkController = [ColoredVKNetworkController controller];
    [networkController sendJSONRequestWithURL:[NSURL URLWithString:stringURL] parameters:nil 
                                      success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
                                          
                                          NSMutableDictionary *tweakPrefs = [[NSMutableDictionary alloc] initWithContentsOfFile:self.prefsPath];
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
                                                                                                     [tweakPrefs writeToFile:self.prefsPath atomically:YES];
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
                                          [tweakPrefs writeToFile:self.prefsPath atomically:YES];
                                          
                                          if (self.checkCompletionHandler) self.checkCompletionHandler(self);
                                          
                                      } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                          if (self.showErrorAlert) {
                                              UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:UIKitLocalizedString(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
                                              [self showAlertWithMessage:error.localizedDescription actions:@[cancelAction]];
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
