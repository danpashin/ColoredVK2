//
//  ColoredVKPrefsFooter.m
//  ColoredVK2
//
//  Created by Даниил on 23.06.18.
//

#import "ColoredVKPrefsFooter.h"
#import "UIColor+ColoredVK.h"

@interface ColoredVKPrefsFooter ()
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation ColoredVKPrefsFooter

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.titleLabel = [UILabel new];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        self.titleLabel.numberOfLines = 0;
        [self addSubview:self.titleLabel];
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.button];
        
        self.button.translatesAutoresizingMaskIntoConstraints = NO;
        [self.button.heightAnchor constraintEqualToConstant:44.0f].active = YES;
        [self.button.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:0.0f].active = YES;
        [self.button.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:8.0f].active = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width;
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(orientation))
        maxWidth -= 16.0f;
    
    
    CGSize labelSize = [self sizeForText:self.titleLabel.text maxWidth:maxWidth font:self.titleLabel.font];
    self.titleLabel.frame = CGRectMake(0, 8.0f, labelSize.width, labelSize.height);
    self.titleLabel.center = CGPointMake(self.center.x, self.titleLabel.center.y);
    
    _preferredHeight = labelSize.height + CGRectGetHeight(self.button.frame);
}

- (CGSize)sizeForText:(NSString *)text maxWidth:(CGFloat)maxWidth font:(UIFont *)font
{
    if (!text)
        return CGSizeZero;
    
    CGRect frame = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin 
                                   attributes:@{NSFontAttributeName:font} context:nil];
    return frame.size;
}


- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setButtonTitle:(NSString *)buttonTitle
{
    _buttonTitle =buttonTitle;
    [self.button setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)setButtonColor:(UIColor *)buttonColor
{
    _buttonColor = buttonColor;
    [self.button setTitleColor:buttonColor forState:UIControlStateNormal];
    [self.button setTitleColor:buttonColor.cvk_darkerColor forState:UIControlStateHighlighted];
    [self.button setTitleColor:buttonColor.cvk_darkerColor forState:UIControlStateSelected];
}

@end
