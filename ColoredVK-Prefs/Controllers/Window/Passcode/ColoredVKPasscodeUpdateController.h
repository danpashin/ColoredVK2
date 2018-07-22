//
//  ColoredVKPasscodeUpdateController.h
//  ColoredVK2
//
//  Created by Даниил on 21/07/2018.
//

#import "ColoredVKPasscodeController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ColoredVKPasscodeUpdateControllerCompletion)(BOOL defaultPasswordIsSet);


@interface ColoredVKPasscodeUpdateController : ColoredVKPasscodeController

+ (void)setNewPasscode:(ColoredVKPasscodeUpdateControllerCompletion)completion;
+ (void)updatePasscode:(ColoredVKPasscodeUpdateControllerCompletion)completion;
+ (void)removePasscode:(ColoredVKPasscodeUpdateControllerCompletion)completion;

@end

NS_ASSUME_NONNULL_END
