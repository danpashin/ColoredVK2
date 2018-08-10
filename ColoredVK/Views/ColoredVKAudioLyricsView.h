//
//  ColoredVKAudioLyricsView.h
//  ColoredVK
//
//  Created by Даниил on 10/11/16.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/_UIBackdropView.h>

@interface ColoredVKAudioLyricsView : UIView

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) _UIBackdropView *blurView;
@property (assign, nonatomic) BOOL hide;

- (void)resetState;

@end
