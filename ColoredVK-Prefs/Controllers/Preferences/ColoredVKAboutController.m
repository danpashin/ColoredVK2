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

@implementation ColoredVKAboutController

- (void)loadView
{
    [super loadView];
    self.table.tableHeaderView = [ColoredVKHeaderView headerForView:self.table];
}

- (void)openDeveloperProfile
{
    if (![self openURL:kPackageDevVKLink])
        [self openURL:kPackageDevLink];
}

- (void)showTextController:(PSSpecifier *)specifier
{
    ColoredVKTextViewController *controller = [[ColoredVKTextViewController alloc] initWithFile:specifier.properties[@"fileName"] 
                                                                                      localized:[specifier.properties[@"localized"] boolValue]];
    controller.backgroundStyle = ColoredVKWindowBackgroundStyleCustom;
    [controller show];
}

@end
