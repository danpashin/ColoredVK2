//
//  NSString+ColoredVK1.m
//  ColoredVK
//
//  Created by Даниил on 09.08.16.
//
//

#import "NSString+ColoredVK.h"
#import "PrefixHeader.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (ColoredVK)

- (UIColor *)colorValue
{
    NSArray *components = [[self stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
    if (components.count > 0) return [UIColor colorWithRed:[components[0] floatValue] green:[components[1] floatValue] blue:[components[2] floatValue] alpha:[components[3] floatValue]];
    return [UIColor blackColor];
}

- (UIColor *)rgbColorValue
{
    NSArray *components = [[self stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
    if (components.count > 0) return [UIColor colorWithRed:[components[0] floatValue] * 255.0f green:[components[1] floatValue] * 255.0f blue:[components[2] floatValue] * 255.0f alpha:[components[3] floatValue]];
    return [UIColor blackColor];
}

- (UIColor *)hexColorValue 
{
    NSString *hexString = self.copy;
    if (![hexString hasPrefix:@"#"]) hexString = [@"#" stringByAppendingString:hexString];
    int red = 0;
    int green = 0;
    int blue = 0;
    sscanf(hexString.UTF8String, "#%02X%02X%02X", &red, &green, &blue);
    return  [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

- (BOOL)isHexColor
{
    NSString *expression = @"(?:#)?(?:[0-9A-Fa-f]{2}){3}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", expression];
    
    return [predicate evaluateWithObject:self];
}
@end
