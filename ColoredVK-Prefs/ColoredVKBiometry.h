//
//  ColoredVKBiometry.h
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import "ColoredVKWindowController.h"

@interface ColoredVKBiometry : ColoredVKWindowController

+ (void)authenticateWithPasscode:(NSString *)password success:( void(^)(void) )successBlock failure:( void(^)(void) )failureBlock;

@property (assign, nonatomic, readonly) BOOL supportsTouchID;
@property (assign, nonatomic, readonly) BOOL supportsFaceID;

@end
