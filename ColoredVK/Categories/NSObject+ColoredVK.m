//
//  NSObject+ColoredVK.m
//  ColoredVK2
//
//  Created by Даниил on 09.04.18.
//

#import "NSObject+ColoredVK.h"

@implementation NSObject (ColoredVK)

+ (void)cvk_runBlockOnMainThread:(void(^)(void))block;
{
    if (!block)
        return; 
    
    if ([NSThread isMainThread])
        block();
    else
        dispatch_async(dispatch_get_main_queue(), block);
}

- (void *)cvk_executeSelector:(SEL)selector
{
    return [self cvk_executeSelector:selector arguments:nil];
}

- (void *)cvk_executeSelector:(SEL)selector arguments:(id)firstArgument, ...
{
    if (![self respondsToSelector:selector])
        return nil;
    
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = selector;
    
    if (firstArgument) {
        [invocation setArgument:&firstArgument atIndex:2];
        va_list args;
        va_start(args, firstArgument);
        
        NSInteger argumentIndex = 3;
        id argument = nil;
        while ((argument = va_arg(args,id))) {
            [invocation setArgument:&argument atIndex:argumentIndex];
            argumentIndex++;
        }
        va_end(args);
    }
    [invocation invoke];
    
    void *result = NULL;
    if (strcmp(signature.methodReturnType, "v") != 0)
        [invocation getReturnValue:&result];
    
    return result;
}

@end
