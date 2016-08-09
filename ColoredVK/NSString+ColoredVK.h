//
//  NSString+ColoredVK1.h
//  ColoredVK
//
//  Created by Даниил on 09.08.16.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSString (ColoredVK)
/**
 Creates string from color
 */
+ (NSString *)stringFromColor:(UIColor*)color;
/**
 Creates hex string from color
 */
+ (NSString *)hexStringFromColor:(UIColor *)color;
@end
