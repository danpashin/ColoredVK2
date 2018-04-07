//
//  UIColor+ColoredVK.m
//  ColoredVK
//
//  Created by Даниил on 09.08.16.
//
//

#import "UIColor+ColoredVK.h"
#import "PrefixHeader.h"
#import "NSString+ColoredVK.h"

@implementation UIColor (ColoredVK)

+ (UIColor *)colorFromString:(NSString *)string
{
    return string.colorValue;
}

- (UIColor *)darkerColor
{
    CGFloat r, g, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:MAX(r - 0.2f, 0.0f) green:MAX(g - 0.2f, 0.0f) blue:MAX(b - 0.2f, 0.0f) alpha:a];
}


+ (UIColor *)savedColorForIdentifier:(NSString *)identifier 
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    return [UIColor savedColorForIdentifier:identifier fromPrefs:prefs];
}

+ (UIColor *)savedColorForIdentifier:(NSString *)identifier fromPrefs:(NSDictionary *)prefs
{
    if (!prefs[identifier])
        return [UIColor defaultColorForIdentifier:identifier];
    
    return [UIColor colorFromString:prefs[identifier]];
}

+ (UIColor *)defaultColorForIdentifier:(NSString *)identifier
{
    if      ([identifier isEqualToString:@"BarBackgroundColor"])         return [UIColor colorWithRed:0.27f green:0.46f blue:0.68f alpha:1];
    else if ([identifier isEqualToString:@"BarForegroundColor"])         return [UIColor whiteColor];
    else if ([identifier isEqualToString:@"ToolBarBackgroundColor"])     return [UIColor colorWithRed:245/255.0f green:245/255.0f blue:248/255.0f alpha:1.0f];
    else if ([identifier isEqualToString:@"ToolBarForegroundColor"])     return [UIColor colorWithRed:127/255.0f green:131/255.0f blue:137/255.0f alpha:1.0f];
    else if ([identifier isEqualToString:@"MenuSeparatorColor"])         return [UIColor colorWithRed:72/255.0f green:86/255.0f blue:97/255.0f alpha:1.0f];
    else if ([identifier isEqualToString:@"SBBackgroundColor"])          return [UIColor clearColor];
    else if ([identifier isEqualToString:@"SBForegroundColor"])          return [UIColor whiteColor];
    else if ([identifier isEqualToString:@"switchesTintColor"])          return nil;
    else if ([identifier isEqualToString:@"switchesOnTintColor"])        return [UIColor colorWithRed:90/255.0f green:130/255.0f blue:180/255.0f alpha:1.0];
    else if ([identifier isEqualToString:@"messageBubbleTintColor"])     return [UIColor whiteColor];
    else if ([identifier isEqualToString:@"messageBubbleSentTintColor"]) return [UIColor colorWithRed:205/255.0f green:226/255.0f blue:250/255.0f alpha:1.0f];
    else if ([identifier isEqualToString:@"messageReadColor"])           return [UIColor colorWithWhite:1.0f alpha:0.15f];
    else if ([identifier isEqualToString:@"dialogsUnreadColor"])         return [UIColor colorWithWhite:1.0f alpha:0.15f];
    else if ([identifier containsString:@"TextColor"])                   return [UIColor colorWithWhite:1.0f alpha:0.9f];
    else if ([identifier containsString:@"BlurTone"])                    return [UIColor clearColor];
    else if ([identifier isEqualToString:@"menuSelectionColor"])         return [UIColor whiteColor];
    else if ([identifier isEqualToString:@"TabbarForegroundColor"])      return [UIColor colorWithRed:0.6f green:0.63f blue:0.67f alpha:1.0f];
    else if ([identifier isEqualToString:@"TabbarBackgroundColor"])      return [UIColor colorWithWhite:1.0f alpha:0.9f];
    else if ([identifier isEqualToString:@"TabbarSelForegroundColor"])   return [UIColor colorWithRed:0.28f green:0.5f blue:0.77f alpha:1.0f];
    else if ([identifier isEqualToString:@"messagesInputBackColor"])     return [UIColor whiteColor];
    else if ([identifier isEqualToString:@"messagesInputTextColor"])     return [UIColor blackColor];
    else                                                                 return [UIColor blackColor];
}

- (NSString *)stringValue
{
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    return  [NSString stringWithFormat:@"%.3f, %.3f, %.3f, %.3f", red, green, blue, alpha];
}

- (NSString *)rgbStringValue
{
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    return  [NSString stringWithFormat:@"%i, %i, %i, %.1f", (int)(red * 255), (int)(green * 255), (int)(blue * 255), alpha];
}

- (NSString *)hexStringValue
{
    CGFloat red, green, blue;
    [self getRed:&red green:&green blue:&blue alpha:nil];
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)(red * 255), (int)(green * 255), (int)(blue * 255)].lowercaseString;
}

@end
