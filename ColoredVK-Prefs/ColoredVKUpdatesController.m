//
//  ColoredVKUpdatesController.m
//  ColoredVK
//
//  Created by Даниил on 13/10/16.
//
//

#import "ColoredVKUpdatesController.h"
#import "PrefixHeader.h"
#import "NSDate+DateTools.h"

@interface ColoredVKUpdatesController ()
@property (strong, nonatomic) NSString *prefsPath;
@property (strong, nonatomic) NSBundle *cvkBunlde;
@end

@implementation ColoredVKUpdatesController

- (UIStatusBarStyle) preferredStatusBarStyle
{
    if ([NSStringFromClass([[UIApplication sharedApplication].keyWindow.rootViewController class]) isEqualToString:@"DeckController"]) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (id)specifiers
{
    self.prefsPath = CVK_PREFS_PATH;
    self.cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    
    NSString *plistName = @"ColoredVKUpdates";
    
    if ([self respondsToSelector:@selector(setBundle:)] && [self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:)]) {
        self.bundle = self.cvkBunlde;
        _specifiers = [[self loadSpecifiersFromPlistName:plistName target:self] mutableCopy];
    } else if ([self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:bundle:)]) {
        _specifiers = [[self loadSpecifiersFromPlistName:plistName target:self bundle:self.cvkBunlde] mutableCopy];
    } 
    else if ([self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:)]) {
        _specifiers = [[self loadSpecifiersFromPlistName:plistName target:self] mutableCopy];
    }
    
    return _specifiers;
}

- (id) readPreferenceValue:(PSSpecifier*)specifier
{    
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
    if (prefs == nil) { prefs = [NSMutableDictionary new]; [prefs writeToFile:self.prefsPath atomically:YES]; }
    
    if (!prefs[specifier.properties[@"key"]]) return specifier.properties[@"default"];
    return prefs[specifier.properties[@"key"]];
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:self.prefsPath];
    [prefs setValue:value forKey:specifier.properties[@"key"]];
    [prefs writeToFile:self.prefsPath atomically:YES];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
}

- (NSString *)getLastCheckForUpdates:(PSSpecifier *)specifier
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";                
    NSDate *lastDate = prefs[@"lastCheckForUpdates"]?[dateFormatter dateFromString:prefs[@"lastCheckForUpdates"]]:[NSDate date];
    
    return lastDate.timeAgoSinceNow;
}

- (void)checkForUpdates:(id)sender
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *stringURL = [NSString stringWithFormat:@"http://danpashin.ru/api/v1.1/checkUpdates.php?userVers=%@&product=com.daniilpashin.coloredvk2", kColoredVKVersion];
#ifndef COMPILE_FOR_JAIL
        stringURL = [stringURL stringByAppendingString:@"&getIPA=1"];
#endif
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest 
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK" message:@"" preferredStyle:UIAlertControllerStyleAlert];
                                   if (!connectionError) {
                                       NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:self.prefsPath];
                                       NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                       if (!responseDict[@"error"]) {
                                           NSString *skip = NSLocalizedStringFromTableInBundle(@"SKIP_THIS_VERSION_BUTTON_TITLE", nil, self.cvkBunlde, nil);
                                           NSString *remindLater = NSLocalizedStringFromTableInBundle(@"REMIND_LATER_BUTTON_TITLE", nil, self.cvkBunlde, nil);
                                           NSString *updateNow = NSLocalizedStringFromTableInBundle(@"UPADTE_BUTTON_TITLE", nil, self.cvkBunlde, nil);
                                                   
                                           alertController.message = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"YOUR_COPY_OF_TWEAK_NEEDS_TO_BE_UPGRADED_ALERT_MESSAGE", nil, self.cvkBunlde, nil), responseDict[@"version"]];
                                           [alertController addAction:[UIAlertAction actionWithTitle:skip style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                               [prefs setValue:responseDict[@"version"] forKey:@"skippedVersion"];
                                               [prefs writeToFile:self.prefsPath atomically:YES];
                                           }]];
                                           [alertController addAction:[UIAlertAction actionWithTitle:remindLater style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
                                           [alertController addAction:[UIAlertAction actionWithTitle:updateNow style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                               NSURL *url = [NSURL URLWithString:responseDict[@"url"]];
                                               if ([[UIApplication sharedApplication] canOpenURL:url]) [[UIApplication sharedApplication] openURL:url];
                                               
                                           }]];
                                       } else {
                                           alertController.message = NSLocalizedStringFromTableInBundle(@"NO_UPDATES_FOUND_BUTTON_TITLE", nil, self.cvkBunlde, nil);
                                           [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
                                       }
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
                                       });
                                       
                                       NSDateFormatter *dateFormatter = [NSDateFormatter new];
                                       dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
                                       [prefs setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:@"lastCheckForUpdates"];
                                       [prefs writeToFile:self.prefsPath atomically:YES];
                                       [self reloadSpecifiers];
                                   }
                               }];
    });

}
@end
