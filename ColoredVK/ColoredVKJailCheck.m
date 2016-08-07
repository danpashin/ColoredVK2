//
//  ColoredVKJailCheck.m
//  ColoredVK
//
//  Created by Даниил on 03.08.16.
//
//

#import "ColoredVKJailCheck.h"

@implementation ColoredVKJailCheck

+ (BOOL)isJailbroken
{
    NSArray *paths = @[@"/Applications/Cydia.app", @"/Library/MobileSubstrate/MobileSubstrate.dylib",  @"/bin/bash", @"/usr/sbin/sshd", @"/usr/bin/ssh", @"/etc/apt"];
    
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {  return YES;  }
    }
    
    return NO;
}

+ (BOOL)isExecutable
{
    return  ([[NSBundle mainBundle].executablePath isEqualToString:@"/Library/PreferenceBundles/ColoredVK.bundle/ColoredVK"]);
}

@end
