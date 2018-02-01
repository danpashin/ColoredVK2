//
//  ColoredVKTextField.m
//  ColoredVK2
//
//  Created by Даниил on 06/01/2018.
//

#import "ColoredVKTextField.h"
#import "PrefixHeader.h"
#import <CoreGraphics/CoreGraphics.h>

@interface ColoredVKTextField () <CAAnimationDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UIButton *showButton;

@end

@implementation ColoredVKTextField

- (void)awakeFromNib
{
    _error = NO;
    
    [super awakeFromNib];
    [self setupLayout];
}

- (void)setupLayout
{
    self.layer.cornerRadius = 8.0f;
    self.backgroundColor = [UIColor colorWithRed:250/255.0f green:250/255.0f blue:250/255.0f alpha:1.0f];
    self.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    [self setError:NO animated:NO];
    
    if (![self.subviews containsObject:self.showButton]) {
        [self addSubview:self.showButton];
    }
    
    if (!CGSizeEqualToSize(self.frame.size, CGSizeZero)) {        
        self.showButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[showButton]|" options:0 metrics:nil views:@{@"showButton":self.showButton}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[showButton(width)]-4-|" options:0 metrics:@{@"width":@(CGRectGetHeight(self.frame))}
                                                                       views:@{@"showButton":self.showButton}]];
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
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        [self.delegate textField:self shouldChangeCharactersInRange:NSMakeRange(0, self.text.length) replacementString:@""];
    }
    self.text = nil;
}


#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    
    CGFloat height = CGRectGetHeight(frame);
    self.showButton.frame = CGRectMake(CGRectGetMaxX(frame) - height - 8, 0, height, height);
    [self setupLayout];
}

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


#pragma mark -
#pragma mark Getters
#pragma mark -

- (UIButton *)showButton
{
    if (!_showButton) {
        _showButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *clearImage = [UIImage imageNamed:@"DeleteIcon" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil];
        clearImage = [clearImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_showButton setImage:clearImage forState:UIControlStateNormal];
        _showButton.tintColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
        _showButton.hidden = YES;
        _showButton.alpha = 0.7f;
        [_showButton addTarget:self action:@selector(clearText) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showButton;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{    
    CGRect origRect = [super textRectForBounds:bounds];  
    
    return CGRectInset(origRect, 16, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect origRect = [super editingRectForBounds:bounds];
    
    return CGRectInset(origRect, 16, 0);
}

@end
