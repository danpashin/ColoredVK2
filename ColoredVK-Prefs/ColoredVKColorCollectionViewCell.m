//
//  ColoredVKColorCollectionViewCell.m
//  ColoredVK2
//
//  Created by Даниил on 20.06.17.
//
//

#import "ColoredVKColorCollectionViewCell.h"
#import "ColoredVKColorPreview.h"
#import "NSString+ColoredVK.h"
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
        self.colorPreview = [ColoredVKColorPreview new];
        self.backgroundView = self.colorPreview;
        
        NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        
        CGFloat size = IS_IPAD ? 20 : 15;
        UIImage *deleteImage = [UIImage imageNamed:@"DeleteIcon" inBundle:cvkBundle compatibleWithTraitCollection:nil];
        
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteButton.frame = CGRectMake(0, 0, size, size);
        [self.deleteButton setImage:deleteImage forState:UIControlStateNormal];
        [self.deleteButton addTarget:self action:@selector(actionDeleteColor) forControlEvents:UIControlEventTouchUpInside];
        self.deleteButton.alpha = 0.5;
        [self.contentView addSubview:self.deleteButton];
        
        self.deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[deleteButton(size)]-5-|" options:0 
                                                                                 metrics:@{@"size":@(size)} views:@{@"deleteButton":self.deleteButton}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[deleteButton(size)]" options:0
                                                                                 metrics:@{@"size":@(size)} views:@{@"deleteButton":self.deleteButton}]];
    }
    return self;
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    self.colorPreview.color = self.color;
}

- (void)setHexColor:(NSString *)hexColor
{
    _hexColor = hexColor;
    
    self.color = hexColor.hexColorValue;
}

- (void)actionDeleteColor
{
    if ([self.delegate respondsToSelector:@selector(colorCell:deleteColor:)])
        [self.delegate colorCell:self deleteColor:self.hexColor];
}

@end
