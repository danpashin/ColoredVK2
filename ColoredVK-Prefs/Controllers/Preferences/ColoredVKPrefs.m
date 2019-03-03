//
//  ColoredVKPrefs.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//

#import "ColoredVKPrefs.h"
@import SafariServices.SFSafariViewController;
#import <objc/runtime.h>

#import "ColoredVKNewInstaller.h"
#import "ColoredVKNightScheme.h"
#import "NSObject+ColoredVK.h"

#import "ColoredVKColorCell.h"
#import "ColoredVKImagePrefsCell.h"

@interface ColoredVKPrefs () {
    UINavigationItem *_navigationItem;
}

@property (strong, nonatomic) id <UIViewControllerPreviewing> forceTouchContext;

@end


@implementation ColoredVKPrefs
@dynamic table;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadPrefsNotification) name:kPackageNotificationReloadInternalPrefs object:nil];
    
    [self readPrefsWithCompetion:^{
        [self updateNightThemeModel];
    }];
}

- (void)loadView
{
    [super loadView];
    
    self.table.separatorColor = [UIColor clearColor];
    self.table.emptyDataSetSource = self;
    self.table.emptyDataSetDelegate = self;
}

- (Class)tableViewClass
{
    return [ColoredVKPrefsTableView class];
}

- (UINavigationItem *)navigationItem
{
    Class VANavigationItemClass = objc_lookUpClass("VANavigationItem");
    if (VANavigationItemClass && !_navigationItem) {
        _navigationItem = [[VANavigationItemClass alloc] init];
    }
    
    if (!_navigationItem) {
        _navigationItem = super.navigationItem;
    }
    
    return _navigationItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.specifier ? self.specifier.name : @"";
    [self updateAppearance:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable && !self.forceTouchContext) {
        self.forceTouchContext = [self registerForPreviewingWithDelegate:self sourceView:self.table];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.forceTouchContext) {
        [self unregisterForPreviewingWithContext:self.forceTouchContext];
    }
}

#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)reloadPrefsNotification
{
    [self readPrefsWithCompetion:nil];
}

- (void)writePrefsWithCompetion:(nullable void(^)(void))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        cvk_writePrefs([self.cachedPrefs copy], kPackageNotificationReloadInternalPrefs);
        
        if (completionBlock)
            completionBlock();
    });
}

- (void)readPrefsWithCompetion:(nullable void(^)(void))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.cachedPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
        if (!self.cachedPrefs) {
            self.cachedPrefs = [NSMutableDictionary dictionary];
        }
        
        if (completionBlock)
            completionBlock();
    });
}

- (void)reloadSpecifiers
{
    [NSObject cvk_runBlockOnMainThread:^{
        [super reloadSpecifiers];
    }];
}

- (void)updateNightThemeModel
{
    ColoredVKNightScheme *nightThemeColorScheme = [ColoredVKNightScheme sharedScheme];
    NSInteger themeType = self.cachedPrefs[@"nightThemeType"] ? [self.cachedPrefs[@"nightThemeType"] integerValue] : -1;
    [nightThemeColorScheme updateForType:themeType];
    
    BOOL vkApp = [ColoredVKNewInstaller sharedInstaller].application.isVKApp;
    nightThemeColorScheme.enabled = ((themeType != -1) && [self.cachedPrefs[@"enabled"] boolValue] && vkApp);
}

- (void)updateAppearance:(BOOL)animated
{
    if (![ColoredVKNewInstaller sharedInstaller].application.isVKApp)
        return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        void (^tableBlock)(void) = ^{
            self.table.separatorColor = [UIColor colorWithRed:232/255.0f green:233/255.0f blue:234/255.0f alpha:1.0f];
            self.table.backgroundColor = [UIColor groupTableViewBackgroundColor];
            self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.235294f green:0.439216f blue:0.662745f alpha:1.0f];
        };
        
        if (animated)
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:tableBlock completion:nil];
        else
            tableBlock();
        
        
        for (PSSpecifier *specifier in self.specifiers) {
            ColoredVKPrefsCell *cell = [self cachedCellForSpecifier:specifier];
            [self updateCellAppearance:cell animated:animated];
        }
    });
}

- (void)updateCellAppearance:(__kindof ColoredVKPrefsCell *)cell animated:(BOOL)animated
{
    if (![ColoredVKNewInstaller sharedInstaller].application.isVKApp)
        return;
    
    ColoredVKNightScheme *nightThemeColorScheme = [ColoredVKNightScheme sharedScheme];
    BOOL nightThemeEnabled = nightThemeColorScheme.enabled;
    
    void (^changeBlock)(void) = ^{
        cell.backgroundColor = nightThemeEnabled ? nightThemeColorScheme.foregroundColor : [UIColor whiteColor];
        
        if (cell.type != PSButtonCell)
            cell.textLabel.textColor = nightThemeEnabled ? nightThemeColorScheme.textColor : [UIColor blackColor];  
        
        if (nightThemeEnabled) {
            if ([cell.accessoryView isKindOfClass:NSClassFromString(@"ColoredVKStepperButton")]) {
                ((UILabel *)[cell.accessoryView valueForKey:@"valueLabel"]).textColor = nightThemeColorScheme.textColor;
            }
            
            UIView *selectedView = [UIView new];
            selectedView.backgroundColor = nightThemeColorScheme.backgroundColor;
            cell.selectedBackgroundView = selectedView;
        
        } else {
            cell.selectedBackgroundView = nil;
        }
    };
    
    if (animated)
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:changeBlock completion:nil];
    else
        changeBlock();
}

- (void)updateSpecifierWithKey:(NSString *)key
{
    PSSpecifier *specifier = [self specifierForID:key];
    if (!specifier)
        return;
    
    [specifier setProperty:@YES forKey:@"wasReloaded"];
    
    PSTableCell *cachedCell = specifier ? [self cachedCellForSpecifier:specifier] : nil;
    if (cachedCell) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [cachedCell refreshCellContentsWithSpecifier:specifier];
        });
    }
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

- (BOOL)openURL:(NSString *)stringURL
{
    NSURL *URL = [NSURL URLWithString:stringURL];
    
    if ([stringURL hasPrefix:@"http"]) {
        SFSafariViewController *safariController = [[SFSafariViewController alloc] initWithURL:URL];
        safariController.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:safariController animated:YES completion:nil];
        
        return YES;
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    BOOL canOpen = [app canOpenURL:URL];
    if (canOpen)
        [app openURL:URL];
    
    return canOpen;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    NSMutableArray <PSSpecifier *> *specifiersArray = [[self loadSpecifiersFromPlistName:plistName target:self bundle:cvkBundle] mutableCopy];
    
    @autoreleasepool {
        if (specifiersArray.count > 0 && localize) {
            NSString *path = [cvkBundle pathForResource:@"ColoredVK" ofType:@"strings"];
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
            }
        }
    }
    
    if (specifiersArray.count == 0)
        specifiersArray = [NSMutableArray array];
    
    return specifiersArray;
}

- (nullable id)readPreferenceValue:(PSSpecifier *)specifier
{
    if (!specifier.properties[@"key"])
        return nil;
    
    if (!self.cachedPrefs[specifier.properties[@"key"]])
        return specifier.properties[@"default"];
    
    return self.cachedPrefs[specifier.properties[@"key"]];
}

- (BOOL)edgeToEdgeCells
{
    return YES;
}


#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setPreferenceValue:(nullable id)value specifier:(PSSpecifier *)specifier
{
    [self setPreferenceValue:value forKey:specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(nullable id)value forKey:(NSString *)key
{
    @synchronized(self) {
        CVKLog(@"value: %@; key: %@", value, key);
        if (!key)
            return;
        
        if (value)
            self.cachedPrefs[key] = value;
        else
            [self.cachedPrefs removeObjectForKey:key];
        
        [self writePrefsWithCompetion:^{
            [self updateSpecifierWithKey:key];
            NSArray *identificsToReloadMenu = @[@"enabled", @"menuSelectionStyle", @"hideMenuSeparators", 
                                                @"changeSwitchColor", @"useMenuParallax", @"changeMenuTextColor", 
                                                @"showMenuCell", @"menuUseBackgroundBlur", @"menuImageBlackout", 
                                                @"enabledMenuImage", @"MenuSeparatorColor", @"switchesTintColor",
                                                @"switchesOnTintColor", @"menuTextColor"];
            
            if ([key isEqualToString:@"nightThemeType"] || [key isEqualToString:@"enabled"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateNightThemeModel];
                    [self updateAppearance:YES];
                });
                
                POST_CORE_NOTIFICATION(kPackageNotificationUpdateNightTheme);
                
            } else if ([identificsToReloadMenu containsObject:key]) {
                POST_CORE_NOTIFICATION(kPackageNotificationReloadMenu);
            } else {
                POST_CORE_NOTIFICATION(kPackageNotificationReloadPrefs);
            }
        }];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.userInteractionEnabled = YES;
    
    
    return cell;
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
    return CVKImage(@"WarningIcon");
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = CVKLocalizedString(@"LOADING_TWEAK_FILES_ERROR_MESSAGE");
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return self.table.tableHeaderView ? -100.0f : -150.0f;
}


#pragma mark -
#pragma mark UIViewControllerPreviewingDelegate
#pragma mark -

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    ColoredVKPrefsCell *prefsCell = (ColoredVKPrefsCell *)previewingContext.sourceView;
    if ([prefsCell isKindOfClass:[ColoredVKPrefsCell class]]) {
        previewingContext.sourceRect = [self.view convertRect:prefsCell.frame fromView:self.table];
        return prefsCell.forceTouchPreviewController;
    }
    
    return nil;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    viewControllerToCommit.view.backgroundColor = [UIColor whiteColor];
    [self showViewController:viewControllerToCommit sender:nil];
}

@end
