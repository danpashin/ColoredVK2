//
//  ColoredVKMainController.h
//  ColoredVK
//
//  Created by Даниил on 26/11/16.
//
//

#import "ColoredVKAudioCover.h"
#import "ColoredVKWallpaperView.h"
#import "ColoredVKNightScheme.h"

@class MenuCell, VKMMainController, MenuViewController;


@interface ColoredVKMainController : NSObject

@property (weak, nonatomic, readonly) __kindof UIViewController *safePreferencesController;
@property (strong, nonatomic) __kindof UITableViewCell *menuCell;
@property (nonatomic, readonly) UITableViewCell *settingsCell;

@property (strong, nonatomic) ColoredVKAudioCover *audioCover;
@property (strong, nonatomic) ColoredVKWallpaperView *menuBackgroundView;
@property (strong, nonatomic) ColoredVKWallpaperView *navBarImageView;

@property (weak, nonatomic) VKMMainController *vkMainController;
@property (weak, nonatomic) MenuViewController *vkMenuController;
@property (weak, nonatomic) ColoredVKNightScheme *nightThemeScheme;

- (void)setImageToTableView:(UITableView *)tableView name:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect blur:(BOOL)blur;
- (void)setImageToTableView:(UITableView *)tableView name:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip 
             parallaxEffect:(BOOL)parallaxEffect blur:(BOOL)blur;
- (void)forceUpdateTableView:(UITableView *)tableView blackout:(CGFloat)blackout blur:(BOOL)blur;

- (UISwipeGestureRecognizer *)swipeForPlayerWithDirection:(UISwipeGestureRecognizerDirection)direction handler:( void(^)(void) )handler;
- (void)setMenuCellSwitchOn:(BOOL)on;

@end
