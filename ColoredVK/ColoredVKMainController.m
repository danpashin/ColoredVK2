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
#import <objc/runtime.h>
#import "ColoredVKPrefsController.h"
#import "UIImage+ResizeMagick.h"
#import "ColoredVKBackgroundImageView.h"

@implementation ColoredVKMainController
static NSString const *switchViewKey = @"cvkCellSwitchKey";

- (MenuCell *)cvkCell
{
    if (!_cvkCell) {
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
            ColoredVKPrefsController *cvkPrefs = [[NSClassFromString(@"ColoredVKPrefsController") alloc] init];
            [mainContext reset:cvkPrefs];
            return nil;
        };
        _cvkCell = cell;
    }
    
    return _cvkCell;
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
    if ((tableView.backgroundView == nil) || (tableView.backgroundView.tag != 23))
        tableView.backgroundView = [[ColoredVKBackgroundImageView alloc] initWithFrame:tableView.frame imageName:name blackout:blackout flip:flip parallaxEffect:parallaxEffect];
}
@end
