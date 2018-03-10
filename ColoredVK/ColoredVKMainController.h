//
//  ColoredVKMainController.h
//  ColoredVK
//
//  Created by Даниил on 26/11/16.
//
//

#import "ColoredVKAudioCover.h"
#import "ColoredVKWallpaperView.h"
#import "ColoredVKNightThemeColorScheme.h"

@class MenuCell, VKMMainController, MenuViewController;


@interface ColoredVKMainController : NSObject

+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect blurBackground:(BOOL)blurBackground;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip 
             parallaxEffect:(BOOL)parallaxEffect blurBackground:(BOOL)blurBackground;
+ (void)forceUpdateTableView:(UITableView *)tableView withBlackout:(CGFloat)blackout blurBackground:(BOOL)blurBackground;

/**
 * Возвращает версию приложения из Info.plist
 */
//@property (readonly, copy, nonatomic) NSString *appVersion;

/**
 * Возвращает версию приложения с номером билда из Info.plist
 */
//@property (readonly, copy, nonatomic) NSString *appVersionDetailed;

@property (strong, nonatomic) MenuCell *menuCell;
@property (strong, nonatomic) UITableViewCell *settingsCell;
@property (strong, nonatomic) ColoredVKAudioCover *audioCover;
@property (strong, nonatomic) ColoredVKWallpaperView *menuBackgroundView;
@property (strong, nonatomic) ColoredVKWallpaperView *navBarImageView;
@property (weak, nonatomic) VKMMainController *vkMainController;
@property (weak, nonatomic) MenuViewController *vkMenuController;
@property (weak, nonatomic) ColoredVKNightThemeColorScheme *nightThemeScheme;


- (void)reloadSwitch:(BOOL)on;

//- (ColoredVKVersionCompare)compareAppVersionWithVersion:(NSString *)second_version;
//- (ColoredVKVersionCompare)compareVersion:(NSString *)first_version withVersion:(NSString *)second_version;

- (UISwipeGestureRecognizer *)swipeForPlayerWithDirection:(UISwipeGestureRecognizerDirection)direction handler:( void(^)(void) )handler;
- (void)actionOpenPreferencesPush:(BOOL)withPush;
- (void)checkCrashes;


@end
