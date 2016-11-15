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
+ (NSString *)stringFromColor:(UIColor*)color
{
    if (color == nil) color = [UIColor blackColor];
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    return  [NSString stringWithFormat:@"%.3f, %.3f, %.3f, %.3f", components[0], components[1], components[2], components[3]];
}

+ (NSString *)hexStringFromColor:(UIColor *)color
{
    if (color == nil) color = [UIColor blackColor];
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)(components[0] * 255), (int)(components[1] * 255), (int)(components[2] * 255)];
}

+ (NSString *)md5StringFromString:(NSString *)string
{
    const char* str = string.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) [ret appendFormat:@"%02x",result[i] ];
    return ret;
}
@end
