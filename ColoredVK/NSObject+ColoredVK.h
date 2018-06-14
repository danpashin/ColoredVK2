//
//  NSObject+ColoredVK.h
//  ColoredVK2
//
//  Created by Даниил on 09.04.18.
//

#import <Foundation/Foundation.h>

typedef void(^SimpleVoidBlock)(void);

@interface NSObject (ColoredVK)
+ (void)cvk_runBlockOnMainThread:(SimpleVoidBlock)block;
@end
