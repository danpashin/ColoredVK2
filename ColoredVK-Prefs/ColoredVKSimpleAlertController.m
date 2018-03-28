//
//  ColoredVKSimpleAlertController.m
//  ColoredVK2
//
//  Created by Даниил on 20.06.17.
//
//

#import "ColoredVKSimpleAlertController.h"
#import "PrefixHeader.h"
#import "UIImage+ColoredVK.h"
#import "ColoredVKNewInstaller.h"
#import "ColoredVKNightThemeColorScheme.h"

static CGFloat const viewsHeight = 32.0f;


@implementation ColoredVKSimpleAlertController

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)viewDidLoad
{
    self.contentViewWantsShadow = NO;
    self.statusBarNeedsHidden = YES;
    self.hideByTouch = YES;
    
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    tap.delegate = self;
    [self.scrollView addGestureRecognizer:tap];
    [self.view addSubview:self.scrollView];
    
    
    self.contentView = [UIView new];
    self.contentView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width - 60.0f, 120.0f);
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 6.0f;
    [self.scrollView addSubview:self.contentView];
    
    
    CGFloat width = self.view.frame.size.width - 10.0f;
    
    self.titleLabel.frame = CGRectMake(0.0f, 0.0f, width, viewsHeight * 1.5f);
    [self.contentView addSubview:self.titleLabel];
    
    
    self.textField.frame = CGRectMake(0.0f, CGRectGetMaxY(self.titleLabel.frame), width, viewsHeight);
    [self.contentView addSubview:self.textField];
    
    
    self.button.frame = CGRectMake(0.0f, CGRectGetMaxY(self.textField.frame), width, viewsHeight);
    [self.contentView addSubview:self.button];
    
    [self setupConstraints];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ColoredVKNightThemeColorScheme *nightThemeColorScheme = [ColoredVKNightThemeColorScheme sharedScheme];
    BOOL isVKApp = [ColoredVKNewInstaller sharedInstaller].application.isVKApp;
    if (isVKApp && nightThemeColorScheme.enabled) {
        self.textField.backgroundColor = nightThemeColorScheme.backgroundColor;
        self.contentView.backgroundColor = nightThemeColorScheme.foregroundColor;
    } else 
        self.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)setupConstraints
{
    [self.view removeConstraints:self.view.constraints];
    [self.contentView removeConstraints:self.contentView.constraints];
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:@{@"scrollView":self.scrollView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:nil views:@{@"scrollView":self.scrollView}]];
    
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleLabel]-|" options:0 metrics:nil views:@{@"titleLabel":self.titleLabel}]];
    
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[textField]-|" options:0 metrics:nil views:@{@"textField":self.textField}]];
    
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[button]-|" options:0 metrics:nil views:@{@"button":self.button}]];
    
    NSDictionary *verticalMetrics = @{@"titleHeight":@(viewsHeight * 1.5f), @"textFieldHeight":@(viewsHeight), @"buttonHeight":@(viewsHeight)};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabel(titleHeight)]-[textField(textFieldHeight)]-[button(buttonHeight)]-|" options:0
                                                                             metrics:verticalMetrics
                                                                               views:@{@"titleLabel":self.titleLabel, @"textField":self.textField, @"button":self.button}]];
    
    CGFloat height = 0;
    for (NSNumber *number in verticalMetrics.allValues) {
        height += number.floatValue;
    }
    height += (self.contentView.subviews.count + 1.0f) * 8.0f;
    
    CGFloat width = (self.prefferedWidth > 0.0f) ? self.prefferedWidth : CGRectGetWidth(self.contentView.frame);
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:0 toItem:self.scrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:0 toItem:self.scrollView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:0 toItem:nil attribute:0 multiplier:1 constant:width]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:0 toItem:nil attribute:0 multiplier:1 constant:height]];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect kbRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.scrollView.contentOffset = CGPointMake(0, kbRect.size.height/2);
}

- (void)keyboardWillHide
{
    self.scrollView.contentOffset = CGPointZero;
}

- (void)setPrefferedWidth:(CGFloat)prefferedWidth
{
    _prefferedWidth = prefferedWidth;
    
    self.contentView.frame = CGRectMake(CGRectGetMinX(self.contentView.frame), CGRectGetMinY(self.contentView.frame), prefferedWidth, CGRectGetHeight(self.contentView.frame));
    [self setupConstraints];
}

- (void)show
{
    [super show];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.contentView.alpha = 0.0f;
        self.contentView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        
        [UIView animateWithDuration:0.6f delay:0.0 usingSpringWithDamping:0.8f initialSpringVelocity:15.0f options:0.0f
                         animations:^{
                             self.contentView.alpha = 1.0;
                             self.contentView.transform = CGAffineTransformIdentity;
                         } completion:nil];
    });
}

- (void)hide
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval bounce1Duration = 0.13f;
        NSTimeInterval bounce2Duration = (bounce1Duration * 2.0f);
        
        [UIView animateWithDuration:bounce1Duration delay:0.0f options:UIViewAnimationOptionCurveEaseOut
                         animations:^(void){
                             self.contentView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                         } completion:^(BOOL firstFinished) {
                             
                             [UIView animateWithDuration:bounce2Duration delay:0.0f options:UIViewAnimationOptionCurveEaseIn
                                              animations:^(void){
                                                  self.contentView.alpha = 0.0f;
                                                  self.contentView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                                              } completion:^(BOOL secondFinished){
                                                  [super hide];
                                              }];
                         }];
    });
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (![touch.view isDescendantOfView:self.contentView] && self.hideByTouch) return YES;
    return NO;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 2;
        
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UITextField *)textField
{
    if (!_textField) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.returnKeyType = UIReturnKeyDone;
        textField.textAlignment = NSTextAlignmentCenter;
        textField.layer.cornerRadius = 5.0f;
        textField.layer.masksToBounds = YES;
        textField.layer.borderWidth = 1.0f;
        textField.layer.borderColor = [UIColor clearColor].CGColor;
        
        _textField = textField;
    }
    
    return _textField;
}

- (UIButton *)button
{
    if (!_button) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 5.0f;
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:80/255.0f green:102/255.0f blue:151/255.0f alpha:1.0]] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:60/255.0f green:82/255.0f blue:131/255.0f alpha:1.0]] forState:UIControlStateHighlighted];
        
        _button = button;
    }
    return _button;
}

@end
