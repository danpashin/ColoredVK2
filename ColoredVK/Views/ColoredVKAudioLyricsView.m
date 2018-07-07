//
//  ColoredVKAudioLyricsView.m
//  ColoredVK
//
//  Created by Даниил on 10/11/16.
//
//

#import "ColoredVKAudioLyricsView.h"


@interface ColoredVKAudioLyricsView ()
@property (strong, nonatomic) UITextView *textView;
@end

@implementation ColoredVKAudioLyricsView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionShow:)]];
        
        _blurView = [[_UIBackdropView alloc] initWithSettings:[_UIBackdropViewSettings settingsForStyle:_UIBackdropViewStyleLight]];
        _blurView.layer.cornerRadius = 14;
        _blurView.layer.masksToBounds = YES;
        _blurView.userInteractionEnabled = YES;
        [self addSubview:_blurView];
              
        _textView = [UITextView new];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.editable = NO;
        _textView.selectable = NO;
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.textColor = [UIColor whiteColor];
        _textView.userInteractionEnabled = YES;
        _textView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        [_blurView addSubview:_textView];
        
        _blurView.alpha = 0.0;
        _hide = YES;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    
    if (!CGRectEqualToRect(self.frame, CGRectZero)) {
        self.blurView.frame = CGRectMake(CGRectGetWidth(self.frame)/12, CGRectGetHeight(self.frame)/14,
                                         CGRectGetWidth(self.frame)-2*(CGRectGetWidth(self.frame)/12), CGRectGetHeight(self.frame)-2*(CGRectGetHeight(self.frame)/14));
        self.textView.frame = CGRectMake(0, 0, CGRectGetWidth(self.blurView.frame), CGRectGetHeight(self.blurView.frame));
        
        self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[view]-spacing-|" options:0 
                                                                     metrics:@{@"spacing":@(CGRectGetHeight(self.frame)/14)} views:@{@"view":self.blurView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[view]-spacing-|" options:0 
                                                                     metrics:@{@"spacing":@(CGRectGetWidth(self.frame)/12)} views:@{@"view":self.blurView}]];  
        
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.blurView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.textView}]];
        [self.blurView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":self.textView}]];
    }
}

- (void)setText:(NSString *)text
{
    _text = text ? text : @"";
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.textView duration:0.2 
                           options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionAllowUserInteraction
                        animations:^{ self.textView.text = self.text; } completion:nil];
    });
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.textView.textColor = self.textColor;
}

- (void)setHide:(BOOL)hide
{
    if (self.text.length > 0) {
        _hide = hide;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{ self.blurView.alpha = hide?0:1; } completion:nil];
        });
    }
}

- (void)actionShow:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) self.hide = !self.hide;
}

- (void)resetState
{
    self.hide = YES;
    self.text = @"";
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p: textColor %@, hidden %@>", [self class], self, self.textColor, @(self.hide)];
}

@end
