//
//  ColoredVKPrefsSelector.m
//  ColoredVK2
//
//  Created by Даниил on 03.11.17.
//

#import "ColoredVKPrefsSelector.h"
#import "ColoredVKNightThemeColorScheme.h"

@interface ColoredVKPrefsSelector ()
@property (strong, nonatomic) NSIndexPath *indexPathForSelectedRow;
@property (strong, nonatomic) UIImageView *tickImageView;
@end

@implementation ColoredVKPrefsSelector

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSMutableArray <PSSpecifier *> *specifiers = [NSMutableArray array];        
        
        if (self.selectorKey) {            
            NSArray <NSString *> *allKeys = [self.specifier propertyForKey:@"validTitles"];
            NSArray *allValues = [self.specifier propertyForKey:@"validValues"];
            if (allKeys.count > 0 && allValues.count > 0) {
                for (NSUInteger i=0; i<allKeys.count; i++) {
                    @autoreleasepool {
                        PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:NSLocalizedStringFromTableInBundle(allKeys[i], @"ColoredVK", self.cvkBundle, nil)
                                                                                target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:)
                                                                                detail:nil cell:PSStaticTextCell edit:nil];
                        [specifier setProperty:allValues[i] forKey:@"selectorValue"];
                        [specifier setProperty:@"SelectorOption" forKey:@"selectorType"];
                        [specifier setProperty:@YES forKey:@"enabled"];
                        
                        [specifiers addObject:specifier];
                    }
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
    
    self.selectorKey = [self.specifier propertyForKey:@"key"];
    self.selectorDefaultValue = [self.specifier propertyForKey:@"default"];
    
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    self.selectorCurrentValue = prefs[self.selectorKey] ? prefs[self.selectorKey] : self.selectorDefaultValue;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tickImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.tickImageView.image = [UIImage imageNamed:@"TickIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
    
    ColoredVKNightThemeColorScheme *nightScheme = [ColoredVKNightThemeColorScheme sharedScheme];
    if (nightScheme.enabled) {
        self.tickImageView.image = [self.tickImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.tickImageView.tintColor = nightScheme.buttonSelectedColor;
    }
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
    if (specifier.properties[@"selectorValue"])
        return nil;
    
    return [super readPreferenceValue:specifier];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
    if (specifier.properties[@"selectorValue"]) {
        PSSpecifier *newSpecifier = [PSSpecifier preferenceSpecifierNamed:specifier.name target:self set:nil get:nil 
                                                                   detail:nil cell:PSListItemCell edit:nil];
        [newSpecifier setProperty:self.selectorKey forKey:@"key"];
        newSpecifier.identifier = self.selectorKey;
        [super setPreferenceValue:value specifier:newSpecifier];
    } else {
        [super setPreferenceValue:value specifier:specifier];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.userInteractionEnabled = YES;
    cell.cellEnabled = YES;
    
    if ([cell isKindOfClass:[PSTableCell class]]) {
        if ([[cell.specifier propertyForKey:@"selectorValue"] isEqual:self.selectorCurrentValue]) {
            cell.accessoryView = self.tickImageView;
            self.indexPathForSelectedRow = indexPath;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    PSTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[PSTableCell class]]) {
        if ([[cell.specifier propertyForKey:@"selectorType"] isEqualToString:@"SelectorOption"]) {
            if (self.indexPathForSelectedRow.section != indexPath.section || self.indexPathForSelectedRow.row != indexPath.row) {
                PSTableCell *selectedCell = [tableView cellForRowAtIndexPath:self.indexPathForSelectedRow];
                selectedCell.accessoryView = nil;
                
                self.indexPathForSelectedRow = indexPath;
                cell.accessoryView = self.tickImageView;
                
                self.selectorCurrentValue = [cell.specifier propertyForKey:@"selectorValue"];
                [self setPreferenceValue:self.selectorCurrentValue specifier:cell.specifier];
                
                [self didSelectValue:self.selectorCurrentValue forKey:self.selectorKey];
            }
        }
    }
}

- (void)didSelectValue:(id)value forKey:(NSString *)key
{
    
}

@end
