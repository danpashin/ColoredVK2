//
//  ColoredVKColorPicker.m
//  ColoredVK
//
//  Created by Даниил on 23.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//


#import "ColoredVKColorPicker.h"
#import "PrefixHeader.h"


@implementation ColoredVKColorPicker

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{    
    prefsPath = CVK_PREFS_PATH;
    cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    
    [super viewDidLoad];
    
    self.prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsPath];
    
    self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"SELECT_COLOR_TITLE", nil, cvkBunlde, nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(writeValues)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"#" style:UIBarButtonItemStylePlain target:self action:@selector(showHexWindow)];
    
    
    self.customColor = [UIColor savedColorForIdentifier:self.cellIdentifier];
    self.navigationController.navigationBar.barTintColor = [UIColor savedColorForIdentifier:@"BarBackgroundColor"];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [UINavigationBar appearanceWhenContainedIn:self.class, nil].titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] } ;
    
    UIView *mainView = [UIView new];
    mainView.backgroundColor = [UIColor whiteColor];
    mainView.frame = CGRectMake(0,self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    
    
    UIButton *resetButton = [[UIButton alloc] initWithFrame:CGRectMake(0, mainView.frame.origin.y - 15, mainView.frame.size.width, 32)];
    [resetButton setTitle:NSLocalizedStringFromTableInBundle(@"RESET_BUTTON_TITLE", nil, cvkBunlde, nil) forState:UIControlStateNormal];
    resetButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [resetButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor colorWithRed:0.8 green:0 blue:0 alpha:1.0] forState:UIControlStateHighlighted];
    resetButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    resetButton.titleLabel.numberOfLines = 2;
    resetButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    [resetButton setTitleShadowColor:[UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(addErrorAnimationForButton:) forControlEvents:UIControlEventTouchUpInside];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(resetColorValue)];
    longPress.minimumPressDuration = 1.0;
    longPress.numberOfTouchesRequired = 1;
    [resetButton addGestureRecognizer:longPress];
    [mainView addSubview:resetButton];
        
    
    CGRect pickerRect = CGRectMake(0,  resetButton.frame.origin.y + resetButton.frame.size.height,  mainView.frame.size.width, mainView.frame.size.height - 100);    
    NKOColorPickerDidChangeColorBlock colorDidChange = ^(UIColor *color){ self.customColor = color;};
    self.colorPickerView = [[NKOColorPickerView alloc] initWithFrame:pickerRect color:self.customColor andDidChangeColorBlock:colorDidChange];
    self.colorPickerView.tintColor = [UIColor colorWithRed:200.0/255.0f green:201.0/255.0f blue:202.0/255.0f alpha:1.0];
    [mainView addSubview:self.colorPickerView];
        
    [self.view addSubview:mainView];
    
    self.view.backgroundColor = mainView.backgroundColor;
    
    
//    mainView.translatesAutoresizingMaskIntoConstraints = NO;
//    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[resetButton(32)]-(10)-|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:NSDictionaryOfVariableBindings(resetButton)]];
//    [mainView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[resetButton(32)]-(10)-|"
//                                                                     options:0
//                                                                     metrics:nil
//                                                                       views:NSDictionaryOfVariableBindings(resetButton)]];
//    [mainView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[resetButton]|"
//                                                                       options:0
//                                                                       metrics:nil
//                                                                         views:NSDictionaryOfVariableBindings(resetButton)]];
//    [mainView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[colorPickerView]|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:NSDictionaryOfVariableBindings(self.colorPickerView)]];
//    
//    self.view.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainView]|"
//                                                                      options:0
//                                                                      metrics:nil
//                                                                        views:NSDictionaryOfVariableBindings(mainView)]];
//    
//    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainView]|"
//                                                                       options:0
//                                                                       metrics:nil
//                                                                         views:NSDictionaryOfVariableBindings(mainView)]];

}


- (void)writeValues 
{
    self.prefs[self.cellIdentifier] = [NSString stringFromColor:self.customColor];
    [self.prefs writeToFile:prefsPath atomically:YES];
    
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
    
    NSString *locString = NSLocalizedStringFromTableInBundle(@"ENTER_HEXEDECIMAL_COLOR_CODE_ALERT_MESSAGE", nil, cvkBunlde, nil);
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
    textField.placeholder = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"EXAMPLE_ALERT_MESSAGE", nil, cvkBunlde, nil), [NSString hexStringFromColor:self.customColor] ];
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
    valueButton.layer.cornerRadius = 5;
    [valueButton setTitle:NSLocalizedStringFromTableInBundle(@"ALERT_COPY_CURRENT_VALUE_TIILE", nil, cvkBunlde, nil) forState:UIControlStateNormal];
    valueButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [valueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    (valueButton.titleLabel).textAlignment = NSTextAlignmentCenter;
    [valueButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:80.0/255.0f green:102.0/255.0f blue:151.0/255.0f alpha:1]] forState:UIControlStateNormal];
    [valueButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:68.0/255.0f green:92.0/255.0f blue:156.0/255.0f alpha:1]] forState:UIControlStateHighlighted];
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
                                              [button setTitle:NSLocalizedStringFromTableInBundle(@"TAP_AND_HOLD_BUTTON_TITLE", nil, cvkBunlde, nil) forState:UIControlStateNormal];
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
    [self.prefs writeToFile:prefsPath atomically:YES];
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
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.keyPath = @"position.x";
        animation.values = @[ @0, @10, @-10, @10, @0 ];
        animation.keyTimes = @[ @0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1 ];
        animation.duration = 0.3;
        animation.additive = YES;
        [textField.layer addAnimation:animation forKey:@"shake"];
    } else {
        textField.layer.borderColor = [UIColor clearColor].CGColor;
        
        self.customColor = [UIColor colorFromHexString:textField.text];
        self.colorPickerView.color = self.customColor;
    }
    [textField resignFirstResponder];
    return YES;
}
@end
