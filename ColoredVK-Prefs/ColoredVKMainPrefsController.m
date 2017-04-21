//
//  ColoredVKMainPrefsController.m
//  ColoredVK
//
//  Created by Даниил on 19.07.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKMainPrefsController.h"
#import "ColoredVKHeaderView.h"
#import "ColoredVKInstaller.h"

@implementation ColoredVKMainPrefsController

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSArray *specifiersArray = [self specifiersForPlistName:@"Main" localize:NO addFooter:YES];
        
        for (PSSpecifier *specifier in specifiersArray) {
            if ([specifier.identifier isEqualToString:@"manageAccount"]) {
                if (!licenceContainsKey(@"Login")) [specifier setProperty:@NO forKey:@"enabled"];
            }
        }
        
        _specifiers = specifiersArray;
    }
    return _specifiers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
#ifndef COMPILE_APP
    [ColoredVKInstaller sharedInstaller];
#endif
    self.prefsTableView.tableHeaderView = [ColoredVKHeaderView headerForView:self.view];
    self.navigationItem.title = @"";
}
@end
