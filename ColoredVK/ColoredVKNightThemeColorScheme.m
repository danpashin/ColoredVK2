//
//  ColoredVKNightThemeColorScheme.m
//  ColoredVK2
//
//  Created by Даниил on 19.10.17.
//

#import "ColoredVKNightThemeColorScheme.h"
#import "PrefixHeader.h"
#import "UIColor+ColoredVK.h"

@implementation ColoredVKNightThemeColorScheme

+ (instancetype)sharedScheme
{
    static ColoredVKNightThemeColorScheme *sharedScheme;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedScheme = [[ColoredVKNightThemeColorScheme alloc] init];
    });
    
    return sharedScheme;
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
    _enabled = (type != CVKNightThemeTypeDisabled);
    
    if (type == CVKNightThemeTypeDarkBlue) {
        _backgroundColor = [UIColor colorWithRed:0.078f green:0.114f blue:0.149f alpha:1.0f];
        _navbackgroundColor = [UIColor colorWithRed:0.141f green:0.204f blue:0.278f alpha:1.0f];
        _foregroundColor = [UIColor colorWithRed:0.106f green:0.157f blue:0.212f alpha:1.0f];
        
        _textColor = [UIColor colorWithWhite:0.9f alpha:0.9f];
        _detailTextColor = [UIColor colorWithRed:0.53f green:0.6f blue:0.65f alpha:1.0f];
        _linkTextColor = [UIColor colorWithRed:0.21f green:0.64f blue:0.96f alpha:1.0f];
        
        _unreadBackgroundColor = [UIColor colorWithRed:0.141f green:0.207f blue:0.278f alpha:0.9f];
        _incomingBackgroundColor = [UIColor colorWithRed:0.21f green:0.29f blue:0.36f alpha:1.0f];
        _outgoingBackgroundColor = [UIColor colorWithRed:0.21f green:0.37f blue:0.56f alpha:1.0f];
        
        _buttonColor = [UIColor colorWithRed:0.49f green:0.56f blue:0.61f alpha:1.0f];
        _buttonSelectedColor = [UIColor colorWithRed:0.1f green:0.59f blue:0.94f alpha:1.0f];
        _switchThumbTintColor = _navbackgroundColor;
        _switchOnTintColor = [UIColor colorWithRed:0.15f green:0.6f blue:0.99f alpha:1.0f];
    }
    else if (type == CVKNightThemeTypeBlack) {
        _backgroundColor = [UIColor blackColor];
        _navbackgroundColor = [UIColor colorWithRed:0.07f green:0.07f blue:0.07f alpha:1.0f];
        _foregroundColor = [UIColor colorWithRed:0.07f green:0.07f blue:0.07f alpha:1.0f];
        
        _textColor = [UIColor colorWithWhite:0.9f alpha:0.9f];
        _detailTextColor = [UIColor colorWithRed:0.49f green:0.49f blue:0.52f alpha:1.0f];
        _linkTextColor = [UIColor colorWithRed:0.0f green:0.6f blue:0.94f alpha:1.0f];
        
        _unreadBackgroundColor = [UIColor colorWithRed:0.12f green:0.12f blue:0.12f alpha:1.0f];
        _incomingBackgroundColor = [UIColor colorWithRed:0.11f green:0.11f blue:0.11f alpha:1.0f];
        _outgoingBackgroundColor = [UIColor colorWithRed:0.17f green:0.17f blue:0.17f alpha:1.0f];
        
        _buttonColor = [UIColor colorWithRed:0.42f green:0.42f blue:0.43f alpha:1.0f];
        _buttonSelectedColor = [UIColor colorWithRed:0.96f green:0.49f blue:0.0f alpha:1.0f];
        
        _switchThumbTintColor = _navbackgroundColor;
        _switchOnTintColor = [UIColor colorWithRed:0.66f green:0.66f blue:0.66f alpha:1.0f];
    } 
    else if (type == CVKNightThemeTypeCustom) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
            
            self->_backgroundColor = [UIColor savedColorForIdentifier:@"nightThemeBackgroundColor" fromPrefs:prefs];
            self->_navbackgroundColor = [UIColor savedColorForIdentifier:@"nightThemeNavBackgroundColor" fromPrefs:prefs];
            self->_foregroundColor = [UIColor savedColorForIdentifier:@"nightThemeForegroundColor" fromPrefs:prefs];
            
            self->_textColor = [UIColor savedColorForIdentifier:@"nightThemeTextColor" fromPrefs:prefs];
            self->_textColor = [UIColor savedColorForIdentifier:@"nightThemeDetailTextColor" fromPrefs:prefs];
           self-> _linkTextColor = [UIColor savedColorForIdentifier:@"nightThemeLinkColor" fromPrefs:prefs];
            
            self->_unreadBackgroundColor = [UIColor savedColorForIdentifier:@"nightThemeUnreadBackgroundColor" fromPrefs:prefs];
            self->_incomingBackgroundColor = [UIColor savedColorForIdentifier:@"nightThemeIncomingBackgroundColor" fromPrefs:prefs];
            self->_outgoingBackgroundColor = [UIColor savedColorForIdentifier:@"nightThemeOutgoingBackgroundColor" fromPrefs:prefs];
            
            self->_buttonColor = [UIColor savedColorForIdentifier:@"nightThemeButtonColor" fromPrefs:prefs];
            self->_buttonSelectedColor = [UIColor savedColorForIdentifier:@"nightThemeButtonSelectedColor" fromPrefs:prefs];
            self->_switchThumbTintColor = [UIColor savedColorForIdentifier:@"nightThemeSwitchThumbColor" fromPrefs:prefs];
            self->_switchOnTintColor = [UIColor savedColorForIdentifier:@"nightThemeSwitchOnTintColor" fromPrefs:prefs];
        });
    }
}

@end
