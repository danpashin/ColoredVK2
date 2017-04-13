//
//  ColoredVKAudioCoverView.h
//  ColoredVK
//
//  Created by Даниил on 24/11/16.
//
//

#import <UIKit/UIKit.h>
#import "VKMethods.h"
#import "SDWebImageManager.h"
#import "ColoredVKAudioLyricsView.h"

@interface ColoredVKAudioCoverView : UIView
- (instancetype)initWithFrame:(CGRect)frame andSeparationPoint:(CGPoint)point;
- (void)updateCoverForAudioPlayer:(AudioPlayer *)player;
- (void)addToView:(UIView *)view;

@property (strong, nonatomic) NSString *track;
@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) UIColor *tintColor;
@property (strong, nonatomic) UIColor *backColor;
@property (assign, nonatomic) BOOL defaultCover;
@property (assign, nonatomic) BOOL customCover;
@property (strong, nonatomic) SDWebImageManager *manager;
@property (strong, nonatomic) ColoredVKAudioLyricsView *audioLyricsView;

@end
