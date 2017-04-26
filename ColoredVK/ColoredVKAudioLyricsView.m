//
//  ColoredVKAudioLyricsView.m
//  ColoredVK
//
//  Created by Даниил on 10/11/16.
//
//

#import "ColoredVKAudioLyricsView.h"
#import "VKMethods.h"
#import "UIGestureRecognizer+BlocksKit.h"


@interface ColoredVKAudioLyricsView ()
@property (strong, nonatomic) UITextView *textView;
@end

@implementation ColoredVKAudioLyricsView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender) {
            if (sender.state == UIGestureRecognizerStateRecognized) self.hide = !self.hide;
        }]];
        
        self.blurView = [[_UIBackdropView alloc] initWithSettings:[_UIBackdropViewSettings settingsForStyle:_UIBackdropViewStyleLight]];
        self.blurView.frame = CGRectMake(self.frame.size.width/12, self.frame.size.height/14, self.frame.size.width-2*(self.frame.size.width/12), self.frame.size.height-2*(self.frame.size.height/14));
        self.blurView.layer.cornerRadius = 14;
        self.blurView.layer.masksToBounds = YES;
        self.blurView.userInteractionEnabled = YES;
              
        self.textView = [UITextView new];
        self.textView.frame = CGRectMake(0, 0, self.blurView.frame.size.width, self.blurView.frame.size.height);
        self.textView.backgroundColor = [UIColor clearColor];
        self.textView.editable = NO;
        self.textView.selectable = NO;
        self.textView.textAlignment = NSTextAlignmentCenter;
        self.textView.textColor = [UIColor whiteColor];
        self.textView.userInteractionEnabled = YES;
        self.textView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        [self.blurView addSubview:self.textView];
        
        [self addSubview:self.blurView];
        
        self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[view]-spacing-|" options:0 metrics:@{@"spacing":@(frame.size.height/14)} views:@{@"view":self.blurView}]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[view]-spacing-|" options:0 metrics:@{@"spacing":@(frame.size.width/12)}  views:@{@"view":self.blurView}]];  
        
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.blurView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:@{@"view":self.textView}]];
        [self.blurView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":self.textView}]];
        
        self.blurView.alpha = 0.0;
        _hide = YES;
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = text;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.textView duration:0.5 
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

- (void)resetState
{
    self.hide = YES;
    self.text = @"";
}

@end
