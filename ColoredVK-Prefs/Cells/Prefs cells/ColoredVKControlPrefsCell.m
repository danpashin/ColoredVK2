//
//  ColoredVKControlPrefsCell.m
//  ColoredVK2
//
//  Created by Даниил on 28.06.18.
//

#import "ColoredVKControlPrefsCell.h"

@implementation ColoredVKControlPrefsCell

- (void)setPreferenceValue:(id)value
{
    SEL setter = @selector(setPreferenceValue:specifier:);
    [self performSetSelector:setter withValue:value object:self.specifier];
}

- (void)setPreferenceValue:(id)value forKey:(NSString *)key
{
    SEL setter = @selector(setPreferenceValue:forKey:);
    [self performSetSelector:setter withValue:value object:key];
}

- (void)performSetSelector:(SEL)selector withValue:(id)value object:(id)object
{
    if (![self.cellTarget respondsToSelector:selector])
        return;
    
    NSMethodSignature *signature = [self.cellTarget methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self.cellTarget;
    invocation.selector = selector;
    
    [invocation setArgument:&value atIndex:2];
    [invocation setArgument:&object atIndex:3];
    [invocation invoke];
}

@end
