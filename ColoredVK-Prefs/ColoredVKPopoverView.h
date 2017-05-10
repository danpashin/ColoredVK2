//
//  ColoredVKPopoverView.h
//  ColoredVK2
//
//  Created by Даниил on 09.05.17.
//
//

#import <UIKit/UIKit.h>

@interface ColoredVKPopoverView : UIView

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *contentView;

@property (assign, nonatomic) BOOL blurBackground;

@property (assign, nonatomic) UIBlurEffectStyle blurStyle;

@end
