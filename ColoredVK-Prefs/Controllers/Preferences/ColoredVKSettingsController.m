//
//  ColoredVKSettingsController.m
//  ColoredVK
//
//  Created by Даниил on 12/02/2017.
//
//

#import "ColoredVKSettingsController.h"
#import "ColoredVKAlertController.h"
#import "ColoredVKNewInstaller.h"
#import "ColoredVKBackupsModel.h"

@interface ColoredVKSettingsController () <ColoredVKBackupsModelDelegate>

@property (strong, nonatomic) ColoredVKBackupsModel *backupsModel;

@end

@implementation ColoredVKSettingsController

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSMutableArray *specifiers = [NSMutableArray array];
        
        for (NSString *backupFullName in self.backupsModel.availableBackups) {
            NSString *name = [self.backupsModel readableNameForBackup:backupFullName];
            
            PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:name target:self set:nil get:nil 
                                                                    detail:nil cell:PSTitleValueCell edit:nil];
            specifier.properties[@"filename"] = backupFullName;
            [specifiers addObject:specifier];
        }
        
        _specifiers = specifiers;
    }
    
    return _specifiers;
}

- (void)loadView
{
    [super loadView];
    self.table.allowsMultipleSelectionDuringEditing = NO;
    
    self.backupsModel = [ColoredVKBackupsModel new];
    self.backupsModel.delegate = self;
}

- (void)shareBackup:(UIButton *)button event:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGPoint currentTouchPosition = [touch locationInView:self.table];
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:currentTouchPosition];
    if (!indexPath)
        return;
    
    PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
    NSString *path = [NSString stringWithFormat:@"%@/%@", CVK_BACKUP_PATH, specifier.properties[@"filename"]];
    NSArray *items = @[[NSURL fileURLWithPath:path isDirectory:NO]];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [self presentPopover:activityVC];
}


#pragma mark -
#pragma mark ColoredVKBackupsModelDelegate
#pragma mark -

- (void)backupsModel:(ColoredVKBackupsModel *)backupsModel didEndUpdatingBackups:(NSArray *)backups
{
    [self reloadSpecifiers];
}


#pragma mark -
#pragma mark DZNEmptyDataSetSource
#pragma mark -

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSMutableAttributedString *string = [[super titleForEmptyDataSet:scrollView] mutableCopy];
    string.mutableString.string = NSLocalizedStringFromTableInBundle(@"NO_FILES_TO_RESTORE", @"ColoredVK", self.cvkBundle, nil);
    UIFont *font =  [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.length)];
    
    return string;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return CVKImageInBundle(@"prefs/TabsIcon", self.cvkBundle);
}


#pragma mark -
#pragma mark UITableViewDataSource
#pragma mark -

- (PSTableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [shareButton addTarget:self action:@selector(shareBackup:event:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *shareImage = CVKImageInBundle(@"prefs/ShareIcon", self.cvkBundle);
    [shareButton setImage:shareImage forState:UIControlStateNormal];
    shareButton.accessibilityLabel = CVKLocalizedStringInBundle(@"SHARE_BACKUP", self.cvkBundle);
    cell.accessoryView = shareButton;
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate
#pragma mark -

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", CVK_BACKUP_PATH, specifier.properties[@"filename"]];
        if (cvk_removeItem(filePath, nil)) {
            [self removeSpecifier:specifier animated:YES];
            [self.backupsModel updateBackups];
        }
    }    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
    
    PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
    NSString *fileName = specifier.properties[@"filename"];
    
    NSString *message = [NSString stringWithFormat:CVKLocalizedStringInBundle(@"RESTORE_BACKUP_QUESTION", self.cvkBundle), fileName];
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:nil message:message];
    [alertController addCancelAction];
    
    NSString *sureTitle = CVKLocalizedStringInBundle(@"YES_I_AM_SURE", self.cvkBundle);
    [alertController addAction:[UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.backupsModel restoreSettingsFromFile:fileName];
    }]];
    [alertController present];
}

@end
