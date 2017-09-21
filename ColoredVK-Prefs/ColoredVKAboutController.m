//
//  ColoredVKAboutController.m
//  ColoredVK
//
//  Created by Даниил on 13.04.17.
//
//

#import "ColoredVKAboutController.h"
#import "ColoredVKTextViewController.h"
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

- (void)showTextController:(PSSpecifier *)specifier
{
    ColoredVKTextViewController *controller = [[ColoredVKTextViewController alloc] initWithFile:specifier.properties[@"fileName"]];
    controller.backgroundStyle = ColoredVKWindowBackgroundStyleBlurred;
    [controller show];
}

@end

