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
        MenuCell *cell = [[objc_getClass("MenuCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cvkCell"];
        cell.backgroundColor = kMenuCellBackgroundColor;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.text = @"ColoredVK 2";
        cell.textLabel.textColor = kMenuCellTextColor;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        cell.imageView.image = [UIImage imageNamed:@"VKMenuIcon" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil];
        
        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = kMenuCellSelectedColor;
        cell.selectedBackgroundView = backgroundView;
        
        UISwitch *switchView = [UISwitch new];
        switchView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/1.2 - switchView.frame.size.width, (cell.contentView.frame.size.height - switchView.frame.size.height)/2, 0, 0);
        switchView.tag = 405;
        switchView.on = enabled;
        switchView.onTintColor = [UIColor defaultColorForIdentifier:@"switchesOnTintColor"];
        [switchView addTarget:self action:@selector(switchTriggered:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(self, (__bridge const void *)(switchViewKey), switchView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [cell.contentView addSubview:switchView];
        
        cell.select = (id)^(id arg1, id arg2) {
            VKMNavContext *mainContext = [[NSClassFromString(@"VKMNavContext") applicationNavRoot] rootNavContext];
            
            NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
            if (!cvkBundle.loaded) [cvkBundle load];
            ColoredVKMainPrefsController *cvkPrefs = [[NSClassFromString(@"ColoredVKMainPrefsController") alloc] init];
            [mainContext reset:cvkPrefs];
            return nil;
        };
        _menuCell = cell;
    }
    
    return _menuCell;
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
                               device.systemVersion, [NSLocale preferredLanguages].firstObject, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], 
                               device.identifierForVendor.UUIDString];
        
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]] 
                                           queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {}];
    }
}

- (NSInteger)compareVersion:(NSString *)first_version withVersion:(NSString *)second_version
{
    if ([first_version isEqualToString:second_version]) return 0;
    
    NSArray *first_version_components = [first_version componentsSeparatedByString:@"."];
    NSArray *second_version_components = [second_version componentsSeparatedByString:@"."];
    NSInteger length = MIN(first_version_components.count, second_version_components.count);
    
    
    for (int i = 0; i < length; i++) {
        NSInteger first_component = [first_version_components[i] integerValue];
        NSInteger second_component = [second_version_components[i] integerValue];
        
        if (first_component > second_component) return 1;
        if (first_component < second_component) return -1;
    }
    
    
    if (first_version_components.count > second_version_components.count) return 1;
    if (first_version_components.count < second_version_components.count) return -1;
    
    return 0;
}

- (NSString *)vkVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (void)checkCrashes
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{        
        BOOL shouldShowCrashAlert = NO;
        NSString *crashFilePath = @"";
        NSFileManager *filemanager = [NSFileManager defaultManager];    
        
        for (NSString *filename in [filemanager contentsOfDirectoryAtPath:CVK_CACHE_PATH error:nil]) {
            if ([filename containsString:@"com.daniilpashin.coloredvk2_crash"]) {
                shouldShowCrashAlert = YES;
                crashFilePath = [NSString stringWithFormat:@"%@/com.daniilpashin.coloredvk2_crash_%@", CVK_CACHE_PATH, filename];
                break;
            }
        }
        
        if (shouldShowCrashAlert) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:kPackageName message:CVKLocalizedString(@"CRASH_DETECTED_WANT_TO_SEND_TO_DEV") preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"SEND") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"BETTER_NOT") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [filemanager removeItemAtPath:crashFilePath error:nil];
                }]];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
            });
        }
    });
}


@end
