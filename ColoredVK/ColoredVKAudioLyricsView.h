//
//  ColoredVKAudioLyricsView.h
//  ColoredVK
//
//  Created by Даниил on 10/11/16.
//
//

#import <UIKit/UIKit.h>
#import "_UIBackdropView.h"

@interface ColoredVKAudioLyricsView : UIView
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) _UIBackdropView *blurView;
@property (assign, nonatomic) BOOL hide;
- (void)resetState;
//- (void)updateWithLyrycsID:(NSNumber *)lyrics_id andToken:(NSString *)token;
- (void)updateLyrycsForArtist:(NSString *)artist title:(NSString *)title;
@end
