//
//  UIColor+ColoredVK.m
//  ColoredVK
//
//  Created by Даниил on 09.08.16.
//
//

#import "UIColor+ColoredVK.h"

@implementation UIColor (ColoredVK)
+ (UIColor *)colorFromString:(NSString *)string
{    
    NSArray *components = [string componentsSeparatedByString:@", "];
    return [UIColor colorWithRed:[components[0] floatValue] green:[components[1] floatValue] blue:[components[2] floatValue] alpha:[components[3] floatValue]];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString 
{
    if (![hexString hasPrefix:@"#"]) { hexString = [@"#" stringByAppendingString:hexString]; }
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
@end
