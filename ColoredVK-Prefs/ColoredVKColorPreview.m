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

static CGFloat const kHexLabelHeight = 25.0f;
static CGFloat const kColorPreviewCornerRadius = 6.0f;

@interface ColoredVKColorPreview ()

@property (strong, nonatomic) UILabel *hexLabel;
@property (strong, nonatomic) UILabel *rgbLabel;
@property (strong, nonatomic) UIView *colorPreview;

@end

@implementation ColoredVKColorPreview

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.colorPreview = [UIView new];
        self.colorPreview.frame = self.bounds;
        self.colorPreview.layer.cornerRadius = kColorPreviewCornerRadius;
        self.colorPreview.layer.masksToBounds = YES;
        [self addSubview:self.colorPreview];
        
        self.rgbLabel = [UILabel new];
        self.rgbLabel.frame = CGRectMake(0, CGRectGetHeight(self.frame) - kHexLabelHeight, CGRectGetWidth(self.frame), kHexLabelHeight / 2);
        self.rgbLabel.textAlignment = NSTextAlignmentCenter;
        self.rgbLabel.backgroundColor = [UIColor whiteColor];
        self.rgbLabel.font = [UIFont systemFontOfSize:10];
        self.rgbLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
        [self.colorPreview addSubview:self.rgbLabel];
        
        self.hexLabel = [UILabel new];
        self.hexLabel.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 2 * kHexLabelHeight, CGRectGetWidth(self.frame), kHexLabelHeight);
        self.hexLabel.textAlignment = NSTextAlignmentCenter;
        self.hexLabel.backgroundColor = [UIColor whiteColor];
        self.hexLabel.font = [UIFont systemFontOfSize:12];
        self.hexLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1];
        [self.colorPreview addSubview:self.hexLabel];
        
        self.layer.shadowRadius = 3.5f;
        self.layer.shadowOpacity = 0.15f;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.layer.shouldRasterize = YES;
        
        [self setupConstraints];
    }
    return self;
}

- (void)setupConstraints
{
    self.colorPreview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[colorPreview]|" options:0 metrics:nil views:@{@"colorPreview":self.colorPreview}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[colorPreview]|" options:0 metrics:nil views:@{@"colorPreview":self.colorPreview}]];
    
    self.hexLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.rgbLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.colorPreview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[hexLabel]|" options:0 metrics:nil views:@{@"hexLabel":self.hexLabel}]];
    [self.colorPreview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[rgbLabel]|" options:0 metrics:nil views:@{@"rgbLabel":self.rgbLabel}]];
    [self.colorPreview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hexLabel(height)][rgbLabel(12.5)]|" options:0 metrics:@{@"height":@(kHexLabelHeight)} 
                                                                                views:@{@"hexLabel":self.hexLabel, @"rgbLabel":self.rgbLabel}]];
    
    CGFloat constant = IS_IPAD ? 2.5 : 2.0;
    self.minHeight = (CGRectGetHeight(self.rgbLabel.frame) + CGRectGetHeight(self.hexLabel.frame)) * constant;
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
