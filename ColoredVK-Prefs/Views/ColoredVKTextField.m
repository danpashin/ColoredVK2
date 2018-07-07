//
//  ColoredVKTextField.m
//  ColoredVK2
//
//  Created by Даниил on 06/01/2018.
//

#import "ColoredVKTextField.h"
#import <CoreGraphics/CoreGraphics.h>
#import "ColoredVKNightScheme.h"

@interface ColoredVKTextField () <CAAnimationDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIButton *securedShowButton;

@end

@implementation ColoredVKTextField

@dynamic delegate;

- (void)awakeFromNib
{
    _error = NO;
    
    [super awakeFromNib];
    
    self.layer.cornerRadius = 8.0f;
    self.backgroundColor = [UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1.0f];
    self.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    [self setError:NO animated:NO];
    
    if ([self respondsToSelector:@selector(textContentType)]) {
        if ([self.textContentType containsString:@"pass"]) {
            self.rightView = self.securedShowButton;
            self.rightViewMode = UITextFieldViewModeWhileEditing;
        }
    }
    
    [self addTarget:self action:@selector(didChangeText) forControlEvents:UIControlEventEditingChanged];
    
    ColoredVKNightScheme *nightScheme = [ColoredVKNightScheme sharedScheme];
    if (nightScheme.enabled) {
        self.backgroundColor = nightScheme.foregroundColor;
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    self.tintColor = CVKMainColor;
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (void)shake
{
    self.error = YES;
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    CGFloat positionX = self.layer.position.x;
    animation.values = @[@(positionX-5),@(positionX),@(positionX+5)];
    animation.repeatCount = 3;
    animation.duration = 0.07;
    animation.autoreverses = YES;
    [self.layer addAnimation:animation forKey:nil];
}

- (void)clear
{
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
        [self.delegate textField:self shouldChangeCharactersInRange:NSMakeRange(0, self.text.length) replacementString:@""];
    
    self.text = @"";
}

- (void)didChangeText
{    
    BOOL removeWhiteSpaces = NO;
    if ([self.delegate respondsToSelector:@selector(textFieldShouldRemoveWhiteSpaces:)])
        removeWhiteSpaces = [self.delegate textFieldShouldRemoveWhiteSpaces:self];
    
    if (removeWhiteSpaces) {
        self.text = [self.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
            [self.delegate textField:self shouldChangeCharactersInRange:NSMakeRange(0, self.text.length) replacementString:self.text];
        
        if ([self.delegate respondsToSelector:@selector(textField:didChangeText:)])
            [self.delegate textField:self didChangeText:self.text];
    }
}

- (void)updateSecureState:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.secureTextEntry = !self.secureTextEntry;
    
    NSString *text = self.text;
    self.text = @"";
    self.text = text;
}


#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setError:(BOOL)error
{
    [self setError:error animated:YES];
}

- (void)setError:(BOOL)error animated:(BOOL)animated
{
    _error = error;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIColor *layerColor = error ? [UIColor redColor] : [UIColor colorWithRed:202/255.0f green:202/255.0f blue:202/255.0f alpha:1.0f];
        CGFloat borderWidth = error ? 1.0f : 0.5f;
        
        ColoredVKNightScheme *nightScheme = [ColoredVKNightScheme sharedScheme];
        if (nightScheme.enabled && !error) {
            layerColor = nightScheme.backgroundColor;
        }
        
        void (^configuringBlock)(void) = ^{
            self.layer.borderColor = layerColor.CGColor;
            self.layer.borderWidth = borderWidth;
        };
        
        if (animated) {
            CABasicAnimation *borderColorAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
            borderColorAnimation.fromValue = (__bridge id _Nullable)(self.layer.borderColor);
            borderColorAnimation.toValue = (__bridge id _Nullable)(layerColor.CGColor);
            borderColorAnimation.duration = 0.3f;
            
            CABasicAnimation *borderWidthAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
            borderWidthAnimation.fromValue = @(self.layer.borderWidth);
            borderWidthAnimation.toValue = @(borderWidth);
            borderWidthAnimation.duration = 0.3f;
            
            CAAnimationGroup *allAnimations = [[CAAnimationGroup alloc] init];
            allAnimations.animations = @[borderColorAnimation, borderWidthAnimation];
            
            configuringBlock();
            [self.layer addAnimation:allAnimations forKey:@"layerAnimation"];
        } else {
            configuringBlock();
        }
    });
}

- (void)setTextContentType:(UITextContentType)textContentType
{
    super.textContentType = textContentType;
    
    if ([textContentType containsString:@"pass"]) {
        self.secureTextEntry = YES;
    }
}


#pragma mark -
#pragma mark Getters
#pragma mark -

- (UIButton *)securedShowButton
{
    if (!_securedShowButton) {
        _securedShowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _securedShowButton.frame = [self rightViewRectForBounds:self.bounds];
        [_securedShowButton addTarget:self action:@selector(updateSecureState:) forControlEvents:UIControlEventTouchUpInside];
        _securedShowButton.accessibilityLabel = CVKLocalizedString(@"SHOW_HIDE_PASSWORD");
        
        NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        UIImage *viewIcon = [UIImage imageNamed:@"user/ViewIcon" inBundle:cvkBundle compatibleWithTraitCollection:nil];
        UIImage *viewIconSelected = [UIImage imageNamed:@"user/ViewIcon-selected" inBundle:cvkBundle compatibleWithTraitCollection:nil];
        [_securedShowButton setImage:viewIcon forState:UIControlStateNormal];
        [_securedShowButton setImage:viewIconSelected forState:UIControlStateSelected];
    }
    return _securedShowButton;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{    
    CGRect origRect = [super textRectForBounds:bounds];  
    
    return CGRectInset(origRect, 16.0f, 0.0f);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect origRect = [super editingRectForBounds:bounds];
    
    return CGRectInset(origRect, 16.0f, 0.0f);
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
    CGFloat boundsWidth = CGRectGetWidth(self.bounds);
    
    return CGRectMake(boundsWidth - boundsHeight, 0, boundsHeight, boundsHeight);
}

@end
