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
        blurEffectView.frame = CGRectMake(frame.size.width/8, 0, self.frame.size.height-2*(frame.size.width/8), self.frame.size.height - 10);
        blurEffectView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        blurEffectView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
        blurEffectView.layer.cornerRadius = 10;
        blurEffectView.layer.masksToBounds = YES;
        
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:blurEffect]];
        vibrancyEffectView.frame = CGRectMake(0, 0, blurEffectView.frame.size.width, blurEffectView.frame.size.height);
        [blurEffectView.contentView addSubview:vibrancyEffectView];
        
        self.textView = [UITextView new];
        self.textView.frame = vibrancyEffectView.frame;
        self.textView.text = self.text;
        self.textView.editable = NO;
        self.textView.selectable = NO;
        self.textView.textAlignment = NSTextAlignmentCenter;
        self.textView.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        self.textView.userInteractionEnabled = YES;
        [vibrancyEffectView.contentView addSubview:self.textView];
        [self.hostView addSubview:blurEffectView];
        [self addSubview:self.hostView];
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.hostView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-spacing-[blurEffectView]-spacing-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:@{@"spacing": @(frame.size.height/10)} views:NSDictionaryOfVariableBindings(blurEffectView)]];
        [self.hostView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-spacing-[blurEffectView]-spacing-|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                     metrics:@{@"spacing": @(frame.size.width/8)} views:NSDictionaryOfVariableBindings(blurEffectView)]];
        
        vibrancyEffectView.translatesAutoresizingMaskIntoConstraints = NO;
        [blurEffectView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[vibrancyEffectView]|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                              metrics:nil views:NSDictionaryOfVariableBindings(vibrancyEffectView)]];
        [blurEffectView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[vibrancyEffectView]|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                              metrics:nil views:NSDictionaryOfVariableBindings(vibrancyEffectView)]];        
        
        self.textView.translatesAutoresizingMaskIntoConstraints = NO;
        [vibrancyEffectView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textView]|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                   metrics:nil views:NSDictionaryOfVariableBindings(_textView)]];
        [vibrancyEffectView.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textView]|" options:NSLayoutFormatDirectionLeadingToTrailing
                                                                                   metrics:nil views:NSDictionaryOfVariableBindings(_textView)]];
        
        self.hostView.hidden = YES;
        _hide = YES;
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = text;
    if (self.textView) [UIView transitionWithView:self.textView duration:0.5 
                                          options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionAllowUserInteraction animations:^{ self.textView.text = self.text; } completion:nil];
}

- (void)setHide:(BOOL)hide
{
    if (self.text.length > 0) {
        _hide = hide;
        [UIView transitionWithView:self.hostView duration:0.3 
                           options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionAllowUserInteraction animations:^{ self.hostView.hidden = hide; } completion:nil];
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

- (void)updateWithLyrycsID:(NSNumber *)lyrics_id andToken:(NSString *)token
{
    NSString *const apiVersion = @"5.62";
    NSString *url = [NSString stringWithFormat:@"https://api.vk.com/method/audio.getLyrics?lyrics_id=%@&access_token=%@&v=%@", lyrics_id, token, apiVersion];
    [(AFJSONRequestOperation *)[NSClassFromString(@"AFJSONRequestOperation")
                                JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                 
                                    if (JSON[@"response"][@"text"]) self.text = JSON[@"response"][@"text"];
                                } failure:nil] start]; 
}

@end
