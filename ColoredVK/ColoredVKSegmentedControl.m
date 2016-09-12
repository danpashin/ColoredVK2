//
//  ColoredVKSegmentedControl.m
//  ColoredVK
//
//  Created by Даниил on 30/08/16.
//
//

#import "ColoredVKSegmentedControl.h"

@implementation ColoredVKSegmentedControl

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier specifier:specifier];
    if (self) {
        PSSpecifier *spec = [PSSpecifier preferenceSpecifierNamed:@"" 
                                                           target:self 
                                                              set:nil 
                                                              get:nil 
                                                           detail:nil 
                                                             cell:PSSegmentCell
                                                             edit:nil];
        [spec setProperty:@[ @"1",  @"2", @"3" ] forKey:@"validTitles"];
        [spec setProperty:@[ @"0",  @"1", @"2" ] forKey:@"validValues"];
        [spec setProperty:@(PSSegmentCell) forKey:@"cell"];
        
        self.specifier = spec;
    }
    return self;
}

@end