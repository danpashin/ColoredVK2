//
//  ColoredVKColorPickerContainer.h
//  ColoredVK2
//
//  Created by Даниил on 19/07/2018.
//

#import <UIKit/UIKit.h>

#import "ColoredVKColorMapView.h"
#import "ColoredVKColorPreview.h"
#import "HRBrightnessSlider.h"


NS_ASSUME_NONNULL_BEGIN
@interface ColoredVKColorPickerContainer : UIView

+ (ColoredVKColorPickerContainer *)loadNib;

@property (strong, nonatomic) IBOutlet UIStackView *mainStackView;

@property (strong, nonatomic) IBOutlet UIStackView *colorMapStackView;
@property (strong, nonatomic) IBOutlet ColoredVKColorMapView *colorMap;
@property (strong, nonatomic) IBOutlet HRBrightnessSlider *brightnessSlider;

@property (strong, nonatomic) IBOutlet UIStackView *colorPreviewStackView;
@property (strong, nonatomic) IBOutlet ColoredVKColorPreview *colorPreview;
@property (strong, nonatomic) IBOutlet UIButton *saveColorButton;

@property (strong, nonatomic) IBOutlet UIStackView *savedStackView;
@property (strong, nonatomic) IBOutlet UILabel *savedTitleLabel;
@property (strong, nonatomic) IBOutlet UICollectionView *savedCollectionView;


- (void)setSavedCollectionViewHeight:(CGFloat)height;

- (void)setColorPreviewSize:(CGSize)size;

@end
NS_ASSUME_NONNULL_END
