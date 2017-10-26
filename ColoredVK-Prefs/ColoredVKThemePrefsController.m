//
//  ColoredVKThemePrefsController.m
//  ColoredVK2
//
//  Created by Даниил on 26.10.17.
//

#import "ColoredVKThemePrefsController.h"

@interface ColoredVKThemePrefsController ()

@property (strong, nonatomic) NSIndexPath *indexPathForSelectedRow;
@property (strong, nonatomic) UIView *closeAppFooter;

@end

@implementation ColoredVKThemePrefsController


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[PSTableCell class]]) {
        if ([cell.specifier.identifier containsString:@"nightThemeType"]) {
            if ([[self readPreferenceValue:cell.specifier] isEqual:[cell.specifier propertyForKey:@"value"]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                self.indexPathForSelectedRow = indexPath;
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    PSTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[PSTableCell class]]) {
        if (cell.type == PSStaticTextCell) {
            if (self.indexPathForSelectedRow) {
                [self deselectRowAtIndexPath:self.indexPathForSelectedRow inTableView:tableView];
            }
            self.indexPathForSelectedRow = indexPath;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            [self setPreferenceValue:[cell.specifier propertyForKey:@"value"] specifier:cell.specifier];
        }
    }
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    PSTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[PSTableCell class]]) {
        if (cell.type == PSStaticTextCell) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

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
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[footerLabel]-[button(44)]|" options:0 metrics:nil views:views]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[footerLabel]-|" options:0 metrics:nil views:views]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[button]-|" options:0 metrics:nil views:views]];
        
        _closeAppFooter = contentView;
    }
    
    return _closeAppFooter;
}

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
        height = 120;
    }
    
    return height;
}

- (void)actionCloseApplication
{
    [[UIApplication sharedApplication] performSelector:@selector(suspend)];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
}

@end
