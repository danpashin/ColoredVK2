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
#import "ColoredVKUpdatesController.h"

@interface ColoredVKAboutController ()

@property (strong, nonatomic) ColoredVKUpdatesController *updatesController;
@property (nonatomic, getter=getLastCheckForUpdates, copy) NSString *lastCheckForUpdates;

@end

@implementation ColoredVKAboutController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.updatesController = [ColoredVKUpdatesController new];
    self.lastCheckForUpdates = self.updatesController.localizedLastCheckForUpdates;
}

- (void)checkForUpdates
{
    __weak typeof(self) weakSelf = self;
    self.updatesController.checkCompletionHandler = ^(ColoredVKUpdatesController *controller) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.lastCheckForUpdates = controller.localizedLastCheckForUpdates;
            [weakSelf reloadSpecifiers];
        });
    };
    self.updatesController.showErrorAlert = YES;
    [self.updatesController checkUpdates];
}

- (void)openDeveloperProfile
{
    [self openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/%@", kPackageDevName]]];
}

- (void)openTesterProfile:(PSSpecifier *)specifier
{
    [self openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/%@", specifier.properties[@"url"]]]];
}

- (void)showUsedLibraries
{
    ColoredVKLicencesController *controller = [ColoredVKLicencesController new];
    controller.backgroundStyle = ColoredVKWindowBackgroundStyleBlurred;
    [controller show];
}

- (void)showLicenceAgreement
{
    ColoredVKHelpController *helpController = [ColoredVKHelpController new];
    helpController.backgroundStyle = ColoredVKWindowBackgroundStyleBlurred;
    [helpController show];
}
@end

