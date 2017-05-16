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
#import "ColoredVKHelpController.h"

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
    NSString *stringURL = [NSString stringWithFormat:@"%@/checkUpdates.php?product=%@&userVers=%@", kPackageAPIURL, kPackageIdentifier, kPackageVersion];
#ifndef COMPILE_FOR_JAIL
    stringURL = [stringURL stringByAppendingString:@"&getIPA=1"];
#endif
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kPackageName message:@"" preferredStyle:UIAlertControllerStyleAlert];
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
                alertController.message = responseDict[@"error"];
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

- (void)openDeveloperProfile
{
    [self openProfieForUsername:kPackageDevName];
}

- (void)openTesterProfile:(PSSpecifier *)specifier
{
    [self openProfieForUsername:specifier.properties[@"url"]];
}

- (void)openProfieForUsername:(NSString *)username
{
    NSURL *appURL = [NSURL URLWithString:[NSString stringWithFormat:@"vk://%@", username]];
    UIApplication *application = [UIApplication sharedApplication];
    if ([application canOpenURL:appURL]) [self openURL:appURL];
    else [self openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/%@", username]]];
}

- (void)showUsedLibraries
{
    ColoredVKLicencesController *controller = [ColoredVKLicencesController new];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showLicenceAgreement
{
    ColoredVKHelpController *helpController = [ColoredVKHelpController new];
    helpController.backgroundStyle = ColoredVKWindowBackgroundStyleBlurred;
    [helpController show];
}
@end

