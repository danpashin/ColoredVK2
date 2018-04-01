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
#import <SafariServices/SFSafariViewController.h>
#import "ColoredVKAccountController.h"
#import "NSString+ColoredVK.h"
#import "ColoredVKBiometry.h"

@interface ColoredVKMainPrefsController ()

@property (strong, nonatomic) NSString *vkAppVersion;
@property (strong, nonatomic) UIView *freeVersionFooter;
@property (assign, nonatomic) BOOL showFreeVersionFooter;

@end

@implementation ColoredVKMainPrefsController

NSArray <NSString *> *cvkPrefsEnabledSpecifiers;

- (NSArray <PSSpecifier *> *)specifiers
{
    if (!_specifiers) {
        NSMutableArray <PSSpecifier *> *specifiersArray = [self specifiersForPlistName:@"Main" localize:YES].mutableCopy;
        
        ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
        
        BOOL shouldDisable = YES;
        if (newInstaller.user.authenticated)
            shouldDisable = (newInstaller.user.accountStatus != ColoredVKUserAccountStatusPaid);
        else if (deviceIsJailed)
            shouldDisable = !installerShouldOpenPrefs;
        
        self.showFreeVersionFooter = shouldDisable;
        
        for (PSSpecifier *specifier in specifiersArray) {
            @autoreleasepool {
                if (specifier.identifier && ![cvkPrefsEnabledSpecifiers containsObject:specifier.identifier] && shouldDisable) {
                    [specifier setProperty:@NO forKey:@"enabled"];
                } else {
                    [specifier setProperty:@YES forKey:@"enabled"];
                }
            }
        }
        
        NSString *footerText = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"TWEAK_FOOTER_TEXT", nil, self.bundle, nil), 
                                [UIDevice currentDevice].systemVersion, kPackageVersion, self.vkAppVersion];
        PSSpecifier *footer = [PSSpecifier emptyGroupSpecifier];
        [footer setProperty:[footerText stringByAppendingString:@"\n\n© Daniil Pashin 2018\nПри поддержке theux.ru"] forKey:@"footerText"];
        [footer setProperty:@"1" forKey:@"footerAlignment"];
        [specifiersArray addObject:footer];
        
        _specifiers = specifiersArray;
    }
    return _specifiers;
}

- (void)commonInit
{
    [super commonInit];
    
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    self.vkAppVersion = prefs[@"vkVersion"] ? prefs[@"vkVersion"] : CVKLocalizedString(@"UNKNOWN");
}

- (void)loadView
{
    [super loadView];
    [[ColoredVKNewInstaller sharedInstaller] checkStatus];
    
    cvkPrefsEnabledSpecifiers = @[@"enableTweakSwitch", @"navToolBarPrefsLink", @"menuPrefsLink", 
                                  @"messagesPrefsLink", @"manageAccount", @"aboutPrefsLink",
                                  @"tweakPrefsLink", @"faqLink"];
    
    self.table.tableHeaderView = [ColoredVKHeaderView headerForView:self.table];   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"";
    
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:@"com.daniilpashin.coloredvk2.reload.prefs.menu" object:nil 
                                                       queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                                                           [weakSelf reloadSpecifiers];
                                                       }];
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
            footerLabel.textContainer.exclusionPaths = @[ [UIBezierPath bezierPathWithRect:CGRectMake(CGRectGetWidth(self.table.frame)-48, 0, 48, 44)] ];
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
    [self reloadSpecifiers];
}

- (void)actionOpenFaq
{    
    SFSafariViewController *sfController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:kPackageFaqLink]];
    [self presentViewController:sfController animated:YES completion:nil];
}


#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [super tableView:tableView viewForFooterInSection:section];
    
    if ((section == 0) && self.showFreeVersionFooter) {
        footer = self.freeVersionFooter;
    }
    
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = [super tableView:tableView heightForFooterInSection:section];
    
    if ((section == 0) && self.showFreeVersionFooter) {
        height = 80;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
    if ([specifier.identifier isEqualToString:@"manageAccount"]) {
        
        void (^presentAccountBlock)(void) = ^{
            ColoredVKAccountController *accountController = [ColoredVKAccountController new];
            [self.navigationController pushViewController:accountController animated:YES];
        };
        
//        if ([ColoredVKNewInstaller sharedInstaller].user.authenticated) {
//            [ColoredVKBiometry authenticateWithPasscode:@"0000" success:presentAccountBlock failure:^{
//                [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            }];
//        } else {
            presentAccountBlock();
//        }
        
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

@end
