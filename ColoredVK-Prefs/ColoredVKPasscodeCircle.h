//
//  ColoredVKPasscodeCircle.h
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import <UIKit/UIKit.h>

@interface ColoredVKPasscodeCircle : UIView

@property (assign, nonatomic) IBInspectable BOOL filled;

- (void)setFilled:(BOOL)filled animated:(BOOL)animated;

@end
