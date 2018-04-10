//
//  ColoredVKMainController.m
//  ColoredVK
//
//  Created by Даниил on 26/11/16.
//
//

#import "ColoredVKMainController.h"
#import "Tweak.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "ColoredVKNewInstaller.h"
#import "UIColor+ColoredVK.h"
#import "ColoredVKNetwork.h"

@implementation ColoredVKMainController
static NSString const *switchViewKey = @"cvkCellSwitchKey";

- (void)setImageToTableView:(UITableView *)tableView name:(NSString *)name blackout:(CGFloat)blackout 
             parallaxEffect:(BOOL)parallaxEffect blur:(BOOL)blur
{
    [self setImageToTableView:tableView name:name blackout:blackout flip:NO parallaxEffect:parallaxEffect blur:blur];
}

- (void)setImageToTableView:(UITableView *)tableView name:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip 
             parallaxEffect:(BOOL)parallaxEffect blur:(BOOL)blur
{
    if (enabled && enableNightTheme)
        return;
    
    if (tableView.backgroundView.tag != 23) {
        ColoredVKWallpaperView *wallView = [[ColoredVKWallpaperView alloc] initWithFrame:tableView.frame imageName:name 
                                                                                blackout:blackout enableParallax:parallaxEffect 
                                                                          blurBackground:blur];
        wallView.flip = flip;
        tableView.backgroundView = wallView;
    }
}

- (void)forceUpdateTableView:(UITableView *)tableView blackout:(CGFloat)blackout blur:(BOOL)blur
{
    if (tableView.backgroundView.tag == 23) {
        ColoredVKWallpaperView *wallView = (ColoredVKWallpaperView *)tableView.backgroundView;
        if ([wallView isKindOfClass:[ColoredVKWallpaperView class]]) {
            [wallView updateViewWithBlackout:blackout];
            wallView.blurBackground = blur;
        }
    }
}

- (__kindof UITableViewCell *)menuCell
{
    if (!_menuCell) {
        NSString *reuseIdentifier = @"cvkMenuCell";
        
        Class className = (NSClassFromString(@"MenuCell") != nil) ? NSClassFromString(@"MenuCell") : [UITableViewCell class];
        UITableViewCell *cell = [[className alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.backgroundColor = kMenuCellBackgroundColor;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.text = @"ColoredVK 2";
        cell.textLabel.textColor = kMenuCellTextColor;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        cell.imageView.image = [UIImage imageNamed:@"vkapp/VKMenuIconAlt" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil];
        
        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = kMenuCellSelectedColor;
        cell.selectedBackgroundView = backgroundView;
        
        UISwitch *switchView = [UISwitch new];
        switchView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/1.2f - switchView.frame.size.width, 
                                      (cell.contentView.frame.size.height - switchView.frame.size.height)/2.0f, 0.0f, 0.0f);
        switchView.tag = 228;
        switchView.on = enabled;
        switchView.onTintColor = [UIColor cvk_defaultColorForIdentifier:@"switchesOnTintColor"];
        [switchView addTarget:self action:@selector(switchTriggered:) forControlEvents:UIControlEventValueChanged];
        objc_setAssociatedObject(self, (__bridge const void *)(switchViewKey), switchView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [cell.contentView addSubview:switchView];
        
        if ([cell respondsToSelector:@selector(select)]) {
            ((MenuCell *)cell).select = (id)^(id arg1, id arg2) {
                [self actionOpenPreferencesPush:NO];
                return nil;
            };
        }
        
        _menuCell = cell;
    }
    
    return _menuCell;
}

- (__kindof UITableViewCell *)settingsCell
{
    if (!_settingsCell) {
        UITableViewCell *settingsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                               reuseIdentifier:@"cvkSettingsCell"];
        
        settingsCell.selectionStyle = UITableViewCellSelectionStyleGray;
        settingsCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        settingsCell.textLabel.text = @"ColoredVK 2";
        settingsCell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        
        UIImage *icon = [UIImage imageNamed:@"vkapp/VKMenuIconAlt" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil];
        settingsCell.imageView.image = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        settingsCell.imageView.tintColor = kVKMainColor;
        
        _settingsCell = settingsCell;
    }
    return _settingsCell;
}

- (void)actionOpenPreferencesPush:(BOOL)withPush
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL innerWithPush = withPush;
        NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        if (!cvkBundle.loaded)
            [cvkBundle load];
        
        UIViewController *cvkPrefs = [[NSClassFromString(@"ColoredVKMainPrefsController") alloc] init];
        if (!cvkPrefs)
            return;
        
        if ([[ColoredVKNewInstaller sharedInstaller].application compareAppVersionWithVersion:@"3.0"] >= 0)
            innerWithPush = YES;
        
        VKMNavContext *mainContext = [[NSClassFromString(@"VKMNavContext") applicationNavRoot] rootNavContext];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (innerWithPush) {
                if ([mainContext respondsToSelector:@selector(push:animated:)])
                    [mainContext push:cvkPrefs animated:YES];
            } else {
                if ([mainContext respondsToSelector:@selector(reset:)])
                    [mainContext reset:cvkPrefs];
            }
        });
    });
}

- (void)switchTriggered:(UISwitch *)switchView
{
    @synchronized(self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:CVK_PREFS_PATH];
            prefs[@"enabled"] = @(switchView.on);
            [prefs writeToFile:CVK_PREFS_PATH atomically:YES];
            
            POST_CORE_NOTIFICATION(kPackageNotificationUpdateNightTheme);
            POST_CORE_NOTIFICATION(kPackageNotificationReloadMenu);
        });
    }
}

- (void)reloadSwitch:(BOOL)on
{
    @synchronized(self) {
        UISwitch *switchView = objc_getAssociatedObject(self, (__bridge const void *)(switchViewKey));
        if ([switchView isKindOfClass:[UISwitch class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [switchView setOn:on animated:YES];
                [switchView setNeedsLayout];
            });
        }
    }
}

- (UISwipeGestureRecognizer *)swipeForPlayerWithDirection:(UISwipeGestureRecognizerDirection)direction handler:( void(^)(void) )handler
{
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer * _Nonnull sender) {
        CGPoint location = [sender locationInView:sender.view];
        UIView *view = [sender.view hitTest:location withEvent:nil];
        if (![view isKindOfClass:[UITextView class]] && [view isKindOfClass:NSClassFromString(@"ColoredVKAudioLyricsView")]) {
            if (handler) {
                handler();
            }
        }
    }];
    swipeGesture.direction = direction;
    
    return swipeGesture;
}

- (void)checkCrashes
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (![[NSFileManager defaultManager] fileExistsAtPath:CVK_CRASH_PATH])
            return;
        
        NSDictionary *crash = [NSDictionary dictionaryWithContentsOfFile:CVK_CRASH_PATH];
        if (!crash)
            return;
        
        ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
        NSDictionary *allInfo = @{@"vk_version":newInstaller.application.detailedVersion, @"cvk_version":kPackageVersion, 
                                  @"ios_version": [UIDevice currentDevice].systemVersion,  @"device": __deviceModel,
                                  @"crash_info":crash};
        
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:allInfo options:0 error:&error];
        if (error)
            return;
        
        NSString *url = [NSString stringWithFormat:@"%@/crash/", kPackageAPIURL];
        [[ColoredVKNetwork sharedNetwork] uploadData:data toRemoteURL:url success:^(NSHTTPURLResponse *response, NSData *rawData) {
            [[NSFileManager defaultManager] removeItemAtPath:CVK_CRASH_PATH error:nil];
        } failure:nil];
    });
}

@end
