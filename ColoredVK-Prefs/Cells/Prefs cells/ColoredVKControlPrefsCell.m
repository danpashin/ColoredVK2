//
//  ColoredVKControlPrefsCell.m
//  ColoredVK2
//
//  Created by Даниил on 28.06.18.
//

#import "ColoredVKControlPrefsCell.h"
#import "NSObject+ColoredVK.h"

@implementation ColoredVKControlPrefsCell

- (void)setPreferenceValue:(id)value
{
    [self.cellTarget cvk_executeSelector:@selector(setPreferenceValue:specifier:) arguments:value, self.specifier, nil];
}

- (void)setPreferenceValue:(id)value forKey:(NSString *)key
{
    [self.cellTarget cvk_executeSelector:@selector(setPreferenceValue:forKey:) arguments:value, key, nil];
}

@end
