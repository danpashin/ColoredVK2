//
//  ColoredVKAudioLyricsView.h
//  ColoredVK
//
//  Created by Даниил on 10/11/16.
//
//

#import <UIKit/UIKit.h>

@interface ColoredVKAudioLyricsView : UIView
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIVisualEffectView *blurView;
@property (assign, nonatomic) BOOL hide;
- (void)resetState;
- (void)updateWithLyrycsID:(NSNumber *)lyrics_id andToken:(NSString *)token;
@end
