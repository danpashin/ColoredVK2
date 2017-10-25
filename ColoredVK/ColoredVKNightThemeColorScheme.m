//
//  ColoredVKNightThemeColorScheme.m
//  ColoredVK2
//
//  Created by Даниил on 19.10.17.
//

#import "ColoredVKNightThemeColorScheme.h"
#import "PrefixHeader.h"

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = CVKNightThemeTypeDarkBlue;
        [self updateForType:self.type];
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
        
        _buttonColor = [UIColor colorWithRed:0.49f green:0.56f blue:0.61f alpha:1.0f];
        _buttonSelectedColor = [UIColor colorWithRed:0.1f green:0.59f blue:0.94f alpha:1.0f];
        _switchTintColor = [UIColor colorWithRed:0.52f green:0.59f blue:0.66f alpha:1.0f];
        _switchOnTintColor = [UIColor colorWithRed:0.15f green:0.6f blue:0.99f alpha:1.0f];
    }
    else if (type == CVKNightThemeTypeBlack) {
        _backgroundColor = [UIColor blackColor];
        _navbackgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.11f alpha:1.0f];
        _foregroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.11f alpha:1.0f];
        
        _textColor = [UIColor colorWithWhite:0.9f alpha:0.9f];
        _linkTextColor = [UIColor colorWithRed:0.0f green:0.6f blue:0.94f alpha:1.0f];
        _unreadBackgroundColor = [UIColor colorWithRed:0.08f green:0.08f blue:0.08f alpha:1.0f];
        _incomingBackgroundColor = [UIColor colorWithRed:0.11f green:0.11f blue:0.11f alpha:1.0f];
        _outgoingBackgroundColor = [UIColor colorWithRed:0.17f green:0.17f blue:0.17f alpha:1.0f];
        
        _buttonColor = [UIColor colorWithRed:0.53f green:0.53f blue:0.53f alpha:1.0f];
        _buttonSelectedColor = [UIColor colorWithWhite:0.9f alpha:0.9f];
        _switchTintColor = [UIColor colorWithRed:0.29f green:0.29f blue:0.29f alpha:1.0f];
        _switchOnTintColor = [UIColor colorWithRed:0.66f green:0.66f blue:0.66f alpha:1.0f];
    } 
    else if (type == CVKNightThemeTypeCustom) {
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
        
        _backgroundColor = [UIColor savedColorForIdentifier:@"nightThemeBackgroundColor" fromPrefs:prefs];
        _navbackgroundColor = [UIColor savedColorForIdentifier:@"nightThemeBavBackgroundColor" fromPrefs:prefs];
        _foregroundColor = [UIColor savedColorForIdentifier:@"nightThemeForegroundColor" fromPrefs:prefs];
        
        _textColor = [UIColor savedColorForIdentifier:@"nightThemeTextColor" fromPrefs:prefs];
        _linkTextColor = [UIColor savedColorForIdentifier:@"nightThemeLinkColor" fromPrefs:prefs];
        _unreadBackgroundColor = [UIColor savedColorForIdentifier:@"nightThemeUnreadBackgroundColor" fromPrefs:prefs];
        _incomingBackgroundColor = [UIColor savedColorForIdentifier:@"nightThemeIncomingBackgroundColor" fromPrefs:prefs];
        _outgoingBackgroundColor = [UIColor savedColorForIdentifier:@"nightThemeOutgoingBackgroundColor" fromPrefs:prefs];
        
        _buttonColor = [UIColor savedColorForIdentifier:@"nightThemeButtonColor" fromPrefs:prefs];
        _buttonSelectedColor = [UIColor savedColorForIdentifier:@"nightThemeButtonSelectedColor" fromPrefs:prefs];
        _switchTintColor = [UIColor savedColorForIdentifier:@"nightThemeSwitchTintColor" fromPrefs:prefs];
        _switchOnTintColor = [UIColor savedColorForIdentifier:@"nightThemeSwitchOnTintColor" fromPrefs:prefs];
    }
}

@end
