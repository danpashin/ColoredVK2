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

@property (copy, nonatomic, readonly) UIColor *cvk_colorValue;
@property (copy, nonatomic, readonly) UIColor *cvk_rgbColorValue;
@property (copy, nonatomic, readonly) UIColor *cvk_hexColorValue;
@property (assign, nonatomic, readonly) BOOL cvk_hexColor;

@end
