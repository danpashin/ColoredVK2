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
@property (assign, nonatomic) BOOL hide;
//@property (assign, nonatomic) BOOL canShow;
- (void)resetState;
@end
