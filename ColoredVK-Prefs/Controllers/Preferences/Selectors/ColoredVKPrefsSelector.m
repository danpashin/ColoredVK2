//
//  ColoredVKPrefsSelector.m
//  ColoredVK2
//
//  Created by Даниил on 03.11.17.
//

#import "ColoredVKPrefsSelector.h"
#import "ColoredVKNightScheme.h"

@interface ColoredVKPrefsSelector ()
@property (strong, nonatomic) NSIndexPath *indexPathForSelectedRow;
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
                        NSString *name = CVKLocalizedStringFromTableInBundle(allKeys[i],  @"ColoredVK", self.cvkBundle);
                        SEL setter = @selector(setPreferenceValue:specifier:);
                        SEL getter = @selector(readPreferenceValue:);
                        
                        PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:name target:self set:setter get:getter
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

- (void)readPrefsWithCompetion:(void (^)(void))completionBlock
{
    [super readPrefsWithCompetion:^{
        if (completionBlock) {
            completionBlock();
            
            self.selectorKey = [self.specifier propertyForKey:@"key"];
            self.selectorDefaultValue = [self.specifier propertyForKey:@"default"];
            self.selectorCurrentValue = self.cachedPrefs[self.selectorKey] ? self.cachedPrefs[self.selectorKey] : self.selectorDefaultValue;
            [self reloadSpecifiers];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tickImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.tickImageView.image = [UIImage imageNamed:@"prefs/TickIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
    
    ColoredVKNightScheme *nightScheme = [ColoredVKNightScheme sharedScheme];
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
    
    if ([cell isKindOfClass:[PSTableCell class]]) {
        cell.cellEnabled = YES;
        if ([[cell.specifier propertyForKey:@"selectorValue"] isEqual:self.selectorCurrentValue]) {
            cell.accessoryView = self.tickImageView;
            self.indexPathForSelectedRow = indexPath;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
    
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
        } else {
            [super tableView:tableView didSelectRowAtIndexPath:indexPath];
        }
    } else {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void)didSelectValue:(id)value forKey:(NSString *)key
{
    
}

@end
