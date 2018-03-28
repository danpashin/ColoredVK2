//
//  ColoredVKPasscodeController.h
//  ColoredVK2
//
//  Created by Даниил on 28.03.18.
//

#import "ColoredVKWindowController.h"
#import "ColoredVKPasscodeView.h"

@interface ColoredVKPasscodeController : ColoredVKWindowController <ColoredVKPasscodeViewDelegate>

@property (strong, nonatomic) NSBundle *cvkBundle;
@property (strong, nonatomic) ColoredVKPasscodeView *contentView;

- (void)setupConstraints NS_REQUIRES_SUPER;

@end
