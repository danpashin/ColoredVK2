//
//  NSError+ColoredVK.h
//  ColoredVK
//
//  Created by Даниил on 29/07/2018.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (ColoredVK)

//+ (instancetype)localizedErrorCode:(NSInteger)code description:(NSString *)description, ... NS_FORMAT_FUNCTION(2, 3);
+ (instancetype)cvk_localizedErrorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description, ... NS_FORMAT_FUNCTION(3, 4);

@end

NS_ASSUME_NONNULL_END
