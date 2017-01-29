//
//  ColoredVKColorPicker.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKColorPickerViewController.h"
#import "PrefixHeader.h"
#import "KLCPopup.h"
#import "HRColorMapView.h"
#import "HRBrightnessSlider.h"
#import "HRColorInfoView.h"
#import "ColoredVKBackgroundImageView.h"

@interface ColoredVKColorPickerViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) NSString *prefsPath;
@property (strong, nonatomic) NSBundle *cvkBunlde;
@property (strong, nonatomic) NSMutableDictionary *prefs;
@property (strong, nonatomic) UIColor *customColor;
@property (strong, nonatomic) UIView *mainView;
@property (strong, nonatomic) KLCPopup *popup;
@property (strong, nonatomic) HRColorInfoView *infoView;
@property (strong, nonatomic) HRBrightnessSlider *sliderView;
@property (strong, nonatomic) HRColorMapView *colorMapView;
@property (assign, nonatomic) CGFloat brightness;
@property (assign, nonatomic) BOOL hideStatusBar;
@end


@implementation ColoredVKColorPickerViewController

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSGenericException reason:@"ColoredVKColorPicker init is forbidden." userInfo:nil];
    return nil;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        self.cellIdentifier = identifier;
        _hideStatusBar = NO;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return self.hideStatusBar;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.prefsPath = CVK_PREFS_PATH;
    self.cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    
    [super viewWillAppear:animated];
    
    
    self.prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:self.prefsPath];
    self.customColor = [UIColor savedColorForIdentifier:self.cellIdentifier];
    [self.customColor getHue:nil saturation:nil brightness:&_brightness alpha:nil];
    
    
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    blurView.frame = self.view.bounds;
    [self.view addSubview:blurView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(writeValues)];
    tap.delegate = self;
    [blurView addGestureRecognizer:tap];
    
    
    self.mainView = [UIView new];
    self.mainView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    
    int widthFromEdge = IS_IPAD?20:6;
    self.mainView.frame = (CGRect){{widthFromEdge, 0}, {self.view.frame.size.width - widthFromEdge*2, self.view.frame.size.height - widthFromEdge*10}};
    self.mainView.center = self.view.center;
    self.mainView.layer.cornerRadius = 16;
    
    
    UINavigationBar *topView = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.mainView.frame.size.width, 44)];
    [topView setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    topView.shadowImage = [UIImage new];
    [self.mainView addSubview:topView];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    UIImage *resetImage = [[UIImage imageNamed:@"ResetIcon" inBundle:self.cvkBunlde compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:resetImage style:UIBarButtonItemStylePlain target:self action:@selector(resetColorValue)];
    
    UIImage *closeImage = [[UIImage imageNamed:@"CloseIcon" inBundle:self.cvkBunlde compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    navItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:closeImage style:UIBarButtonItemStylePlain target:self action:@selector(writeValues)];
    
    topView.items = @[navItem];
    
    
    
    self.infoView = [HRColorInfoView new];
    self.infoView.frame = CGRectMake(10, topView.frame.origin.y + topView.frame.size.height, 60, 80);
    self.infoView.color = self.customColor;
    [self.infoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHexWindow)]];
    [self.mainView addSubview:self.infoView];
    
    self.sliderView = [HRBrightnessSlider new];
    self.sliderView.frame = CGRectMake(self.infoView.frame.origin.x + self.infoView.frame.size.width + 10, (self.infoView.frame.origin.y + self.infoView.frame.size.height)/2, 
                                       self.mainView.frame.size.width - (self.infoView.frame.origin.x + self.infoView.frame.size.width + 10), 32);
    [self.sliderView addTarget:self action:@selector(setColorBrightness:) forControlEvents:UIControlEventValueChanged];
    self.sliderView.color = self.customColor;
    self.sliderView.brightnessLowerLimit = @0;
    [self.mainView addSubview:self.sliderView];    
    
    CGRect pickerRect = CGRectMake(10, topView.frame.origin.y + topView.frame.size.height + 120, self.mainView.frame.size.width-20, 
                                   self.mainView.frame.size.height - (topView.frame.origin.y + topView.frame.size.height + 120));    
    self.colorMapView = [HRColorMapView colorMapWithFrame:pickerRect saturationUpperLimit:0.9];
    [self.colorMapView addTarget:self action:@selector(setColor:) forControlEvents:UIControlEventValueChanged];
    self.colorMapView.color = self.customColor;
    self.colorMapView.tileSize = @1;
    self.colorMapView.brightness = 1;
    self.colorMapView.layer.masksToBounds = YES;
    self.colorMapView.layer.cornerRadius = self.mainView.layer.cornerRadius/2;
    [self.mainView addSubview:self.colorMapView];
    
    
    [self.view addSubview:self.mainView];
    
    
    self.mainView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-fromEdge-[_mainView]-fromEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:@{ @"fromEdge" : @(widthFromEdge*4)} views:NSDictionaryOfVariableBindings(_mainView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-fromEdge-[_mainView]-fromEdge-|" options:NSLayoutFormatDirectionLeadingToTrailing 
                                                                      metrics:@{ @"fromEdge" : @(widthFromEdge)} views:NSDictionaryOfVariableBindings(_mainView)]];
    
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurView]|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil views:NSDictionaryOfVariableBindings(blurView)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                      metrics:nil views:NSDictionaryOfVariableBindings(blurView)]];
    
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topView(height)]" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:@{@"height":@44} views:NSDictionaryOfVariableBindings(topView)]];
    
    [self.mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topView]|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil views:NSDictionaryOfVariableBindings(topView)]];
    
    self.infoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-fromTop-[_infoView(height)]" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:@{@"height":@(self.infoView.frame.size.height), @"fromTop": @(topView.frame.origin.y + topView.frame.size.height)} views:NSDictionaryOfVariableBindings(_infoView)]];
    
    [self.mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_infoView(width)]" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:@{@"width" : @(self.infoView.frame.size.width)} views:NSDictionaryOfVariableBindings(_infoView)]];
    
    self.sliderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-fromTop-[_sliderView(16)]" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:@{@"fromTop": @((self.infoView.frame.origin.y + self.infoView.frame.size.height)/2 + 10)} views:NSDictionaryOfVariableBindings(_sliderView)]];
    
    [self.mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-fromLeft-[_sliderView]-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:@{@"fromLeft" : @(self.infoView.frame.origin.x + self.infoView.frame.size.width + 10)} views:NSDictionaryOfVariableBindings(_sliderView)]];
    
    self.colorMapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-fromTop-[_colorMapView]-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:@{@"fromTop": @((self.infoView.frame.origin.y + self.infoView.frame.size.height) + 10)} views:NSDictionaryOfVariableBindings(_colorMapView)]];
    
    [self.mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[_colorMapView]-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                          metrics:nil views:NSDictionaryOfVariableBindings(_colorMapView)]];
    
    

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShown) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHidden) name:UIKeyboardWillHideNotification object:nil];
    
    
    self.hideStatusBar = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setupMainView];
}

- (void)setupMainView
{
    self.mainView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.mainView.bounds cornerRadius:self.mainView.layer.cornerRadius].CGPath;
    self.mainView.layer.shadowRadius = 4;
    self.mainView.layer.shadowOffset = CGSizeMake(0, 3);
    self.mainView.layer.shadowColor = [UIColor blackColor].CGColor;
    
    CGFloat shadowOpacity = 0.1;
    CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    shadowAnimation.fromValue = @0.0;
    shadowAnimation.toValue = @(shadowOpacity);
    shadowAnimation.duration = 1.0;
    [self.mainView.layer addAnimation:shadowAnimation forKey:@"shadowOpacity"];
    self.mainView.layer.shadowOpacity = shadowOpacity;
}

- (void)setHideStatusBar:(BOOL)hideStatusBar
{
    _hideStatusBar = hideStatusBar;
    
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    } completion:nil];
}

- (void)updateColorsFromPicker:(BOOL)fromPicker
{
    CGFloat hue, saturation, brightness;
    [self.customColor getHue:&hue saturation:&saturation brightness:&brightness alpha:nil];
    self.customColor = [UIColor colorWithHue:hue saturation:saturation brightness:fromPicker?self.brightness:brightness alpha:1];
    self.infoView.color = self.customColor;
    self.sliderView.color = self.customColor;
    self.colorMapView.color = self.customColor;
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

- (void)keyboardWillShown
{
    self.popup.shouldDismissOnBackgroundTouch = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.popup.contentView.frame = CGRectMake(self.popup.contentView.frame.origin.x, self.popup.contentView.frame.origin.y - 50,
                                                  self.popup.contentView.frame.size.width, self.popup.contentView.frame.size.height);
    }];

}
- (void)keyboardWillHidden
{
    self.popup.shouldDismissOnBackgroundTouch = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.popup.contentView.frame = CGRectMake(self.popup.contentView.frame.origin.x, self.popup.contentView.frame.origin.y + 50,
                                                  self.popup.contentView.frame.size.width, self.popup.contentView.frame.size.height);
    }];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{    
    if ([touch.view isDescendantOfView:[self.view viewWithTag:10]]) return YES;
    return NO;
}

- (void)resetColorValue
{
    UIAlertController *warningAlert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"WARNING", nil, self.cvkBunlde, nil)  
                                                                          message:NSLocalizedStringFromTableInBundle(@"RESET_COLOR_QUESTION", nil, self.cvkBunlde, nil) 
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Delete")
                                                     style:UIAlertActionStyleDestructive 
                                                   handler:^(UIAlertAction *action) { 
                                                       if (self.prefs[self.cellIdentifier]) [self.prefs removeObjectForKey:self.cellIdentifier];
                                                       [self.prefs writeToFile:self.prefsPath atomically:YES];
                                                       [self dismissPicker];
                                                   }]];
    [self presentViewController:warningAlert animated:YES completion:nil];
    
}


- (void)writeValues 
{
    self.prefs[self.cellIdentifier] = self.customColor.stringValue;
    [self.prefs writeToFile:self.prefsPath atomically:YES];
    
    [self dismissPicker];
}

- (void)dismissPicker 
{
    [self.popup dismiss:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk.prefs.colorUpdate" object:nil userInfo:@{ @"CVKColorCellIdentifier" : self.cellIdentifier }];
    
    NSArray *identificsToReloadMenu = @[@"MenuSeparatorColor", @"switchesTintColor", @"switchesOnTintColor"];
    if ([identificsToReloadMenu containsObject:self.cellIdentifier]) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
    
    self.hideStatusBar = NO;
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.pickerWindow.hidden = YES;
        self.pickerWindow = nil;
    }];
}


- (void) showHexWindow 
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = CGRectMake(0, 0, self.view.frame.size.width - 60, 120);
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 6;
    
    int width = view.frame.size.width - 10;
    int height = 30;
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 30)];
    title.center = CGPointMake(view.frame .size.width / 2, 20);
    
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
    [valueButton addTarget:self action:@selector(highlightButtonBorder:) forControlEvents:UIControlEventTouchDown];
    [valueButton addTarget:self action:@selector(unHighlightButtonBorder:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
    [valueButton addTarget:self action:@selector(copyHEXValue) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:valueButton];
    
    self.popup = [KLCPopup popupWithContentView:view 
                                       showType:KLCPopupShowTypeBounceIn
                                    dismissType:KLCPopupDismissTypeBounceOut 
                                       maskType:KLCPopupMaskTypeDimmed
                       dismissOnBackgroundTouch:YES 
                          dismissOnContentTouch:NO];
    [self.popup show];
}

- (void)highlightButtonBorder:(UIButton *)button
{
    button.layer.borderColor = [UIColor colorWithRed:60.0/255.0f green:82.0/255.0f blue:131.0/255.0f alpha:1].CGColor;
}

- (void)unHighlightButtonBorder:(UIButton *)button
{
    button.layer.borderColor = [UIColor colorWithRed:80.0/255.0f green:102.0/255.0f blue:151.0/255.0f alpha:1].CGColor;
}

- (void)copyHEXValue 
{ 
    [UIPasteboard generalPasteboard].string = [UIColor savedColorForIdentifier:self.cellIdentifier].hexStringValue;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *expression = @"(?:#)?(?:[0-9A-Fa-f]{2}){3}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", expression];
    
    if (![predicate evaluateWithObject:textField.text]) {
        textField.layer.borderColor = [UIColor colorWithRed:0.8 green:0 blue:0 alpha:1.0].CGColor;
    } else {
        textField.layer.borderColor = [UIColor clearColor].CGColor;
        
        self.customColor = textField.text.hexColorValue;
        [self updateColorsFromPicker:NO];
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
@end
