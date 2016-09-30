//
//  ColoredVKColorPicker.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKColorPicker.h"
#import "PrefixHeader.h"
#import "NKOColorPickerView.h"
#import "KLCPopup.h"

@interface ColoredVKColorPicker() <UITextFieldDelegate>
@property (strong, nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) NSString *prefsPath;
@property (strong, nonatomic) NSBundle *cvkBunlde;
@property (strong, nonatomic) NSMutableDictionary *prefs;
@property (strong, nonatomic) UIColor *customColor;
@property (strong, nonatomic) UIView *mainView;
@property (strong, nonatomic) KLCPopup *popup;
@property (strong, nonatomic) NKOColorPickerView *colorPickerView;
@end


@implementation ColoredVKColorPicker

- (instancetype)init
{
    CVKLog(@"ColoredVKColorPicker init is deprecated. Use initWithIdentifier:");
    return nil;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        self.cellIdentifier = identifier;
    } else {
        self.cellIdentifier = @"";
    }
    return self;
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    self.prefsPath = CVK_PREFS_PATH;
    self.cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    
    [super viewDidLoad];
    
    self.prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:self.prefsPath];
    
    self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"SELECT_COLOR_TITLE", nil, self.cvkBunlde, nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(writeValues)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"#" style:UIBarButtonItemStylePlain target:self action:@selector(showHexWindow)];
    
    
    self.customColor = [UIColor savedColorForIdentifier:self.cellIdentifier];
    self.navigationController.navigationBar.barTintColor = [UIColor savedColorForIdentifier:@"BarBackgroundColor"];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [UINavigationBar appearanceWhenContainedIn:self.class, nil].titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] } ;
    
    self.mainView = [UIView new];
    self.mainView.backgroundColor = [UIColor whiteColor];
    self.mainView.frame = (CGRect){{0, self.navigationController.navigationBar.frame.size.height}, self.view.frame.size};
    if (IS_IPAD) self.mainView.frame = (CGRect){{0,self.navigationController.navigationBar.frame.size.height}, self.navigationController.preferredContentSize};
    
    
    UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.mainView.frame.origin.y - 15, self.mainView.frame.size.width, 32)];
    [resetButton setTitle:NSLocalizedStringFromTableInBundle(@"RESET_BUTTON_TITLE", nil, self.cvkBunlde, nil) forState:UIControlStateNormal];
    resetButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [resetButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor colorWithRed:0.8 green:0 blue:0 alpha:1.0] forState:UIControlStateHighlighted];
    resetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    resetButton.titleLabel.numberOfLines = 2;
    resetButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [resetButton setTitleShadowColor:[UIColor colorWithRed:225.0/255.0f green:226.0/255.0f blue:227.0/255.0f alpha:1] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(addErrorAnimationForButton:) forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(resetColorValue)];
    longPress.minimumPressDuration = 1.0;
    longPress.numberOfTouchesRequired = 1;
    [resetButton addGestureRecognizer:longPress];
    [self.mainView addSubview:resetButton];
        
    
    CGRect pickerRect = CGRectMake(0,  resetButton.frame.origin.y + resetButton.frame.size.height,  self.mainView.frame.size.width, self.mainView.frame.size.height - 100);
    self.colorPickerView = [[NKOColorPickerView alloc] initWithFrame:pickerRect 
                                                               color:self.customColor 
                                              andDidChangeColorBlock:^(UIColor *color) {
                                                  self.customColor = color;
                                                  if ([self.cellIdentifier isEqualToString:@"BarBackgroundColor"]) self.navigationController.navigationBar.barTintColor = color;
                                                  if ([self.cellIdentifier isEqualToString:@"BarForegroundColor"]) self.navigationController.navigationBar.tintColor = color;
                                              }];
    self.colorPickerView.tintColor = [UIColor colorWithRed:200.0/255.0f green:201.0/255.0f blue:202.0/255.0f alpha:1.0];
    [self.mainView addSubview:self.colorPickerView];
        
    [self.view addSubview:self.mainView];
    
    self.view.backgroundColor = self.mainView.backgroundColor;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShown
{
    [UIView animateWithDuration:0.2 animations:^{
        self.popup.contentView.frame = CGRectMake(self.popup.contentView.frame.origin.x, self.popup.contentView.frame.origin.y - 50,
                                                  self.popup.contentView.frame.size.width, self.popup.contentView.frame.size.height);
    }];

}
- (void)keyboardWillHidden
{
    [UIView animateWithDuration:0.2 animations:^{
        self.popup.contentView.frame = CGRectMake(self.popup.contentView.frame.origin.x, self.popup.contentView.frame.origin.y + 50,
                                                  self.popup.contentView.frame.size.width, self.popup.contentView.frame.size.height);
    }];
}




- (void)writeValues 
{
    self.prefs[self.cellIdentifier] = [NSString stringFromColor:self.customColor];
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
    
    [self dismissViewControllerAnimated:YES completion:nil]; 
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
    textField.placeholder = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"EXAMPLE_ALERT_MESSAGE", nil, self.cvkBunlde, nil), [NSString hexStringFromColor:self.customColor] ];
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
    [valueButton addTarget:self action:@selector(unHighlightButtonBorder:) forControlEvents:UIControlEventTouchUpOutside];
    [valueButton addTarget:self action:@selector(unHighlightButtonBorder:) forControlEvents:UIControlEventTouchUpInside];
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


- (void)addErrorAnimationForButton:(UIButton*)button
{
    NSString *oldTitle = [button titleForState:UIControlStateNormal];
    
    NSTimeInterval hideTimeInterval = 0.5f;
    NSTimeInterval showDelay = 1.0f;
    [UIView animateWithDuration:hideTimeInterval 
                     animations:^{ button.alpha = 0.0; }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:1.0f
                                          animations:^{ 
                                              [button setTitle:NSLocalizedStringFromTableInBundle(@"TAP_AND_HOLD_BUTTON_TITLE", nil, self.cvkBunlde, nil) forState:UIControlStateNormal];
                                              button.alpha = 1.0; 
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:hideTimeInterval delay:showDelay options:0 animations:^{ button.alpha = 0.0; } 
                                                               completion:^(BOOL finished) { 
                                                                   [UIView animateWithDuration:1.0f animations:^{ [button setTitle:oldTitle forState:UIControlStateNormal]; button.alpha = 1.0; }];
                                                               }
                                               ];
                                          }
                          ];
                     }
     ];
}

- (void)resetColorValue
{
    if (self.prefs[self.cellIdentifier] != nil) {
        [self.prefs removeObjectForKey:self.cellIdentifier];
    }
    [self.prefs writeToFile:self.prefsPath atomically:YES];
    [self dismissPicker];
}

- (void)copyHEXValue 
{ 
    [UIPasteboard generalPasteboard].string = [NSString hexStringFromColor:[UIColor savedColorForIdentifier:self.cellIdentifier]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *expression = @"(?:#)?(?:[0-9A-Fa-f]{2}){3}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", expression];
    
    if (![predicate evaluateWithObject:textField.text]) {
        textField.layer.borderColor = [UIColor colorWithRed:0.8 green:0 blue:0 alpha:1.0].CGColor;
    } else {
        textField.layer.borderColor = [UIColor clearColor].CGColor;
        
        self.customColor = [UIColor colorFromHexString:textField.text];
        self.colorPickerView.color = self.customColor;
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
