//
//  UIColor+ColoredVK.m
//  ColoredVK
//
//  Created by Даниил on 09.08.16.
//
//

#import "UIColor+ColoredVK.h"
#import "NSString+ColoredVK.h"
#import "PrefixHeader.h"

@implementation UIColor (ColoredVK)
+ (UIColor *)colorFromString:(NSString *)string
{
    return string.colorValue;
}

- (UIColor *)darkerColor
{
    CGFloat r, g, b, a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:MAX(r - 0.2, 0.0) green:MAX(g - 0.2, 0.0) blue:MAX(b - 0.2, 0.0)  alpha:a];
}


+ (UIColor *)savedColorForIdentifier:(NSString *)identifier 
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    return [UIColor savedColorForIdentifier:identifier fromPrefs:prefs];
}

+ (UIColor *)savedColorForIdentifier:(NSString *)identifier fromPrefs:(NSDictionary *)prefs
{    
    if (prefs[identifier] == nil) return [UIColor defaultColorForIdentifier:identifier];
    return [UIColor colorFromString:prefs[identifier]];
}

+ (UIColor *)defaultColorForIdentifier:(NSString *)identifier
{
    if      ([identifier isEqualToString:@"BarBackgroundColor"])       return [UIColor colorWithRed:60.00/255.0f green:112.0/255.0f blue:169.0/255.0f alpha:1];
    else if ([identifier isEqualToString:@"BarForegroundColor"])       return [UIColor whiteColor];
    else if ([identifier isEqualToString:@"ToolBarBackgroundColor"])   return [UIColor colorWithRed:245.0/255.0f green:245.0/255.0f blue:248.0/255.0f alpha:1];
    else if ([identifier isEqualToString:@"ToolBarForegroundColor"])   return [UIColor colorWithRed:127.0/255.0f green:131.0/255.0f blue:137.0/255.0f alpha:1];
    else if ([identifier isEqualToString:@"MenuSeparatorColor"])       return [UIColor colorWithRed:72.00/255.0f green:86.00/255.0f blue:97.00/255.0f alpha:1];
    else if ([identifier isEqualToString:@"SBBackgroundColor"])        return [UIColor clearColor];
    else if ([identifier isEqualToString:@"SBForegroundColor"])        return [UIColor whiteColor];
    else if ([identifier isEqualToString:@"switchesTintColor"])        return nil;
    else if ([identifier isEqualToString:@"switchesOnTintColor"])      return [UIColor colorWithRed:90/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1.0];
    else if ([identifier isEqualToString:@"messageBubbleTintColor"])   return [UIColor whiteColor];
    else if ([identifier isEqualToString:@"messageBubbleSentTintColor"]) return [UIColor colorWithRed:205/255.0f green:226/255.0f blue:250/255.0f alpha:1];
    else if ([identifier isEqualToString:@"messageReadColor"])         return [UIColor colorWithWhite:1 alpha:0.15];
    else if ([identifier containsString:@"TextColor"])                 return [UIColor colorWithWhite:1 alpha:0.9];
    else                                                               return [UIColor blackColor];
}

+ (UIColor *)lightBlackColor
{
    return [UIColor colorWithWhite:20/255.0f alpha:1.0];
}

+ (UIColor *)darkBlackColor
{
    return [UIColor colorWithWhite:10/255.0f alpha:1.0];
}

+ (UIColor *)buttonsTintColor
{
    return [UIColor colorWithRed:0.7 green:0 blue:0 alpha:1.0];
}


- (NSString *)stringValue
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    return  [NSString stringWithFormat:@"%.3f, %.3f, %.3f, %.3f", components[0], components[1], components[2], components[3]];
}

- (NSString *)hexStringValue
{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)(components[0] * 255), (int)(components[1] * 255), (int)(components[2] * 255)];
}
@end
