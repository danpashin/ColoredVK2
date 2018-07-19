//
//  ColoredVKColorPickerContainer.m
//  ColoredVK2
//
//  Created by Даниил on 19/07/2018.
//

#import "ColoredVKColorPickerContainer.h"

@interface ColoredVKColorPickerContainer ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *savedCollectionViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *savedCollectionViewHeightConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *colorPreviewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *colorPreviewHeightConstraint;


@property (assign, nonatomic, readonly) CGSize savedCollectionViewItemSize;

@end

@implementation ColoredVKColorPickerContainer

+ (ColoredVKColorPickerContainer *)loadNib
{
    ColoredVKColorPickerContainer *container = nil;
    NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    
    NSArray *nibViews = [cvkBundle loadNibNamed:NSStringFromClass(self) owner:container options:nil];
    container = nibViews.firstObject;
    
    return container;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.colorMap.brightness = 1.0f;
    self.brightnessSlider.brightnessLowerLimit = @0;
    
    UIImage *plusImage = CVKImage(@"color_picker/SaveIcon");
    [self.saveColorButton setImage:plusImage forState:UIControlStateNormal];
    [self.saveColorButton setImage:plusImage forState:UIControlStateSelected];
    [self.saveColorButton setTitle:UIKitLocalizedString(@"Save") forState:UIControlStateNormal];
    [self.saveColorButton setTitleColor:[UIColor colorWithRed:90/255.0f green:130/255.0f blue:180/255.0f alpha:1.0] forState:UIControlStateNormal];
    
    self.savedTitleLabel.text = CVKLocalizedString(@"SAVED_COLORS");
    self.savedTitleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    self.savedTitleLabel.numberOfLines = 2;
    self.savedTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.savedTitleLabel.textColor = [UIColor darkGrayColor];
    self.savedTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.savedCollectionView.collectionViewLayout;
    collectionViewLayout.itemSize = self.savedCollectionViewItemSize;
    
    CGFloat collectionViewHeight = IS_IPAD ? 120 : 112.5;
    if ([UIScreen mainScreen].bounds.size.height == 480.0f) //    iPhone 4S
        collectionViewHeight = 95;
    
    [self setSavedCollectionViewHeight:collectionViewHeight];
    [self setColorPreviewSize:self.savedCollectionViewItemSize];
}

- (void)setSavedCollectionViewHeight:(CGFloat)height
{
    self.savedCollectionViewWidthConstraint.constant = height;
    self.savedCollectionViewHeightConstraint.constant = height;
}

- (void)setColorPreviewSize:(CGSize)size
{
    self.colorPreviewWidthConstraint.constant = size.width;
    self.colorPreviewHeightConstraint.constant = size.height;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.savedCollectionView.collectionViewLayout;
    collectionViewLayout.itemSize = self.savedCollectionViewItemSize;
    collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    if (!IS_IPAD && UIDeviceOrientationIsLandscape(orientation)) {
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        self.savedTitleLabel.font = [self.savedTitleLabel.font fontWithSize:16.0f];
        [self.saveColorButton setTitle:@"" forState:UIControlStateNormal];
        self.saveColorButton.titleEdgeInsets = UIEdgeInsetsZero;
    } else {
        self.savedTitleLabel.font = [self.savedTitleLabel.font fontWithSize:20.0f];
        
        self.saveColorButton.titleLabel.hidden = NO;
        [self.saveColorButton setTitle:UIKitLocalizedString(@"Save") forState:UIControlStateNormal];
        self.saveColorButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    }
    
    if (IS_IPAD || UIDeviceOrientationIsPortrait(orientation)) {
        self.mainStackView.axis = UILayoutConstraintAxisVertical;
        self.colorPreviewStackView.axis = UILayoutConstraintAxisHorizontal;
        
    }
    else if (!IS_IPAD && UIDeviceOrientationIsLandscape(orientation)) {
        self.mainStackView.axis = UILayoutConstraintAxisHorizontal;
        self.colorPreviewStackView.axis = UILayoutConstraintAxisVertical;
    }
}

- (CGSize)savedCollectionViewItemSize
{
    CGFloat screenScale = [UIScreen mainScreen].scale;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGSize collectionViewItemSize = CGSizeMake(120, 96);    //  for iPad
    if (!IS_IPAD) {
        collectionViewItemSize = CGSizeMake(90, 90);
        
        if (UIInterfaceOrientationIsLandscape(orientation) && (screenScale != 3.0f))
            collectionViewItemSize.height -= 10;
        
        
        if ([UIScreen mainScreen].bounds.size.height == 480.0f)
            collectionViewItemSize.height -= 10;
    }
    
    return collectionViewItemSize;
}

@end
