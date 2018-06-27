//
//  ColoredVKSegmentPrefsCell.m
//  ColoredVK2
//
//  Created by Даниил on 27.06.18.
//

#import "ColoredVKSegmentPrefsCell.h"

@interface ColoredVKSegmentPrefsCell ()
@property (strong, nonatomic) UISegmentedControl *segment;
@end

@implementation ColoredVKSegmentPrefsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {
        CGFloat segmentHeight = 34.0f;
        
        self.segment = [UISegmentedControl new];
        self.segment.layer.cornerRadius = segmentHeight / 2;
        self.segment.layer.borderWidth = 1.0f;
        self.segment.layer.masksToBounds = YES;
        [self.segment addTarget:self action:@selector(segmentTriggered:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.segment];
        
        ColoredVKNightScheme *nightScheme = [ColoredVKNightScheme sharedScheme];
        self.segment.tintColor = nightScheme.enabled ? nightScheme.buttonColor : CVKMainColor;
        self.segment.layer.borderColor = self.segment.tintColor.CGColor;
        
        self.segment.translatesAutoresizingMaskIntoConstraints = NO;
        [self.segment.heightAnchor constraintEqualToConstant:segmentHeight].active = YES;
        [self.segment.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[segment]-8-|" options:0 
                                                                                 metrics:nil views:@{@"segment":self.segment}]];
    }
    return self;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier
{
    [super refreshCellContentsWithSpecifier:specifier];
    
    NSArray <NSString *> *titles = [specifier propertyForKey:@"validTitles"];
    for (NSString *title in titles) {
        NSString *localized = CVKLocalizedStringFromTable(title, @"ColoredVK");
        [self.segment insertSegmentWithTitle:localized atIndex:self.segment.numberOfSegments animated:NO];
    }
    
    id currentValue = self.currentPrefsValue;
    if (currentValue) {
        NSArray *values = [specifier propertyForKey:@"validValues"];
        self.segment.selectedSegmentIndex = [values indexOfObject:currentValue];
    }
}

- (void)segmentTriggered:(UISegmentedControl *)segment
{
    if ([self.cellTarget respondsToSelector:self.cellAction]) {
        NSArray *values = [self.specifier propertyForKey:@"validValues"];
        id selectedValue = values[self.segment.selectedSegmentIndex];
        
        objc_msgSend(self.cellTarget, self.cellAction, selectedValue, self.specifier);
    }
}

- (id)customBackgroundView
{
    return nil;
}

@end
