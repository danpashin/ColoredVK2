//
//  ColoredVKPasscodeController.h
//  ColoredVK2
//
//  Created by Даниил on 28.03.18.
//

#import "ColoredVKWindowController.h"
#import "ColoredVKPasscodeView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ColoredVKPasscodeController : ColoredVKWindowController <ColoredVKPasscodeViewDelegate>

+ (void)performFeedbackWithType:(UINotificationFeedbackType)type;

@property (strong, nonatomic) ColoredVKPasscodeView *contentView;

- (void)performFeedbackWithType:(UINotificationFeedbackType)type;
- (void)setupConstraints NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
