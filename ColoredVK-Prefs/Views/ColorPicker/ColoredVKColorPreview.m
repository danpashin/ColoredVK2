//
//  ColoredVKColorPreview.m
//  ColoredVK2
//
//  Created by Даниил on 19.06.17.
//
//

#import "ColoredVKColorPreview.h"
#import <objc/runtime.h>
#import "UIColor+ColoredVK.h"

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
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.colorPreview = [UIView new];
    self.colorPreview.layer.cornerRadius = kColorPreviewCornerRadius;
    self.colorPreview.layer.masksToBounds = YES;
    [self addSubview:self.colorPreview];
    
    self.rgbLabel = [UILabel new];
    self.rgbLabel.textAlignment = NSTextAlignmentCenter;
    self.rgbLabel.backgroundColor = [UIColor whiteColor];
    self.rgbLabel.font = [UIFont systemFontOfSize:10];
    self.rgbLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    NIGHT_THEME_DISABLE_CUSTOMISATION(self.rgbLabel);
    [self.colorPreview addSubview:self.rgbLabel];
    
    self.hexLabel = [UILabel new];
    self.hexLabel.textAlignment = NSTextAlignmentCenter;
    self.hexLabel.backgroundColor = [UIColor whiteColor];
    self.hexLabel.font = [UIFont systemFontOfSize:12];
    self.hexLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
    NIGHT_THEME_DISABLE_CUSTOMISATION(self.hexLabel);
    [self.colorPreview addSubview:self.hexLabel];
    
    self.layer.shadowRadius = 3.5f;
    self.layer.shadowOpacity = 0.15f;
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.shouldRasterize = YES;
    
    self.colorPreview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[colorPreview]|" options:0 metrics:nil views:@{@"colorPreview":self.colorPreview}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[colorPreview]|" options:0 metrics:nil views:@{@"colorPreview":self.colorPreview}]];
    
    self.hexLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.rgbLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.colorPreview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[hexLabel]|" options:0 metrics:nil views:@{@"hexLabel":self.hexLabel}]];
    [self.colorPreview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[rgbLabel]|" options:0 metrics:nil views:@{@"rgbLabel":self.rgbLabel}]];
    [self.colorPreview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hexLabel(hexHeight)][rgbLabel(rgbHeight)]|"
                                                                              options:0 metrics:@{@"hexHeight":@(kHexLabelHeight), @"rgbHeight":@(kHexLabelHeight / 2)} 
                                                                                views:@{@"hexLabel":self.hexLabel, @"rgbLabel":self.rgbLabel}]];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    self.colorPreview.backgroundColor = color;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *hexString = color.cvk_hexStringValue;
        NSString *rgbString = color.cvk_rgbStringValue;        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.hexLabel.text = hexString;
            self.rgbLabel.text = rgbString;
        });
    });
}

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    
    CGFloat constant = IS_IPAD ? 2.5 : 2.0;
    self.minHeight = (CGRectGetHeight(self.rgbLabel.frame) + CGRectGetHeight(self.hexLabel.frame)) * constant;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
}

@end
