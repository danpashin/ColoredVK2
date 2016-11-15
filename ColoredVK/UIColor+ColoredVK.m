//
//  UIColor+ColoredVK.m
//  ColoredVK
//
//  Created by Даниил on 09.08.16.
//
//

#import "UIColor+ColoredVK.h"
#import "PrefixHeader.h"

@implementation UIColor (ColoredVK)
+ (UIColor *)colorFromString:(NSString *)string
{
    NSArray *components = [[string stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
    if (components.count > 0) return [UIColor colorWithRed:[components[0] floatValue] green:[components[1] floatValue] blue:[components[2] floatValue] alpha:[components[3] floatValue]];
    return UIColor.blackColor;
}

+ (UIColor *)colorFromHexString:(NSString *)hexString 
{
    if (![hexString hasPrefix:@"#"]) hexString = [@"#" stringByAppendingString:hexString];
    int red = 0;
    int green = 0;
    int blue = 0;
    sscanf(hexString.UTF8String, "#%02X%02X%02X", &red, &green, &blue);
    return  [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

+ (UIColor *)darkerColorForColor:(UIColor *)color
{
    CGFloat r, g, b, a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    return [UIColor colorWithRed:MAX(r - 0.2, 0.0) green:MAX(g - 0.2, 0.0) blue:MAX(b - 0.2, 0.0)  alpha:a];
}

+ (UIColor *)savedColorForIdentifier:(NSString *)identifier 
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    
    if (prefs[identifier] == nil) return [UIColor defaultColorForIdentifier:identifier];
    return [UIColor colorFromString:prefs[identifier]];
}

+ (UIColor *)defaultColorForIdentifier:(NSString *)identifier
{
    if      ([identifier isEqualToString:@"BarBackgroundColor"])       return [UIColor colorWithRed:60.00/255.0f green:112.0/255.0f blue:169.0/255.0f alpha:1];
    else if ([identifier isEqualToString:@"BarForegroundColor"])       return UIColor.whiteColor;
    else if ([identifier isEqualToString:@"ToolBarBackgroundColor"])   return [UIColor colorWithRed:245.0/255.0f green:245.0/255.0f blue:248.0/255.0f alpha:1];
    else if ([identifier isEqualToString:@"ToolBarForegroundColor"])   return [UIColor colorWithRed:127.0/255.0f green:131.0/255.0f blue:137.0/255.0f alpha:1];
    else if ([identifier isEqualToString:@"MenuSeparatorColor"])       return [UIColor colorWithRed:72.00/255.0f green:86.00/255.0f blue:97.00/255.0f alpha:1];
    else if ([identifier isEqualToString:@"SBBackgroundColor"])        return UIColor.clearColor;
    else if ([identifier isEqualToString:@"SBForegroundColor"])        return UIColor.whiteColor;
    else if ([identifier isEqualToString:@"switchesTintColor"])        return nil;
    else if ([identifier isEqualToString:@"switchesOnTintColor"])      return [UIColor colorWithRed:90/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1.0];
    else                                                               return UIColor.blackColor;
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
@end
