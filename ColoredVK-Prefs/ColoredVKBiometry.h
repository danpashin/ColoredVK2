//
//  ColoredVKBiometry.h
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import "ColoredVKWindowController.h"

@interface ColoredVKBiometry : ColoredVKWindowController

+ (void)authenticateWithSuccess:( void(^)(void) )successBlock failure:( void(^)(void) )failureBlock;

@end
