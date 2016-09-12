//
//  ColoredVKJailCheck.m
//  ColoredVK
//
//  Created by Даниил on 03.08.16.
//
//

#import "ColoredVKJailCheck.h"
#import <UIKit/UIKit.h>

@implementation ColoredVKJailCheck

+ (BOOL)isInjected
{
    return  [[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle].bundlePath stringByAppendingString:@"/ColoredVK2.bundle/ColoredVK2.dylib"]];
}

@end