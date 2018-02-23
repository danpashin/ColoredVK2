//
//  ColoredVKAudioCover.h
//  ColoredVK
//
//  Created by Даниил on 24/11/16.
//
//

#import <UIKit/UIKit.h>

@interface ColoredVKAudioCover : NSObject

@property (strong, nonatomic, readonly) UIColor *color;
@property (strong, nonatomic, readonly) UIColor *backColor;
@property (strong, nonatomic) void (^updateCompletionBlock)(ColoredVKAudioCover *cover);

- (void)updateViewFrame:(CGRect)frame andSeparationPoint:(CGPoint)separationPoint;
- (void)updateCoverForArtist:(NSString *)artist title:(NSString *)title;
- (void)addToView:(UIView *)view;
- (void)updateColorScheme;

@end
