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

@interface ColoredVKColorPicker() <UITextFieldDelegate, UIGestureRecognizerDelegate>
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
    [[NSException exceptionWithName:NSGenericException reason:@"ColoredVKColorPicker init is forbidden. Use initWithIdentifier:" userInfo:nil] raise];
    return nil;
}

- (instancetype)initWithIdentifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        self.cellIdentifier = identifier;
    }
    return self;
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.prefsPath = CVK_PREFS_PATH;
    self.cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    
    [super viewWillAppear:animated];
    
    
    self.prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:self.prefsPath];
    self.customColor = [UIColor savedColorForIdentifier:self.cellIdentifier];
    
    
    UIView *backView = [[UIView alloc] initWithFrame:self.view.frame];
    backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    backView.tag = 10;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(writeValues)];
    tap.delegate = self;
    [backView addGestureRecognizer:tap];
    [self.view addSubview:backView];
    
    
    self.mainView = [UIView new];
    self.mainView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
    
    int widthFromEdge = IS_IPAD?20:8;
    self.mainView.frame = (CGRect){{widthFromEdge, 0}, {self.view.frame.size.width - widthFromEdge*2, self.view.frame.size.height - widthFromEdge*10}};
    self.mainView.center = self.view.center;
    self.mainView.layer.masksToBounds = YES;
    self.mainView.layer.cornerRadius = 10;
    
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    blurView.frame = self.mainView.bounds;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.mainView addSubview:blurView];
    
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, self.mainView.frame.size.width, 32)];
    topView.backgroundColor = [UIColor clearColor];
    [self.mainView addSubview:topView];
    
    UIButton *hexButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, topView.frame.size.height, topView.frame.size.height)];
    hexButton.center = CGPointMake(hexButton.frame.origin.x + hexButton.frame.size.width/2, hexButton.frame.size.height/2);
    [hexButton setTitle:@"#" forState:UIControlStateNormal];
    hexButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [hexButton setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    [hexButton addTarget:self action:@selector(showHexWindow) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:hexButton];
    
    UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, topView.frame.size.width/1.8, topView.frame.size.height)];
    resetButton.center = CGPointMake(topView.center.x, resetButton.frame.size.height/2);
    [resetButton setTitle:NSLocalizedStringFromTableInBundle(@"RESET_BUTTON_TITLE", nil, self.cvkBunlde, nil) forState:UIControlStateNormal];
    resetButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    resetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [resetButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor colorWithRed:0.8 green:0 blue:0 alpha:1.0] forState:UIControlStateHighlighted];
    [resetButton addTarget:self action:@selector(resetColorValue) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:resetButton];
    
    int width = 58;
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(topView.frame.size.width - width - 5, 0, width, topView.frame.size.height)];
    doneButton.center = CGPointMake(doneButton.frame.origin.x + doneButton.frame.size.width/2, doneButton.frame.size.height/2);
    [doneButton setTitle:UIKitLocalizedString(@"Save") forState:UIControlStateNormal];
    doneButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    doneButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [doneButton setTitleColor:[UIColor colorWithRed:0 green:122/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(writeValues) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:doneButton];    
    
    CGRect pickerRect = CGRectMake(0, topView.frame.origin.y + topView.frame.size.height,  
                                   self.mainView.frame.size.width, 
                                   self.mainView.frame.size.height - (topView.frame.origin.y + topView.frame.size.height));
    self.colorPickerView = [[NKOColorPickerView alloc] initWithFrame:pickerRect color:self.customColor 
                                              andDidChangeColorBlock:^(UIColor *color) { self.customColor = color; }];
    self.colorPickerView.tintColor = [UIColor colorWithRed:200.0/255.0f green:201.0/255.0f blue:202.0/255.0f alpha:1.0];
    [self.mainView addSubview:self.colorPickerView];
        
    [self.view addSubview:self.mainView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:2.0 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.mainView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    } completion:nil];
    
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
                                                                          message:NSLocalizedStringFromTableInBundle(@"THIS_ACTION_CAN_NOT_BE_UNDONE", nil, self.cvkBunlde, nil) 
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    [warningAlert addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Delete")
                                                     style:UIAlertActionStyleDestructive 
                                                   handler:^(UIAlertAction *action) { 
                                                       if (self.prefs[self.cellIdentifier] != nil) {
                                                           [self.prefs removeObjectForKey:self.cellIdentifier];
                                                       }
                                                       [self.prefs writeToFile:self.prefsPath atomically:YES];
                                                       [self dismissPicker];
                                                   }]];
    [self presentViewController:warningAlert animated:YES completion:nil];
    
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
