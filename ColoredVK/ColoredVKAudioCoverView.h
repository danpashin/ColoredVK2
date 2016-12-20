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

@interface ColoredVKAudioCoverView : UIView
- (instancetype)initWithFrame:(CGRect)frame andSeparationPoint:(CGPoint)point;
- (void)updateCoverForAudioPlayer:(AudioPlayer *)player;

@property (strong, nonatomic) NSString *track;
@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) UIColor *tintColor;
@property (strong, nonatomic) UIColor *backColor;
@property (assign, nonatomic) BOOL defaultCover;
@property (strong, nonatomic) SDWebImageManager *manager;
@end
