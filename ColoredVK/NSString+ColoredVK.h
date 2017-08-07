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
@property (nonatomic, readonly, copy) UIColor *colorValue;
@property (nonatomic, readonly, copy) UIColor *hexColorValue;
@property (nonatomic, getter=isHexColor, readonly) BOOL hexColor;
@end
