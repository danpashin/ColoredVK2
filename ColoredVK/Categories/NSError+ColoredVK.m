//
//  NSError+ColoredVK.m
//  ColoredVK
//
//  Created by Даниил on 29/07/2018.
//

#import "NSError+ColoredVK.h"

@implementation NSError (ColoredVK)

+ (instancetype)cvk_localizedErrorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description, ...
{
    va_list args;
    va_start(args, description);
    NSMutableString *localizedDescription = [[NSMutableString alloc] initWithFormat:CVKLocalizedString(description) arguments:args];
    va_end(args);
    [localizedDescription appendFormat:CVKLocalizedString(@"\n(ERROR_CODE_%i)"), code];
    
    return [self errorWithDomain:domain code:code 
                           userInfo:@{NSLocalizedDescriptionKey:localizedDescription}];
}

@end
