//
//  NSString+ColoredVK1.m
//  ColoredVK
//
//  Created by Даниил on 09.08.16.
//
//

#import "NSString+ColoredVK.h"

@implementation NSString (ColoredVK)
+ (NSString *)stringFromColor:(UIColor*)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    return  [NSString stringWithFormat:@"%.3f, %.3f, %.3f, %.3f", components[0], components[1], components[2], components[3]];
}

+ (NSString *)hexStringFromColor:(UIColor *)color
{
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)(components[0] * 255), (int)(components[1] * 255), (int)(components[2] * 255)];
}
@end
