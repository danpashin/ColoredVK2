//
//  ColoredVKColorPicker.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKColorPickerController.h"
#import "ColoredVKAlertController.h"
#import "ColoredVKSimpleAlertController.h"

#import "ColoredVKColorPickerContainer.h"
#import "ColoredVKColorCollectionViewCell.h"
#import "UIScrollView+EmptyDataSet.h"

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

@property (assign, nonatomic) UIEdgeInsets saveButtonLabelInsets;

@property (strong, nonatomic) ColoredVKColorPickerContainer *container;

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
    UIImage *resetImage = [CVKImageInBundle(@"color_picker/ResetIcon", self.cvkBundle) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:resetImage style:UIBarButtonItemStylePlain target:self action:@selector(actionResetColor)];
    navItem.leftBarButtonItem.accessibilityLabel = CVKLocalizedString(@"RESET_COLOR");
    
    self.container = [ColoredVKColorPickerContainer loadNib];
    [self.contentView addSubview:self.container];
    
    
    [self.container.colorMap addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventValueChanged];
    [self.container.brightnessSlider addTarget:self action:@selector(setColorBrightness:) forControlEvents:UIControlEventValueChanged];
    [self.container.saveColorButton addTarget:self action:@selector(actionSaveColor) forControlEvents:UIControlEventTouchUpInside];
    [self.container.colorPreview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionShowHexWindow)]];
    
    [self.container.savedCollectionView registerClass:[ColoredVKColorCollectionViewCell class] forCellWithReuseIdentifier:@"colorCell"];
    self.container.savedCollectionView.delegate = self;
    self.container.savedCollectionView.dataSource = self;
    self.container.savedCollectionView.emptyDataSetSource = self;
    self.container.savedCollectionView.emptyDataSetDelegate = self;
    
    
    self.customColor = [UIColor cvk_savedColorForIdentifier:self.identifier];
    if (self.customColor == nil)
        self.customColor = [UIColor clearColor];
    
    [self.customColor getHue:nil saturation:nil brightness:&_brightness alpha:nil];
    
    self.container.brightnessSlider.color = self.customColor;
    self.container.colorPreview.color = self.customColor;
    self.container.colorMap.color = self.customColor;
    
    [self updateSavedColorsFromPrefs];
    
    [self setupConstraints];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.contentViewWantsShadow) {
        self.contentView.layer.shadowRadius = IS_IPAD ? 15.0f : 8.0f;
        self.contentView.layer.shadowOpacity = IS_IPAD ? 0.15f : 0.3f;
        self.contentView.layer.shadowOffset = CGSizeZero;
    }
}

- (void)setupConstraints
{    
    self.container.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentViewNavigationBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[navBar]-|" 
                                                                             options:0 metrics:nil 
                                                                               views:@{@"navBar":self.contentViewNavigationBar}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[container]-|" 
                                                                             options:0 metrics:nil 
                                                                               views:@{@"container":self.container}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[navBar(44)]-[container]-|" 
                                                                             options:0 metrics:nil
                                                                               views:@{@"navBar":self.contentViewNavigationBar, @"container":self.container}]];
}

- (void)updateSavedColorsFromPrefs
{
    self.savedColors = [NSMutableArray array];
    if ([self.dataSource respondsToSelector:@selector(savedColorsForColorPicker:)]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray <NSString *> *savedColors = [self.dataSource savedColorsForColorPicker:self];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.container.savedCollectionView performBatchUpdates:^{
                    [[savedColors reverseObjectEnumerator].allObjects enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [self.savedColors addObject:obj];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                        [self.container.savedCollectionView insertItemsAtIndexPaths:@[indexPath]];
                    }];
                    
                    [self.container.savedCollectionView reloadData];
                    [self.container.savedCollectionView.collectionViewLayout invalidateLayout];
                    
                } completion:nil];
            });
        });
    } 
}

- (void)updateColorsFromPicker:(BOOL)fromPicker
{
    CGFloat hue, saturation, brightness;
    [self.customColor getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
    self.customColor = [UIColor colorWithHue:hue saturation:saturation brightness:fromPicker ? self.brightness : brightness alpha:1];
    self.container.colorPreview.color = self.customColor;
    self.container.brightnessSlider.color = self.customColor;
    
    if (!fromPicker)
        self.container.colorMap.color = self.customColor;
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
    ColoredVKAlertController *warningAlert = [ColoredVKAlertController alertControllerWithTitle:CVKLocalizedString(@"WARNING")  
                                                                                        message:CVKLocalizedString(@"RESET_COLOR_QUESTION") 
                                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [warningAlert addCancelAction];
    [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        self.state = ColoredVKColorPickerStateReset;
        [self hide];
    }]];
    [warningAlert presentFromController:self];
}

- (void)actionShowHexWindow
{
    ColoredVKSimpleAlertController *hexWindow = [[ColoredVKSimpleAlertController alloc] init];
    hexWindow.textField.placeholder = [NSString stringWithFormat:CVKLocalizedString(@"EXAMPLE_ALERT_MESSAGE"), self.customColor.cvk_hexStringValue];
    hexWindow.textField.delegate = self;
    NSString *buttonTitle = CVKLocalizedString(@"COPY_SAVED");
    [hexWindow.button setTitle:buttonTitle forState:UIControlStateNormal];
    [hexWindow.button addTarget:self action:@selector(actionCopySavedHex) forControlEvents:UIControlEventTouchUpInside];
    [hexWindow.button setBackgroundImage:nil forState:UIControlStateNormal];
    [hexWindow.button setBackgroundImage:nil forState:UIControlStateHighlighted];
    [hexWindow.button setTitleColor:CVKMainColor forState:UIControlStateNormal];
    [hexWindow.button setTitleColor:CVKMainColor.cvk_darkerColor forState:UIControlStateHighlighted];
    
    NSString *locString = CVKLocalizedString(@"ENTER_HEXEDECIMAL_COLOR_CODE_ALERT_MESSAGE");
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
        
        [self.container.savedCollectionView performBatchUpdates:^{
            [self.container.savedCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
            [self.container.savedCollectionView reloadData];
            [self.container.savedCollectionView.collectionViewLayout invalidateLayout];
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
            [self.container.savedCollectionView performBatchUpdates:^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.savedColors indexOfObject:hexColor] inSection:0];
                [self.savedColors removeObject:hexColor];
                [self.container.savedCollectionView deleteItemsAtIndexPaths:@[indexPath]];
                [self.container.savedCollectionView reloadData];
                [self.container.savedCollectionView.collectionViewLayout invalidateLayout];
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
    return CVKImageInBundle(@"color_picker/WindowsIcon", self.cvkBundle);
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = CVKLocalizedString(@"OH_YOU_HAVE_NOT_SAVED_COLORS");
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

@end
