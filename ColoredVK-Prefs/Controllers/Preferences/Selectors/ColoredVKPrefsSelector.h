//
//  ColoredVKPrefsSelector.h
//  ColoredVK2
//
//  Created by Даниил on 03.11.17.
//

#import "ColoredVKGeneralPrefs.h"

@interface ColoredVKPrefsSelector : ColoredVKGeneralPrefs

@property (copy, nonatomic) NSString *selectorKey;
@property (strong, nonatomic) id selectorDefaultValue;
@property (strong, nonatomic) id selectorCurrentValue;

@property (strong, nonatomic, readonly) UIImageView *tickImageView;

- (void)didSelectValue:(id)value forKey:(NSString *)key;

@end
