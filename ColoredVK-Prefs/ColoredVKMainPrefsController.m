//
//  ColoredVKMainPrefsController.m
//  ColoredVK
//
//  Created by Даниил on 19.07.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKMainPrefsController.h"
#import "ColoredVKHeaderView.h"
#import "ColoredVKUpdatesController.h"
#import "ColoredVKNewInstaller.h"
#import "ColoredVKAlertController.h"
#import <SafariServices/SafariServices.h>
#import "ColoredVKWebViewController.h"

@interface ColoredVKMainPrefsController ()

@property (strong, nonatomic) UIView *freeVersionFooter;
@property (assign, nonatomic) NSUInteger freeeVersionSection;
@property (assign, nonatomic) BOOL showFreeVersionFooter;

@end

@implementation ColoredVKMainPrefsController

NSArray <NSString *> *specifiersToEnable;

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSMutableArray *specifiersArray = [self specifiersForPlistName:@"Main" localize:NO addFooter:YES].mutableCopy;
        
        ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller]; 
        BOOL shouldDisable = (!newInstaller.tweakPurchased || !newInstaller.tweakActivated);
        
        self.showFreeVersionFooter = shouldDisable;
        
        for (PSSpecifier *specifier in specifiersArray) {
            if (![specifiersToEnable containsObject:specifier.identifier] && shouldDisable) {
                [specifier setProperty:@NO forKey:@"enabled"];
            } else {
                [specifier setProperty:@YES forKey:@"enabled"];
            }
        }
        
        _specifiers = specifiersArray.copy;
    }
    return _specifiers;
}

- (void)loadView
{
    [super loadView];
    
    self.freeeVersionSection = 0;
    specifiersToEnable = @[@"enableTweakSwitch", @"navToolBarPrefsLink", @"menuPrefsLink", 
                           @"messagesPrefsLink", @"manageAccount", @"aboutPrefsLink",
                           @"tweakPrefsLink", @"faqLink"];
    
    self.prefsTableView.tableHeaderView = [ColoredVKHeaderView headerForView:self.prefsTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"com.daniilpashin.coloredvk2.reload.prefs.menu" object:nil];
    
    
    ColoredVKUpdatesController *updatesController = [ColoredVKUpdatesController new];
    if (updatesController.shouldCheckUpdates)
        [updatesController checkUpdates];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"";
}

- (void)reloadTable
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadSpecifiers];
    });
}

- (UIView *)freeVersionFooter
{
    if (!_freeVersionFooter) {
        UIView *contentView = [[UIView alloc] init];
        
        UILabel *footerLabel = [[UILabel alloc] init];
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.text = CVKLocalizedString(@"YOU_HAVE_FREE_VERSION");
        footerLabel.textColor = @"CF000F".hexColorValue;
        footerLabel.textAlignment = NSTextAlignmentCenter;
        footerLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
        footerLabel.numberOfLines = 0;
        [contentView addSubview:footerLabel];
        
        UIButton *hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [hideButton setTitle:CVKLocalizedString(@"HIDE") forState:UIControlStateNormal];
        [hideButton setTitleColor:CVKMainColor forState:UIControlStateNormal];
        hideButton.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
        [hideButton addTarget:self action:@selector(actionHideFreeVersionFooter) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:hideButton];
        
        footerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        hideButton.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[footerLabel]-[hideButton(btnHeight)]|" options:0 metrics:@{@"btnHeight":@16} views:@{@"footerLabel":footerLabel, @"hideButton":hideButton}]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[footerLabel]-|" options:0 metrics:nil views:@{@"footerLabel":footerLabel}]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[hideButton]-|" options:0 metrics:nil views:@{ @"hideButton":hideButton}]];
        
        _freeVersionFooter = contentView;
    }
    
    return _freeVersionFooter;
}

- (void)setShowFreeVersionFooter:(BOOL)showFreeVersionFooter
{
    _showFreeVersionFooter = showFreeVersionFooter;
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    if (![prefs[@"hideFreeVersionFooter"] boolValue]) {
        _showFreeVersionFooter = showFreeVersionFooter;
        self.freeVersionFooter.hidden = !showFreeVersionFooter;
    } else {
        _showFreeVersionFooter = NO;
        self.freeVersionFooter.hidden = YES;
    }
}

- (void)actionHideFreeVersionFooter
{
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    prefs[@"hideFreeVersionFooter"] = @YES;
    [prefs writeToFile:CVK_PREFS_PATH atomically:YES];
    
    self.showFreeVersionFooter = NO;
    [self reloadTable];
}

- (void)actionOpenFaq
{
    NSURL *url = [NSURL URLWithString:kPackageFaqLink];
    
    if (SYSTEM_VERSION_IS_MORE_THAN(@"9.0")) {
        SFSafariViewController *sfController = [[SFSafariViewController alloc] initWithURL:url];
        [self presentViewController:sfController animated:YES completion:nil];
    } else {
        ColoredVKWebViewController *webController = [ColoredVKWebViewController new];
        webController.url = url;
        webController.request = [NSURLRequest requestWithURL:webController.url];
        [webController presentFromController:self];
    }
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [super tableView:tableView viewForFooterInSection:section];
    
    if ((section == self.freeeVersionSection) && self.showFreeVersionFooter) {        
        footer = self.freeVersionFooter;
    }
    
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = [super tableView:tableView heightForFooterInSection:section];
    
    if ((section == self.freeeVersionSection) && self.showFreeVersionFooter) {
        height = 75;
    }
    
    return height;
}

@end
