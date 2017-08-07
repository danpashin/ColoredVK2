//
//  ColoredVKColorPicker.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKColorPickerController.h"
#import "PrefixHeader.h"
#import "HRColorMapView.h"
#import "HRBrightnessSlider.h"
#import "ColoredVKColorPreview.h"
#import "ColoredVKColorCollectionViewCell.h"
#import "ColoredVKSimpleAlertController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "ColoredVKResponsiveButton.h"
#import "ColoredVKAlertController.h"

typedef NS_ENUM(NSUInteger, ColoredVKColorPickerState) {
    ColoredVKColorPickerStateDismiss = 1,
    ColoredVKColorPickerStateReset
};


@interface ColoredVKColorPickerController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, ColoredVKColorCollectionViewCellDelegate>

@property (strong, nonatomic) NSBundle *cvkBundle;
@property (strong, nonatomic) NSString *prefsPath;
@property (assign, nonatomic) ColoredVKColorPickerState state;
@property (assign, nonatomic) CGFloat brightness;
@property (strong, nonatomic) UIColor *customColor;
@property (strong, nonatomic) NSString *customHexColor;
@property (strong, nonatomic) NSMutableArray <NSString *> *savedColors;
@property (assign, nonatomic, readonly) CGSize savedCollectionViewItemSize;

@property (strong, nonatomic) ColoredVKColorPreview *infoView;
@property (strong, nonatomic) HRBrightnessSlider *sliderView;
@property (strong, nonatomic) HRColorMapView *colorMapView;
@property (strong, nonatomic) ColoredVKResponsiveButton *saveColorButton;
@property (strong, nonatomic) UILabel *savedColorsLabel;
@property (strong, nonatomic) UICollectionView *savedCollectionView;

@property (strong, nonatomic) UIView *colorMapContainer;
@property (strong, nonatomic) UIView *colorPreviewContainer;
@property (strong, nonatomic) UIView *savedColorsContainer;

@end


@implementation ColoredVKColorPickerController

+ (instancetype)pickerWithIdentifier:(NSString *)identifier
{
    return [[ColoredVKColorPickerController alloc] initWithIdentifier:identifier];
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSGenericException reason:[NSString stringWithFormat:@"%s is forbidden.", __FUNCTION__] userInfo:nil];
    return nil;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        
        self.customColor = [UIColor savedColorForIdentifier:self.identifier];
        if (self.customColor == nil)
            self.customColor = [UIColor clearColor];
        
        [self.customColor getHue:nil saturation:nil brightness:&_brightness alpha:nil];
        
        self.sliderView.color = self.customColor;
        self.infoView.color = self.customColor;
        self.colorMapView.color = self.customColor;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    self.prefsPath = CVK_PREFS_PATH;
    
    [self setupDefaultContentView];
    [self.contentView addSubview:self.contentViewNavigationBar];
    
    UINavigationItem *navItem = self.contentViewNavigationBar.items.firstObject;
    UIImage *resetImage = [[UIImage imageNamed:@"ResetIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:resetImage style:UIBarButtonItemStylePlain target:self action:@selector(actionResetColor)];
    
    
    
    self.colorMapContainer = [UIView new];
    self.colorMapContainer.frame = CGRectMake(0, CGRectGetMaxY(self.contentViewNavigationBar.frame), CGRectGetWidth(self.contentView.frame), CGRectGetWidth(self.contentView.frame)-60);
    [self.contentView addSubview:self.colorMapContainer];
    
    CGRect colorMapRect = CGRectMake(8, 8, CGRectGetWidth(self.colorMapContainer.frame) - 16, CGRectGetWidth(self.colorMapContainer.frame) - 60);
    
    self.colorMapView = [HRColorMapView colorMapWithFrame:colorMapRect saturationUpperLimit:0.9f];
    [self.colorMapView addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventValueChanged];
    self.colorMapView.tileSize = @1;
    self.colorMapView.brightness = 1;
    self.colorMapView.layer.masksToBounds = YES;
    self.colorMapView.layer.cornerRadius = 10;
    [self.colorMapContainer addSubview:self.colorMapView];
    
    self.sliderView = [HRBrightnessSlider new];
    self.sliderView.frame = CGRectMake(0, CGRectGetMaxY(self.colorMapView.frame), CGRectGetWidth(self.colorMapContainer.frame), 32);
    [self.sliderView addTarget:self action:@selector(setColorBrightness:) forControlEvents:UIControlEventValueChanged];
    self.sliderView.brightnessLowerLimit = @0;
    [self.colorMapContainer addSubview:self.sliderView];
    
    
    
    
    self.colorPreviewContainer = [UIView new];
    self.colorPreviewContainer.frame = CGRectMake(0, CGRectGetMaxY(self.colorMapContainer.frame), CGRectGetWidth(self.contentView.frame), 0);
    [self.contentView addSubview:self.colorPreviewContainer];
    
    self.infoView = [ColoredVKColorPreview new];
    [self.infoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionShowHexWindow)]];
    [self.colorPreviewContainer addSubview:self.infoView];
    
    self.saveColorButton = [ColoredVKResponsiveButton buttonWithType:UIButtonTypeCustom];
    self.saveColorButton.frame = CGRectMake(CGRectGetMaxX(self.infoView.frame) + 20, CGRectGetMinY(self.infoView.frame), CGRectGetWidth(self.colorPreviewContainer.frame)-(CGRectGetMaxX(self.infoView.frame) + 30), 32);
    UIImage *plusImage = [UIImage imageNamed:@"SaveIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
    [self.saveColorButton setImage:plusImage forState:UIControlStateNormal];
    [self.saveColorButton setImage:plusImage forState:UIControlStateSelected];
    [self.saveColorButton setTitle:UIKitLocalizedString(@"Save") forState:UIControlStateNormal];
    [self.saveColorButton setTitleColor:[UIColor colorWithRed:90/255.0f green:130/255.0f blue:180/255.0f alpha:1.0] forState:UIControlStateNormal];
    self.saveColorButton.cachedTitleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    self.saveColorButton.titleEdgeInsets = self.saveColorButton.cachedTitleEdgeInsets;
    [self.saveColorButton addTarget:self action:@selector(actionSaveColor) forControlEvents:UIControlEventTouchUpInside];
    [self.colorPreviewContainer addSubview:self.saveColorButton];
    
    
    
    self.savedColorsContainer = [UIView new];
    self.savedColorsContainer.frame = CGRectMake(0, CGRectGetMaxY(self.colorPreviewContainer.frame), CGRectGetWidth(self.contentView.frame), 126);
    [self.contentView addSubview:self.savedColorsContainer];
    
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
        [self.saveColorButton setTitle:self.saveColorButton.cachedTitle forState:UIControlStateNormal];
        self.saveColorButton.titleEdgeInsets = self.saveColorButton.cachedTitleEdgeInsets;
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
    [self.contentView removeConstraints:self.contentView.constraints];
    [self.colorMapContainer removeConstraints:self.colorMapContainer.constraints];
    [self.colorPreviewContainer removeConstraints:self.colorPreviewContainer.constraints];
    [self.savedColorsContainer removeConstraints:self.savedColorsContainer.constraints];
    
    self.contentViewNavigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[navBar]|" options:0 metrics:nil views:@{@"navBar":self.contentViewNavigationBar}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[navBar(44)]" options:0 metrics:nil views:@{@"navBar":self.contentViewNavigationBar}]];

    self.colorMapView.translatesAutoresizingMaskIntoConstraints = NO;
    self.sliderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.colorMapContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[colorMapView]-|" options:0 metrics:nil views:@{@"colorMapView":self.colorMapView}]];
    [self.colorMapContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sliderView]-|" options:0 metrics:nil views:@{@"sliderView":self.sliderView}]];
    [self.colorMapContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[colorMapView]-[sliderView(sliderViewHeight)]-|" options:0
                                                                                   metrics:@{@"sliderViewHeight":@16} 
                                                                                     views:@{@"colorMapView":self.colorMapView, @"sliderView":self.sliderView}]];
    CGFloat screenScale = [UIScreen mainScreen].scale;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
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
    
    self.colorMapContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.colorPreviewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.savedColorsContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.savedCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.savedColorsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.saveColorButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.infoView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *containers = @{@"colorMapContainer":self.colorMapContainer, @"colorPreviewContainer":self.colorPreviewContainer, @"savedColorsContainer":self.savedColorsContainer};
    
    if (IS_IPAD || UIDeviceOrientationIsPortrait(orientation)) {
        CGSize infoViewSize = self.savedCollectionViewItemSize;
        
        [self.colorPreviewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[infoView]-|" options:0 metrics:nil views:@{@"infoView":self.infoView}]];
        [self.colorPreviewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[saveColorButton]-|" options:0 metrics:nil views:@{@"saveColorButton":self.saveColorButton}]];
        [self.colorPreviewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[infoView(infoViewWidth)]-[saveColorButton]-|" options:0
                                                                                           metrics:@{@"infoViewWidth":@(infoViewSize.width)} 
                                                                                             views:@{@"infoView":self.infoView, @"saveColorButton":self.saveColorButton}]];
        
        [self.savedColorsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[savedColorsLabel]|" options:0 metrics:nil views:@{@"savedColorsLabel":self.savedColorsLabel}]];
        [self.savedColorsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[savedCollectionView]|" options:0 metrics:nil views:@{@"savedCollectionView":self.savedCollectionView}]];
        [self.savedColorsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[savedColorsLabel(savedLabelHeight)][savedCollectionView]|" options:0
                                                                                          metrics:@{@"savedLabelHeight":@(savedLabelHeight)} 
                                                                                            views:@{@"savedColorsLabel":self.savedColorsLabel, @"savedCollectionView":self.savedCollectionView}]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[container]|" options:0 metrics:nil views:@{@"container":self.colorMapContainer}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[container]|" options:0 metrics:nil views:@{@"container":self.colorPreviewContainer}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[container]|" options:0 metrics:nil views:@{@"container":self.savedColorsContainer}]];
        
        NSString *vertContainers = @"V:|-44-[colorMapContainer][colorPreviewContainer(colorPreviewContainerHeight)][savedColorsContainer(savedColorsContainerHeight)]|";
        NSDictionary *vertMetrics = @{@"colorPreviewContainerHeight":@(infoViewSize.height), @"savedColorsContainerHeight":@(collectionViewHeight + savedLabelHeight)};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vertContainers options:0 metrics:vertMetrics views:containers]];
    }
    else if (!IS_IPAD && UIDeviceOrientationIsLandscape(orientation)) {
        [self.colorPreviewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[infoView]-|" options:0 metrics:nil views:@{@"infoView":self.infoView}]];
        [self.colorPreviewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[saveColorButton]-|" options:0 metrics:nil views:@{@"saveColorButton":self.saveColorButton}]];
        [self.colorPreviewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[infoView(infoViewHeight)]-[saveColorButton]-|" options:0
                                                                                           metrics:@{@"infoViewHeight":@(infoViewHeight)} 
                                                                                             views:@{@"infoView":self.infoView, @"saveColorButton":self.saveColorButton}]];
        
        [self.savedColorsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[savedColorsLabel]|" options:0 metrics:nil views:@{@"savedColorsLabel":self.savedColorsLabel}]];
        [self.savedColorsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[savedCollectionView]|" options:0 metrics:nil views:@{@"savedCollectionView":self.savedCollectionView}]];
        [self.savedColorsContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[savedColorsLabel(savedColorsLabelHeight)][savedCollectionView]-|" options:0
                                                                                          metrics:@{@"savedColorsLabelHeight":@(savedLabelHeight * 2)} 
                                                                                            views:@{@"savedColorsLabel":self.savedColorsLabel, @"savedCollectionView":self.savedCollectionView}]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-44-[container]|" options:0 metrics:nil views:@{@"container":self.colorMapContainer}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-44-[container]|" options:0 metrics:nil views:@{@"container":self.colorPreviewContainer}]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-44-[container]|" options:0 metrics:nil views:@{@"container":self.savedColorsContainer}]];
        
        NSString *horizontalContainers = @"H:|[colorMapContainer][colorPreviewContainer(colorPreviewContainerWidth)][savedColorsContainer(savedColorsContainerWidth)]|";
        NSDictionary *horizontalMetrics = @{@"colorPreviewContainerWidth":@(infoViewHeight), @"savedColorsContainerWidth":@(collectionViewHeight)};
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:horizontalContainers options:0 metrics:horizontalMetrics views:containers]];
    }
}

- (void)updateSavedColorsFromPrefs
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.savedColors = [NSMutableArray array];
        if ([self.dataSource respondsToSelector:@selector(savedColorsForColorPicker:)]) {
            [self.savedCollectionView performBatchUpdates:^{
                NSArray <NSString *> *savedColors = [self.dataSource savedColorsForColorPicker:self];
                
                int collectionViewInsertIndex = 0;
                for (int i=(int)savedColors.count-1; i>=0; i--) {
                    
                    [self.savedColors addObject:savedColors[i]];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:collectionViewInsertIndex inSection:0];
                    [self.savedCollectionView insertItemsAtIndexPaths:@[indexPath]];
                    collectionViewInsertIndex++;
                }
                [self.savedCollectionView reloadData];
            } completion:nil];
        }
    });
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
    
    self.customHexColor = self.customColor.hexStringValue;
}

- (void)setColorBrightness:(HRBrightnessSlider *)brightnessSlider
{
    self.brightness = brightnessSlider.brightness.floatValue;
    [self updateColorsFromPicker:YES];
}

- (CGSize)savedCollectionViewItemSize
{
    CGFloat screenScale = [UIScreen mainScreen].scale;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    CGSize collectionViewItemSize = CGSizeMake(120, 96);    //  for iPad
    if (!IS_IPAD) {        
        if (screenScale == 3.0f) collectionViewItemSize = CGSizeMake(90, 90);   //  for 3x scale devices
        else                     collectionViewItemSize = CGSizeMake(70, 90);   //  for other devices
        
        if (UIDeviceOrientationIsLandscape(orientation) && (screenScale != 3.0f))
            collectionViewItemSize.height -= 10;
        
               
        if ([UIScreen mainScreen].bounds.size.height == 480.0f)
            collectionViewItemSize.height -= 10;
    }
    
    return collectionViewItemSize;
}

- (void)hide
{
    if (!self.state) self.state = ColoredVKColorPickerStateDismiss;
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
    ColoredVKSimpleAlertController *hexWindow = [ColoredVKSimpleAlertController new];
    hexWindow.textField.placeholder = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"EXAMPLE_ALERT_MESSAGE", nil, self.cvkBundle, nil), self.customColor.hexStringValue];
    hexWindow.textField.delegate = self;
    NSString *buttonTitle = NSLocalizedStringFromTableInBundle(@"COPY_SAVED", nil, self.cvkBundle, nil);
    [hexWindow.button setTitle:buttonTitle forState:UIControlStateNormal];
    [hexWindow.button addTarget:self action:@selector(actionCopySavedHex) forControlEvents:UIControlEventTouchUpInside];
    [hexWindow.button setBackgroundImage:nil forState:UIControlStateNormal];
    [hexWindow.button setBackgroundImage:nil forState:UIControlStateHighlighted];
    UIColor *titleColor = [UIColor colorWithRed:90/255.0f green:130/255.0f blue:180/255.0f alpha:1.0f];
    [hexWindow.button setTitleColor:titleColor forState:UIControlStateNormal];
    [hexWindow.button setTitleColor:titleColor.darkerColor forState:UIControlStateHighlighted];
    
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
    [UIPasteboard generalPasteboard].string = [UIColor savedColorForIdentifier:self.identifier].hexStringValue;
}

- (void)actionSaveColor
{    
    [self.savedCollectionView performBatchUpdates:^{
        if (![self.savedColors containsObject:self.customHexColor]) {
            [self.savedColors insertObject:self.customHexColor atIndex:0];
        
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.savedCollectionView insertItemsAtIndexPaths:@[indexPath]];
            
            if ([self.delegate respondsToSelector:@selector(colorPicker:didSaveColor:)])
                [self.delegate colorPicker:self didSaveColor:self.customHexColor];
            
            [self.savedCollectionView reloadData];
        }
    } completion:nil];
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
    
    self.customColor = self.savedColors[indexPath.row].hexColorValue;
    
    [self updateColorsFromPicker:NO];
}


#pragma mark - ColoredVKColorCollectionViewCellDelegate

- (void)colorCell:(ColoredVKColorCollectionViewCell *)cell deleteColor:(NSString *)hexColor
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.savedCollectionView performBatchUpdates:^{
            if ([self.savedColors containsObject:hexColor]) {
                NSUInteger index = [self.savedColors indexOfObject:hexColor];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                
                [self.savedColors removeObject:hexColor];
                [self.savedCollectionView deleteItemsAtIndexPaths:@[indexPath]];
                
                if ([self.delegate respondsToSelector:@selector(colorPicker:didDeleteColor:)])
                    [self.delegate colorPicker:self didDeleteColor:hexColor];
                
                [self.savedCollectionView reloadData];
            }
        } completion:nil];
    });
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!textField.text.hexColor) {
            textField.layer.borderColor = [UIColor colorWithRed:0.8 green:0 blue:0 alpha:1.0].CGColor;
        } else {
            textField.layer.borderColor = [UIColor clearColor].CGColor;
            
            self.customColor = textField.text.hexColorValue;
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
    return [UIImage imageNamed:@"WindowsIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = NSLocalizedStringFromTableInBundle(@"OH_YOU_HAVE_NOT_SAVED_COLORS", nil, self.cvkBundle, nil);
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

@end
