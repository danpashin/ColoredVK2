//
//  ColoredVKThemePrefsController.m
//  ColoredVK2
//
//  Created by Даниил on 26.10.17.
//

#import "ColoredVKThemePrefsController.h"
#import "ColoredVKPrefsFooter.h"

#import "ColoredVKNightThemeColorScheme.h"
#import "ColoredVKNewInstaller.h"

#import <objc/message.h>
@import Darwin.POSIX.spawn;


@interface ColoredVKThemePrefsController ()

@property (strong, nonatomic) ColoredVKPrefsFooter *closeAppFooter;
@property (strong, nonatomic) NSArray <PSSpecifier *> *customColorsSpecifiers;
@property (assign, nonatomic) BOOL specifiersAlreadyInserted;

@end


@implementation ColoredVKThemePrefsController

- (void)loadView
{
    [super loadView];
    
    self.customColorsSpecifiers = [self specifiersForPlistName:@"plists/NightTheme" localize:YES];
    for (PSSpecifier *specifier in self.customColorsSpecifiers) {
        [specifier setProperty:@YES forKey:@"enabled"];
    }
}

- (void)updateType:(BOOL)animated
{
    if ([self.selectorCurrentValue integerValue] != CVKNightThemeTypeCustom) {
        self.specifiersAlreadyInserted = NO;
        [self removeContiguousSpecifiers:self.customColorsSpecifiers animated:animated];
    } 
    else if (!self.specifiersAlreadyInserted) {
        [self insertContiguousSpecifiers:self.customColorsSpecifiers afterSpecifierID:@"customColorsGroup" animated:animated];
    }
}

- (void)reloadSpecifiers
{
    [super reloadSpecifiers];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateType:NO];
    });
}

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSMutableArray *specifiers = [super.specifiers mutableCopy];
        
        [specifiers addObjectsFromArray:self.customColorsSpecifiers];
        self.specifiersAlreadyInserted = YES;
        
        _specifiers = specifiers;
    }
    return _specifiers;
}

- (void)didSelectValue:(id)value forKey:(NSString *)key
{
    [self updateType:YES];
}

- (void)updateNightTheme
{
    [super updateNightTheme];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateFooterColors:YES];
    });
}

- (void)updateFooterColors:(BOOL)animated
{
    ColoredVKNightThemeColorScheme *nightScheme = [ColoredVKNightThemeColorScheme sharedScheme];
    
    UIColor *titleColor = nightScheme.textColor;
    UIColor *buttonColor = nightScheme.buttonColor;
    UIColor *tickColor = nightScheme.buttonSelectedColor;
    if ([self.selectorCurrentValue integerValue] == CVKNightThemeTypeDisabled || !nightScheme.enabled) {
        titleColor = [UIColor grayColor];
        buttonColor = [UIColor redColor];
        tickColor = CVKMainColor;
    }
    
    void (^updateBlock)(void) = ^{
        self.closeAppFooter.titleColor = titleColor;
        self.closeAppFooter.buttonColor = buttonColor;
        self.tickImageView.tintColor = tickColor;
    };
    
    if (animated)
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:updateBlock completion:nil];
    else 
        updateBlock();
}

#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [super tableView:tableView viewForFooterInSection:section];
    
    if (section == 0) {
        footer = self.closeAppFooter;
    }
    
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height = [super tableView:tableView heightForFooterInSection:section];
    
    if (section == 0) {
        height = self.closeAppFooter.preferredHeight;
    }
    
    return height;
}

#pragma mark -


- (ColoredVKPrefsFooter *)closeAppFooter
{
    if (!_closeAppFooter) {
        _closeAppFooter = [[ColoredVKPrefsFooter alloc] init];
        _closeAppFooter.title = CVKLocalizedString(@"CLOSE_APP_FOOTER_TEXT");
        _closeAppFooter.buttonTitle = CVKLocalizedString(@"CLOSE_APP_FOOTER_BUTTON_TEXT");
        [_closeAppFooter.button addTarget:self action:@selector(actionCloseApplication) forControlEvents:UIControlEventTouchUpInside];
        [self updateFooterColors:NO];
    }
    
    return _closeAppFooter;
}

- (void)actionCloseApplication
{
    if ([ColoredVKNewInstaller sharedInstaller].application.isVKApp) {
        objc_msgSend([UIApplication sharedApplication], @selector(suspend));
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            exit(0);
        });
    } else {
        char *args[] = {"/usr/bin/killall", "-9", "VKClient", NULL};
        posix_spawn(NULL, args[0], NULL, NULL, args, NULL);
    }
}

@end
