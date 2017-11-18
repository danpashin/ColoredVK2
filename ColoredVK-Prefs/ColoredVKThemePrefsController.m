//
//  ColoredVKThemePrefsController.m
//  ColoredVK2
//
//  Created by Даниил on 26.10.17.
//

#import "ColoredVKThemePrefsController.h"
#import "ColoredVKNightThemeColorScheme.h"
#import "ColoredVKNewInstaller.h"

@interface ColoredVKThemePrefsController ()

@property (strong, nonatomic) UIView *closeAppFooter;
@property (strong, nonatomic) NSArray <PSSpecifier *> *customColorsSpecifiers;
@property (assign, nonatomic) BOOL specifiersAlreadyInserted;

@end


@implementation ColoredVKThemePrefsController

- (void)loadView
{
    [super loadView];
    
    self.customColorsSpecifiers = [self specifiersForPlistName:@"plists/NightTheme" localize:YES addFooter:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateType];
}

- (void)updateType
{
    if ([self.selectorCurrentValue integerValue] != CVKNightThemeTypeCustom) {
        self.specifiersAlreadyInserted = NO;
        [self removeContiguousSpecifiers:self.customColorsSpecifiers animated:YES];
    } 
    else if (!self.specifiersAlreadyInserted) {
        [self insertContiguousSpecifiers:self.customColorsSpecifiers afterSpecifierID:@"customColorsGroup" animated:YES];
    }
}

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSMutableArray *specifiers = [super.specifiers mutableCopy];
        
        [specifiers addObjectsFromArray:self.customColorsSpecifiers];
        self.specifiersAlreadyInserted = YES;
        
        ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller]; 
        BOOL shouldDisable = (!newInstaller.tweakPurchased || !newInstaller.tweakActivated);
        for (PSSpecifier *specifier in specifiers) {
            @autoreleasepool {
                if (shouldDisable || ![[self.specifier propertyForKey:@"enabled"] boolValue]) {
                    [specifier setProperty:@NO forKey:@"enabled"];
                } else {
                    [specifier setProperty:@YES forKey:@"enabled"];
                }
            }
        }
        
        _specifiers = specifiers;
    }
    return _specifiers;
}

- (void)didSelectValue:(id)value forKey:(NSString *)key
{
    [super didSelectValue:value forKey:key];
    [self updateType];
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
        height = 100;
    }
    
    return height;
}

#pragma mark -


- (UIView *)closeAppFooter
{
    if (!_closeAppFooter) {
        UIView *contentView = [[UIView alloc] init];
        
        UITextView *footerLabel = [[UITextView alloc] init];
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.text = CVKLocalizedString(@"CLOSE_APP_FOOTER_TEXT");
        footerLabel.textColor = [UIColor grayColor];
        footerLabel.textAlignment = NSTextAlignmentCenter;
        footerLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]-0.5f];
        footerLabel.editable = NO;
        footerLabel.selectable = NO;
        footerLabel.scrollEnabled = NO;
        [contentView addSubview:footerLabel];
        
        UIButton *closeAppButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeAppButton setTitle:CVKLocalizedString(@"CLOSE_APP_FOOTER_BUTTON_TEXT") forState:UIControlStateNormal];
        [closeAppButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [closeAppButton setTitleColor:[UIColor redColor].darkerColor forState:UIControlStateHighlighted];
        [closeAppButton setTitleColor:[UIColor redColor].darkerColor forState:UIControlStateSelected];
        [closeAppButton addTarget:self action:@selector(actionCloseApplication) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:closeAppButton];
        
        footerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        closeAppButton.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = @{@"footerLabel":footerLabel, @"button":closeAppButton};
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[footerLabel]-|" options:0 metrics:nil views:views]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[footerLabel]-|" options:0 metrics:nil views:views]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(44)]|" options:0 metrics:nil views:views]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[button]-|" options:0 metrics:nil views:views]];
        
        _closeAppFooter = contentView;
    }
    
    return _closeAppFooter;
}

- (void)actionCloseApplication
{
    objc_msgSend([UIApplication sharedApplication], @selector(suspend));
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
}

@end
