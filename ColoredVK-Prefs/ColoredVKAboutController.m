//
//  ColoredVKAboutController.m
//  ColoredVK
//
//  Created by Даниил on 13.04.17.
//
//

#import "ColoredVKAboutController.h"
#import "ColoredVKHUD.h"
#import "NSDate+DateTools.h"
#import "ColoredVKLicencesController.h"

@implementation ColoredVKAboutController

- (NSString *)getLastCheckForUpdates
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    
    return prefs[@"lastCheckForUpdates"]?[dateFormatter dateFromString:prefs[@"lastCheckForUpdates"]].timeAgoSinceNow : NSLocalizedStringFromTableInBundle(@"NEVER", nil, self.cvkBundle, nil);
}

- (void)checkForUpdates
{
    NSString *stringURL = [NSString stringWithFormat:@"%@/checkUpdates.php?userVers=%@&product=com.daniilpashin.coloredvk2", kColoredVKAPIURL, kColoredVKVersion];
#ifndef COMPILE_FOR_JAIL
    stringURL = [stringURL stringByAppendingString:@"&getIPA=1"];
#endif
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK 2" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:self.prefsPath];
            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (!responseDict[@"error"]) {
                NSString *skip = NSLocalizedStringFromTableInBundle(@"SKIP_THIS_VERSION_BUTTON_TITLE", nil, self.cvkBundle, nil);
                NSString *remindLater = NSLocalizedStringFromTableInBundle(@"REMIND_LATER_BUTTON_TITLE", nil, self.cvkBundle, nil);
                NSString *updateNow = NSLocalizedStringFromTableInBundle(@"UPADTE_BUTTON_TITLE", nil, self.cvkBundle, nil);
                
                alertController.message = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"UPGRADE_IS_AVAILABLE_ALERT_MESSAGE", nil, self.cvkBundle, nil),
                                           responseDict[@"version"], responseDict[@"changelog"]];
                [alertController addAction:[UIAlertAction actionWithTitle:skip style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [prefs setValue:responseDict[@"version"] forKey:@"skippedVersion"];
                    [prefs writeToFile:self.prefsPath atomically:YES];
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:remindLater style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
                [alertController addAction:[UIAlertAction actionWithTitle:updateNow style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self openURL:[NSURL URLWithString:responseDict[@"url"]]];
                }]];
            } else {
                alertController.message = NSLocalizedStringFromTableInBundle(@"NO_UPDATES_FOUND_BUTTON_TITLE", nil, self.cvkBundle, nil);
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
            }
            [self presentViewController:alertController animated:YES completion:nil];
            
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
            [prefs setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:@"lastCheckForUpdates"];
            [prefs writeToFile:self.prefsPath atomically:YES];
            [self reloadSpecifiers];
        }
    }];
}

- (void)openProfie
{
    NSURL *appURL = [NSURL URLWithString:@"vk://vk.com/danpashin"];
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:appURL]) [self openURL:appURL];
    else [self openURL:[NSURL URLWithString:@"https://vk.com/danpashin"]];
}

- (void)openTesterPage:(PSSpecifier *)specifier
{
    NSURL *appURL = [NSURL URLWithString:[NSString stringWithFormat:@"vk://vk.com/%@", specifier.properties[@"url"]]];
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:appURL]) [self openURL:appURL];
    else [self openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/%@", specifier.properties[@"url"]]]];
}

- (void)showUsedLibraries
{
    ColoredVKLicencesController *controller = [ColoredVKLicencesController new];
    [self.navigationController pushViewController:controller animated:YES];
}
@end

