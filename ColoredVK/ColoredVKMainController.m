//
//  ColoredVKMainController.m
//  ColoredVK
//
//  Created by Даниил on 26/11/16.
//
//

#import "ColoredVKMainController.h"
#import "Tweak.h"
#import "ColoredVKNewInstaller.h"
#import "UIColor+ColoredVK.h"
#import "ColoredVKNetwork.h"

@interface ColoredVKMainController ()
@property (strong, nonatomic) UISwitch *menuCellSwitch;
@end

@implementation ColoredVKMainController

BOOL VKMIdenticalController(id self, SEL _cmd, id arg1)
{
    return NO;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        __block id crashObserver = [center addObserverForName:UIWindowDidBecomeVisibleNotification object:nil 
                                                queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
                                                    [center removeObserver:crashObserver];
                                                    [self sendCrashIfNeeded];
                                                }];
    }
    return self;
}

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
        
        Class cellClass = objc_lookUpClass("TitleMenuCell");
        if (!cellClass) {
            cellClass = objc_lookUpClass("MenuCell");
            if (!cellClass)
                cellClass = [UITableViewCell class];
        }
        
        UITableViewCell *cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.backgroundColor = kMenuCellBackgroundColor;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.text = kPackageName;
        cell.textLabel.textColor = kMenuCellTextColor;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        cell.imageView.image = [UIImage imageNamed:@"vkapp/VKMenuIconAlt" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil];
        
        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = kMenuCellSelectedColor;
        cell.selectedBackgroundView = backgroundView;
        
        self.menuCellSwitch = [UISwitch new];
        self.menuCellSwitch.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/1.2f - self.menuCellSwitch.frame.size.width, 
                                      (cell.contentView.frame.size.height - self.menuCellSwitch.frame.size.height)/2.0f, 0.0f, 0.0f);
        self.menuCellSwitch.tag = 228;
        self.menuCellSwitch.on = enabled;
        self.menuCellSwitch.onTintColor = [UIColor cvk_defaultColorForIdentifier:@"switchesOnTintColor"];
        [self.menuCellSwitch addTarget:self action:@selector(switchTriggered) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:self.menuCellSwitch];
        
        if ([cell respondsToSelector:@selector(select)]) {
            ((TitleMenuCell *)cell).select = ^(id model) {
                return self.safePreferencesController;
            };
        }
        
        _menuCell = cell;
    }
    
    return _menuCell;
}

- (UITableViewCell *)settingsCell
{
    UITableViewCell *settingsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cvkSettingsCell"];
    settingsCell.selectionStyle = UITableViewCellSelectionStyleGray;
    settingsCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    settingsCell.textLabel.text = kPackageName;
    settingsCell.textLabel.font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    
    UIImage *icon = [UIImage imageNamed:@"vkapp/VKMenuIconAlt" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil];
    settingsCell.imageView.image = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    settingsCell.imageView.tintColor = isNew3XClient ? [UIColor colorWithRed:0.667f green:0.682f blue:0.702f alpha:1.0f] : kVKMainColor;
    
    return settingsCell;
}

- (__kindof UIViewController *)safePreferencesController
{
    NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
    if (!cvkBundle.loaded)
        [cvkBundle load];
    
    UIViewController *prefs = [[NSClassFromString(@"ColoredVKMainPrefsController") alloc] init];
    if (!prefs)
        prefs = [UIViewController new];
    
    SEL isIdenticalControllerSel = @selector(VKMIdenticalController:);
    if (![prefs respondsToSelector:isIdenticalControllerSel]) {
        class_addMethod([prefs class], isIdenticalControllerSel, (IMP)VKMIdenticalController, "v@:@");
    }
    
    return prefs;
}

- (void)switchTriggered
{
    @synchronized(self) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:CVK_PREFS_PATH];
            prefs[@"enabled"] = @(self.menuCellSwitch.on);
            
            cvk_writePrefs(prefs, kPackageNotificationUpdateNightTheme);
        });
    }
}

- (void)setMenuCellSwitchOn:(BOOL)on
{
    @synchronized(self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.menuCellSwitch setOn:on animated:YES];
            [self.menuCellSwitch setNeedsLayout];
        });
    }
}

- (UISwipeGestureRecognizer *)swipeForPlayerWithDirection:(UISwipeGestureRecognizerDirection)direction handler:( void(^)(void) )handler
{
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handlePlayerGesture:)];
    objc_setAssociatedObject(swipeGesture, "handler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    swipeGesture.direction = direction;
    
    return swipeGesture;
}

- (void)handlePlayerGesture:(UISwipeGestureRecognizer *)swipeGesture
{
    CGPoint location = [swipeGesture locationInView:swipeGesture.view];
    UIView *view = [swipeGesture.view hitTest:location withEvent:nil];
    
    if (![view isKindOfClass:[UITextView class]] && [view isKindOfClass:NSClassFromString(@"ColoredVKAudioLyricsView")]) {
        void(^handler)(void) = objc_getAssociatedObject(swipeGesture, "handler");
        if (handler) {
            handler();
        }
    }
}

- (void)sendCrashIfNeeded
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (![[NSFileManager defaultManager] fileExistsAtPath:CVK_CRASH_PATH])
            return;
        
        NSDictionary *crash = [NSDictionary dictionaryWithContentsOfFile:CVK_CRASH_PATH];
        if (!crash)
            return;
        
        if (__deviceModel.length == 0)
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
            cvk_removeFile(CVK_CRASH_PATH, nil);
        } failure:nil];
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [object removeObserver:self forKeyPath:keyPath];
    
    if (enabled && [keyPath isEqualToString:@"layer.fillColor"]) {
        if ([object isKindOfClass:objc_lookUpClass("_TtC3vkm9BadgeView")] && enableNightTheme) {
            _TtC3vkm9BadgeView *badgeView = object;
            const CGFloat *components = CGColorGetComponents(badgeView.layer.fillColor);
            if (components[2] >= 0.79f) {
                badgeView.layer.fillColor = self.nightThemeScheme.buttonSelectedColor.CGColor;
            } else if (components[2] > 0.0f) {
                badgeView.layer.fillColor = self.nightThemeScheme.navbackgroundColor.CGColor;
            }
        }
    }
    
    [object addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:context];
}

@end
