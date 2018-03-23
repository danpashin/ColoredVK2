//
//  ColoredVKColorCollectionViewCell.m
//  ColoredVK2
//
//  Created by Даниил on 20.06.17.
//
//

#import "ColoredVKColorCollectionViewCell.h"
#import "PrefixHeader.h"

@interface ColoredVKColorCollectionViewCell ()

@property (strong, nonatomic) ColoredVKColorPreview *colorPreview;
@property (strong, nonatomic) UIButton *deleteButton;

@end

@implementation ColoredVKColorCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _colorPreview = [[ColoredVKColorPreview alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        [self.contentView addSubview:_colorPreview];
        
        NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        
        CGFloat size = 32.0f;
        UIImage *deleteImage = [UIImage imageNamed:@"color_picker/DeleteIcon" inBundle:cvkBundle compatibleWithTraitCollection:nil];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(0, 0, size, size);
        [_deleteButton setImage:deleteImage forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(actionDeleteColor) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.alpha = 0.5f;
        _deleteButton.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(5.0f, 8.0f, size/1.5f, size/1.5f) cornerRadius:size/2].CGPath;
        _deleteButton.layer.shadowOpacity = 0.2f;
        _deleteButton.layer.shadowRadius = 2.0f;
        [self.contentView addSubview:_deleteButton];
        
        _deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[deleteButton(size)]|" options:0 metrics:@{@"size":@(size)} views:@{@"deleteButton":_deleteButton}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[deleteButton(size)]" options:0 metrics:@{@"size":@(size)} views:@{@"deleteButton":_deleteButton}]];
        
        _colorPreview.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[colorPreview]|" options:0 metrics:nil views:@{@"colorPreview":_colorPreview}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[colorPreview]|" options:0 metrics:nil views:@{@"colorPreview":_colorPreview}]];
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
