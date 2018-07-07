//
//  ColoredVKPrefsFooter.h
//  ColoredVK2
//
//  Created by Даниил on 23.06.18.
//

#import <UIKit/UIKit.h>

@interface ColoredVKPrefsFooter : UIView

@property (assign, nonatomic, readonly) CGFloat preferredHeight;

@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic, readonly) UIButton *button;
@property (strong, nonatomic) NSString *buttonTitle;
@property (strong, nonatomic) UIColor *buttonColor;


- (instancetype)init;

@end
