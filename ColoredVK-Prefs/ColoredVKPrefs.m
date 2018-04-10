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
#import "UITableViewCell+ColoredVK.h"
#import <objc/runtime.h>
#import "UIScrollView+EmptyDataSet.h"

@interface ColoredVKPrefs ()  <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@end

@implementation ColoredVKPrefs

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit
{
    _cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    if (!self.cvkBundle)
        _cvkBundle = [NSBundle mainBundle];
    
    [self readPrefsWithCompetion:^{
        self.shouldChangeSwitchColor = ([self.cachedPrefs[@"enabled"] boolValue] && [self.cachedPrefs[@"changeSwitchColor"] boolValue]);
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            ColoredVKNightThemeColorScheme *nightThemeColorScheme = [ColoredVKNightThemeColorScheme sharedScheme];
            NSInteger themeType = self.cachedPrefs[@"nightThemeType"] ? [self.cachedPrefs[@"nightThemeType"] integerValue] : -1;
            [nightThemeColorScheme updateForType:themeType];
            
            BOOL vkApp = [ColoredVKNewInstaller sharedInstaller].application.isVKApp;
            nightThemeColorScheme.enabled = ((themeType != -1) && [self.cachedPrefs[@"enabled"] boolValue] && vkApp);
        });
        
        if (self->_specifiers && self->_specifiers.count > 0)
            [self reloadSpecifiers];
    }];
}

- (void)loadView
{
    [super loadView];
    
    self.table.separatorColor = [UIColor clearColor];
    self.table.emptyDataSetSource = self;
    self.table.emptyDataSetDelegate = self;
    
    ColoredVKNightThemeColorScheme *nightThemeColorScheme = [ColoredVKNightThemeColorScheme sharedScheme];
    if ([ColoredVKNewInstaller sharedInstaller].application.isVKApp && nightThemeColorScheme.enabled) {
        self.table.backgroundColor = nightThemeColorScheme.backgroundColor;
        self.navigationController.navigationBar.barTintColor = nightThemeColorScheme.navbackgroundColor;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.specifier ? self.specifier.name : @"";
}

#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)writePrefsWithCompetion:(nullable void(^)(void))completionBlock
{
    @synchronized(self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            [self.cachedPrefs writeToFile:CVK_PREFS_PATH atomically:YES];
            
            if (completionBlock)
                completionBlock();
        });
    }
}

- (void)readPrefsWithCompetion:(nullable void(^)(void))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        self.cachedPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
        if (!self.cachedPrefs) {
            self.cachedPrefs = [NSMutableDictionary dictionary];
            [self writePrefsWithCompetion:nil];
        }
        
        if (completionBlock)
            completionBlock();
    });
}

- (void)reloadSpecifiers
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super reloadSpecifiers];
    });
}

- (void)updateNightTheme
{
    if (![ColoredVKNewInstaller sharedInstaller].application.isVKApp)
        return;
    
    ColoredVKNightThemeColorScheme *nightThemeColorScheme = [ColoredVKNightThemeColorScheme sharedScheme];
    
    NSInteger themeType = self.cachedPrefs[@"nightThemeType"] ? [self.cachedPrefs[@"nightThemeType"] integerValue] : -1;
    [nightThemeColorScheme updateForType:themeType];
    nightThemeColorScheme.enabled = ((themeType != -1) && [self.cachedPrefs[@"enabled"] boolValue]);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.table.separatorColor = [UIColor clearColor];
            self.table.backgroundColor = [UIColor colorWithRed:0.937255f green:0.937255f blue:0.956863f alpha:1.0f];
            self.navigationController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        } completion:nil];
        
        
        for (PSSpecifier *specifier in self.specifiers) {
            PSTableCell *cell = [self cachedCellForSpecifier:specifier];
            [self updateNightThemeForCell:cell animated:YES];
        }
    });
}

- (void)updateNightThemeForCell:(UITableViewCell *)cell animated:(BOOL)animated
{
    if (![ColoredVKNewInstaller sharedInstaller].application.isVKApp)
        return;
    
    ColoredVKNightThemeColorScheme *nightThemeColorScheme = [ColoredVKNightThemeColorScheme sharedScheme];
    ColoredVKCellBackgroundView *backgroundView = cell.customBackgroundView;
    
    void (^changeBlock)(void) = ^{
        backgroundView.backgroundColor         = nightThemeColorScheme.enabled ? nightThemeColorScheme.foregroundColor : nil;
        backgroundView.separatorColor          = nightThemeColorScheme.enabled ? nightThemeColorScheme.backgroundColor : nil;
        backgroundView.selectedBackgroundColor = nightThemeColorScheme.enabled ? nightThemeColorScheme.backgroundColor : nil;
        cell.textLabel.textColor               = nightThemeColorScheme.enabled ? nightThemeColorScheme.textColor : [UIColor blackColor];  
        
        if (nightThemeColorScheme.enabled) {
            if ([cell.accessoryView isKindOfClass:NSClassFromString(@"ColoredVKStepperButton")]) {
                ((UILabel *)[cell.accessoryView valueForKey:@"valueLabel"]).textColor = nightThemeColorScheme.textColor;
            }
        }
    };
    
    if (animated)
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:changeBlock completion:nil];
    else
        changeBlock();
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
        [self presentViewController:controller animated:YES completion:nil];
    });
}

- (void)showPurchaseAlert
{
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:kPackageName message:CVKLocalizedString(@"AVAILABLE_IN_FULL_VERSION")
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"THINK_LATER") style:UIAlertActionStyleCancel 
                                                      handler:^(UIAlertAction *action) {}]];
    [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"OF_COURSE") style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          [[ColoredVKNewInstaller sharedInstaller].user actionPurchase];
                                                      }]];
    [alertController presentFromController:self];
}


#pragma mark -
#pragma mark Getters
#pragma mark -

- (UIStatusBarStyle)preferredStatusBarStyle
{
    BOOL vkApp = [ColoredVKNewInstaller sharedInstaller].application.isVKApp;
    return vkApp ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSString *plistName = [@"plists/" stringByAppendingString:self.specifier.properties[@"plistToLoad"]];
        _specifiers = [self specifiersForPlistName:plistName localize:YES];
    }
    return _specifiers;
}

- (NSArray <PSSpecifier*> *)specifiersForPlistName:(NSString *)plistName localize:(BOOL)localize 
{
    NSMutableArray *specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self bundle:self.cvkBundle] mutableCopy];
    
    @autoreleasepool {
        if (specifiersArray.count > 0 && localize) {
            NSString *path = [self.cvkBundle pathForResource:@"ColoredVK" ofType:@"strings"];
            NSDictionary *localizable = [NSDictionary dictionaryWithContentsOfFile:path];
            NSString *(^localizedStringForKey)(NSString *key) = ^NSString *(NSString *key) {
                if (!key)
                    return @"";
                
                return localizable[key] ? localizable[key] : key;
            };
            
            for (PSSpecifier *specifier in specifiersArray) {
                specifier.name = localizedStringForKey(specifier.name);
                
                NSString *footerDictText = specifier.properties[@"footerText"];
                if (footerDictText) {
                    NSString *footerNewText = @"";
                    if ([footerDictText isEqualToString:@"AVAILABLE_IN_%@_AND_HIGHER"]) {
                        footerNewText = [NSString stringWithFormat:localizedStringForKey(footerDictText), specifier.properties[@"requiredVersion"]];
                    } else if ([specifier.identifier isEqualToString:@"manageSettingsFooter"]) {
                        footerNewText = [NSString stringWithFormat:localizedStringForKey(footerDictText), CVK_BACKUP_PATH];
                    } else {
                        footerNewText = localizedStringForKey(footerDictText);
                    }
                    [specifier setProperty:footerNewText forKey:@"footerText"];
                }
                
                if (specifier.properties[@"label"])
                    [specifier setProperty:localizedStringForKey(specifier.properties[@"label"]) forKey:@"label"];
                if (specifier.properties[@"detailedLabel"])
                    [specifier setProperty:localizedStringForKey(specifier.properties[@"detailedLabel"]) forKey:@"detailedLabel"];
                
                if (specifier.properties[@"validTitles"]) {
                    NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
                    for (NSString *key in specifier.titleDictionary.allKeys) {
                        [tempDict setValue:localizedStringForKey(specifier.titleDictionary[key]) forKey:key];
                    }
                    specifier.titleDictionary = tempDict;
                }
            }
        }
    }
    
    if (specifiersArray.count == 0)
        specifiersArray = [NSMutableArray array];
    
    return specifiersArray;
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
    if (!specifier.properties[@"key"])
        return nil;
    
    if (!self.cachedPrefs[specifier.properties[@"key"]])
        return specifier.properties[@"default"];
    
    return self.cachedPrefs[specifier.properties[@"key"]];
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

- (BOOL)edgeToEdgeCells
{
    return YES;
}


#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    if (value)
        [self.cachedPrefs setValue:value forKey:specifier.properties[@"key"]];
    else
        [self.cachedPrefs removeObjectForKey:specifier.properties[@"key"]];
    
    [self writePrefsWithCompetion:^{
        NSArray *identificsToReloadMenu = @[@"enableTweakSwitch", @"menuSelectionStyle", @"hideMenuSeparators", 
                                            @"changeSwitchColor", @"useMenuParallax", @"changeMenuTextColor", 
                                            @"showMenuCell", @"menuUseBackgroundBlur"];
        
        if ([specifier.identifier isEqualToString:@"nightThemeType"]) {
            [self updateNightTheme];
            POST_CORE_NOTIFICATION(kPackageNotificationReloadMenu);
            POST_CORE_NOTIFICATION(kPackageNotificationUpdateNightTheme);
            return;
        }
        
        if ([identificsToReloadMenu containsObject:specifier.identifier])
            POST_CORE_NOTIFICATION(kPackageNotificationReloadMenu);
        else 
            POST_CORE_NOTIFICATION(kPackageNotificationReloadPrefs);
        
        if ([specifier.identifier isEqualToString:@"enableTweakSwitch"]) {
            [self updateNightTheme];
            POST_CORE_NOTIFICATION(kPackageNotificationUpdateNightTheme);
        }
    }];
}

#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.userInteractionEnabled = YES;
    cell.layoutMargins = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 18.0f);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    objc_setAssociatedObject(cell, "change_switch_color", @(self.shouldChangeSwitchColor), OBJC_ASSOCIATION_ASSIGN);
    [cell renderBackgroundWithColor:nil separatorColor:nil forTableView:tableView indexPath:indexPath];
    [self updateNightThemeForCell:cell animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    NSString *text = self.cvkBundle ? CVKLocalizedStringInBundle(@"LOADING_TWEAK_FILES_ERROR_MESSAGE", self.cvkBundle) : @"";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return self.table.tableHeaderView ? -100.0f : -150.0f;
}

@end
