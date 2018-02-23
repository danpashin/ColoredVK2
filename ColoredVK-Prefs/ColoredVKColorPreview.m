//
//  ColoredVKColorPreview.m
//  ColoredVK2
//
//  Created by Даниил on 19.06.17.
//
//

#import "ColoredVKColorPreview.h"
#import "UIColor+ColoredVK.h"
#import "PrefixHeader.h"
#import <objc/runtime.h>

static CGFloat const kHexLabelHeight = 25.0f;
static CGFloat const kColorPreviewCornerRadius = 6.0f;

@interface ColoredVKColorPreview ()

@property (strong, nonatomic) UILabel *hexLabel;
@property (strong, nonatomic) UILabel *rgbLabel;
@property (strong, nonatomic) UIView *colorPreview;

@end

@implementation ColoredVKColorPreview

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _colorPreview = [UIView new];
        _colorPreview.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        _colorPreview.layer.cornerRadius = kColorPreviewCornerRadius;
        _colorPreview.layer.masksToBounds = YES;
        [self addSubview:_colorPreview];
        
        _rgbLabel = [UILabel new];
        _rgbLabel.frame = CGRectMake(0, CGRectGetHeight(frame) - kHexLabelHeight, CGRectGetWidth(frame), kHexLabelHeight / 2);
        _rgbLabel.textAlignment = NSTextAlignmentCenter;
        _rgbLabel.backgroundColor = [UIColor whiteColor];
        _rgbLabel.font = [UIFont systemFontOfSize:10];
        _rgbLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
        objc_setAssociatedObject(_rgbLabel, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
        [_colorPreview addSubview:_rgbLabel];
        
        _hexLabel = [UILabel new];
        _hexLabel.frame = CGRectMake(0, CGRectGetHeight(frame) - 2 * kHexLabelHeight, CGRectGetWidth(frame), kHexLabelHeight);
        _hexLabel.textAlignment = NSTextAlignmentCenter;
        _hexLabel.backgroundColor = [UIColor whiteColor];
        _hexLabel.font = [UIFont systemFontOfSize:12];
        _hexLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
        objc_setAssociatedObject(_hexLabel, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
        [_colorPreview addSubview:_hexLabel];
        
        self.layer.shadowRadius = 3.5f;
        self.layer.shadowOpacity = 0.15f;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        _colorPreview.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[colorPreview]|" options:0 metrics:nil views:@{@"colorPreview":_colorPreview}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[colorPreview]|" options:0 metrics:nil views:@{@"colorPreview":_colorPreview}]];
        
        _hexLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _rgbLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_colorPreview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[hexLabel]|" options:0 metrics:nil views:@{@"hexLabel":_hexLabel}]];
        [_colorPreview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[rgbLabel]|" options:0 metrics:nil views:@{@"rgbLabel":_rgbLabel}]];
        [_colorPreview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hexLabel(hexHeight)][rgbLabel(rgbHeight)]|"
                                                                                  options:0 metrics:@{@"hexHeight":@(kHexLabelHeight), @"rgbHeight":@(kHexLabelHeight / 2)} 
                                                                                    views:@{@"hexLabel":_hexLabel, @"rgbLabel":_rgbLabel}]];
        
        CGFloat constant = IS_IPAD ? 2.5 : 2.0;
        self.minHeight = (CGRectGetHeight(self.rgbLabel.frame) + CGRectGetHeight(self.hexLabel.frame)) * constant;
    }
    return self;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    self.colorPreview.backgroundColor = color;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *hexString = color.hexStringValue;
        NSString *rgbString = color.rgbStringValue;        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.hexLabel.text = hexString;
            self.rgbLabel.text = rgbString;
        });
    });
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
}

@end
