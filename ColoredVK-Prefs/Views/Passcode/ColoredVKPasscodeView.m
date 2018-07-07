//
//  ColoredVKPasscodeView.m
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import "ColoredVKPasscodeView.h"
#import "PrefixHeader.h"

#import "ColoredVKPasscodeCircle.h"
#import "ColoredVKPasscodeButton.h"

@interface ColoredVKPasscodeView () <CAAnimationDelegate>

@property (strong, nonatomic) IBOutlet UIStackView *numbersStackView;
@property (strong, nonatomic) IBOutlet UIStackView *circlesStackView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *circlesStackWidthConstraint;

@end

@implementation ColoredVKPasscodeView

+ (instancetype)viewForOwner:(id)owner
{
    NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    NSArray *nibViews = [cvkBundle loadNibNamed:NSStringFromClass([self class]) owner:owner options:nil];
    return nibViews.firstObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.maxDigits = 4;
    _passcode = [NSMutableString string];
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (IBAction)buttonPressed:(UIButton *)button
{
    if ([button isEqual:self.bottomRightButton]) {
        if (self.passcode.length == 0) {
            if ([self.delegate respondsToSelector:@selector(passcodeView:didTapBottomButton:)])
                [self.delegate passcodeView:self didTapBottomButton:self.bottomRightButton];
            return;
        }
        
        [self.passcode deleteCharactersInRange:NSMakeRange(self.passcode.length-1, 1)];
        [self updateCirclesByAddingChar:NO];
    }
    else if ([button isEqual:self.bottomLeftButton]) {
        if ([self.delegate respondsToSelector:@selector(passcodeView:didTapBottomButton:)])
            [self.delegate passcodeView:self didTapBottomButton:self.bottomLeftButton];
        
        return;
    }
    else if (self.passcode.length + 1 <= self.maxDigits) {
        [self.passcode appendString:button.titleLabel.text];
        [self updateCirclesByAddingChar:YES];
        
        if (self.passcode.length == self.maxDigits) {
            if ([self.delegate respondsToSelector:@selector(passcodeView:didUpdatedPasscode:)])
                [self.delegate passcodeView:self didUpdatedPasscode:self.passcode];
            
            return;
        }
    }
    
    [self updateCancelButton];
}

- (void)updateCirclesByAddingChar:(BOOL)addingChar
{
    if (self.passcode.length > self.maxDigits)
        return;
    
    ColoredVKPasscodeCircle *circle = self.circlesStackView.arrangedSubviews[self.passcode.length - (addingChar ? 1 : 0)];
    [circle setFilled:!circle.filled animated:circle.filled];
}

- (void)updateCancelButton
{
    BOOL selected = (self.passcode.length != 0);
    self.bottomRightButton.titleLabel.layer.transform = selected ? CATransform3DMakeScale(0, 0, 0) : CATransform3DIdentity;
    self.bottomRightButton.selected = selected;
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    self.titleLabel.textColor = self.tintColor;
    
    for (UIStackView *stackView in self.numbersStackView.arrangedSubviews) {
        for (UIButton *button in stackView.arrangedSubviews) {
            button.tintColor = self.tintColor;
        }
    }
}


#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setInvalidPasscode:(BOOL)invalidPasscode
{
    _invalidPasscode = invalidPasscode;
    
    if (!self.invalidPasscode)
        return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSUInteger i=0; i<self.maxDigits; i++) {
            ColoredVKPasscodeCircle *circle = self.circlesStackView.subviews[i];
            [circle setFilled:YES animated:NO];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
            animation.delegate = self;
            CGFloat positionX = self.circlesStackView.layer.position.x;
            animation.values = @[@(positionX - 5.0f), @(positionX), @(positionX + 5.0f)];
            animation.repeatCount = 3.0f;
            animation.duration = 0.07f;
            animation.autoreverses = YES;
            [self.circlesStackView.layer addAnimation:animation forKey:nil];
        });
    });
}

- (void)setMaxDigits:(NSUInteger)maxDigits
{
    if (maxDigits < 4)
        maxDigits = 4;
    
    if (maxDigits != self.maxDigits) {
        _maxDigits = maxDigits;
        
        for (UIView *subview in self.circlesStackView.arrangedSubviews) {
            [subview removeFromSuperview];
        }
        
        CGFloat circleHeight = 12.0f;
        CGRect frame = CGRectMake(0, 0, circleHeight, circleHeight);
        for (NSUInteger i=0; i<maxDigits; i++) {
            ColoredVKPasscodeCircle *circle = [[ColoredVKPasscodeCircle alloc] initWithFrame:frame];
            [self.circlesStackView addArrangedSubview:circle];
            
            circle.translatesAutoresizingMaskIntoConstraints = NO;
            [circle.heightAnchor constraintEqualToConstant:circleHeight].active = YES;
            [circle.widthAnchor constraintEqualToConstant:circleHeight].active = YES;
        }
        
        self.circlesStackWidthConstraint.constant = circleHeight * maxDigits + self.circlesStackView.spacing * (maxDigits - 1);
    }
}

#pragma mark -
#pragma mark CAAnimationDelegate
#pragma mark -

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.invalidPasscode) {
        _invalidPasscode = NO;
        for (NSUInteger i=0; i<self.maxDigits; i++) {
            ColoredVKPasscodeCircle *circle = self.circlesStackView.subviews[i];
            [circle setFilled:NO animated:YES];
        }
        [self.passcode setString:@""];
        [self updateCancelButton];
    }
}

@end
