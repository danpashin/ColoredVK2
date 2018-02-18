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
    [self openURL:[NSURL URLWithString:@"https://vk.com/danpashin"]];
}

- (void)openTesterProfile:(PSSpecifier *)specifier
{
    [self openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/%@", specifier.properties[@"url"]]]];
}

- (void)showTextController:(PSSpecifier *)specifier
{
    ColoredVKTextViewController *controller = [[ColoredVKTextViewController alloc] initWithFile:specifier.properties[@"fileName"] 
                                                                                      localized:[specifier.properties[@"localized"] boolValue]];
    controller.backgroundStyle = ColoredVKWindowBackgroundStyleCustom;
    controller.app_is_vk = self.app_is_vk;
    controller.enableNightTheme = self.nightThemeColorScheme.enabled;
    controller.nightThemeColorScheme = self.nightThemeColorScheme;
    [controller show];
}

@end

