//
//  ColoredVKNightThemeColorScheme.m
//  ColoredVK2
//
//  Created by Даниил on 19.10.17.
//

#import "ColoredVKNightThemeColorScheme.h"

@implementation ColoredVKNightThemeColorScheme

+ (instancetype)colorSchemeForType:(CVKNightThemeType)type
{
    return [[ColoredVKNightThemeColorScheme alloc] initWithType:type];
}

- (instancetype)initWithType:(CVKNightThemeType)type
{
    self = [super init];
    
    if (self) {
        [self updateForType:type];
    }
    return self;
}


- (void)updateForType:(CVKNightThemeType)type
{
    _type = type;
    
    if (type == CVKNightThemeTypeDarkBlue) {
        _backgroundColor = [UIColor colorWithRed:0.08f green:0.11f blue:0.15f alpha:1.0f];
        _navbackgroundColor = [UIColor colorWithRed:0.15f green:0.20f blue:0.27f alpha:1.0f];
        _foregroundColor = [UIColor colorWithRed:0.11f green:0.16f blue:0.21f alpha:1.0f];
        
        _textColor = [UIColor colorWithWhite:0.9f alpha:0.9f];
        _linkTextColor = [UIColor colorWithRed:0.21f green:0.64f blue:0.96f alpha:1.0f];
        _unreadBackgroundColor = [UIColor colorWithRed:0.14f green:0.18f blue:0.22f alpha:1.0f];
        _incomingBackgroundColor = [UIColor colorWithRed:0.21f green:0.29f blue:0.36f alpha:1.0f];
        _outgoingBackgroundColor = [UIColor colorWithRed:0.21f green:0.37f blue:0.56f alpha:1.0f];
    }
}

@end
