//
//  ColoredVKAudioLyricsView.m
//  ColoredVK
//
//  Created by Даниил on 10/11/16.
//
//

#import "ColoredVKAudioLyricsView.h"
#import "VKMethods.h"


@interface ColoredVKAudioLyricsView ()
@property (strong, nonatomic) UITextView *textView;
@end

@implementation ColoredVKAudioLyricsView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionShow:)]];
        
        self.blurView = [[_UIBackdropView alloc] initWithSettings:[_UIBackdropViewSettings settingsForStyle:_UIBackdropViewStyleLight]];
        self.blurView.layer.cornerRadius = 14;
        self.blurView.layer.masksToBounds = YES;
        self.blurView.userInteractionEnabled = YES;
        [self addSubview:self.blurView];
              
        self.textView = [UITextView new];
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.editable = NO;
        self.textView.selectable = NO;
        self.textView.textAlignment = NSTextAlignmentCenter;
        self.textView.textColor = [UIColor whiteColor];
        self.textView.userInteractionEnabled = YES;
        self.textView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        [self.blurView addSubview:self.textView];
        
        self.blurView.alpha = 0.0;
        _hide = YES;
    }
    return self;
}

- (void)setupConstraints
{
    if (!CGRectEqualToRect(self.frame, CGRectZero)) {
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

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    
    if (!CGRectEqualToRect(self.frame, CGRectZero)) {
        self.blurView.frame = CGRectMake(CGRectGetWidth(self.frame)/12, CGRectGetHeight(self.frame)/14,
                                         CGRectGetWidth(self.frame)-2*(CGRectGetWidth(self.frame)/12), CGRectGetHeight(self.frame)-2*(CGRectGetHeight(self.frame)/14));
        self.textView.frame = CGRectMake(0, 0, CGRectGetWidth(self.blurView.frame), CGRectGetHeight(self.blurView.frame));
        
        [self setupConstraints];
    }
}

- (void)setText:(NSString *)text
{
    _text = text;
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
    return [NSString stringWithFormat:@" %@; textColor %@; hidden %@ ", super.description, self.textColor, @(self.hide)];
}

@end
