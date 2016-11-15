//
//  ColoredVKListController.m
//  test
//
//  Created by Даниил on 22/10/16.
//  Copyright © 2016 Даниил. All rights reserved.
//

#import "ColoredVKListController.h"
#import "PrefixHeader.h"
#import "ColoredVKSelectCell.h"
#import "PSSpecifier.h"
#import "UIColor+ColoredVK.h"
#import "NSString+ColoredVK.h"

@interface ColoredVKListController () <ColoredVKSelectCellDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray *cells;
@property (strong, nonatomic) NSMutableDictionary *prefs;
@property (strong, nonatomic) NSString *name;
@end

@implementation ColoredVKListController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UINavigationBar *navbar = self.navigationController.navigationBar;
    if ([navbar.subviews containsObject:[navbar viewWithTag:10]]) {
        [[navbar viewWithTag:10] removeFromSuperview];        
        [navbar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.cells = [NSMutableArray array];
    self.prefs = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    self.name = self.specifier.properties[@"nameToSave"];
    
    for (UIView *view in self.view.subviews) {
        if ([NSStringFromClass([view class]) isEqualToString:@"UITableView"]) {
            UITableView *tableView = (UITableView *)view;
            tableView.allowsMultipleSelection = YES;
            tableView.separatorColor = [UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1];
            break;
        }
    }
    
    NSString *path = [[NSBundle bundleWithPath:CVK_BUNDLE_PATH] pathForResource:@"AdvancedInfo" ofType:@"plist" inDirectory:@"plists"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *items = dict[self.name]?[dict[self.name] mutableCopy]:[NSMutableDictionary dictionary];
    
    for (NSDictionary *item in items) {
        NSString *label = item[@"label"];
        ColoredVKSelectCell *cell = [[ColoredVKSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cvkCell"];
        cell.textLabel.text = NSLocalizedStringFromTableInBundle(label, @"ColoredVK", [NSBundle bundleWithPath:CVK_BUNDLE_PATH], nil);
        cell.value = item[@"key"];
        cell.select = [self.prefs[self.name][cell.value] boolValue];
        cell.delegate = self;
        if (self.specifier.properties[@"cellToHighlight"] && [label isEqualToString:self.specifier.properties[@"cellToHighlight"]]) {
            cell.backgroundColor = [UIColor colorFromHexString:@"dee6f0"];
            [UIView animateWithDuration:1.5 delay:1.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{ cell.backgroundColor = [UIColor whiteColor]; } completion:nil];
            
        }
        [self.cells addObject:cell];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cells.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ColoredVKSelectCell *cell = self.cells[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { }

- (void)didTapCell:(ColoredVKSelectCell *)cell
{
    NSMutableDictionary *blurDict = self.prefs[self.name]?[self.prefs[self.name] mutableCopy]:[NSMutableDictionary dictionary];
    
    blurDict[cell.value] = @(cell.select);
    if ([cell.value containsString:@"."]) for (NSString *value in [cell.value componentsSeparatedByString:@"."]) blurDict[value] = @(cell.select);
    
    self.prefs[self.name] = blurDict;
    [self.prefs writeToFile:CVK_PREFS_PATH atomically:YES];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
}
@end
