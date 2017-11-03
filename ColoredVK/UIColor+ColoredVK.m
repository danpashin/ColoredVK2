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
    return [UIColor colorWithRed:MAX(r - 0.2, 0.0) green:MAX(g - 0.2, 0.0) blue:MAX(b - 0.2, 0.0) alpha:a];
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
    if      ([identifier isEqualToString:@"BarBackgroundColor"])         return [UIColor colorWithRed:0.27f green:0.46f blue:0.68f alpha:1];
    else if ([identifier isEqualToString:@"BarForegroundColor"])         return [UIColor whiteColor];
    else if ([identifier isEqualToString:@"ToolBarBackgroundColor"])     return [UIColor colorWithRed:245.0/255.0f green:245.0/255.0f blue:248.0/255.0f alpha:1];
    else if ([identifier isEqualToString:@"ToolBarForegroundColor"])     return [UIColor colorWithRed:127.0/255.0f green:131.0/255.0f blue:137.0/255.0f alpha:1];
    else if ([identifier isEqualToString:@"MenuSeparatorColor"])         return [UIColor colorWithRed:72.00/255.0f green:86.00/255.0f blue:97.00/255.0f alpha:1];
    else if ([identifier isEqualToString:@"SBBackgroundColor"])          return [UIColor clearColor];
    else if ([identifier isEqualToString:@"SBForegroundColor"])          return [UIColor whiteColor];
    else if ([identifier isEqualToString:@"switchesTintColor"])          return nil;
    else if ([identifier isEqualToString:@"switchesOnTintColor"])        return [UIColor colorWithRed:90/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1.0];
    else if ([identifier isEqualToString:@"messageBubbleTintColor"])     return [UIColor whiteColor];
    else if ([identifier isEqualToString:@"messageBubbleSentTintColor"]) return [UIColor colorWithRed:205/255.0f green:226/255.0f blue:250/255.0f alpha:1];
    else if ([identifier isEqualToString:@"messageReadColor"])           return [UIColor colorWithWhite:1 alpha:0.15];
    else if ([identifier isEqualToString:@"dialogsUnreadColor"])         return [UIColor colorWithWhite:1 alpha:0.15];
    else if ([identifier containsString:@"TextColor"])                   return [UIColor colorWithWhite:1 alpha:0.9];
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

+ (UIColor *)colorWithGradientStyle:(UIGradientStyle)gradientStyle withFrame:(CGRect)frame andColors:(NSArray<UIColor *> *)colors
{
    if (colors.count == 0) return [UIColor blackColor];
    
    CAGradientLayer *backgroundGradientLayer = [CAGradientLayer layer];
    backgroundGradientLayer.frame = frame;
    
        //To simplfy formatting, we'll iterate through our colors array and create a mutable array with their CG counterparts
    NSMutableArray *cgColors = [[NSMutableArray alloc] init];
    for (UIColor *color in colors) {
        [cgColors addObject:(id)color.CGColor];
    }
    switch (gradientStyle) {
        case UIGradientStyleTopToBottom:
        default: {
                //Set out gradient's colors
            backgroundGradientLayer.colors = cgColors;
            
                //Convert our CALayer to a UIImage object
            UIGraphicsBeginImageContextWithOptions(backgroundGradientLayer.bounds.size,NO, [UIScreen mainScreen].scale);
            [backgroundGradientLayer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return [UIColor colorWithPatternImage:backgroundColorImage];
        }
            
    }

}

- (BOOL)isEqualToColor:(UIColor *)color offset:(CGFloat)offset
{
    CGFloat firstHue = 0, firstSaturation = 0, firstBright = 0, secondHue = 0, secondSaturation = 0, secondBright = 0;
    
    [self getHue:&firstHue saturation:&firstSaturation brightness:&firstBright alpha:nil];
    [color getHue:&secondHue saturation:&secondSaturation brightness:&secondBright alpha:nil];
    
    BOOL hue_is_equal = ((secondHue - offset >= firstHue) && (secondHue + offset <= firstHue));
    BOOL saturation_is_equal = ((secondSaturation - offset >= firstSaturation) && (secondSaturation + offset <= firstSaturation));
    BOOL bright_is_equal = ((secondBright - offset >= firstBright) && (secondBright + offset <= firstBright));
    
    return (hue_is_equal && saturation_is_equal && bright_is_equal);
}
@end
