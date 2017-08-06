//
//  ColoredVKMainController.m
//  ColoredVK
//
//  Created by Даниил on 26/11/16.
//
//

#import "ColoredVKMainController.h"
#import "Tweak.h"
#import "PrefixHeader.h"
#import "ColoredVKMainPrefsController.h"
#import "ColoredVKWallpaperView.h"
#import <sys/utsname.h>
#import "UIGestureRecognizer+BlocksKit.h"

@implementation ColoredVKMainController
static NSString const *switchViewKey = @"cvkCellSwitchKey";

+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout
{
    [self setImageToTableView:tableView withName:name blackout:blackout flip:NO parallaxEffect:NO];
}

+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip 
{
    [self setImageToTableView:tableView withName:name blackout:blackout flip:flip parallaxEffect:NO];
}

+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect
{
    [self setImageToTableView:tableView withName:name blackout:blackout flip:NO parallaxEffect:parallaxEffect];
}

+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip  parallaxEffect:(BOOL)parallaxEffect 
{
    if (tableView.backgroundView.tag != 23)
        tableView.backgroundView = [[ColoredVKWallpaperView alloc] initWithFrame:tableView.frame imageName:name blackout:blackout flip:flip parallaxEffect:parallaxEffect];
}

- (MenuCell *)menuCell
{
    if (!_menuCell) {
        NSString *reuseIdentifier = @"cvkMenuCell";
        MenuCell *cell = [[objc_getClass("MenuCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        if (!cell) {
            cell = (MenuCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
        cell.backgroundColor = kMenuCellBackgroundColor;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.text = @"ColoredVK 2";
        cell.textLabel.textColor = kMenuCellTextColor;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        cell.imageView.image = [UIImage imageNamed:@"VKMenuIcon" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil];
        
        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = kMenuCellSelectedColor;
        cell.selectedBackgroundView = backgroundView;
        
        UISwitch *switchView = [UISwitch new];
        switchView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/1.2 - switchView.frame.size.width, (cell.contentView.frame.size.height - switchView.frame.size.height)/2, 0, 0);
        switchView.tag = 228;
        switchView.on = enabled;
        switchView.onTintColor = [UIColor defaultColorForIdentifier:@"switchesOnTintColor"];
        [switchView addTarget:self action:@selector(switchTriggered:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(self, (__bridge const void *)(switchViewKey), switchView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [cell.contentView addSubview:switchView];
        
        if ([cell respondsToSelector:@selector(select)]) {
            cell.select = (id)^(id arg1, id arg2) {
                [self actionOpenPreferencesPush:NO];
                return nil;
            };
        }
        _menuCell = cell;
    }
    
    return _menuCell;
}

- (VKMCell *)settingsCell
{
    if (!_settingsCell) {
        NSString *reuseIdentifier = @"cvkSettingsCell";
        VKMCell *settingsCell = [[objc_getClass("VKMCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        if (!settingsCell) {
            settingsCell = (VKMCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        }
        
        settingsCell.selectionStyle = UITableViewCellSelectionStyleGray;
        settingsCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        settingsCell.textLabel.text = @"ColoredVK 2";
        settingsCell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        
        UIImage *icon = [UIImage imageNamed:@"VKMenuIcon" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil];
        icon = [icon imageWithTintColor:[UIColor colorWithRed:88/255.0f green:133/255.0f blue:184/255.0f alpha:1.0f]];
        settingsCell.imageView.image = icon;

        
        _settingsCell = settingsCell;
    }
    return _settingsCell;
}

- (void)actionOpenPreferencesPush:(BOOL)withPush
{
    VKMNavContext *mainContext = [[NSClassFromString(@"VKMNavContext") applicationNavRoot] rootNavContext];
    
    NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    if (!cvkBundle.loaded) [cvkBundle load];
    ColoredVKMainPrefsController *cvkPrefs = [[NSClassFromString(@"ColoredVKMainPrefsController") alloc] init];
    
    if (withPush) {
        [mainContext push:cvkPrefs animated:YES];
    } else {
        [mainContext reset:cvkPrefs];
    }
}

- (void)switchTriggered:(UISwitch *)switchView
{
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:CVK_PREFS_PATH];
    prefs[@"enabled"] = @(switchView.on);
    [prefs writeToFile:CVK_PREFS_PATH atomically:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, NULL, YES);
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
    });
}

- (void)reloadSwitch:(BOOL)on
{
    UISwitch *switchView = objc_getAssociatedObject(self, (__bridge const void *)(switchViewKey));
    if (switchView) [switchView setOn:enabled animated:YES];
}

- (void)sendStats
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    BOOL sendStatistics = prefs[@"sendStatistics"]?[prefs[@"sendStatistics"] boolValue]:YES;
    if (sendStatistics) {
        struct utsname systemInfo;
        uname(&systemInfo);
        UIDevice *device = [UIDevice currentDevice];
        
        NSString *stringURL = [NSString stringWithFormat:@"%@/stats/?product=%@&version=%@&device=%@&ios_version=%@&device_language=%@&vk_version=%@&identifier=%@", 
                               kPackageAPIURL, kPackageIdentifier, kPackageVersion, @(systemInfo.machine), 
                               device.systemVersion, [NSLocale preferredLanguages].firstObject, self.appVersion, 
                               device.identifierForVendor.UUIDString];
        
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]] 
                                           queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {}];
    }
}

- (ColoredVKVersionCompare)compareAppVersionWithVersion:(NSString *)second_version
{
    return [self compareVersion:self.appVersion withVersion:second_version];
}

- (ColoredVKVersionCompare)compareVersion:(NSString *)first_version withVersion:(NSString *)second_version
{
    if ([first_version isEqualToString:second_version])
        return ColoredVKVersionCompareEqual;
    
    NSArray *first_version_components = [first_version componentsSeparatedByString:@"."];
    NSArray *second_version_components = [second_version componentsSeparatedByString:@"."];
    NSInteger length = MIN(first_version_components.count, second_version_components.count);
    
    
    for (int i = 0; i < length; i++) {
        NSInteger first_component = [first_version_components[i] integerValue];
        NSInteger second_component = [second_version_components[i] integerValue];
        
        if (first_component > second_component)
            return ColoredVKVersionCompareMore;
        
        if (first_component < second_component)
            return ColoredVKVersionCompareLess;
    }
    
    
    if (first_version_components.count > second_version_components.count)
        return ColoredVKVersionCompareMore;
    
    if (first_version_components.count < second_version_components.count)
        return ColoredVKVersionCompareLess;
    
    
    return ColoredVKVersionCompareEqual;
}

- (NSString *)appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (UISwipeGestureRecognizer *)swipeForPlayerWithDirection:(UISwipeGestureRecognizerDirection)direction handler:( void(^)() )handler
{
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer * _Nonnull sender) {
        CGPoint location = [sender locationInView:sender.view];
        UIView *view = [sender.view hitTest:location withEvent:nil];
        if (![view isKindOfClass:[UITextView class]] && [view isKindOfClass:[ColoredVKAudioLyricsView class]]) {
            if (handler) {
                handler();
            }
        }
    }];
    swipeGesture.direction = direction;
    
    return swipeGesture;
}


@end
