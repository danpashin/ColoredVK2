//
//  ColoredVKBiometry.h
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import "ColoredVKPasscodeController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ColoredVKBiometry : ColoredVKPasscodeController

@property (assign, nonatomic, readonly, class) BOOL defaultPasswordIsSet;
+ (void)authenticateWithSuccess:( void(^)(void) )successBlock failure:( void(^_Nullable)(void) )failureBlock;

@property (assign, nonatomic, readonly) BOOL supportsTouchID;
@property (assign, nonatomic, readonly) BOOL supportsFaceID;

@end

extern NSNumber * _Nullable __biometryDefaultPasswordIsSet;

NS_ASSUME_NONNULL_END
