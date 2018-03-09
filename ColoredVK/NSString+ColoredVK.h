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

@property (copy, nonatomic, readonly) UIColor *colorValue;
@property (copy, nonatomic, readonly) UIColor *rgbColorValue;
@property (copy, nonatomic, readonly) UIColor *hexColorValue;
@property (assign, nonatomic, readonly) BOOL hexColor;

@end
