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
@property (strong, nonatomic) UIView *hostView;
@end

@implementation ColoredVKAudioLyricsView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.text = @"";
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)]];
        
        self.hostView = [UIView new];
        self.hostView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height - 10);
        blurEffectView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        blurEffectView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        blurEffectView.layer.cornerRadius = 2;
        blurEffectView.layer.masksToBounds = YES;
        
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:blurEffect]];
        vibrancyEffectView.frame = CGRectMake(0, 0, blurEffectView.frame.size.width, blurEffectView.frame.size.height);
        [blurEffectView.contentView addSubview:vibrancyEffectView];
        
        [self resetState];
        self.textView = [UITextView new];
        self.textView.frame = vibrancyEffectView.frame;
        self.textView.text = self.text;
        self.textView.editable = NO;
        self.textView.selectable = NO;
        self.textView.textAlignment = NSTextAlignmentCenter;
        self.textView.showsVerticalScrollIndicator = NO;
        [vibrancyEffectView.contentView addSubview:self.textView];
        [self.hostView addSubview:blurEffectView];
        [self addSubview:self.hostView];
        
        self.hostView.hidden = YES;
        _hide = YES;
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = text;
    if (self.textView) {
        [UIView transitionWithView:self.textView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{ self.textView.text = self.text; } 
                        completion:nil];
    }
}

- (void)setHide:(BOOL)hide
{
    if (self.text.length > 0) {
        _hide = hide;
        [UIView transitionWithView:self.hostView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{ self.hostView.hidden = hide; } completion:nil];
    }
}

- (void)tapRecognized:(UITapGestureRecognizer *)recognizer
{    
    if (recognizer.state == UIGestureRecognizerStateRecognized) self.hide = !self.hide;
}

- (void)resetState
{
    self.hide = YES;
    self.text = @"";
}

@end
