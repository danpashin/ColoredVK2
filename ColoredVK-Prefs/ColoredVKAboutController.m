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
    [self openURL:@"https://vk.com/danpashin"];
}

- (void)showTextController:(PSSpecifier *)specifier
{
    ColoredVKTextViewController *controller = [[ColoredVKTextViewController alloc] initWithFile:specifier.properties[@"fileName"] 
                                                                                      localized:[specifier.properties[@"localized"] boolValue]];
    controller.backgroundStyle = ColoredVKWindowBackgroundStyleCustom;
    [controller show];
}

@end
