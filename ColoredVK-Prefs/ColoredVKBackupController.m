//
//  ColoredVKBackupController.m
//  ColoredVK
//
//  Created by Даниил on 12/02/2017.
//
//

#import "ColoredVKBackupController.h"
#import "PrefixHeader.h"
#import "PSSpecifier.h"
#import "ColoredVKHUD.h"
#import "ColoredVKPrefs.h"

@implementation ColoredVKBackupController

- (UIStatusBarStyle) preferredStatusBarStyle
{
    if ([[NSBundle mainBundle].executablePath.lastPathComponent isEqualToString:@"vkclient"]) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSMutableArray *specifiers = [NSMutableArray array];
    
        NSFileManager *filemanager = [NSFileManager defaultManager];    
        for (NSString *filename in [filemanager contentsOfDirectoryAtPath:CVK_BACKUP_PATH error:nil]) {
            if ([filename containsString:@"com.daniilpashin.coloredvk2"]) {
                NSMutableArray *components = [filename componentsSeparatedByString:@"_"].mutableCopy;
                [components removeObjectAtIndex:0];
                NSString *name = @"";
                for (NSString *str in components) {
                    name = [name stringByAppendingString:[NSString stringWithFormat:@"%@_", str]];
                }
                name = [name stringByReplacingCharactersInRange:NSMakeRange(name.length-1, 1) withString:@""];
                
                PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:name target:self set:nil get:nil detail:nil cell:PSTitleValueCell edit:nil];
                [specifier.properties setValue:filename forKey:@"filename"];
                [specifiers addObject:specifier];
            }
        }
        if (specifiers.count == 0) [specifiers addObject:self.errorMessage];
        
        _specifiers = [specifiers copy];
    }
    
    return _specifiers;
}

- (void)viewDidLoad
{
    self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    [super viewDidLoad];
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITableView class]]) {
            UITableView *tableView = (UITableView *)view;
            tableView.separatorColor = [UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1];
            tableView.allowsMultipleSelectionDuringEditing = NO;
            break;
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];   
        
        NSError *error = nil;
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@", CVK_BACKUP_PATH, specifier.properties[@"filename"]] error:&error];
        if (!error && success) [self removeSpecifier:specifier animated:YES];
    }    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    CGFloat buttonWidth = 30.0;
    if (![cell.contentView.subviews containsObject:[cell.contentView viewWithTag:2]]) {
        UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width-1.5*buttonWidth, 0, buttonWidth, buttonWidth)];
        [shareButton addTarget:self action:@selector(actionShare:) forControlEvents:UIControlEventTouchUpInside];
        [shareButton setImage:[UIImage imageNamed:@"ShareIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        shareButton.accessibilityValue = [self specifierAtIndexPath:indexPath].properties[@"filename"];
        shareButton.tag = 2;
        [cell.contentView addSubview:shareButton];
        
        shareButton.translatesAutoresizingMaskIntoConstraints = NO;
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[shareButton]-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:nil views:NSDictionaryOfVariableBindings(shareButton)]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[shareButton(width)]-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                 metrics:@{@"width":@(buttonWidth)} views:NSDictionaryOfVariableBindings(shareButton)]];    }
    return cell;
}


- (PSSpecifier *)errorMessage
{
    PSSpecifier *errorMessage = [PSSpecifier preferenceSpecifierNamed:@"" target:self set:nil get:nil detail:nil cell:PSGroupCell edit:nil];
    [errorMessage setProperty:CVKLocalizedStringFromTable(@"NO_FILES_TO_RESTORE", @"ColoredVK") forKey:@"footerText"];
    [errorMessage setProperty:@"1" forKey:@"footerAlignment"];
    return errorMessage;
}

- (void)actionShare:(UIButton *)button
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", CVK_BACKUP_PATH, button.accessibilityValue];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:path isDirectory:NO]] applicationActivities:nil];
    if (IS_IPAD) {
        activityVC.modalPresentationStyle = UIModalPresentationPopover;
        activityVC.popoverPresentationController.sourceView = button.superview;
        activityVC.popoverPresentationController.sourceRect = CGRectZero;
    }
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:activityVC animated:YES completion:nil];
}

@end
