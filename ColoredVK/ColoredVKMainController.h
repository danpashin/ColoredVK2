//
//  ColoredVKMainController.h
//  ColoredVK
//
//  Created by Даниил on 26/11/16.
//
//

#import "VKMethods.h"
#import "ColoredVKAudioLyricsView.h"
#import "ColoredVKAudioCover.h"
#import "ColoredVKWallpaperView.h"

@interface ColoredVKMainController : NSObject
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip parallaxEffect:(BOOL)parallaxEffect;

- (void)reloadSwitch:(BOOL)on;
- (void)switchTriggered:(UISwitch*)switchView;
@property (strong, nonatomic) MenuCell *menuCell;

/**
 * Returns -1  if  (first_version < second_version).
 * Returns  1  if  (first_version > second_version).
 * Returns  0  if  (first_version = second_version).
 */
- (NSInteger)compareVersion:(NSString *)first_version withVersion:(NSString *)second_version;
- (void)sendStats;
- (void)checkCrashes;

/**
 * Returns application version from Info.plist
 */
@property (readonly, copy, nonatomic) NSString *vkVersion;

@property (strong, nonatomic) ColoredVKAudioCover *coverView;
@property (strong, nonatomic) ColoredVKWallpaperView *menuBackgroundView;
@property (strong, nonatomic) ColoredVKWallpaperView *navBarImageView;

@end
