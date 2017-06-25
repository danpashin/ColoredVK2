//
//  ColoredVKAudioCover.h
//  ColoredVK
//
//  Created by Даниил on 24/11/16.
//
//

#import <UIKit/UIKit.h>
#import "VKMethods.h"
#import "SDWebImageManager.h"
#import "ColoredVKAudioLyricsView.h"

@interface ColoredVKAudioCover : NSObject

- (void)updateViewFrame:(CGRect)frame andSeparationPoint:(CGPoint)separationPoint;
- (void)updateCoverForArtist:(NSString *)artist title:(NSString *)title;
- (void)addToView:(UIView *)view;

@property (strong, nonatomic) NSString *track;
@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) UIColor *color;
@property (strong, nonatomic) UIColor *backColor;
@property (assign, nonatomic) BOOL defaultCover;
@property (assign, nonatomic) BOOL customCover;
@property (strong, nonatomic) ColoredVKAudioLyricsView *audioLyricsView;

@end
