//
//  ColoredVKAboutController.m
//  ColoredVK
//
//  Created by Даниил on 13.04.17.
//
//

#import "ColoredVKAboutController.h"
#import "ColoredVKTextViewController.h"
#import "ColoredVKHeaderView.h"
#import "ColoredVKNewInstaller.h"

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

- (void)showTextController:(PSSpecifier *)specifier
{
    ColoredVKTextViewController *controller = [[ColoredVKTextViewController alloc] initWithFile:specifier.properties[@"fileName"] 
                                                                                      localized:[specifier.properties[@"localized"] boolValue]];
    controller.backgroundStyle = ColoredVKWindowBackgroundStyleCustom;
    [controller show];
}

@end
