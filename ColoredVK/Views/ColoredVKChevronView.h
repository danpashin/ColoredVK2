//
//  ColoredVKChevronView.h
//  test
//
//  Created by Даниил on 03/08/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ColoredVKChevronViewState)  {
    ColoredVKChevronViewStateOpened,
    ColoredVKChevronViewStateClosed
};

@interface ColoredVKChevronView : UIView

@property (assign, nonatomic) ColoredVKChevronViewState state;

- (void)setState:(ColoredVKChevronViewState)state animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
