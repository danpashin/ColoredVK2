//
//  PPNumberButton.m
//  PPNumberButton
//
//  Created by AndyPang on 16/8/31.
//  Copyright © 2016年 AndyPang. All rights reserved.
//

#import "PPNumberButton.h"

#ifdef DEBUG
#define PPLog(...) printf("[%s] %s [第%d行]: %s\n", __TIME__ ,__PRETTY_FUNCTION__ ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define PPLog(...)
#endif


@interface PPNumberButton () <UITextFieldDelegate>
/** 减按钮*/
@property (nonatomic, strong) UIButton *decreaseBtn;
/** 加按钮*/
@property (nonatomic, strong) UIButton *increaseBtn;
/** 数量展示/输入框*/
@property (nonatomic, strong) UITextField *textField;
/** 快速加减定时器*/
@property (nonatomic, strong) NSTimer *timer;
/** 控件自身的宽*/
@property (nonatomic, assign) CGFloat width;
/** 控件自身的高*/
@property (nonatomic, assign) CGFloat height;

@end


@implementation PPNumberButton

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupUI];
        //整个控件的默认尺寸(和某宝上面的按钮同样大小)
        if(CGRectIsEmpty(frame)) { self.frame = CGRectMake(0, 0, 110, 30); };
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self setupUI];
    }
    return self;
}

+ (instancetype)numberButtonWithFrame:(CGRect)frame
{
    return [[PPNumberButton alloc] initWithFrame:frame];
}
#pragma mark - 设置UI子控件
- (void)setupUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 3.f;
    self.clipsToBounds = YES;
    
    _minValue = 1;
    _maxValue = NSIntegerMax;
    _inputFieldFont = 15;
    _buttonTitleFont = 17;
    
    //加,减按钮
    self.increaseBtn = [self creatButton];
    self.decreaseBtn = [self creatButton];
    [self addSubview:self.decreaseBtn];
    [self addSubview:self.increaseBtn];
    
    //数量展示/输入框
    self.textField = [[UITextField alloc] init];
    self.textField.delegate = self;
    self.textField.textAlignment = NSTextAlignmentCenter;
    self.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.textField.font = [UIFont systemFontOfSize:self.inputFieldFont];
    self.textField.text = [NSString stringWithFormat:@"%@", @(self.minValue)];
    
    [self addSubview:_textField];
}

//设置加减按钮的公共方法
- (UIButton *)creatButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:self.buttonTitleFont];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchUpInside|UIControlEventTouchCancel];
    return button;
}

#pragma mark - layoutSubviews
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.width =  self.frame.size.width;
    self.height = self.frame.size.height;
    self.textField.frame = CGRectMake(self.height, 0, self.width - 2*self.height, self.height);
    self.increaseBtn.frame = CGRectMake(self.width - self.height, 0, self.height, self.height);
    
    if (self.decreaseHide && self.textField.text.integerValue < self.minValue) {
        self.decreaseBtn.frame = CGRectMake(self.width-self.height, 0, self.height, self.height);
    } else {
        self.decreaseBtn.frame = CGRectMake(0, 0, self.height, self.height);
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self checkTextFieldNumberWithUpdate];
    [self buttonClickCallBackWithIncreaseStatus:NO];
}

#pragma mark - 加减按钮点击响应
/**
 点击: 单击逐次加减,长按连续快速加减
 */
- (void)touchDown:(UIButton *)sender
{
    [self.textField resignFirstResponder];
    
    if (sender == self.increaseBtn) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(increase) userInfo:nil repeats:YES];
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(decrease) userInfo:nil repeats:YES];
    }
    [self.timer fire];
}

/**
 手指松开
 */
- (void)touchUp:(UIButton *)sender { [self cleanTimer]; }

/**
 加运算
 */
- (void)increase
{
    [self checkTextFieldNumberWithUpdate];
    
    NSInteger number = _textField.text.integerValue + 1;
    
    if (number <= self.maxValue) {
        // 当按钮为"减号按钮隐藏模式",且输入框值==设定最小值,减号按钮展开
        if (self.decreaseHide && number == self.minValue) {
            [self rotationAnimationMethod];
            [UIView animateWithDuration:0.3f animations:^{
                self.decreaseBtn.alpha = 1;
                self.decreaseBtn.frame = CGRectMake(0, 0, self.height, self.height);
            } completion:^(BOOL finished) {
                self.textField.hidden = NO;
            }];
        }
        self.textField.text = [NSString stringWithFormat:@"%@", @(number)];
        
        [self buttonClickCallBackWithIncreaseStatus:YES];
    } else {
        if (self.shakeAnimation) { [self shakeAnimationMethod]; } PPLog(@"已超过最大数量%ld",_maxValue);
    }
}

/**
 减运算
 */
- (void)decrease
{
    [self checkTextFieldNumberWithUpdate];
    
    NSInteger number = (_textField.text).integerValue - 1;
    
    if (number >= self.minValue) {
        self.textField.text = [NSString stringWithFormat:@"%@", @(number)];
        [self buttonClickCallBackWithIncreaseStatus:NO];
    } else {
        // 当按钮为"减号按钮隐藏模式",且输入框值 < 设定最小值,减号按钮隐藏
        if (self.decreaseHide && number < self.minValue) {
            self.textField.hidden = YES;
            self.textField.text = [NSString stringWithFormat:@"%@",@(self.minValue-1)];
            
            [self buttonClickCallBackWithIncreaseStatus:NO];
            [self rotationAnimationMethod];
            
            [UIView animateWithDuration:0.3f animations:^{
                self.decreaseBtn.alpha = 0;
                self.decreaseBtn.frame = CGRectMake(self.width-self.height, 0, self.height, self.height);
            }];

            return;
        }
        if (self.shakeAnimation) { [self shakeAnimationMethod]; } PPLog(@"数量不能小于%ld",_minValue);
    }
}

/**
 点击响应
 */
- (void)buttonClickCallBackWithIncreaseStatus:(BOOL)increaseStatus
{
    self.resultBlock ? self.resultBlock(_textField.text.integerValue, increaseStatus) : nil;
    if ([self.delegate respondsToSelector:@selector(pp_numberButton: number: increaseStatus:)]) {
        [self.delegate pp_numberButton:self number:self.textField.text.integerValue increaseStatus:increaseStatus];
    }
}

/**
 检查TextField中数字的合法性,并修正
 */
- (void)checkTextFieldNumberWithUpdate
{
    NSString *minValueString = [NSString stringWithFormat:@"%@", @(self.minValue)];
    NSString *maxValueString = [NSString stringWithFormat:@"%@", @(self.maxValue)];
    
    if (!(self.textField.text).pp_isNotBlank || self.textField.text.integerValue < self.minValue) {
        self.textField.text = self.decreaseHide ? [NSString stringWithFormat:@"%@", @(minValueString.integerValue-1)]:minValueString;
    }
    self.textField.text.integerValue > self.maxValue ? self.textField.text = maxValueString : nil;
}

/**
 清除定时器
 */
- (void)cleanTimer
{
    if (self.timer.isValid) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - 加减按钮的属性设置

- (void)setDecreaseHide:(BOOL)decreaseHide
{
    // 当按钮为"减号按钮隐藏模式(饿了么/百度外卖/美团外卖按钮样式)"
    if (decreaseHide) {
        if (self.textField.text.integerValue <= self.minValue) {
            self.textField.hidden = YES;
            self.decreaseBtn.alpha = 0;
            self.textField.text = [NSString stringWithFormat:@"%@", @(self.minValue-1)];
            self.decreaseBtn.frame = CGRectMake(self.width-self.height, 0, self.height, self.height);
        }
        self.backgroundColor = [UIColor clearColor];
    } else {
        self.decreaseBtn.frame = CGRectMake(0, 0, self.height, self.height);
    }
    _decreaseHide = decreaseHide;
}

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
    self.textField.enabled = editing;
}

- (void)setMinValue:(NSInteger)minValue
{
    _minValue = minValue;
    self.textField.text = [NSString stringWithFormat:@"%@", @(minValue)];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = borderColor.CGColor;
    
    self.decreaseBtn.layer.borderWidth = 0.5;
    self.decreaseBtn.layer.borderColor = borderColor.CGColor;
    
    self.increaseBtn.layer.borderWidth = 0.5;
    self.increaseBtn.layer.borderColor = borderColor.CGColor;
}

- (void)setButtonTitleFont:(CGFloat)buttonTitleFont
{
    self.buttonTitleFont = buttonTitleFont;
    self.increaseBtn.titleLabel.font = [UIFont boldSystemFontOfSize:buttonTitleFont];
    self.decreaseBtn.titleLabel.font = [UIFont boldSystemFontOfSize:buttonTitleFont];
}

- (void)setIncreaseTitle:(NSString *)increaseTitle
{
    _increaseTitle = increaseTitle;
    [self.increaseBtn setTitle:increaseTitle forState:UIControlStateNormal];
}

- (void)setDecreaseTitle:(NSString *)decreaseTitle
{
    _decreaseTitle = decreaseTitle;
    [self.decreaseBtn setTitle:decreaseTitle forState:UIControlStateNormal];
}

- (void)setIncreaseImage:(UIImage *)increaseImage
{
    _increaseImage = increaseImage;
    [self.increaseBtn setBackgroundImage:increaseImage forState:UIControlStateNormal];
}

- (void)setDecreaseImage:(UIImage *)decreaseImage
{
    _decreaseImage = decreaseImage;
    [self.decreaseBtn setBackgroundImage:decreaseImage forState:UIControlStateNormal];
}

#pragma mark - 输入框中的内容设置
- (NSInteger)currentNumber { return _textField.text.integerValue; }

- (void)setCurrentNumber:(NSInteger)currentNumber
{
    if (self.decreaseHide && currentNumber < self.minValue) {
        self.textField.hidden = YES;
        self.decreaseBtn.alpha = 0;
        self.decreaseBtn.frame = CGRectMake(self.width-_height, 0, self.height, self.height);
    } else {
        self.textField.hidden = NO;
        self.decreaseBtn.alpha = 1;
        self.decreaseBtn.frame = CGRectMake(0, 0, self.height, self.height);
    }
    self.textField.text = [NSString stringWithFormat:@"%@", @(currentNumber)];
    [self checkTextFieldNumberWithUpdate];
}

- (void)setInputFieldFont:(CGFloat)inputFieldFont
{
    _inputFieldFont = inputFieldFont;
    self.textField.font = [UIFont systemFontOfSize:inputFieldFont];
}
#pragma mark - 核心动画
/**
 抖动动画
 */
- (void)shakeAnimationMethod
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    CGFloat positionX = self.layer.position.x;
    animation.values = @[@(positionX-10),@(positionX),@(positionX+10)];
    animation.repeatCount = 3;
    animation.duration = 0.07;
    animation.autoreverses = YES;
    [self.layer addAnimation:animation forKey:nil];
}
/**
 旋转动画
 */
- (void)rotationAnimationMethod
{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotationAnimation.toValue = @(M_PI*2);
    rotationAnimation.duration = 0.3f;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    [self.decreaseBtn.layer addAnimation:rotationAnimation forKey:nil];
}
@end

#pragma mark - NSString分类

@implementation NSString (PPNumberButton)
- (BOOL)pp_isNotBlank
{
    NSCharacterSet *blank = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![blank characterIsMember:c]) {
            return YES;
        }
    }
    return NO;
}

@end
