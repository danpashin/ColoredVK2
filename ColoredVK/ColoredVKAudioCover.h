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
- (void)updateColorScheme;

@property (strong, nonatomic, readonly) UIColor *color;
@property (strong, nonatomic, readonly) UIColor *backColor;
@property (strong, nonatomic) void (^updateCompletionBlock)(ColoredVKAudioCover *cover);

@end
