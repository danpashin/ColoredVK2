//
//  ColoredVKAboutController.m
//  ColoredVK
//
//  Created by Даниил on 13.04.17.
//
//

#import "ColoredVKAboutController.h"
#import "ColoredVKLicencesController.h"
#import "ColoredVKUpdatesController.h"
#import "ColoredVKHeaderView.h"


@implementation ColoredVKAboutController

- (void)loadView
{
    [super loadView];
    self.prefsTableView.tableHeaderView = [ColoredVKHeaderView headerForView:self.prefsTableView];
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

@end

