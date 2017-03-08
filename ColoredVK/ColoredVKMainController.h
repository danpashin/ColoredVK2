//
//  ColoredVKMainController.h
//  ColoredVK
//
//  Created by Даниил on 26/11/16.
//
//

#import "VKMethods.h"
#import "ColoredVKAudioLyricsView.h"
#import "ColoredVKAudioCoverView.h"
#import "ColoredVKBackgroundImageView.h"

@interface ColoredVKMainController : NSObject
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip parallaxEffect:(BOOL)parallaxEffect;

- (void)reloadSwitch:(BOOL)on;
- (void)switchTriggered:(UISwitch*)switchView;
@property (strong, nonatomic) MenuCell *cvkCell;

@property (strong, nonatomic) ColoredVKAudioLyricsView *cvkLyricsView;
@property (strong, nonatomic) ColoredVKAudioCoverView *cvkCoverView;
@property (strong, nonatomic) ColoredVKBackgroundImageView *mainMenuBackgroundView;
@property (strong, nonatomic) ColoredVKBackgroundImageView *navBarImageView;

@end
