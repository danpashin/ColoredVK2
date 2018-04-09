//
//  NSObject+ColoredVK.m
//  ColoredVK2
//
//  Created by Даниил on 09.04.18.
//

#import "NSObject+ColoredVK.h"

@implementation NSObject (ColoredVK)

+ (void)cvk_runVoidBlockOnMainThread:(SimpleVoidBlock)block
{
    if (!block)
        return;
    else
        block = [block copy];
    
    if ([NSThread isMainThread])
        block();
    else
        dispatch_async(dispatch_get_main_queue(), block);
}

@end
