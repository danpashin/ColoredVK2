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

@interface ColoredVKColorPickerController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, ColoredVKColorCollectionViewCellDelegate>

@property (strong, nonatomic) NSBundle *cvkBundle;
@property (strong, nonatomic) NSString *prefsPath;
@property (assign, nonatomic) ColoredVKColorPickerState state;
@property (assign, nonatomic) CGFloat brightness;
@property (strong, nonatomic) UIColor *customColor;
@property (strong, nonatomic) NSString *customHexColor;
@property (strong, nonatomic) NSMutableArray <NSString *> *savedColors;

@property (strong, nonatomic) ColoredVKColorPreview *infoView;
@property (strong, nonatomic) HRBrightnessSlider *sliderView;
@property (strong, nonatomic) HRColorMapView *colorMapView;
@property (strong, nonatomic) UIButton *saveColorButton;
@property (strong, nonatomic) UILabel *savedColorsLabel;
@property (strong, nonatomic) UICollectionView *savedCollectionView;

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
    
    CGRect colorMapRect = CGRectMake(10, CGRectGetMaxY(self.contentViewNavigationBar.frame), CGRectGetWidth(self.contentView.frame)-20, CGRectGetWidth(self.contentView.frame)-60);
    
    self.colorMapView = [HRColorMapView colorMapWithFrame:colorMapRect saturationUpperLimit:0.9f];
    [self.colorMapView addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventValueChanged];
    self.colorMapView.tileSize = @1;
    self.colorMapView.brightness = 1;
    self.colorMapView.layer.masksToBounds = YES;
    self.colorMapView.layer.cornerRadius = self.contentView.layer.cornerRadius/2;
    [self.contentView addSubview:self.colorMapView];
    
    self.sliderView = [HRBrightnessSlider new];
    self.sliderView.frame = CGRectMake(0, CGRectGetMaxY(self.colorMapView.frame), CGRectGetWidth(self.contentView.frame), 32);
    [self.sliderView addTarget:self action:@selector(setColorBrightness:) forControlEvents:UIControlEventValueChanged];
    self.sliderView.brightnessLowerLimit = @0;
    [self.contentView addSubview:self.sliderView];
    
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGFloat infoViewWidth = IS_IPAD ? 60 * scale: 45 * scale;
    CGFloat infoViewHeight = IS_IPAD ? 50 * scale : 35 * scale;
    
    self.infoView = [ColoredVKColorPreview new];
    self.infoView.frame = CGRectMake(10, CGRectGetMaxY(self.sliderView.frame) + 10, infoViewWidth, infoViewHeight);
    [self.infoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionShowHexWindow)]];
    [self.contentView addSubview:self.infoView];
    
    
    self.saveColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveColorButton.frame = CGRectMake(CGRectGetMaxX(self.infoView.frame) + 20, CGRectGetMinY(self.infoView.frame), CGRectGetWidth(self.contentView.frame)-(CGRectGetMaxX(self.infoView.frame) + 30), 32);
    [self.saveColorButton setImage:[UIImage imageNamed:@"SaveIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [self.saveColorButton setTitle:UIKitLocalizedString(@"Save") forState:UIControlStateNormal];
    [self.saveColorButton setTitleColor:[UIColor colorWithRed:90/255.0f green:130/255.0f blue:180/255.0f alpha:1.0] forState:UIControlStateNormal];
    self.saveColorButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
    [self.saveColorButton addTarget:self action:@selector(actionSaveColor) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.saveColorButton];
    
    
    self.savedColorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.infoView.frame) + 10, CGRectGetWidth(self.contentView.frame) - 20, 26)];
    self.savedColorsLabel.text = NSLocalizedStringFromTableInBundle(@"SAVED_COLORS", nil, self.cvkBundle, nil);
    self.savedColorsLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    self.savedColorsLabel.textAlignment = NSTextAlignmentCenter;
    self.savedColorsLabel.textColor = [UIColor darkGrayColor];
    [self.contentView addSubview:self.savedColorsLabel];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 0);
    layout.minimumLineSpacing = 10;
    
    self.savedCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.savedColorsLabel.frame) + 10, CGRectGetWidth(self.contentView.frame), 100) collectionViewLayout:layout];
    self.savedCollectionView.backgroundColor = [UIColor clearColor];
    self.savedCollectionView.pagingEnabled = YES;
    self.savedCollectionView.showsHorizontalScrollIndicator = NO;
    [self.savedCollectionView registerClass:[ColoredVKColorCollectionViewCell class] forCellWithReuseIdentifier:@"colorCell"];
    self.savedCollectionView.delegate = self;
    self.savedCollectionView.dataSource = self;
    self.savedCollectionView.emptyDataSetSource = self;
    self.savedCollectionView.emptyDataSetDelegate = self;
    [self.contentView addSubview:self.savedCollectionView];
    

    [self updateSavedColorsFromPrefs];
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
    
    self.contentViewNavigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[navBar]|" options:0 metrics:nil views:@{@"navBar":self.contentViewNavigationBar}]];
    
    self.colorMapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[colorMapView]-|" options:0 metrics:nil views:@{@"colorMapView":self.colorMapView}]];
    
    self.sliderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sliderView]-|" options:0 metrics:nil views:@{@"sliderView":self.sliderView}]];
    
    self.infoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[infoView(width)]" options:0 metrics:@{@"width":@(CGRectGetWidth(self.infoView.frame))} views:@{@"infoView":self.infoView}]];
    
    self.savedColorsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[savedLabel]-|" options:0 metrics:nil views:@{@"savedLabel":self.savedColorsLabel}]];
    
    self.savedCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[savedCollectionView]|" options:0 metrics:nil views:@{@"savedCollectionView":self.savedCollectionView}]];
    
    
    CGFloat collectionViewMinHeight = IS_IPAD ? CGRectGetHeight(self.infoView.frame) * 1.5 : CGRectGetHeight(self.infoView.frame) / 1.25;
    CGFloat savedLabelheight = 26;
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (!IS_IPAD && (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)) {
        collectionViewMinHeight = 0;
        savedLabelheight = 0;
    }
    
    NSString *vertFormat = @"V:|[navBar(navBarHeight)]-[colorMapView(<=maxColorMapWidth)]-[sliderView(sliderHeight)]-[infoView(infoViewHeight)]-[savedLabel(labelHeight)][savedCollectionView(>=collectionViewMinHeight)]|";
    NSDictionary *vertMetrics = @{
                                  @"navBarHeight":@44, @"sliderHeight":@16, @"labelHeight":@(savedLabelheight), 
                                  @"infoViewHeight":@(CGRectGetHeight(self.infoView.frame)), @"maxColorMapWidth":@(CGRectGetWidth(self.colorMapView.frame) / 1.25), @"collectionViewMinHeight":@(collectionViewMinHeight)
                                  };
    
    NSDictionary *vertViews = @{
                                @"navBar":self.contentViewNavigationBar, @"colorMapView":self.colorMapView, @"sliderView":self.sliderView, 
                                @"infoView":self.infoView, @"savedLabel":self.savedColorsLabel, @"savedCollectionView":self.savedCollectionView
                                };
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vertFormat options:0 metrics:vertMetrics views:vertViews]];
    
    
    self.saveColorButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.saveColorButton attribute:NSLayoutAttributeLeft relatedBy:0 toItem:self.infoView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.saveColorButton attribute:NSLayoutAttributeTop relatedBy:0 toItem:self.infoView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.saveColorButton attribute:NSLayoutAttributeBottom relatedBy:0 toItem:self.infoView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.saveColorButton attribute:NSLayoutAttributeRight relatedBy:0 toItem:self.contentView attribute:NSLayoutAttributeRightMargin multiplier:1 constant:0]];
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
    UIAlertController *warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"WARNING", nil, self.cvkBundle, nil)  
                                                                          message:NSLocalizedStringFromTableInBundle(@"RESET_COLOR_QUESTION", nil, self.cvkBundle, nil) 
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        self.state = ColoredVKColorPickerStateReset;
        [self hide];
    }]];
    [self presentViewController:warningAlert animated:YES completion:nil];
}

- (void)actionShowHexWindow
{
    ColoredVKSimpleAlertController *hexWindow = [ColoredVKSimpleAlertController new];
    hexWindow.textField.placeholder = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"EXAMPLE_ALERT_MESSAGE", nil, self.cvkBundle, nil), self.customColor.hexStringValue];
    hexWindow.textField.delegate = self;
    [hexWindow.button setTitle:NSLocalizedStringFromTableInBundle(@"ALERT_COPY_CURRENT_VALUE_TIILE", nil, self.cvkBundle, nil) forState:UIControlStateNormal];
    [hexWindow.button addTarget:self action:@selector(actionCopySavedHex) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *locString = NSLocalizedStringFromTableInBundle(@"ENTER_HEXEDECIMAL_COLOR_CODE_ALERT_MESSAGE", nil, self.cvkBundle, nil);
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:locString];
    
    NSRange rangeBefore = NSMakeRange(0, [locString substringToIndex:[locString rangeOfString:@"("].location].length );
    NSRange rangeAfter = NSMakeRange([locString rangeOfString:@"("].location, [locString substringFromIndex:[locString rangeOfString:@"("].location].length );
    
    [attributedText setAttributes:@{ NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0f] } range:rangeBefore];
    [attributedText setAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:10.0f], NSForegroundColorAttributeName:[UIColor lightGrayColor] } range:rangeAfter];
    hexWindow.titleLabel.attributedText = attributedText;
    
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
    return CGSizeMake(CGRectGetWidth(collectionView.frame) / 4.5, CGRectGetHeight(collectionView.frame) / 1.25);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
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
                    [self.delegate colorPicker:self didDeleteColor:self.customHexColor];
                
                [self.savedCollectionView reloadData];
            }
        } completion:nil];
    });
}


#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSString *expression = @"(?:#)?(?:[0-9A-Fa-f]{2}){3}";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", expression];
        
        if (![predicate evaluateWithObject:textField.text]) {
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
