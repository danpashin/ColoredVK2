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
#import "HRColorInfoView.h"

@interface ColoredVKColorPickerController () <UITextFieldDelegate>

@property (strong, nonatomic) NSBundle *cvkBunlde;
@property (strong, nonatomic) UIColor *customColor;
@property (assign, nonatomic) CGFloat brightness;

@property (strong, nonatomic) UIScrollView *hexScrollView;
@property (strong, nonatomic) HRColorInfoView *infoView;
@property (strong, nonatomic) HRBrightnessSlider *sliderView;
@property (strong, nonatomic) HRColorMapView *colorMapView;

@end


@implementation ColoredVKColorPickerController

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
    
    self.cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.backgroundView isKindOfClass:[UIVisualEffectView class]])
            self.backgroundView.backgroundColor = [self.customColor colorWithAlphaComponent:0.1];
    });
    
    [self setupDefaultContentView];
    
    UINavigationBar *navBar = self.contentViewNavigationBar;
    [self.contentView addSubview:navBar];
    
    UINavigationItem *navItem = navBar.items.firstObject;
    UIImage *resetImage = [[UIImage imageNamed:@"ResetIcon" inBundle:self.cvkBunlde compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:resetImage style:UIBarButtonItemStylePlain target:self action:@selector(resetColorValue)];
    
    self.infoView = [HRColorInfoView new];
    self.infoView.frame = CGRectMake(10, CGRectGetMinY(navBar.frame) + CGRectGetHeight(navBar.frame), 60, 80);
    [self.infoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHexWindow)]];
    [self.contentView addSubview:self.infoView];
    
    self.sliderView = [HRBrightnessSlider new];
    self.sliderView.frame = CGRectMake(CGRectGetMinX(self.infoView.frame) + CGRectGetWidth(self.infoView.frame) + 10, (CGRectGetMinY(self.infoView.frame) + CGRectGetHeight(self.infoView.frame))/2, 
                                       CGRectGetWidth(self.contentView.frame) - (CGRectGetMinX(self.infoView.frame) + CGRectGetWidth(self.infoView.frame) + 10), 32);
    [self.sliderView addTarget:self action:@selector(setColorBrightness:) forControlEvents:UIControlEventValueChanged];
    self.sliderView.brightnessLowerLimit = @0;
    [self.contentView addSubview:self.sliderView];    
    
    CGRect pickerRect = CGRectMake(10, CGRectGetMinY(navBar.frame) + CGRectGetHeight(navBar.frame) + CGRectGetHeight(self.infoView.frame) + 10, CGRectGetWidth(self.contentView.frame)-20, 
                                   CGRectGetHeight(self.contentView.frame) - (CGRectGetMinY(navBar.frame) + CGRectGetHeight(navBar.frame) + 120));    
    self.colorMapView = [HRColorMapView colorMapWithFrame:pickerRect saturationUpperLimit:0.9];
    [self.colorMapView addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventValueChanged];
    self.colorMapView.tileSize = @1;
    self.colorMapView.brightness = 1;
    self.colorMapView.layer.masksToBounds = YES;
    self.colorMapView.layer.cornerRadius = self.contentView.layer.cornerRadius/2;
    [self.contentView addSubview:self.colorMapView];
    
    navBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[navBar(height)]" options:0 metrics:@{@"height":@44} views:@{@"navBar":navBar}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[navBar]|" options:0 metrics:nil views:@{@"navBar":navBar}]];
    
    self.infoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-fromTop-[infoView(height)]" options:0 
                                                                          metrics:@{@"height":@(self.infoView.frame.size.height), @"fromTop":@(CGRectGetMinY(navBar.frame) + CGRectGetHeight(navBar.frame))} 
                                                                            views:@{@"infoView":self.infoView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[infoView(width)]" options:0 metrics:@{@"width" : @(self.infoView.frame.size.width)} views:@{@"infoView":self.infoView}]];
    
    self.sliderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-fromTop-[sliderView(16)]" options:0
                                                                          metrics:@{@"fromTop": @((self.infoView.frame.origin.y + self.infoView.frame.size.height)/2 + 10)}
                                                                            views:@{@"sliderView":self.sliderView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-fromLeft-[sliderView]-|" options:0
                                                                          metrics:@{@"fromLeft" : @(self.infoView.frame.origin.x + self.infoView.frame.size.width + 10)}
                                                                            views:@{@"sliderView":self.sliderView}]];
    
    self.colorMapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-fromTop-[colorMapView]-|" options:0
                                                                          metrics:@{@"fromTop": @((self.infoView.frame.origin.y + self.infoView.frame.size.height) + 10)}
                                                                            views:@{@"colorMapView":self.colorMapView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[colorMapView]-|" options:0 metrics:nil views:@{@"colorMapView":self.colorMapView}]];
    
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}


- (void)updateColorsFromPicker:(BOOL)fromPicker
{
    CGFloat hue, saturation, brightness;
    [self.customColor getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
    self.customColor = [UIColor colorWithHue:hue saturation:saturation brightness:fromPicker?self.brightness:brightness alpha:1];
    self.infoView.color = self.customColor;
    self.sliderView.color = self.customColor;
    self.colorMapView.color = self.customColor;
    
    if ([self.backgroundView isKindOfClass:[UIVisualEffectView class]])
        self.backgroundView.backgroundColor = [self.customColor colorWithAlphaComponent:0.1];
    
    if ([self.delegate respondsToSelector:@selector(colorPicker:didChangeColor:)]) [self.delegate colorPicker:self didChangeColor:self.customColor];
    
//    self.colorMapView.brightness = fromPicker?self.brightness:brightness;
}

- (void)setColor:(HRColorMapView *)colorMap
{
    self.customColor = colorMap.color;
    [self updateColorsFromPicker:YES];
}

- (void)setColorBrightness:(HRBrightnessSlider *)brightnessSlider
{
    self.brightness = brightnessSlider.brightness.floatValue;
    [self updateColorsFromPicker:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect kbRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.hexScrollView.contentOffset = CGPointMake(0, kbRect.size.height/2);
}

- (void)keyboardWillHide
{
    self.hexScrollView.contentOffset = CGPointZero;
}

- (void)resetColorValue
{
    UIAlertController *warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"WARNING", nil, self.cvkBunlde, nil)  
                                                                          message:NSLocalizedStringFromTableInBundle(@"RESET_COLOR_QUESTION", nil, self.cvkBunlde, nil) 
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        if ([self.delegate respondsToSelector:@selector(colorPicker:didResetColorForIdentifier:)]) [self.delegate colorPicker:self didResetColorForIdentifier:self.identifier];
        [self hide];
    }]];
    [self presentViewController:warningAlert animated:YES completion:nil];
}

- (void)hide
{
    if ([self.delegate respondsToSelector:@selector(colorPickerWillDismiss:)]) [self.delegate colorPickerWillDismiss:self];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    
    [super hide];
}


- (void)showHexWindow
{
    self.hexScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.hexScrollView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self.view addSubview:self.hexScrollView];
    
    self.hexScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[hexScrollView]|" options:0 metrics:nil views:@{@"hexScrollView":self.hexScrollView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[hexScrollView]|" options:0 metrics:nil views:@{@"hexScrollView":self.hexScrollView}]];
    
    UITapGestureRecognizer *hexTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissHexView)];
    [self.hexScrollView addGestureRecognizer:hexTap];
    
    
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width - 60, 120);
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 6;
    
    int width = view.frame.size.width - 10;
    int height = 30;
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    title.center = CGPointMake(view.frame.size.width / 2, 20);
    
    NSString *locString = NSLocalizedStringFromTableInBundle(@"ENTER_HEXEDECIMAL_COLOR_CODE_ALERT_MESSAGE", nil, self.cvkBunlde, nil);
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:locString];
    
    NSRange rangeBefore = NSMakeRange(0, [locString substringToIndex:[locString rangeOfString:@"("].location].length );
    NSRange rangeAfter = NSMakeRange([locString rangeOfString:@"("].location, [locString substringFromIndex:[locString rangeOfString:@"("].location].length );
    
    [attributedText setAttributes:@{ NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0f] } range:rangeBefore];
    [attributedText setAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:10.0f], NSForegroundColorAttributeName:[UIColor lightGrayColor] } range:rangeAfter];
    
    title.attributedText = attributedText;
    title.textAlignment = NSTextAlignmentCenter;
    title.adjustsFontSizeToFitWidth = YES;
    title.numberOfLines = 2;
    [view addSubview:title];
    
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    textField.center = CGPointMake(view.frame .size.width / 2, title.center.y + 35);
    textField.placeholder = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"EXAMPLE_ALERT_MESSAGE", nil, self.cvkBunlde, nil), self.customColor.hexStringValue];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.delegate = self;
    textField.layer.cornerRadius = 5.0f;
    textField.layer.masksToBounds = YES;
    textField.layer.borderWidth = 1.0f;
    textField.layer.borderColor = [UIColor clearColor].CGColor;
    [view addSubview:textField];
    
    
    UIButton *valueButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    valueButton.center = CGPointMake(view.frame .size.width / 2, textField.center.y + 40);
    valueButton.layer.masksToBounds = YES;
    valueButton.layer.cornerRadius = 6;
    valueButton.layer.borderColor = [UIColor colorWithRed:80.0/255.0f green:102.0/255.0f blue:151.0/255.0f alpha:1].CGColor;
    valueButton.layer.borderWidth = 1.0;
    [valueButton setTitle:NSLocalizedStringFromTableInBundle(@"ALERT_COPY_CURRENT_VALUE_TIILE", nil, self.cvkBunlde, nil) forState:UIControlStateNormal];
    valueButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [valueButton setTitleColor:[UIColor colorWithRed:80.0/255.0f green:102.0/255.0f blue:151.0/255.0f alpha:1] forState:UIControlStateNormal];
    [valueButton setTitleColor:[UIColor colorWithRed:60.0/255.0f green:82.0/255.0f blue:131.0/255.0f alpha:1] forState:UIControlStateHighlighted];
    valueButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [valueButton addTarget:self action:@selector(highlightButtonBorder:) forControlEvents:UIControlEventTouchDragEnter];
    [valueButton addTarget:self action:@selector(unHighlightButtonBorder:) forControlEvents:UIControlEventTouchDragExit];
    [valueButton addTarget:self action:@selector(copyColorHexValue:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:valueButton];
    
    [self.hexScrollView addSubview:view];
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.hexScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:0 toItem:self.hexScrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.hexScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:0 toItem:self.hexScrollView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.hexScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:0 toItem:nil attribute:0 multiplier:1 constant:CGRectGetWidth(view.frame)]];
    [self.hexScrollView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:0 toItem:nil attribute:0 multiplier:1 constant:CGRectGetHeight(view.frame)]];
    
    view.alpha = 0.0;
    view.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:15.0 options:0
                     animations:^{
                         view.alpha = 1.0;
                         view.transform = CGAffineTransformIdentity;
                     } completion:nil];
}

- (void)dismissHexView
{
    NSTimeInterval bounce1Duration = 0.13;
    NSTimeInterval bounce2Duration = (bounce1Duration * 2.0);
    
    UIView *hexContainerView = self.hexScrollView.subviews.lastObject;
    
    [UIView animateWithDuration:bounce1Duration delay:0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void){
                         hexContainerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:bounce2Duration delay:0  options:UIViewAnimationOptionCurveEaseIn
                                          animations:^(void){
                                              hexContainerView.alpha = 0.0;
                                              hexContainerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                          } completion:^(BOOL finished){
                                              [self.hexScrollView removeFromSuperview];
                                          }];
                     }];
}

- (void)highlightButtonBorder:(UIButton *)button
{
    button.layer.borderColor = [UIColor colorWithRed:60.0/255.0f green:82.0/255.0f blue:131.0/255.0f alpha:1].CGColor;
}

- (void)unHighlightButtonBorder:(UIButton *)button
{
    button.layer.borderColor = [UIColor colorWithRed:80.0/255.0f green:102.0/255.0f blue:151.0/255.0f alpha:1].CGColor;
}

- (void)copyColorHexValue:(UIButton *)button
{
    button.layer.borderColor = [UIColor colorWithRed:80.0/255.0f green:102.0/255.0f blue:151.0/255.0f alpha:1].CGColor;
    [UIPasteboard generalPasteboard].string = [UIColor savedColorForIdentifier:self.identifier].hexStringValue;
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

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
@end
