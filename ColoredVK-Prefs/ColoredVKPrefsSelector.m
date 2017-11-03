//
//  ColoredVKPrefsSelector.m
//  ColoredVK2
//
//  Created by Даниил on 03.11.17.
//

#import "ColoredVKPrefsSelector.h"
#import "ColoredVKNewInstaller.h"

@interface ColoredVKPrefsSelector ()

@property (copy, nonatomic) NSString *selectorKey;
@property (strong, nonatomic) id selectorDefaultValue;

@property (strong, nonatomic) NSIndexPath *indexPathForSelectedRow;
@property (strong, nonatomic) UIImageView *tickImageView;

@end

@implementation ColoredVKPrefsSelector

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSMutableArray <PSSpecifier *> *specifiers = [NSMutableArray array];
        
        if (self.selectorKey) {
            ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller]; 
            BOOL shouldDisable = (!newInstaller.tweakPurchased || !newInstaller.tweakActivated);
            
            NSArray <NSString *> *allKeys = [self.specifier propertyForKey:@"selectorKeys"];
            NSArray *allValues = [self.specifier propertyForKey:@"selectorValues"];
            if (allKeys.count > 0 && allValues.count > 0) {
                for (int i=0; i<allKeys.count; i++) {                    
                    PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:NSLocalizedStringFromTableInBundle(allKeys[i], @"ColoredVK", self.cvkBundle, nil)
                                                                            target:self set:nil get:nil detail:nil cell:PSListItemCell edit:nil];
                    [specifier setProperty:allValues[i] forKey:@"key"];
                    [specifier setProperty:@"SelectorOption" forKey:@"selectorType"];
                    
                    if (shouldDisable || ![[self.specifier propertyForKey:@"enabled"] boolValue]) {
                        [specifier setProperty:@NO forKey:@"enabled"];
                    } else {
                        [specifier setProperty:@YES forKey:@"enabled"];
                    }
                    
                    [specifiers addObject:specifier];
                }
            }
        }
        
        _specifiers = specifiers;
    }
    return _specifiers;
}

- (void)loadView
{
    [super loadView];
    
    self.selectorKey = [self.specifier propertyForKey:@"selectorKey"];
    self.selectorDefaultValue = [self.specifier propertyForKey:@"selectorDefaultValue"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tickImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.tickImageView.image = [UIImage imageNamed:@"TickIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    PSSpecifier *newSpecifier = [PSSpecifier preferenceSpecifierNamed:specifier.name target:self set:nil get:nil detail:nil cell:PSListItemCell edit:nil];
    [newSpecifier setProperty:self.selectorKey forKey:@"key"];
    newSpecifier.identifier = self.selectorKey;
    [super setPreferenceValue:value specifier:newSpecifier];
    
    NSLog(@"setValue %@ forKey: %@", value, self.selectorKey);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[PSTableCell class]]) {
        if ([[cell.specifier propertyForKey:@"key"] isEqual:self.selectorDefaultValue]) {
            cell.accessoryView = self.tickImageView;
            self.indexPathForSelectedRow = indexPath;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];    
    if (!newInstaller.tweakPurchased || !newInstaller.tweakActivated)
        return;
    
    PSTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[PSTableCell class]]) {
        if ([[cell.specifier propertyForKey:@"selectorType"] isEqualToString:@"SelectorOption"]) {
            if (self.indexPathForSelectedRow.section != indexPath.section || self.indexPathForSelectedRow.row != indexPath.row) {
                PSTableCell *selectedCell = [tableView cellForRowAtIndexPath:self.indexPathForSelectedRow];
                selectedCell.accessoryView = nil;
                
                self.indexPathForSelectedRow = indexPath;
                cell.accessoryView = self.tickImageView;
                
                [self setPreferenceValue:[cell.specifier propertyForKey:@"key"] specifier:cell.specifier];
            }
        }
    }
}


@end
