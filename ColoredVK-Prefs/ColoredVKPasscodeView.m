//
//  ColoredVKPasscodeView.m
//  ColoredVK2
//
//  Created by Даниил on 24.03.18.
//

#import "ColoredVKPasscodeView.h"
#import "PrefixHeader.h"
#import "UIImage+ColoredVK.h"
#import "ColoredVKPasscodeCircle.h"

@interface ColoredVKPasscodeView ()
@property (strong, nonatomic) NSBundle *cvkBundle;

@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *fingerButton;
@property (strong, nonatomic) IBOutlet UIStackView *circlesStackView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *circlesStackWidthConstraint;

@end

@implementation ColoredVKPasscodeView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.maxDigits = 4;
    _passcode = [NSMutableString string];
    self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    
    self.cancelButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self updateCancelButton];
}


#pragma mark -
#pragma mark Actions
#pragma mark -

- (IBAction)buttonPressed:(UIButton *)button
{
    if ([button isEqual:self.cancelButton]) {
        if (self.passcode.length == 0) {
            if ([self.delegate respondsToSelector:@selector(passcodeViewRequestedDismiss:)])
                [self.delegate passcodeViewRequestedDismiss:self];
            
            return;
        }
        
        [self.passcode deleteCharactersInRange:NSMakeRange(self.passcode.length-1, 1)];
        [self updateCirclesByAddingChar:NO];
    } 
    else if ([button isEqual:self.fingerButton]) {
        BOOL supportsBiometric = (self.supportsTouchID || self.supportsFaceID);
        if (supportsBiometric && [self.delegate respondsToSelector:@selector(passcodeViewRequestedBiometric:)])
            [self.delegate passcodeViewRequestedBiometric:self];
        
        return;
    } 
    else if (self.passcode.length + 1 > self.maxDigits) {
        [self addErrorAnimation];
        return;
    } 
    else {
        [self.passcode appendString:button.titleLabel.text];
        [self updateCirclesByAddingChar:YES];
    }
    
    [self updateCancelButton];
    
    if ([self.delegate respondsToSelector:@selector(passcodeView:didUpdatedPasscode:)])
        [self.delegate passcodeView:self didUpdatedPasscode:self.passcode];
}

- (void)updateCancelButton
{
    NSString *title = (self.passcode.length != 0) ? CVKLocalizedStringInBundle(@"DELETE", self.cvkBundle) : UIKitLocalizedString(@"Cancel");
    [self.cancelButton setTitle:title forState:UIControlStateNormal];
}

- (void)updateCirclesByAddingChar:(BOOL)addingChar
{
    if (self.passcode.length > self.maxDigits)
        return;
    
    ColoredVKPasscodeCircle *circle = self.circlesStackView.subviews[self.passcode.length - (addingChar ? 1 : 0)];
    [circle setFilled:!circle.filled animated:circle.filled];
}

- (void)addErrorAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    CGFloat positionX = self.circlesStackView.layer.position.x;
    animation.values = @[@(positionX - 5.0f), @(positionX), @(positionX + 5.0f)];
    animation.repeatCount = 3.0f;
    animation.duration = 0.07f;
    animation.autoreverses = YES;
    [self.circlesStackView.layer addAnimation:animation forKey:nil];
}


#pragma mark -
#pragma mark Setters
#pragma mark -

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

- (void)setSupportsTouchID:(BOOL)supportsTouchID
{
    _supportsTouchID = supportsTouchID;
    
    if (supportsTouchID) {
        UIImage *fingerprint = [UIImage imageNamed:@"prefs/FingerprintIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
        [self.fingerButton setImage:[fingerprint imageWithAlpha:0.7f] forState:UIControlStateNormal];
    }
}

- (void)setSupportsFaceID:(BOOL)supportsFaceID
{
    _supportsFaceID = supportsFaceID;
    
    if (supportsFaceID) {
        UIImage *face = [UIImage imageNamed:@"prefs/FaceIcon" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
        [self.fingerButton setImage:[face imageWithAlpha:0.7f] forState:UIControlStateNormal];
    }
}

@end
