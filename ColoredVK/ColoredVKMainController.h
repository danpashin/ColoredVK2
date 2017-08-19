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


typedef NS_ENUM(NSInteger, ColoredVKVersionCompare)
{
    ColoredVKVersionCompareLess = -1,
    ColoredVKVersionCompareEqual = 0,
    ColoredVKVersionCompareMore = 1
//    ColoredVKVersionCompareMoreOrEqual = ColoredVKVersionCompareEqual|ColoredVKVersionCompareMore,
//    ColoredVKVersionCompareLessOrEqual = ColoredVKVersionCompareEqual|ColoredVKVersionCompareLess
};

@interface ColoredVKMainController : NSObject

+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect blurBackground:(BOOL)blurBackground;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip 
             parallaxEffect:(BOOL)parallaxEffect blurBackground:(BOOL)blurBackground;

/**
 * Returns application version from Info.plist
 */
@property (readonly, copy, nonatomic) NSString *appVersion;

@property (strong, nonatomic) MenuCell *menuCell;
@property (strong, nonatomic) UITableViewCell *settingsCell;
@property (strong, nonatomic) ColoredVKAudioCover *audioCover;
@property (strong, nonatomic) ColoredVKWallpaperView *menuBackgroundView;
@property (strong, nonatomic) ColoredVKWallpaperView *navBarImageView;
@property (weak, nonatomic) VKMMainController *vkMainController;


- (void)reloadSwitch:(BOOL)on;

- (ColoredVKVersionCompare)compareAppVersionWithVersion:(NSString *)second_version;
- (ColoredVKVersionCompare)compareVersion:(NSString *)first_version withVersion:(NSString *)second_version;

- (void)sendStats;
- (UISwipeGestureRecognizer *)swipeForPlayerWithDirection:(UISwipeGestureRecognizerDirection)direction handler:( void(^)() )handler;
- (void)actionOpenPreferencesPush:(BOOL)withPush;
- (void)checkCrashes;


@end
