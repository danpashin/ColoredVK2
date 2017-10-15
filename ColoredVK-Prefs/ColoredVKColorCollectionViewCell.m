//
//  ColoredVKColorCollectionViewCell.m
//  ColoredVK2
//
//  Created by Даниил on 20.06.17.
//
//

#import "ColoredVKColorCollectionViewCell.h"
#import "NSString+ColoredVK.h"
#import "PrefixHeader.h"

@interface ColoredVKColorCollectionViewCell ()

@property (strong, nonatomic) UIButton *deleteButton;

@end

@implementation ColoredVKColorCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.colorPreview = [ColoredVKColorPreview new];
        self.colorPreview.frame = self.bounds;
        [self.contentView addSubview:self.colorPreview];
        
        NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        
        CGFloat size = 32;
        UIImage *deleteImage = [UIImage imageNamed:@"DeleteIcon" inBundle:cvkBundle compatibleWithTraitCollection:nil];
        
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteButton.frame = CGRectMake(0, 0, size, size);
        [self.deleteButton setImage:deleteImage forState:UIControlStateNormal];
        [self.deleteButton addTarget:self action:@selector(actionDeleteColor) forControlEvents:UIControlEventTouchUpInside];
        self.deleteButton.alpha = 0.5;
        self.deleteButton.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(5, 8, size/1.5, size/1.5) cornerRadius:size/2].CGPath;
        self.deleteButton.layer.shadowOpacity = 0.2f;
        self.deleteButton.layer.shadowRadius = 2.0f;
        [self.contentView addSubview:self.deleteButton];
        
        self.deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[deleteButton(size)]|" options:0 metrics:@{@"size":@(size)} views:@{@"deleteButton":self.deleteButton}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[deleteButton(size)]" options:0 metrics:@{@"size":@(size)} views:@{@"deleteButton":self.deleteButton}]];
        
        self.colorPreview.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[colorPreview]|" options:0 metrics:nil views:@{@"colorPreview":self.colorPreview}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[colorPreview]|" options:0 metrics:nil views:@{@"colorPreview":self.colorPreview}]];
    }
    return self;
}

- (void)setHexColor:(NSString *)hexColor
{
    _hexColor = hexColor;
    
    self.colorPreview.color = hexColor.hexColorValue;
}

- (void)actionDeleteColor
{
    if ([self.delegate respondsToSelector:@selector(colorCell:deleteColor:)])
        [self.delegate colorCell:self deleteColor:self.hexColor];
}

@end
