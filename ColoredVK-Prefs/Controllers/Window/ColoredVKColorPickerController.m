//
//  ColoredVKColorPicker.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKColorPickerController.h"
#import "ColoredVKColorMapView.h"
#import "HRBrightnessSlider.h"
#import "ColoredVKColorPreview.h"
#import "ColoredVKColorCollectionViewCell.h"
#import "ColoredVKSimpleAlertController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "ColoredVKAlertController.h"

#import "UIColor+ColoredVK.h"
#import "NSString+ColoredVK.h"

typedef NS_ENUM(NSUInteger, ColoredVKColorPickerState) {
    ColoredVKColorPickerStateDismiss = 1,
    ColoredVKColorPickerStateReset
};


@interface ColoredVKColorPickerController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, ColoredVKColorCollectionViewCellDelegate>

@property (strong, nonatomic, readonly) NSBundle *cvkBundle;
@property (assign, nonatomic) ColoredVKColorPickerState state;
@property (assign, nonatomic) CGFloat brightness;
@property (strong, nonatomic) UIColor *customColor;
@property (strong, nonatomic) NSString *customHexColor;
@property (strong, nonatomic) NSMutableArray <NSString *> *savedColors;
@property (assign, nonatomic, readonly) CGSize savedCollectionViewItemSize;

@property (strong, nonatomic) ColoredVKColorPreview *infoView;
@property (strong, nonatomic) HRBrightnessSlider *sliderView;
@property (strong, nonatomic) ColoredVKColorMapView *colorMapView;
@property (strong, nonatomic) UIButton *saveColorButton;
@property (strong, nonatomic) UILabel *savedColorsLabel;
@property (strong, nonatomic) UICollectionView *savedCollectionView;

@property (strong, nonatomic) UIView *colorMapContainer;
@property (strong, nonatomic) UIView *colorPreviewContainer;
@property (strong, nonatomic) UIView *savedColorsContainer;

@property (strong, nonatomic) UIStackView *stackView;
@property (strong, nonatomic) UIView *stackContainerView;

@property (assign, nonatomic) UIEdgeInsets saveButtonLabelInsets;

@end

@interface HRColorMapView ()
@property (atomic, strong) CALayer *colorMapLayer; // brightness 1.0
@property (atomic, strong) CALayer *colorMapBackgroundLayer; // brightness 0 (= black)

@end


@implementation ColoredVKColorPickerController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithIdentifier:@""];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithIdentifier:@""];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _identifier = identifier;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backgroundStyle = ColoredVKWindowBackgroundStyleCustom;
    self.backgroundView = [UIView new];
    
    _cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    
    [self setupDefaultContentView];
    [self.contentView addSubview:self.contentViewNavigationBar];
    
    UINavigationItem *navItem = self.contentViewNavigationBar.items.firstObject;
    UIImage *resetImage = [[UIImage imageNamed:@"color_picker/ResetIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:resetImage style:UIBarButtonItemStylePlain target:self action:@selector(actionResetColor)];
    navItem.leftBarButtonItem.accessibilityLabel = CVKLocalizedStringFromTableInBundle(@"RESET_COLOR", nil, self.cvkBundle);
    
    
    self.stackContainerView = [UIView new];
    self.stackContainerView.frame = CGRectMake(8, CGRectGetMaxY(self.contentViewNavigationBar.frame), CGRectGetWidth(self.contentView.frame)-16.0f, CGRectGetHeight(self.contentView.frame) - 64);
    [self.contentView addSubview:self.stackContainerView];
    
    self.stackView = [[UIStackView alloc] initWithArrangedSubviews:@[]];
    self.stackView.frame = CGRectMake(8, CGRectGetMaxY(self.contentViewNavigationBar.frame), CGRectGetWidth(self.contentView.frame)-16.0f, CGRectGetHeight(self.contentView.frame) - 64);
    self.stackView.axis = UILayoutConstraintAxisVertical;
    self.stackView.spacing = 8.0f;
    self.stackView.alignment = UIStackViewAlignmentFill;
    self.stackView.distribution = UIStackViewDistributionFill;
    [self.stackContainerView addSubview:self.stackView];
    
    
    
    self.colorMapContainer = [UIView new];
    [self.stackView addArrangedSubview:self.colorMapContainer];
    
    CGRect colorMapRect = CGRectMake(0, 0, CGRectGetWidth(self.stackView.frame), CGRectGetWidth(self.stackView.frame));
    
    self.colorMapView = [[ColoredVKColorMapView alloc] initWithFrame:colorMapRect saturationUpperLimit:0.9f];
    [self.colorMapView addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventValueChanged];
    self.colorMapView.tileSize = @1;
    self.colorMapView.brightness = 1;
    self.colorMapView.layer.masksToBounds = YES;
    self.colorMapView.layer.cornerRadius = 15;
    [self.colorMapContainer addSubview:self.colorMapView];
    
    self.sliderView = [HRBrightnessSlider new];
    self.sliderView.frame = CGRectMake(0, CGRectGetMaxY(self.colorMapView.frame), CGRectGetWidth(self.stackView.frame), 32);
    [self.sliderView addTarget:self action:@selector(setColorBrightness:) forControlEvents:UIControlEventValueChanged];
    self.sliderView.brightnessLowerLimit = @0;
    [self.colorMapContainer addSubview:self.sliderView];
    
    
    
    
    self.colorPreviewContainer = [UIView new];
    [self.stackView addArrangedSubview:self.colorPreviewContainer];
    
    self.infoView = [ColoredVKColorPreview new];
    self.infoView.frame = CGRectMake(0, 0, 70, 70);
    [self.infoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionShowHexWindow)]];
    [self.colorPreviewContainer addSubview:self.infoView];
    
    self.saveColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveColorButton.frame = CGRectMake(CGRectGetMaxX(self.infoView.frame) + 20, CGRectGetMinY(self.infoView.frame), CGRectGetWidth(self.colorPreviewContainer.frame)-(CGRectGetMaxX(self.infoView.frame) + 30), 32);
    UIImage *plusImage = [UIImage imageNamed:@"color_picker/SaveIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
    [self.saveColorButton setImage:plusImage forState:UIControlStateNormal];
    [self.saveColorButton setImage:plusImage forState:UIControlStateSelected];
    [self.saveColorButton setTitle:UIKitLocalizedString(@"Save") forState:UIControlStateNormal];
    [self.saveColorButton setTitleColor:[UIColor colorWithRed:90/255.0f green:130/255.0f blue:180/255.0f alpha:1.0] forState:UIControlStateNormal];
    self.saveButtonLabelInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    self.saveColorButton.titleEdgeInsets = self.saveButtonLabelInsets;
    [self.saveColorButton addTarget:self action:@selector(actionSaveColor) forControlEvents:UIControlEventTouchUpInside];
    [self.colorPreviewContainer addSubview:self.saveColorButton];
    
    
    
    self.savedColorsContainer = [UIView new];
    [self.stackView addArrangedSubview:self.savedColorsContainer];
    
    self.savedColorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, CGRectGetWidth(self.savedColorsContainer.frame) - 16, 26)];
    self.savedColorsLabel.text = NSLocalizedStringFromTableInBundle(@"SAVED_COLORS", nil, self.cvkBundle, nil);
    self.savedColorsLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    self.savedColorsLabel.numberOfLines = 2;
    self.savedColorsLabel.textAlignment = NSTextAlignmentCenter;
    self.savedColorsLabel.textColor = [UIColor darkGrayColor];
    self.savedColorsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.savedColorsContainer addSubview:self.savedColorsLabel];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    layout.minimumLineSpacing = 10;
    layout.itemSize = self.savedCollectionViewItemSize;
    
    self.savedCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.savedColorsLabel.frame) + 8, CGRectGetWidth(self.savedColorsContainer.frame), 100) 
                                                  collectionViewLayout:layout];
    self.savedCollectionView.backgroundColor = [UIColor clearColor];
    self.savedCollectionView.pagingEnabled = YES;
    self.savedCollectionView.showsHorizontalScrollIndicator = NO;
    self.savedCollectionView.showsVerticalScrollIndicator = NO;
    [self.savedCollectionView registerClass:[ColoredVKColorCollectionViewCell class] forCellWithReuseIdentifier:@"colorCell"];
    self.savedCollectionView.delegate = self;
    self.savedCollectionView.dataSource = self;
    self.savedCollectionView.emptyDataSetSource = self;
    self.savedCollectionView.emptyDataSetDelegate = self;
    [self.savedColorsContainer addSubview:self.savedCollectionView];
    
    
    self.customColor = [UIColor cvk_savedColorForIdentifier:self.identifier];
    if (self.customColor == nil)
        self.customColor = [UIColor clearColor];
    
    [self.customColor getHue:nil saturation:nil brightness:&_brightness alpha:nil];
    
    self.sliderView.color = self.customColor;
    self.infoView.color = self.customColor;
    self.colorMapView.color = self.customColor;
    
    [self updateSavedColorsFromPrefs];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)self.savedCollectionView.collectionViewLayout;
    collectionViewLayout.itemSize = self.savedCollectionViewItemSize;
    collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    if (!IS_IPAD && UIDeviceOrientationIsLandscape(orientation)) {
        collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        self.savedColorsLabel.font = [self.savedColorsLabel.font fontWithSize:16.0f];
        [self.saveColorButton setTitle:@"" forState:UIControlStateNormal];
        self.saveColorButton.titleEdgeInsets = UIEdgeInsetsZero;
    } else {
        self.saveColorButton.titleLabel.hidden = NO;
        [self.saveColorButton setTitle:UIKitLocalizedString(@"Save") forState:UIControlStateNormal];
        self.saveColorButton.titleEdgeInsets = self.saveButtonLabelInsets;
        self.savedColorsLabel.font = [self.savedColorsLabel.font fontWithSize:20.0f];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self setupConstraints];
    
    if (self.contentViewWantsShadow) {
        self.contentView.layer.shadowRadius = IS_IPAD ? 15.0f : 8.0f;
        self.contentView.layer.shadowOpacity = IS_IPAD ? 0.15f : 0.3f;
        self.contentView.layer.shadowOffset = CGSizeZero;
    }
}

- (void)setupConstraints
{
    if (!self.stackContainerView.superview)
        return;
    
    [self.colorMapContainer removeConstraints:self.colorMapContainer.constraints];
    [self.colorPreviewContainer removeConstraints:self.colorPreviewContainer.constraints];
    [self.savedColorsContainer removeConstraints:self.savedColorsContainer.constraints];
    
    self.contentViewNavigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.stackContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[stackContainer]-|" options:0 metrics:nil views:@{@"stackContainer":self.stackContainerView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[navBar]|" options:0 metrics:nil views:@{@"navBar":self.contentViewNavigationBar}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[navBar(44)][stackContainer]-|" options:0 metrics:nil 
                                                                               views:@{@"navBar":self.contentViewNavigationBar, @"stackContainer":self.stackContainerView}]];
    
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stackContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[stackView]|" options:0 metrics:nil views:@{@"stackView":self.stackView}]];
    [self.stackContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[stackView]|" options:0 metrics:nil views:@{@"stackView":self.stackView}]];
    
    self.colorMapView.translatesAutoresizingMaskIntoConstraints = NO;
    self.sliderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.colorMapContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[colorMapView]|" options:0 metrics:nil views:@{@"colorMapView":self.colorMapView}]];
    [self.colorMapContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[sliderView]|" options:0 metrics:nil views:@{@"sliderView":self.sliderView}]];
    [self.colorMapContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[colorMapView]-[sliderView(16)]|" options:0
                                                                                   metrics:nil views:@{@"colorMapView":self.colorMapView, @"sliderView":self.sliderView}]];
    
    CGFloat screenScale = [UIScreen mainScreen].scale;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGFloat infoViewHeight = IS_IPAD ? 120 : 85;
    if (screenScale == 3.0f)
        infoViewHeight = 100;
    
    CGFloat savedLabelHeight = 26;
    CGFloat collectionViewHeight = IS_IPAD ? infoViewHeight : 112.5;
    
        //    
        //    iPhone 4S
        //    
    if ([UIScreen mainScreen].bounds.size.height == 480.0f)
        collectionViewHeight = 95;
    
    self.colorPreviewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.infoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.saveColorButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.savedColorsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.savedColorsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.savedCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (IS_IPAD || UIInterfaceOrientationIsPortrait(orientation)) {
        CGSize infoViewSize = self.savedCollectionViewItemSize;
        
        self.stackView.axis = UILayoutConstraintAxisVertical;
        [self.colorPreviewContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.colorPreviewContainer attribute:NSLayoutAttributeHeight 
                                                                               relatedBy:0 toItem:nil attribute:0 multiplier:1.0f constant:infoViewSize.height]];
        
        [self.colorPreviewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[infoView]|" options:0 metrics:nil views:@{@"infoView":self.infoView}]];
        [self.colorPreviewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[saveColorButton]|" options:0 metrics:nil views:@{@"saveColorButton":self.saveColorButton}]];
        [self.colorPreviewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[infoView(infoViewWidth)]-[saveColorButton]|" options:0
                                                                                           metrics:@{@"infoViewWidth":@(infoViewSize.width + 5.0f)} 
                                                                                             views:@{@"infoView":self.infoView, @"saveColorButton":self.saveColorButton}]];
        
        [self.savedColorsContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.savedColorsContainer attribute:NSLayoutAttributeHeight 
                                                                              relatedBy:0 toItem:nil attribute:0 multiplier:1.0f constant:collectionViewHeight+16.0f]];
        
        [self.savedColorsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[savedColorsLabel]|" options:0 metrics:nil views:@{@"savedColorsLabel":self.savedColorsLabel}]];
        [self.savedColorsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[savedCollectionView]|" options:0 metrics:nil views:@{@"savedCollectionView":self.savedCollectionView}]];
        [self.savedColorsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[savedColorsLabel(savedLabelHeight)][savedCollectionView]|" options:0
                                                                                          metrics:@{@"savedLabelHeight":@(savedLabelHeight)} 
                                                                                            views:@{@"savedColorsLabel":self.savedColorsLabel, @"savedCollectionView":self.savedCollectionView}]];
    }
    else if (!IS_IPAD && UIInterfaceOrientationIsLandscape(orientation)) {
        self.stackView.axis = UILayoutConstraintAxisHorizontal;
        
        [self.colorPreviewContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.colorPreviewContainer attribute:NSLayoutAttributeWidth 
                                                                               relatedBy:0 toItem:nil attribute:0 multiplier:1.0f constant:infoViewHeight]];
        
        [self.colorPreviewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[infoView]|" options:0 metrics:nil views:@{@"infoView":self.infoView}]];
        [self.colorPreviewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[saveColorButton]|" options:0 metrics:nil views:@{@"saveColorButton":self.saveColorButton}]];
        [self.colorPreviewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[infoView(infoViewHeight)]-[saveColorButton]|" options:0
                                                                                           metrics:@{@"infoViewHeight":@(infoViewHeight)} 
                                                                                             views:@{@"infoView":self.infoView, @"saveColorButton":self.saveColorButton}]];
        
        [self.savedColorsContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.savedColorsContainer attribute:NSLayoutAttributeWidth 
                                                                              relatedBy:0 toItem:nil attribute:0 multiplier:1.0f constant:collectionViewHeight]];
        
        [self.savedColorsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[savedColorsLabel]|" options:0 metrics:nil views:@{@"savedColorsLabel":self.savedColorsLabel}]];
        [self.savedColorsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[savedCollectionView]|" options:0 metrics:nil views:@{@"savedCollectionView":self.savedCollectionView}]];
        [self.savedColorsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[savedColorsLabel(savedColorsLabelHeight)][savedCollectionView]|" options:0
                                                                                          metrics:@{@"savedColorsLabelHeight":@(savedLabelHeight * 2)} 
                                                                                            views:@{@"savedColorsLabel":self.savedColorsLabel, @"savedCollectionView":self.savedCollectionView}]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.colorMapView.colorMapLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.colorMapView.frame), CGRectGetHeight(self.colorMapView.frame));
        self.colorMapView.colorMapBackgroundLayer.frame = self.colorMapView.colorMapLayer.frame;
    });
}

- (void)updateSavedColorsFromPrefs
{
    self.savedColors = [NSMutableArray array];
    if ([self.dataSource respondsToSelector:@selector(savedColorsForColorPicker:)]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray <NSString *> *savedColors = [self.dataSource savedColorsForColorPicker:self];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.savedCollectionView performBatchUpdates:^{
                    [[savedColors reverseObjectEnumerator].allObjects enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [self.savedColors addObject:obj];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                        [self.savedCollectionView insertItemsAtIndexPaths:@[indexPath]];
                    }];
                    
                    [self.savedCollectionView reloadData];
                } completion:nil];
            });
        });
    } 
}


- (void)updateColorsFromPicker:(BOOL)fromPicker
{
    CGFloat hue, saturation, brightness;
    [self.customColor getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
    self.customColor = [UIColor colorWithHue:hue saturation:saturation brightness:fromPicker?self.brightness:brightness alpha:1];
    self.infoView.color = self.customColor;
    self.sliderView.color = self.customColor;
    self.colorMapView.color = self.customColor;
}

- (void)setColor:(HRColorMapView *)colorMap
{
    self.customColor = colorMap.color;
    [self updateColorsFromPicker:YES];
}

- (void)setCustomColor:(UIColor *)customColor
{
    _customColor = customColor;
    
    self.customHexColor = self.customColor.cvk_hexStringValue;
}

- (void)setColorBrightness:(HRBrightnessSlider *)brightnessSlider
{
    self.brightness = brightnessSlider.brightness.floatValue;
    [self updateColorsFromPicker:YES];
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

- (void)hide
{
    if (!self.state)
        self.state = ColoredVKColorPickerStateDismiss;
    
    if ([self.delegate respondsToSelector:@selector(colorPicker:willDismissWithColor:)]) {
        UIColor *color = (self.state == ColoredVKColorPickerStateDismiss) ? self.customColor : nil;
        [self.delegate colorPicker:self willDismissWithColor:color];
    }
    
    self.backgroundView.backgroundColor = [UIColor clearColor];
    [super hide];
}

#pragma mark - Actions

- (void)actionResetColor
{
    ColoredVKAlertController *warningAlert = [ColoredVKAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"WARNING", nil, self.cvkBundle, nil)  
                                                                                        message:NSLocalizedStringFromTableInBundle(@"RESET_COLOR_QUESTION", nil, self.cvkBundle, nil) 
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        self.state = ColoredVKColorPickerStateReset;
        [self hide];
    }]];
    [warningAlert presentFromController:self];
}

- (void)actionShowHexWindow
{
    ColoredVKSimpleAlertController *hexWindow = [[ColoredVKSimpleAlertController alloc] init];
    hexWindow.textField.placeholder = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"EXAMPLE_ALERT_MESSAGE", nil, self.cvkBundle, nil), self.customColor.cvk_hexStringValue];
    hexWindow.textField.delegate = self;
    NSString *buttonTitle = NSLocalizedStringFromTableInBundle(@"COPY_SAVED", nil, self.cvkBundle, nil);
    [hexWindow.button setTitle:buttonTitle forState:UIControlStateNormal];
    [hexWindow.button addTarget:self action:@selector(actionCopySavedHex) forControlEvents:UIControlEventTouchUpInside];
    [hexWindow.button setBackgroundImage:nil forState:UIControlStateNormal];
    [hexWindow.button setBackgroundImage:nil forState:UIControlStateHighlighted];
    UIColor *titleColor = [UIColor colorWithRed:90/255.0f green:130/255.0f blue:180/255.0f alpha:1.0f];
    [hexWindow.button setTitleColor:titleColor forState:UIControlStateNormal];
    [hexWindow.button setTitleColor:titleColor.cvk_darkerColor forState:UIControlStateHighlighted];
    
    NSString *locString = NSLocalizedStringFromTableInBundle(@"ENTER_HEXEDECIMAL_COLOR_CODE_ALERT_MESSAGE", nil, self.cvkBundle, nil);
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:locString];
    
    NSRange rangeBefore = NSMakeRange(0, [locString substringToIndex:[locString rangeOfString:@"("].location].length );
    NSRange rangeAfter = NSMakeRange([locString rangeOfString:@"("].location, [locString substringFromIndex:[locString rangeOfString:@"("].location].length );
    
    [attributedText setAttributes:@{ NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0], NSForegroundColorAttributeName:[UIColor darkGrayColor]} range:rangeBefore];
    [attributedText setAttributes:@{ NSFontAttributeName:[UIFont preferredFontForTextStyle:UIFontTextStyleFootnote], NSForegroundColorAttributeName:[UIColor lightGrayColor] } range:rangeAfter];
    hexWindow.titleLabel.attributedText = attributedText;
    
    if (IS_IPAD)
        hexWindow.prefferedWidth = CGRectGetWidth(self.contentView.frame) - 60;
    
    [hexWindow show];
}

- (void)actionCopySavedHex
{
    UIColor *savedColor = [UIColor cvk_savedColorForIdentifier:self.identifier];
    if (savedColor)
        [UIPasteboard generalPasteboard].string = savedColor.cvk_hexStringValue;
}

- (void)actionSaveColor
{
    if (![self.savedColors containsObject:self.customHexColor]) {
        [self.savedColors insertObject:self.customHexColor atIndex:0];
        
        [self.savedCollectionView performBatchUpdates:^{
            [self.savedCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
            [self.savedCollectionView reloadData];
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(colorPicker:didSaveColor:)])
                [self.delegate colorPicker:self didSaveColor:self.customHexColor];
        }];
    }
}



#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.savedColors.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ColoredVKColorCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"colorCell" forIndexPath:indexPath];
    cell.hexColor = self.savedColors[indexPath.row];
    cell.delegate = self;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return ((UICollectionViewFlowLayout *)collectionViewLayout).itemSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    self.customColor = self.savedColors[indexPath.row].cvk_hexColorValue;
    
    [self updateColorsFromPicker:NO];
}


#pragma mark - ColoredVKColorCollectionViewCellDelegate

- (void)colorCell:(ColoredVKColorCollectionViewCell *)cell deleteColor:(NSString *)hexColor
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.savedColors containsObject:hexColor]) {
            [self.savedCollectionView performBatchUpdates:^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.savedColors indexOfObject:hexColor] inSection:0];
                [self.savedColors removeObject:hexColor];
                [self.savedCollectionView deleteItemsAtIndexPaths:@[indexPath]];
                [self.savedCollectionView reloadData];
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(colorPicker:didDeleteColor:)])
                    [self.delegate colorPicker:self didDeleteColor:hexColor];
            }];
        }
    });
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!textField.text.cvk_hexColor) {
            textField.layer.borderColor = [UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1.0f].CGColor;
        } else {
            textField.layer.borderColor = [UIColor clearColor].CGColor;
            
            self.customColor = textField.text.cvk_hexColorValue;
            [self updateColorsFromPicker:NO];
        }
    });
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - DZNEmptyDataSetDelegate

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"color_picker/WindowsIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = NSLocalizedStringFromTableInBundle(@"OH_YOU_HAVE_NOT_SAVED_COLORS", nil, self.cvkBundle, nil);
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

@end