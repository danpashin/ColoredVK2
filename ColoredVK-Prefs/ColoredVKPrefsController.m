//
//  ColoredVKPrefsController.m
//  ColoredVK
//
//  Created by Даниил on 19.07.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKPrefsController.h"
#import "PrefixHeader.h"
#import "ColoredVKHeaderView.h"
#import "ColoredVKInstaller.h"
#import "ColoredVKPrefs.h"
#import "NSData+AES.h"
#import "NSData+AESCrypt.h"
#import "ColoredVKHUD.h"

@interface ColoredVKPrefsController ()
@property (strong, nonatomic) NSString *prefsPath;
@property (strong, nonatomic) NSBundle *cvkBunlde;
@property (strong, nonatomic) NSString *cvkFolder;
@end

@implementation ColoredVKPrefsController

- (UIStatusBarStyle) preferredStatusBarStyle
{
    if ([[NSBundle mainBundle].executablePath.lastPathComponent isEqualToString:@"vkclient"]) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (id)specifiers
{
    if (!_specifiers) {
        NSString *plistName = @"Main";
        NSMutableArray *specifiersArray = [NSMutableArray new];
        if ([self respondsToSelector:@selector(setBundle:)] && [self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:)]) {
            self.bundle = self.cvkBunlde;
            specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self] mutableCopy];
        } else if ([self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:bundle:)]) {
            specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self bundle:self.cvkBunlde] mutableCopy];
        } 
        else if ([self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:)]) {
            specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self] mutableCopy];
        }
        
        if (specifiersArray.count == 0) {
            specifiersArray = [NSMutableArray new];
            [specifiersArray addObject:[self errorMessage]];
        }
        [specifiersArray addObject:[self footer]];
        
        _specifiers = [specifiersArray copy];
    }
    return _specifiers;
}

- (void)viewDidLoad
{
    
    self.prefsPath = CVK_PREFS_PATH;
    self.cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    self.cvkFolder = CVK_FOLDER_PATH;
    [super viewDidLoad];
    [[ColoredVKInstaller sharedInstaller] install:^(BOOL disableTweak) {}];
    for (UIView *view in self.view.subviews) {
        if ([CLASS_NAME(view) isEqualToString:@"UITableView"]) {
            UITableView *tableView = (UITableView *)view;
            tableView.tableHeaderView = [ColoredVKHeaderView headerForView:self.view];
            tableView.separatorColor = [UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1];
            break;
        }
    }
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
    if ([specifier.identifier isEqualToString:@"enabled"]) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.black.theme"), NULL, NULL, YES);
    }
}


- (PSSpecifier *)footer
{
    NSString *footerText = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"TWEAK_FOOTER_TEXT", nil, self.cvkBunlde, nil), [self getTweakVersion], [self getVKVersion] ];
    
    PSSpecifier *footer = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [footer setProperty:[footerText stringByAppendingString:@"\n\n© Daniil Pashin 2015"] forKey:@"footerText"];
    [footer setProperty:@"1" forKey:@"footerAlignment"];
    
    return footer;
}

- (PSSpecifier *)errorMessage
{
    PSSpecifier *errorMessage = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [errorMessage setProperty:[NSLocalizedStringFromTableInBundle(@"LOADING_TWEAK_FILES_ERROR_MESSAGE", nil, self.cvkBunlde, nil) stringByAppendingString:@"\n\nhttps://vk.com/danpashin"] forKey:@"footerText"];
    [errorMessage setProperty:@"1" forKey:@"footerAlignment"];
    return errorMessage;
}

- (NSString *)getTweakVersion
{
    return [kColoredVKVersion stringByReplacingOccurrencesOfString:@"-" withString:@" "];
}

- (NSString *)getVKVersion
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
    return prefs[@"vkVersion"];
}

- (void)resetSettings
{
    void (^resetSettingsBlock)() = ^{
        if ([[NSBundle mainBundle].executablePath.lastPathComponent isEqualToString:@"vkclient"]) 
            self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:60/255.0f green:112/255.0f blue:169/255.0f alpha:1];
        
        ColoredVKHUD *hud = [ColoredVKHUD showHUD];
        hud.operation = [NSBlockOperation blockOperationWithBlock:^{
            NSError *error = nil;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:self.prefsPath error:&error];
            [fileManager removeItemAtPath:CVK_FOLDER_PATH error:&error];
            [fileManager removeItemAtPath:kDRMLicencePath error:&error];
            [self reloadSpecifiers];
            CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
            CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
            CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk.reload.menu"),   NULL, NULL, YES);
            CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk.black.theme"),   NULL, NULL, YES);
            error?[hud showFailure]:[hud showSuccess];
        }];  
    };
        
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"WARNING", nil, self.cvkBunlde, nil)
                                                                             message:NSLocalizedStringFromTableInBundle(@"RESET_SETTINGS_QUESTION", nil, self.cvkBunlde, nil) 
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *resetTitle = [NSLocalizedStringFromTableInBundle(@"RESET_SETTINGS", @"Main", self.cvkBunlde, nil) componentsSeparatedByString:@" "].firstObject;
    UIAlertAction *resetAction = [UIAlertAction actionWithTitle:resetTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) { resetSettingsBlock(); }];
    
    NSData *decryptedData = [[NSData dataWithContentsOfFile:kDRMLicencePath] AES128DecryptedDataWithKey:kDRMLicenceKey];
    NSDictionary *dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
    if ([dict.allKeys containsObject:@"Login"]) {        
        resetAction.enabled = NO;
        alertController.message = [alertController.message stringByAppendingString:@"\nПодтвердите данное действие паролем"];
        
        __weak typeof(self) weakSelf = self;
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = UIKitLocalizedString(@"Password");
            textField.secureTextEntry = YES;
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:@{@"textField":textField, @"action":resetAction}];
        }];
        resetAction = [UIAlertAction actionWithTitle:resetTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kDRMRemoteServerURL]];
            request.HTTPMethod = @"POST";
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
            NSString *password = [[alertController.textFields[0].text dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:kDRMAuthorizeKey].base64Encoding;
            NSString *parameters = [NSString stringWithFormat:@"login=%@&password=%@&action=logout&version=%@", dict[@"Login"], password, kDRMPackageVersion];
            request.HTTPBody = [parameters dataUsingEncoding:NSUTF8StringEncoding];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                if (!connectionError) {
                    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if (!responseDict[@"error"])  resetSettingsBlock();
                    else [self showAlertWithText:[NSString stringWithFormat:CVKLocalizedString(@"ERROR %@"), responseDict[@"error"]]];
                } else [self showAlertWithText:[NSString stringWithFormat:CVKLocalizedString(@"ERROR %@"), connectionError.localizedDescription]];
            }];
        }];
    }
    
    [alertController addAction:resetAction];
    [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)textFieldChanged:(NSNotification *)notification
{
    if (notification && ([notification.object isKindOfClass:[NSDictionary class]] && ( ((NSDictionary *)notification.object).allKeys.count == 2)) ) {
        NSDictionary *dict = notification.object;
        UITextField *textField = dict[@"textField"];
        UIAlertAction *resetAction = dict[@"action"];
        
        if (textField.text.length > 0) resetAction.enabled = YES;
        else resetAction.enabled = NO;
    }
}

- (void)showAlertWithText:(NSString *)text
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK 2" message:text preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}
@end
