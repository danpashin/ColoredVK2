//
//  ColoredVKPrefs.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//

#import "ColoredVKPrefs.h"
#import "ColoredVKAlertController.h"
#import "ColoredVKNewInstaller.h"
#import "Tweak.h"
#import "ColoredVKStepperButton.h"


@implementation ColoredVKPrefs

- (UIStatusBarStyle)preferredStatusBarStyle
{    
    return self.app_is_vk ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSString *plistName = [@"plists/" stringByAppendingString:self.specifier.properties[@"plistToLoad"]];
        _specifiers = [self specifiersForPlistName:plistName localize:YES addFooter:NO];
    }
    return _specifiers;
}

- (NSArray <PSSpecifier*> *)specifiersForPlistName:(NSString *)plistName localize:(BOOL)localize addFooter:(BOOL)addFooter
{
    NSMutableArray *specifiersArray = [NSMutableArray new];
    if ([self respondsToSelector:@selector(setBundle:)] && [self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:)]) {
        self.bundle = self.cvkBundle;
        specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self] mutableCopy];
    } else if ([self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:bundle:)]) {
        specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self bundle:self.cvkBundle] mutableCopy];
    } 
    else if ([self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:)]) {
        specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self] mutableCopy];
    }
    
    if (localize) {
        for (PSSpecifier *specifier in specifiersArray) {
            specifier.name = NSLocalizedStringFromTableInBundle(specifier.name, @"ColoredVK", self.bundle, nil);
            
            if (specifier.properties[@"footerText"]) {
                if ([specifier.properties[@"footerText"] isEqualToString:@"AVAILABLE_IN_%@_AND_HIGHER"]) {
                    NSString *string = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(specifier.properties[@"footerText"], @"ColoredVK", self.bundle, nil), specifier.properties[@"requiredVersion"]];
                    [specifier setProperty:string forKey:@"footerText"];
                } else
                    [specifier setProperty:NSLocalizedStringFromTableInBundle(specifier.properties[@"footerText"], @"ColoredVK", self.bundle, nil) forKey:@"footerText"];
            }
            if (specifier.properties[@"label"])
                [specifier setProperty:NSLocalizedStringFromTableInBundle(specifier.properties[@"label"], @"ColoredVK", self.bundle, nil) forKey:@"label"];
            if (specifier.properties[@"detailedLabel"])
                [specifier setProperty:NSLocalizedStringFromTableInBundle(specifier.properties[@"detailedLabel"], @"ColoredVK", self.bundle, nil) forKey:@"detailedLabel"];
            
            if (specifier.properties[@"validTitles"]) {
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
                for (NSString *key in specifier.titleDictionary.allKeys) 
                    [tempDict setValue:NSLocalizedStringFromTableInBundle(specifier.titleDictionary[key], @"ColoredVK", self.bundle, nil) forKey:key];
                specifier.titleDictionary = [tempDict copy];
            }
            
            if ([specifier.identifier isEqualToString:@"checkUpdates"] && [kPackageVersion containsString:@"beta"])
                [specifier setProperty:@NO forKey:@"enabled"];
            if ([specifier.identifier isEqualToString:@"manageSettingsFooter"] && specifier.properties[@"footerText"])
                 [specifier setProperty:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(specifier.properties[@"footerText"], @"ColoredVK", self.bundle, nil), CVK_BACKUP_PATH]
                                 forKey:@"footerText"];
        }
    }
    
    if (specifiersArray.count == 0) {
        specifiersArray = [NSMutableArray new];
    } else {
        if (addFooter) [specifiersArray addObject:self.footer];
    }
    
    return [specifiersArray copy];
}

- (void)loadView
{
    [super loadView];
    
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITableView class]]) {
            self.prefsTableView = (UITableView *)view;
            self.prefsTableView.separatorColor = [UIColor clearColor];
            break;
        }
    }
    
    self.prefsTableView.emptyDataSetSource = self;
    self.prefsTableView.emptyDataSetDelegate = self;
    
    
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller]; 
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    self.enableNightTheme = prefs[@"nightThemeType"] ? ([prefs[@"nightThemeType"] integerValue] != -1) : NO;
    self.enableNightTheme = ([prefs[@"enabled"] boolValue] && self.enableNightTheme && newInstaller.tweakPurchased && newInstaller.tweakActivated);
    self.nightThemeColorScheme = [ColoredVKNightThemeColorScheme colorSchemeForType:[prefs[@"nightThemeType"] integerValue]];
    
    if (self.app_is_vk && self.enableNightTheme) {
        self.prefsTableView.backgroundColor = self.nightThemeColorScheme.backgroundColor;
        self.navigationController.navigationBar.barTintColor = self.nightThemeColorScheme.navbackgroundColor;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.specifier ? self.specifier.name : @"";
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
    if (prefs == nil) { prefs = [NSMutableDictionary new]; [prefs writeToFile:self.prefsPath atomically:YES]; }
    
    if (!prefs[specifier.properties[@"key"]]) return specifier.properties[@"default"];
    return prefs[specifier.properties[@"key"]];
}


- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:self.prefsPath];
    if (value) [prefs setValue:value forKey:specifier.properties[@"key"]];
    else [prefs removeObjectForKey:specifier.properties[@"key"]];
    [prefs writeToFile:self.prefsPath atomically:YES];
    
    NSArray *identificsToReloadMenu = @[@"enableTweakSwitch", @"menuSelectionStyle", @"hideMenuSeparators", 
                                        @"changeSwitchColor", @"useMenuParallax", @"changeMenuTextColor", 
                                        @"showMenuCell"];
    
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    
    if ([specifier.identifier containsString:@"nightThemeType"]) {
        [self updateNightTheme];
        CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.reload.menu"), nil, nil, YES);
        CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.night.theme"), nil, nil, YES);
    }
    
    CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), nil, nil, YES);
    
    if ([identificsToReloadMenu containsObject:specifier.identifier])
        CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.reload.menu"), nil, nil, YES);
    
    if ([specifier.identifier isEqualToString:@"enableTweakSwitch"]) {
        [self updateNightTheme];
        CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.night.theme"), nil, nil, YES);
        CFNotificationCenterPostNotification(center, CFSTR("com.daniilpashin.coloredvk2.update.corners"), nil, nil, YES);
    }
}

- (void)updateNightTheme
{
    if (!self.app_is_vk)
        return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.prefsTableView.separatorColor = [UIColor clearColor];
            self.prefsTableView.backgroundColor = [UIColor colorWithRed:0.937255f green:0.937255f blue:0.956863f alpha:1.0f];
            self.navigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        } completion:nil];
    });
}


- (PSSpecifier *)footer
{
    NSString *footerText = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"TWEAK_FOOTER_TEXT", nil, self.bundle, nil), self.tweakVersion, self.vkAppVersion ];
    PSSpecifier *footer = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [footer setProperty:[footerText stringByAppendingString:@"\n\n© Daniil Pashin 2017"] forKey:@"footerText"];
    [footer setProperty:@"1" forKey:@"footerAlignment"];
    return footer;
}

- (NSString *)tweakVersion
{
    return [kPackageVersion stringByReplacingOccurrencesOfString:@"-" withString:@" "];
}

- (NSString *)vkAppVersion
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:self.prefsPath];
    return prefs[@"vkVersion"] ? prefs[@"vkVersion"] : CVKLocalizedString(@"UNKNOWN");
}

- (NSBundle *)cvkBundle
{
    return [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
}

- (NSString *)cvkFolder
{
    return CVK_FOLDER_PATH;
}

- (NSString *)prefsPath
{
    return CVK_PREFS_PATH;
}

- (BOOL)openURL:(NSURL *)url
{
    UIApplication *application = [UIApplication sharedApplication];
    
    if ([application canOpenURL:url]) {
        BOOL urlIsOpen = [application openURL:url];
        
        return urlIsOpen;
    }
    
    return NO;
}

- (void)presentPopover:(UIViewController *)controller
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (IS_IPAD) {
            controller.modalPresentationStyle = UIModalPresentationPopover;
            controller.popoverPresentationController.permittedArrowDirections = 0;
            controller.popoverPresentationController.sourceView = self.view;
            controller.popoverPresentationController.sourceRect = self.view.bounds;
        }
        [self.navigationController presentViewController:controller animated:YES completion:nil];
    });
}

- (void)showPurchaseAlert
{
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:kPackageName message:CVKLocalizedString(@"AVAILABLE_IN_FULL_VERSION")
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"THINK_LATER") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"OF_COURSE") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[ColoredVKNewInstaller sharedInstaller] actionPurchase];
    }]];
    [alertController presentFromController:self];
}

- (BOOL)app_is_vk
{
    return [[NSBundle mainBundle].executablePath.lastPathComponent.lowercaseString isEqualToString:@"vkclient"];
}

- (PSSpecifier *)specifierForIndexPath:(NSIndexPath *)indexPath
{
    PSSpecifier *specifier = nil;
    if ([self respondsToSelector:@selector(specifierAtIndexPath:)]) {
        specifier = [self specifierAtIndexPath:indexPath];
    } else {
        NSInteger index = [self indexForRow:indexPath.row inGroup:indexPath.section];
        specifier = [self specifierAtIndex:index];
    }
    
    return specifier;
}


#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.userInteractionEnabled = YES;
    objc_setAssociatedObject(cell, "nightThemeColorScheme", self.nightThemeColorScheme, OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(cell, "app_is_vk", @(self.app_is_vk), OBJC_ASSOCIATION_ASSIGN);
    objc_setAssociatedObject(cell, "enableNightTheme", @(self.enableNightTheme), OBJC_ASSOCIATION_ASSIGN);
        
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cornerRadius = 10.f;
    CGRect bounds = CGRectInset(cell.bounds, 8, 0);
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = [UIColor whiteColor].CGColor;
    
    if (self.app_is_vk && self.enableNightTheme) {
        cell.textLabel.textColor = self.nightThemeColorScheme.textColor;
        layer.fillColor = self.nightThemeColorScheme.foregroundColor.CGColor;
        if ([cell.accessoryView isKindOfClass:[ColoredVKStepperButton class]]) {
            ((UILabel *)[cell.accessoryView valueForKey:@"valueLabel"]).textColor = self.nightThemeColorScheme.textColor;
        }
    }
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    BOOL addSeparatorLine = YES;
    if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
        CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
        addSeparatorLine = NO;
    } else if (indexPath.row == 0) {
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
    } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    } else {
        CGPathAddRect(pathRef, nil, bounds);
    }
    layer.path = pathRef;
    CFRelease(pathRef);
    
    if (addSeparatorLine) {
        CALayer *lineLayer = [CALayer layer];
        CGFloat lineHeight = (1.0f / [UIScreen mainScreen].scale);
        CGFloat margin = 8.0f;
        lineLayer.frame = CGRectMake(CGRectGetMinX(bounds) + margin, 0, CGRectGetWidth(bounds) - (margin * 2), lineHeight);
        lineLayer.backgroundColor = [UIColor colorWithRed:232/255.0f green:233/255.0f blue:234/255.0f alpha:1.0f].CGColor;
        [layer addSublayer:lineLayer];
        
        if (self.app_is_vk && self.enableNightTheme) {
            lineLayer.backgroundColor = self.nightThemeColorScheme.foregroundColor.CGColor;
        }
    }
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:bounds];
    backgroundView.backgroundColor = [UIColor clearColor];
    [backgroundView.layer insertSublayer:layer atIndex:0];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundView = backgroundView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSSpecifier *specifier = [self specifierForIndexPath:indexPath];
    if ([specifier.properties[@"cell"] isEqualToString:@"PSGiantIconCell"])
        return 64.0f;
    
    return 48.0f;
}


#pragma mark -
#pragma mark DZNEmptyDataSetSource
#pragma mark -

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"WarningIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = NSLocalizedStringFromTableInBundle(@"LOADING_TWEAK_FILES_ERROR_MESSAGE", nil, self.cvkBundle, nil);
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    if (self.prefsTableView.tableHeaderView) {
        return -100.0f;
    }
    return -150.0f;
}

@end
