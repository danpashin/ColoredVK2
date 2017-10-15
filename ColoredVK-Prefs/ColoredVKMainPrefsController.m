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
        
        UITextView *footerLabel = [[UITextView alloc] init];
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.text = CVKLocalizedString(@"YOU_HAVE_FREE_VERSION");
        footerLabel.textColor = @"CF000F".hexColorValue;
        footerLabel.textAlignment = NSTextAlignmentCenter;
        footerLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]-0.5f];
        footerLabel.editable = NO;
        footerLabel.selectable = NO;
        footerLabel.scrollEnabled = NO;
        [contentView addSubview:footerLabel];
        
        UIButton *hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"CloseIconAlt" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
        [hideButton setImage:image forState:UIControlStateNormal];
        hideButton.accessibilityLabel = CVKLocalizedString(@"HIDE");
        [hideButton addTarget:self action:@selector(actionHideFreeVersionFooter) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:hideButton];
        
        footerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[footerLabel]|" options:0 metrics:nil views:@{@"footerLabel":footerLabel}]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]-|" options:0 metrics:nil views:@{@"label":footerLabel}]];        
        
        hideButton.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[button(44)]" options:0 metrics:nil views:@{@"button":hideButton}]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(44)]|" options:0 metrics:nil views:@{@"button":hideButton}]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            footerLabel.textContainer.exclusionPaths = @[ [UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetWidth(contentView.frame)-48, 0, 48, 44)] ];
        });
        
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
    
    if (@available(iOS 9.0, *)) {
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
        height = 80;
    }
    
    return height;
}

@end
