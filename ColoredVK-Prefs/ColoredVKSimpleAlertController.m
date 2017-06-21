//
//  ColoredVKSimpleAlertController.m
//  ColoredVK2
//
//  Created by Даниил on 20.06.17.
//
//

#import "ColoredVKSimpleAlertController.h"
#import "PrefixHeader.h"

static CGFloat const viewsHeight = 30.0f;


@implementation ColoredVKSimpleAlertController

- (void)viewDidLoad
{
    self.contentViewWantsShadow = NO;
    self.statusBarNeedsHidden = YES;
    self.hideByTouch = NO;
    
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
    [self.view addSubview:self.scrollView];
    
    
    self.contentView = [UIView new];
    self.contentView.frame = CGRectMake(0, 0, self.view.frame.size.width - 60, 120);
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 6;
    self.contentView.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.contentView];
    
    
    CGFloat width = self.view.frame.size.width - 10;
    
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, viewsHeight * 1.5)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.numberOfLines = 2;
    [self.contentView addSubview:self.titleLabel];
    
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), width, viewsHeight)];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.textAlignment = NSTextAlignmentCenter;
    self.textField.layer.cornerRadius = 5.0f;
    self.textField.layer.masksToBounds = YES;
    self.textField.layer.borderWidth = 1.0f;
    self.textField.layer.borderColor = [UIColor clearColor].CGColor;
    [self.contentView addSubview:self.textField];
    
    
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, viewsHeight)];
    self.button.layer.masksToBounds = YES;
    self.button.layer.cornerRadius = 6;
    self.button.layer.borderColor = [UIColor colorWithRed:80.0/255.0f green:102.0/255.0f blue:151.0/255.0f alpha:1].CGColor;
    self.button.layer.borderWidth = 1.0;
    self.button.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.button setTitleColor:[UIColor colorWithRed:80.0/255.0f green:102.0/255.0f blue:151.0/255.0f alpha:1] forState:UIControlStateNormal];
    [self.button setTitleColor:[UIColor colorWithRed:60.0/255.0f green:82.0/255.0f blue:131.0/255.0f alpha:1] forState:UIControlStateHighlighted];
    self.button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.button addTarget:self action:@selector(highlightButtonBorder:) forControlEvents:UIControlEventTouchDragEnter];
    [self.button addTarget:self action:@selector(unHighlightButtonBorder:) forControlEvents:UIControlEventTouchDragExit];
    [self.contentView addSubview:self.button];
    
    [self setupConstraints];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupConstraints
{
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:@{@"scrollView":self.scrollView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:nil views:@{@"scrollView":self.scrollView}]];
    
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleLabel]-|" options:0 metrics:nil views:@{@"titleLabel":self.titleLabel}]];
    
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[textField]-|" options:0 metrics:nil views:@{@"textField":self.textField}]];
    
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[button]-|" options:0 metrics:nil views:@{@"button":self.button}]];
    
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabel]-[textField]-[button]-|" options:0
                                                                             metrics:nil
                                                                               views:@{@"titleLabel":self.titleLabel, @"textField":self.textField, @"button":self.button}]];
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:0 toItem:self.scrollView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:0 toItem:self.scrollView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:0 toItem:nil attribute:0 multiplier:1 constant:CGRectGetWidth(self.contentView.frame)]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:0 toItem:nil attribute:0 multiplier:1 constant:CGRectGetHeight(self.contentView.frame)]];
}

- (void)highlightButtonBorder:(UIButton *)button
{
    button.layer.borderColor = [UIColor colorWithRed:60.0/255.0f green:82.0/255.0f blue:131.0/255.0f alpha:1].CGColor;
}

- (void)unHighlightButtonBorder:(UIButton *)button
{
    button.layer.borderColor = [UIColor colorWithRed:80.0/255.0f green:102.0/255.0f blue:151.0/255.0f alpha:1].CGColor;
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

- (void)show
{
    [super show];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.contentView.alpha = 0.0;
        self.contentView.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:15.0 options:0
                         animations:^{
                             self.contentView.alpha = 1.0;
                             self.contentView.transform = CGAffineTransformIdentity;
                         } completion:nil];
    });
}

- (void)hide
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval bounce1Duration = 0.13;
        NSTimeInterval bounce2Duration = (bounce1Duration * 2.0);
        
        [UIView animateWithDuration:bounce1Duration delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^(void){
                             self.contentView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         } completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:bounce2Duration delay:0  options:UIViewAnimationOptionCurveEaseIn
                                              animations:^(void){
                                                  self.contentView.alpha = 0.0;
                                                  self.contentView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                              } completion:^(BOOL finished){
                                                  [super hide];
                                              }];
                         }];
    });
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end
