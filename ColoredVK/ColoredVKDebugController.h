//
//  ColoredVKDebugController.h
//  ColoredVK
//
//  Created by Даниил on 26.06.16.
//
//


#import <Foundation/Foundation.h>

@interface ColoredVKDebugController : NSObject
+ (NSString*) uploadDebug:(NSData *)debugData filename:(NSString *)filename;
@end
