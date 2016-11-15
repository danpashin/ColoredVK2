//
//  ColoredVK.mm
//  ColoredVK
//
//  Created by Даниил on 21.04.16.
//  Copyright (c) 2016 Daniil Pashin. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MobileGestalt/MobileGestalt.h>
#import <sys/utsname.h>
#import "CaptainHook/CaptainHook.h"
#import "NSData+AES.h"

#import "ColoredVKInstaller.h"
#import "PrefixHeader.h"
#import "UIBarButtonItem+BlocksKit.h"
#import "VKMethods.h"
#import "UIImage+ResizeMagick.h"
#import "NSDate+DateTools.h"
#import <dlfcn.h>
#import "ColoredVKPrefsController.h"
#import "ColoredVKBackgroundImageView.h"
#import "ColoredVKAudioLyricsView.h"



#define CLASS_NAME(obj) NSStringFromClass([obj class])

#define kMenuCellBackgroundColor [UIColor colorWithRed:56.0/255.0f green:69.0/255.0f blue:84.0/255.0f alpha:1]
#define kMenuCellSelectedColor [UIColor colorWithRed:47.0/255.0f green:58.0/255.0f blue:71.0/255.0f alpha:1]
#define kMenuCellSeparatorColor [UIColor colorWithRed:72.0/255.0f green:86.0/255.0f blue:97.0/255.0f alpha:1]
#define kMenuCellTextColor [UIColor colorWithRed:233.0/255.0f green:234.0/255.0f blue:235.0/255.0f alpha:1]

#define kNewsTableViewBackgroundColor [UIColor colorWithRed:237.0/255.0f green:238.0/255.0f blue:240.0/255.0f alpha:1]
#define kNewsTableViewSeparatorColor [UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1]

#define textBackgroundColor [UIColor.redColor colorWithAlphaComponent:0.3]





typedef NS_ENUM(NSInteger, CVKCellSelectionStyle) {
    CVKCellSelectionStyleNone = 0,
    CVKCellSelectionStyleTransparent,
    CVKCellSelectionStyleBlurred
};

typedef NS_ENUM(NSInteger, CVKKeyboardStyle) {
    CVKKeyboardStyleWhite = 0,
    CVKKeyboardStyleBlack
};

NSTimeInterval updatesInterval;

BOOL tweakEnabled = NO;
BOOL VKSettingsEnabled;

NSString *prefsPath;
NSString *cvkFolder;
NSBundle *cvkBunlde;
NSBundle *vksBundle;

BOOL enabled;
BOOL enabledBarColor;
BOOL showBar;
BOOL enabledToolBarColor;
BOOL enabledBarImage;


BOOL enabledMenuImage;
BOOL hideMenuSeparators;
BOOL hideMessagesListSeparators;
BOOL hideGroupsListSeparators;
BOOL enabledMessagesImage;
BOOL enabledMessagesListImage;
BOOL enabledGroupsListImage;
BOOL enabledAudioImage;
BOOL changeAudioPlayerAppearance;
BOOL minimizeAudioPlayer;

CGFloat menuImageBlackout;
CGFloat chatImageBlackout;
CGFloat chatListImageBlackout;
CGFloat groupsListImageBlackout;
CGFloat audioImageBlackout;

BOOL useMessagesBlur;
BOOL useMessagesListBlur;
BOOL useGroupsListBlur;
BOOL useAudioBlur;

BOOL useMenuParallax;
BOOL useMessagesListParallax;
BOOL useMessagesParallax;
BOOL useGroupsListParallax;
BOOL useAudioParallax;


BOOL hideMenuSearch;
BOOL changeSwitchColor;
BOOL changeSBColors;
BOOL enabledBlackTheme;
BOOL blackThemeWasEnabled;
BOOL shouldCheckUpdates;

UITableView *menuTableView;
//UITableView *chatTableView;
UITableView *newsFeedTableView;

UIColor *menuSeparatorColor;
UIColor *barBackgroundColor;
UIColor *barForegroundColor;
UIColor *toolBarBackgroundColor;
UIColor *toolBarForegroundColor;
UIColor *SBBackgroundColor;
UIColor *SBForegroundColor;
UIColor *switchesTintColor;
UIColor *switchesOnTintColor;

UIButton *postCreationButton;
static void *const kcvkMenuSwitch = (void*)&kcvkMenuSwitch;
MenuCell *cvkCell;

CVKCellSelectionStyle menuSelectionStyle;
CVKKeyboardStyle keyboardStyle;
ColoredVKAudioLyricsView *cvkLyricsView;
UIImageView *cvkCoverView;




@interface ColoredVKMainController : NSObject

+ (void)setupMenuBar:(UITableView*)tableView;
+ (void)resetMenuTableView:(UITableView*)tableView;

+ (void)setupUISearchBar:(UISearchBar*)searchBar;
+ (void)resetUISearchBar:(UISearchBar*)searchBar;

+ (UIVisualEffectView *)blurForView:(UIView *)view withTag:(int)tag;

+ (MenuCell*) createCustomCell;
+ (void)switchTriggered:(UISwitch*)switchView;

+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip parallaxEffect:(BOOL)parallaxEffect;

+ (void)downloadCoverForArtist:(NSString *)artist song:(NSString *)song completionBlock:( void(^)(UIImage *image) )block;
@end


#pragma mark Static methods

static UIImage *coloredImage(UIColor *color, UIImage *originalImage)
{    
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, originalImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        [color setFill];
        CGContextTranslateCTM(context, 0, originalImage.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextClipToMask(context, CGRectMake(0, 0, originalImage.size.width, originalImage.size.height), originalImage.CGImage);
        CGContextFillRect(context, CGRectMake(0, 0, originalImage.size.width, originalImage.size.height));
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        return image;
    }
    UIGraphicsEndImageContext();
    
    return originalImage;
}



static void checkUpdates()
{
    NSString *stringURL = [NSString stringWithFormat:@"http://danpashin.ru/api/v%@/checkUpdates.php?userVers=%@&product=com.daniilpashin.coloredvk2", API_VERSION, kColoredVKVersion];
#ifndef COMPILE_FOR_JAIL
    stringURL = [stringURL stringByAppendingString:@"&getIPA=1"];
#endif
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest 
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (!connectionError) {
                                   NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsPath];
                                   NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                   if (!responseDict[@"error"]) {
                                       NSString *version = responseDict[@"version"];
                                       
                                       if (![prefs[@"skippedVersion"] isEqualToString:version]) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               NSString *message = [NSString stringWithFormat:CVKLocalizedString(@"YOUR_COPY_OF_TWEAK_NEEDS_TO_BE_UPGRADED_ALERT_MESSAGE"), version];
                                               UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK 2" message:message preferredStyle:UIAlertControllerStyleAlert];
                                               [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"SKIP_THIS_VERSION_BUTTON_TITLE") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                                   [prefs setValue:version forKey:@"skippedVersion"];
                                                   [prefs writeToFile:prefsPath atomically:YES];
                                               }]];
                                               [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"REMIND_LATER_BUTTON_TITLE") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
                                               [alertController addAction:[UIAlertAction actionWithTitle:CVKLocalizedString(@"UPADTE_BUTTON_TITLE") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                                   NSURL *url = [NSURL URLWithString:responseDict[@"url"]];
                                                   if ([[UIApplication sharedApplication] canOpenURL:url]) [[UIApplication sharedApplication] openURL:url];
                                                   
                                               }]];
                                               [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
                                           });
                                       }
                                   }
                                   
                                   NSDateFormatter *dateFormatter = [NSDateFormatter new];
                                   dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
                                   [prefs setValue:[dateFormatter stringFromDate:[NSDate date]] forKey:@"lastCheckForUpdates"];
                                   [prefs writeToFile:prefsPath atomically:YES];
                               }
                           }];
}


static void reloadPrefs()
{
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:prefsPath];
    
    if (prefs && tweakEnabled) {
        enabled = [prefs[@"enabled"] boolValue];
        enabledBarColor = [prefs[@"enabledBarColor"] boolValue];
        showBar = [prefs[@"showBar"] boolValue];
        enabledToolBarColor = [prefs[@"enabledToolBarColor"] boolValue];
        enabledBarImage = [prefs[@"enabledBarImage"] boolValue];
//        enabledBlackTheme = [prefs[@"enabledBlackTheme"] boolValue];
        enabledBlackTheme = NO;
        shouldCheckUpdates = prefs[@"checkUpdates"]?[prefs[@"checkUpdates"] boolValue]:YES;
        changeSBColors = [prefs[@"changeSBColors"] boolValue];
        changeSwitchColor = [prefs[@"changeSwitchColor"] boolValue];
        
        
        
        enabledMenuImage = [prefs[@"enabledMenuImage"] boolValue];
        enabledMessagesImage = [prefs[@"enabledMessagesImage"] boolValue];
        enabledMessagesListImage = [prefs[@"enabledMessagesListImage"] boolValue];
        enabledGroupsListImage = [prefs[@"enabledGroupsListImage"] boolValue];
        enabledAudioImage = [prefs[@"enabledAudioImage"] boolValue];
        changeAudioPlayerAppearance = [prefs[@"changeAudioPlayerAppearance"] boolValue];
        minimizeAudioPlayer = [prefs[@"minimizeAudioPlayer"] boolValue];
        
        hideMenuSearch = [prefs[@"hideMenuSearch"] boolValue];
        hideMenuSeparators = [prefs[@"hideMenuSeparators"] boolValue];
        hideMessagesListSeparators = [prefs[@"hideMessagesListSeparators"] boolValue];
        hideGroupsListSeparators = [prefs[@"hideGroupsListSeparators"] boolValue];
        
        useMessagesBlur = [prefs[@"useMessagesBlur"] boolValue];
        useMessagesListBlur = [prefs[@"useMessagesListBlur"] boolValue];
        useGroupsListBlur = [prefs[@"useGroupsListBlur"] boolValue];
        useAudioBlur = [prefs[@"useAudioBlur"] boolValue];
        
        useMenuParallax = [prefs[@"useMenuParallax"] boolValue];
        useMessagesListParallax = [prefs[@"useMessagesListParallax"] boolValue];
        useMessagesParallax = [prefs[@"useMessagesParallax"] boolValue];
        useGroupsListParallax = [prefs[@"useGroupsListParallax"] boolValue];
        useAudioParallax = [prefs[@"useAudioParallax"] boolValue];
        
        menuImageBlackout = [prefs[@"menuImageBlackout"] floatValue];
        chatImageBlackout = [prefs[@"chatImageBlackout"] floatValue];
        chatListImageBlackout = [prefs[@"chatListImageBlackout"] floatValue];
        groupsListImageBlackout = [prefs[@"groupsListImageBlackout"] floatValue];
        audioImageBlackout = [prefs[@"audioImageBlackout"] floatValue];
        
        
        
        
        updatesInterval = prefs[@"updatesInterval"]?[prefs[@"updatesInterval"] doubleValue]:1.0;
        menuSelectionStyle = prefs[@"menuSelectionStyle"]?[prefs[@"menuSelectionStyle"] integerValue]:CVKCellSelectionStyleTransparent;
        keyboardStyle = prefs[@"keyboardStyle"]?[prefs[@"keyboardStyle"] intValue]:CVKKeyboardStyleBlack;
        
        menuSeparatorColor = prefs[@"MenuSeparatorColor"]?[UIColor colorFromString:prefs[@"MenuSeparatorColor"]]:[UIColor defaultColorForIdentifier:@"MenuSeparatorColor"];
        barBackgroundColor = prefs[@"BarBackgroundColor"]?[UIColor colorFromString:prefs[@"BarBackgroundColor"]]:[UIColor defaultColorForIdentifier:@"BarBackgroundColor"];
        barForegroundColor = prefs[@"BarForegroundColor"]?[UIColor colorFromString:prefs[@"BarForegroundColor"]]:[UIColor defaultColorForIdentifier:@"BarForegroundColor"];
        toolBarBackgroundColor = prefs[@"ToolBarBackgroundColor"]?[UIColor colorFromString:prefs[@"ToolBarBackgroundColor"]]:[UIColor defaultColorForIdentifier:@"ToolBarBackgroundColor"];
        toolBarForegroundColor = prefs[@"ToolBarForegroundColor"]?[UIColor colorFromString:prefs[@"ToolBarForegroundColor"]]:[UIColor defaultColorForIdentifier:@"ToolBarForegroundColor"];
        SBBackgroundColor = prefs[@"SBBackgroundColor"]?[UIColor colorFromString:prefs[@"SBBackgroundColor"]]:[UIColor defaultColorForIdentifier:@"SBBackgroundColor"];
        SBForegroundColor = prefs[@"SBForegroundColor"]?[UIColor colorFromString:prefs[@"SBForegroundColor"]]:[UIColor defaultColorForIdentifier:@"SBForegroundColor"];
        switchesTintColor = prefs[@"switchesTintColor"]?[UIColor colorFromString:prefs[@"switchesTintColor"]]:[UIColor defaultColorForIdentifier:@"switchesTintColor"];
        switchesOnTintColor = prefs[@"switchesOnTintColor"]?[UIColor colorFromString:prefs[@"switchesOnTintColor"]]:[UIColor defaultColorForIdentifier:@"switchesOnTintColor"];
        
        
        id theStatusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
        if (theStatusBar != nil) {
            if (enabled && (!enabledBlackTheme && changeSBColors)) {
                [theStatusBar performSelector:@selector(setForegroundColor:) withObject:SBForegroundColor ];
                [theStatusBar performSelector:@selector(setBackgroundColor:) withObject:SBBackgroundColor ];
            } else if (enabled && enabledBlackTheme) {
                [theStatusBar performSelector:@selector(setForegroundColor:) withObject:UIColor.lightGrayColor ];
                [theStatusBar performSelector:@selector(setBackgroundColor:) withObject:UIColor.darkBlackColor ];
                
                blackThemeWasEnabled = YES;  
            } else {
                [theStatusBar performSelector:@selector(setForegroundColor:) withObject:nil];
                [theStatusBar performSelector:@selector(setBackgroundColor:) withObject:nil];
            }
        }
            
        if (blackThemeWasEnabled && !enabledBlackTheme) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ blackThemeWasEnabled = NO; });
        if (!cvkCell) cvkCell = [ColoredVKMainController createCustomCell];
        for (UIView *view in cvkCell.subviews)  if ([view isKindOfClass:NSClassFromString(@"UISwitch")]) { UISwitch *switchView = (UISwitch *)view; switchView.on = enabled; }
    }
}


static void showAlertWithMessage(NSString *message)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ColoredVK 2" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    });
}


static void setBlur(id bar, BOOL set)
{
    if (set) {
        if ([bar isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navbar = bar;
            
            navbar.barTintColor = UIColor.clearColor;
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            blurEffectView.frame = CGRectMake(0, -20, navbar.frame.size.width, navbar.frame.size.height + 20);
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            blurEffectView.tag = 10;
            blurEffectView.layer.backgroundColor =  [UIColor.blackColor colorWithAlphaComponent:0.3].CGColor;
            blurEffectView.userInteractionEnabled = NO;
            
            UIView *borderView = [UIView new];
            borderView.frame = CGRectMake(0, navbar.frame.size.height + 19, navbar.frame.size.width, 1);
            borderView.backgroundColor = UIColor.whiteColor;
            borderView.alpha = 0.1;
            [blurEffectView addSubview:borderView];
            
            if (![navbar.subviews containsObject:[navbar viewWithTag:10]]) {                        
                [navbar addSubview:blurEffectView];
                [navbar sendSubviewToBack:blurEffectView];
                [navbar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            }
        } 
        else if  ([bar isKindOfClass:[UIToolbar class]]) {
            UIToolbar *toolBar = bar;
            
            toolBar.barTintColor = UIColor.clearColor;
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            blurEffectView.frame = CGRectMake(0, 0, toolBar.frame.size.width, toolBar.frame.size.height);
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            blurEffectView.tag = 10;
            blurEffectView.userInteractionEnabled = NO;
            
            UIView *borderView = [UIView new];
            borderView.frame = CGRectMake(0, 0, toolBar.frame.size.width, 1);
            borderView.backgroundColor = UIColor.whiteColor;
            borderView.alpha = 0.1;
            [blurEffectView addSubview:borderView];
            
            if (![toolBar.subviews containsObject:[toolBar viewWithTag:10]]) {                        
                [toolBar addSubview:blurEffectView];
                [toolBar sendSubviewToBack:blurEffectView];
                [toolBar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
            }
        }
    } else {
        if ([bar isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navbar = bar;
            if ([navbar.subviews containsObject:[navbar viewWithTag:10]]) {
                [[navbar viewWithTag:10] removeFromSuperview];        
                [navbar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            }
        } else if  ([bar isKindOfClass:[UIToolbar class]]) {
            UIToolbar *toolBar = bar;
            if ([toolBar.subviews containsObject:[toolBar viewWithTag:10]]) [[toolBar viewWithTag:10] removeFromSuperview];
        }
    }
}


static void setPostCreationButtonColor()
{
    if (enabled && enabledBlackTheme) {
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:UIColor.lightBlackColor] forState:UIControlStateNormal];
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:UIColor.lightBlackColor] forState:UIControlStateHighlighted];
        
        for (CALayer *layer in postCreationButton.layer.sublayers) {
            if (layer.backgroundColor != nil) layer.backgroundColor = UIColor.darkBlackColor.CGColor;
        }
        
        for (UIView *view in postCreationButton.subviews) {
            if ([@"UIView" isEqualToString:CLASS_NAME(view)]) view.backgroundColor = UIColor.darkBlackColor;
        }
    } else {
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:UIColor.whiteColor] forState:UIControlStateNormal];
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:UIColor.whiteColor] forState:UIControlStateHighlighted];
        
        for (CALayer *layer in postCreationButton.layer.sublayers) {
            if (layer.backgroundColor == UIColor.darkBlackColor.CGColor) layer.backgroundColor = kNewsTableViewSeparatorColor.CGColor;
        }
        
        for (UIView *view in postCreationButton.subviews) {
            if ([@"UIView" isEqualToString:CLASS_NAME(view)]) view.backgroundColor = kNewsTableViewSeparatorColor;
        }
    }
}

static NSArray *getInfoForActionController()
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[cvkBunlde pathForResource:@"AdvancedInfo" ofType:@"plist" inDirectory:@"plists"]];
    if (dict) {
        NSArray *arr = dict[@"ImagesDLInfo"];
        if (arr) return arr;
        else return @[];
    } else return @[];
}



@implementation ColoredVKMainController

+ (void)setupMenuBar:(UITableView*)tableView
{
    [self setupUISearchBar:(UISearchBar*)tableView.tableHeaderView];
}

+ (void)resetMenuTableView:(UITableView*)tableView 
{
    tableView.backgroundView = nil;
    tableView.backgroundColor = kMenuCellBackgroundColor;
    for (UIView *view in tableView.superview.subviews) if ((view.tag == 25) || (view.tag == 23)) [view removeFromSuperview];
    [self resetUISearchBar:(UISearchBar*)tableView.tableHeaderView];
}



+ (void) setupUISearchBar:(UISearchBar*)searchBar
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *barBackground = searchBar.subviews[0].subviews[0];
        if (menuSelectionStyle == CVKCellSelectionStyleBlurred) {
            searchBar.backgroundColor = UIColor.clearColor;
            if (![barBackground.subviews containsObject: [barBackground viewWithTag:102] ]) [barBackground addSubview:[self blurForView:barBackground withTag:102]];
        } else if (menuSelectionStyle == CVKCellSelectionStyleTransparent) {
            if ([barBackground.subviews containsObject: [barBackground viewWithTag:102]]) [[barBackground viewWithTag:102] removeFromSuperview];
            searchBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
        } else searchBar.backgroundColor = UIColor.clearColor;
        
        UIView *subviews = searchBar.subviews.lastObject;
        UITextField *barTextField = subviews.subviews[1];
        if ([barTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
            barTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:barTextField.placeholder  
                                                                                 attributes: @{ NSForegroundColorAttributeName: [UIColor.whiteColor colorWithAlphaComponent:0.5] }];
        }
    });
    
}


+ (void)resetUISearchBar:(UISearchBar*)searchBar
{
    searchBar.backgroundColor = kMenuCellBackgroundColor;
    
    UIView *barBackground = searchBar.subviews[0].subviews[0];
    if ([barBackground.subviews containsObject: [barBackground viewWithTag:102] ]) [[barBackground viewWithTag:102] removeFromSuperview];
    
    UIView *subviews = searchBar.subviews.lastObject;
    UITextField *barTextField = subviews.subviews[1];
    if ([barTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        barTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:barTextField.placeholder
                                                                             attributes:@{
                                                                                          NSForegroundColorAttributeName : [UIColor colorWithRed:162/255.0f green:168/255.0f blue:173/255.0f alpha:1]
                                                                                          }];
    }
}




+ (MenuCell *)createCustomCell
{    
    MenuCell *cell = [[objc_getClass("MenuCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cvkCell"];
    cell.backgroundColor = kMenuCellBackgroundColor;
    cell.contentView.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.text = @"ColoredVK";
    cell.textLabel.textColor = kMenuCellTextColor;
    cell.textLabel.backgroundColor = UIColor.clearColor;
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];
    cell.imageView.image = [UIImage imageNamed:@"VKMenuIcon" inBundle:cvkBunlde compatibleWithTraitCollection:nil];
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = kMenuCellSelectedColor;
    cell.selectedBackgroundView = backgroundView;
    
    UISwitch *switchView = [UISwitch new];
    switchView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/1.2 - switchView.frame.size.width, (cell.contentView.frame.size.height - switchView.frame.size.height)/2, 0, 0);
    switchView.tag = 405;
    switchView.on = enabled;
    switchView.onTintColor = [UIColor defaultColorForIdentifier:@"switchesOnTintColor"];
    [switchView addTarget:self action:@selector(switchTriggered:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(self, kcvkMenuSwitch, switchView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [cell addSubview:switchView];
    
    cell.select = (id)^(id arg1, id arg2) {
        VKMNavContext *mainContext = [[objc_getClass("VKMNavContext") applicationNavRoot] rootNavContext];
#ifdef COMPILE_FOR_JAILBREAK
        UIViewController *cvkPrefs = [[UIStoryboard storyboardWithName:@"Main" bundle:cvkBunlde] instantiateInitialViewController];
        [mainContext reset:cvkPrefs];
#else
        ColoredVKPrefsController *cvkPrefs = [[objc_getClass("ColoredVKPrefsController") alloc] init];
        [mainContext reset:cvkPrefs];
#endif
        return nil;
    };
    
    return cell;
}

+ (void)switchTriggered:(UISwitch *)switchView
{
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsPath];
    prefs[@"enabled"] = @(switchView.on);
    [prefs writeToFile:prefsPath atomically:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.black.theme"), NULL, NULL, YES);
    });
}


+ (UIVisualEffectView *) blurForView:(UIView *)view withTag:(int)tag
{
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    blurEffectView.frame = view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurEffectView.tag = tag;
    
    return blurEffectView;
}

+ (void)downloadImageWithSource:(NSString *)url identificator:(NSString *)imageID completionBlock:( void(^)(BOOL success, NSString *message) )block
{
    AFImageRequestOperation *imageOperation = [NSClassFromString(@"AFImageRequestOperation") 
                                               imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                                               imageProcessingBlock:^UIImage *(UIImage *image) { return image; }
                                               cacheName:nil
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   if (![[NSFileManager defaultManager] fileExistsAtPath:cvkFolder]) [[NSFileManager defaultManager] createDirectoryAtPath:cvkFolder withIntermediateDirectories:NO attributes:nil error:nil];
                                                   NSString *imagePath = [cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", imageID]];
                                                   NSString *prevImagePath = [cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", imageID]];
                                                   
                                                   UIImage *newImage = [image resizedImageByMagick: [NSString stringWithFormat:@"%fx%f#", UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height]];
                                                   
                                                   NSError *error = nil;
                                                   [UIImagePNGRepresentation(newImage) writeToFile:imagePath options:NSDataWritingAtomic error:&error];
                                                   if (!error) {
                                                       UIGraphicsBeginImageContext(CGSizeMake(40, 40));
                                                       UIImage *preview = newImage;
                                                       [preview drawInRect:CGRectMake(0, 0, 40, 40)];
                                                       preview = UIGraphicsGetImageFromCurrentImageContext();
                                                       [UIImagePNGRepresentation(preview) writeToFile:prevImagePath options:NSDataWritingAtomic error:&error];
                                                       UIGraphicsEndImageContext();
                                                   }
                                                   
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk.image.update" object:nil userInfo:@{@"identifier" : imageID}];
                                                   
                                                   if ([imageID isEqualToString:@"menuBackgroundImage"]) {
                                                       CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
                                                   }
                                                   dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(error?NO:YES, error?error.localizedDescription:@"");  });
                                                   
                                               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(NO, error.localizedDescription); });
                                               }];
    [imageOperation start];

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
    if (tableView.backgroundView == nil) {
        tableView.backgroundView = [[ColoredVKBackgroundImageView alloc] imageLayerWithFrame:tableView.frame withImageName:name blackout:blackout flip:flip parallaxEffect:parallaxEffect];
    } 
}

+ (void)downloadCoverForArtist:(NSString *)artist song:(NSString *)song completionBlock:( void(^)(UIImage *image) )block
{
    UIImage *noCover = [UIImage imageNamed:@"CoverImage" inBundle:cvkBunlde compatibleWithTraitCollection:nil];
    
    NSString *url = [NSString stringWithFormat:@"http://danpashin.ru/api/v%@/getCover.php?artist=%@&track=%@", API_VERSION, artist, song];
//    http://danpashin.ru/api/v1.2/getCover.php?artist=cycle+of+pain&track=5
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@"+"];

    AFJSONRequestOperation *operation = [NSClassFromString(@"AFJSONRequestOperation") 
                                         JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                 
                                             NSDictionary *responseDict = JSON;
                                             if (!responseDict[@"error"] && responseDict[@"coverURL"]) {
                                                 CHLog(@"%@", responseDict);
//                                                 NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:responseDict[@"coverURL"]]];
//                                                 AFImageRequestOperation *imageOperation = [NSClassFromString(@"AFImageRequestOperation") 
//                                                                                            imageRequestOperationWithRequest:request
//                                                                                            imageProcessingBlock:^UIImage *(UIImage *image) { return image; }
//                                                                                            cacheName:nil
//                                                                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                                                                                if (block) block(image);
//                                                                                            } 
//                                                                                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                                                                                if (block) block(noCover);
//                                                                                            }];
//                                                 [imageOperation start];
                                             } else if (block) block(noCover);
                                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {  if (block) block(noCover); CHLog(@"%@", error); }];
//    [operation start];

}
@end


static void setNavigationBar(UINavigationBar *navBar)
{
    if (enabled) {
        if (enabledBlackTheme) {
            setBlur(navBar, NO);
            navBar.barTintColor = UIColor.darkBlackColor;
            navBar.tintColor = UIColor.lightGrayColor;
            navBar.titleTextAttributes = @{ NSForegroundColorAttributeName : UIColor.lightGrayColor };
        }  else if (enabledBarColor) {
                if (enabledBarImage) navBar.barTintColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[cvkFolder stringByAppendingString:@"/barImage.png"]]];
                else navBar.barTintColor = barBackgroundColor;
                navBar.tintColor = barForegroundColor;
                navBar.titleTextAttributes = @{ NSForegroundColorAttributeName : barForegroundColor };
            }
    }
}

static void setToolBar(UIToolbar *toolbar)
{
    if (enabled && [toolbar respondsToSelector:@selector(setBarTintColor:)]) {
        if (enabledBlackTheme) {
            
            setBlur(toolbar, NO);
            toolbar.translucent = NO;
            NSArray *controllersToChange = @[@"UIView", @"RootView"];
            if ([controllersToChange containsObject:CLASS_NAME(toolbar.superview)]) {
                toolbar.tintColor = UIColor.lightGrayColor;
                toolbar.barTintColor = UIColor.darkBlackColor;
                for (UIView *subview in toolbar.subviews) {
                    if (![@"_UIToolbarBackground" isEqualToString:CLASS_NAME(subview)]) {
                        if ([subview respondsToSelector:@selector(setBackgroundColor:)]) subview.backgroundColor = UIColor.clearColor;
                    }
                }
            }
            for (id view in toolbar.subviews) {
                if ([view isKindOfClass:UITextView.class]) {
                    UITextView *textView = view;
                    textView.backgroundColor = UIColor.lightBlackColor;
                    textView.textColor = UIColor.lightGrayColor;
                }
            }
        } else if (enabledToolBarColor) {
            NSArray *controllersToChange = @[@"UIView", @"RootView"];
            if ([controllersToChange containsObject:CLASS_NAME(toolbar.superview)]) {
                BOOL canUseTint = YES;
                BOOL needsButtonColor = NO;
                for (id view in toolbar.subviews) {
                    if ([@"InputPanelViewTextView" isEqualToString:CLASS_NAME(view)]) {
                        canUseTint = NO;
                        needsButtonColor = YES;
                        break;
                    }
                }
                toolbar.barTintColor = toolBarBackgroundColor;
                if (canUseTint) toolbar.tintColor = toolBarForegroundColor;
                
                if (needsButtonColor) {
                    for (UIView *view in toolbar.subviews) {
                        if ([view isKindOfClass:UIButton.class]) {
                            UIButton *btn = (UIButton *)view;
                            [btn setTitleColor:[UIColor darkerColorForColor:toolBarForegroundColor] forState:UIControlStateDisabled];
                            [btn setTitleColor:toolBarForegroundColor forState:UIControlStateNormal];
                            BOOL btnToExclude = NO;
                            NSArray *btnsWithActionsToExclude = @[@"actionToggleEmoji:"];
                            for (NSString *action in [btn actionsForTarget:btn.allTargets.allObjects[0] forControlEvent:UIControlEventTouchUpInside]) {
                                if ([btnsWithActionsToExclude containsObject:action]) btnToExclude = YES;
                            }
                            if (!btnToExclude && btn.currentImage) [btn setImage:coloredImage(toolBarForegroundColor, [btn imageForState:UIControlStateNormal]) forState:UIControlStateNormal];
                        }
                    }
                    
                }
                
            }
        } 
    } else setBlur(toolbar, NO);
}



#pragma mark - GLOBAL METHODS

#pragma mark AppDelegate
CHDeclareClass(AppDelegate);
CHOptimizedMethod(2, self, BOOL, AppDelegate, application, UIApplication*, application, didFinishLaunchingWithOptions, NSDictionary *, options)
{
    [cvkBunlde load];
    reloadPrefs();
    
    CHSuper(2, AppDelegate, application, application, didFinishLaunchingWithOptions, options);
    
    [[ColoredVKInstaller alloc] startWithCompletionBlock:^(BOOL disableTweak) {
        if (!disableTweak) {
            tweakEnabled = YES;
            reloadPrefs();
        }
    }];
    if (shouldCheckUpdates) {
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
        if (!prefs[@"lastCheckForUpdates"] || ([dateFormatter dateFromString:prefs[@"lastCheckForUpdates"]].daysAgo >= updatesInterval)) checkUpdates();
    }
    
    return YES;
}



#pragma mark UINavigationBar
CHDeclareClass(UINavigationBar);
CHOptimizedMethod(0, self, void, UINavigationBar, layoutSubviews)
{
    CHSuper(0, UINavigationBar, layoutSubviews);
    setNavigationBar(self);
}

CHOptimizedMethod(0, self, void, UINavigationBar, setNeedsLayout)
{
    CHSuper(0, UINavigationBar, setNeedsLayout);
    setNavigationBar(self);
}



#pragma mark UIToolbar
CHDeclareClass(UIToolbar);
CHOptimizedMethod(0, self, void, UIToolbar, layoutSubviews)
{
    CHSuper(0, UIToolbar, layoutSubviews);
    setToolBar(self);
}

CHOptimizedMethod(0, self, void, UIToolbar, setNeedsLayout)
{
    CHSuper(0, UIToolbar, setNeedsLayout);
    setToolBar(self);
}


#pragma mark UITextInputTraits
CHDeclareClass(UITextInputTraits);
CHOptimizedMethod(0, self, long long, UITextInputTraits, keyboardAppearance) 
{
    if (enabled) {
        if (enabledBlackTheme) return CVKKeyboardStyleBlack;
        return keyboardStyle;
    }
    return CHSuper(0, UITextInputTraits, keyboardAppearance);
}



#pragma mark - BLACK THEME
#pragma mark UITableViewCell
CHDeclareClass(UITableViewCell);
CHOptimizedMethod(0, self, void, UITableViewCell, layoutSubviews)
{
    CHSuper(0, UITableViewCell, layoutSubviews);
    if (enabled && enabledBlackTheme) {
        if (self.backgroundColor != UIColor.lightBlackColor) self.backgroundColor = UIColor.lightBlackColor;
    }
}



#pragma mark UITableViewCellSelectedBackground
CHDeclareClass(UITableViewCellSelectedBackground);
CHOptimizedMethod(1, self, void, UITableViewCellSelectedBackground, drawRect, CGRect, rect)
{
    if (enabled && enabledBlackTheme) {
        if ([self respondsToSelector:@selector(setSelectionTintColor:)]) self.selectionTintColor = UIColor.darkBlackColor;
        
    }
    CHSuper(1, UITableViewCellSelectedBackground, drawRect, rect);
}

#pragma mark UITableViewIndex
CHDeclareClass(UITableViewIndex);
CHOptimizedMethod(0, self, void, UITableViewIndex, layoutSubviews)
{
    if (enabled && enabledBlackTheme) {
        if ([self respondsToSelector:@selector(setIndexBackgroundColor:)]) {
            self.indexColor = UIColor.lightGrayColor;
            self.indexBackgroundColor = UIColor.clearColor;
        }
    }
    CHSuper(0, UITableViewIndex, layoutSubviews);
}

#pragma mark UITableView
CHDeclareClass(UITableView);
CHOptimizedMethod(0, self, void, UITableView, layoutSubviews)
{
    CHSuper(0, UITableView, layoutSubviews);
    
    if (enabled && enabledBlackTheme) {
        self.separatorColor = UIColor.darkBlackColor;
        self.backgroundColor = UIColor.darkBlackColor;
    }
}



#pragma mark PSListController
CHDeclareClass(PSListController);
CHOptimizedMethod(2, self, UITableViewCell*, PSListController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, PSListController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && enabledBlackTheme) {
        tableView.backgroundView = nil;
        tableView.backgroundColor = UIColor.darkBlackColor;
        cell.backgroundColor = UIColor.lightBlackColor;
    } else if (blackThemeWasEnabled) {
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        cell.backgroundColor = UIColor.whiteColor; 
    }
    
    return cell;
}


#pragma mark UILabel
CHDeclareClass(UILabel);
CHOptimizedMethod(1, self, void, UILabel, drawRect, CGRect, rect)
{
    if (enabled && enabledBlackTheme) { 
        self.textColor = UIColor.lightGrayColor;
        self.alpha = 0.8;
    } else if (blackThemeWasEnabled) self.alpha = 1;
    
    CHSuper(1, UILabel, drawRect, rect);
}


#pragma mark UIButton
CHDeclareClass(UIButton);
CHOptimizedMethod(0, self, void, UIButton, layoutSubviews)
{
    CHSuper(0, UIButton, layoutSubviews);
    if (enabled && enabledBlackTheme) self.tintColor = [UIColor colorWithRed:0.7 green:0 blue:0 alpha:1.0];
}

#pragma mark VKMGroupedCell
CHDeclareClass(VKMGroupedCell);
CHOptimizedMethod(2, self, id, VKMGroupedCell, initWithStyle, UITableViewCellStyle, style, reuseIdentifier, NSString*, reuseIdentifier)
{
    VKMGroupedCell *cell = CHSuper(2, VKMGroupedCell, initWithStyle, style, reuseIdentifier, reuseIdentifier);
    
    if (enabled && enabledBlackTheme) cell.contentView.backgroundColor = UIColor.lightBlackColor;
    
    return  cell;
}

#pragma mark VKMSearchBar
CHDeclareClass(VKMSearchBar);
CHOptimizedMethod(1, self, void, VKMSearchBar, setFrame, CGRect, frame)
{
    CHSuper(1, VKMSearchBar, setFrame, frame);
    
    if (enabled && enabledBlackTheme) {
        for (id subview in self.subviews.lastObject.subviews) {
            if ([@"UISearchBarTextField" isEqualToString:CLASS_NAME([subview class])]) {
                UITextField *field = subview;
                field.backgroundColor = UIColor.lightBlackColor;
                field.textColor = UIColor.lightGrayColor;
                self.backgroundImage = [UIImage imageWithColor:UIColor.darkBlackColor];
                self.tintColor = UIColor.lightGrayColor;
                break;
            }            
        }
    } else if (blackThemeWasEnabled) {
        if ([@"IOS7TableViewWithForcedBottomSeparator" isEqualToString:CLASS_NAME(self.superview)]) {
            for (id subview in self.subviews.lastObject.subviews) {
                if ([@"UISearchBarTextField" isEqualToString:CLASS_NAME([subview class])]) {
                    UITextField *field = subview;
                    field.backgroundColor = UIColor.clearColor;
                    field.textColor = [UIColor colorWithRed:233/255.0f green:234/255.0f blue:235/255.0f alpha:1];
                    self.backgroundImage = nil;
                    break;
                }
            }
        } else {
            for (id subview in self.subviews.lastObject.subviews) {
                if ([@"UISearchBarTextField" isEqualToString:CLASS_NAME(subview)]) {
                    UITextField *field = subview;
                    field.backgroundColor = UIColor.whiteColor;
                    field.textColor = UIColor.blackColor;
                    break;
                }
            }
        }
    }
}

#pragma mark UIAlertController
CHDeclareClass(UIAlertController);
CHOptimizedMethod(1, self, void, UIAlertController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, UIAlertController, viewWillAppear, animated);
    
    if (enabled && enabledBlackTheme) {
        for (UIView *view in self.view.subviews.lastObject.subviews) {
            if ([@"UIView" isEqualToString:CLASS_NAME(view)]) {
                for (UIView *subView in view.subviews) {
                    for (UIView *subSubView in subView.subviews) {
                        for (UIView *anyView in subSubView.subviews) {
                            anyView.backgroundColor = UIColor.lightBlackColor;
                        }
                    }
                }
            }
        }
    }
}


#pragma mark UISwitch
CHDeclareClass(UISwitch);
CHOptimizedMethod(0, self, void, UISwitch, layoutSubviews)
{
    CHSuper(0, UISwitch, layoutSubviews);
    
    if ([self isKindOfClass:NSClassFromString(@"UISwitch")] && (self.tag != 404)) {
        
        if (enabled && enabledBlackTheme) {
            self.onTintColor = [UIColor colorWithWhite:0.2 alpha:1.0];
            self.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
            self.thumbTintColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        } else if (enabled && changeSwitchColor) {
            self.onTintColor = switchesOnTintColor;
            self.tintColor = switchesTintColor;
            self.thumbTintColor = nil;
        } else {
            self.tintColor = nil;
            self.thumbTintColor = nil;
            if ((self.tag == 405) || (self.tag == 228)) self.onTintColor = [UIColor colorWithRed:90/255.0f green:130/255.0f blue:180/255.0f alpha:1.0];
            else self.onTintColor = nil;
        }
    }
}


#pragma mark UISegmentedControl
CHDeclareClass(UISegmentedControl);
CHOptimizedMethod(0, self, void, UISegmentedControl, layoutSubviews)
{
    CHSuper(0, UISegmentedControl, layoutSubviews);
    
    if ([self isKindOfClass:NSClassFromString(@"UISegmentedControl")]) {
        if (enabled && enabledBlackTheme) self.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    }
}

#pragma mark UISegmentedControl
CHDeclareClass(UIRefreshControl);
CHOptimizedMethod(0, self, void, UIRefreshControl, layoutSubviews)
{
    CHSuper(0, UIRefreshControl, layoutSubviews);
    
    if ([self isKindOfClass:NSClassFromString(@"UIRefreshControl")]) {
        if (enabled && enabledBlackTheme) self.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    }
}

#pragma mark GLOBAL METHODS
#pragma mark -


#pragma  mark FeedbackController
CHDeclareClass(FeedbackController);
CHOptimizedMethod(2, self, UITableViewCell*, FeedbackController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, FeedbackController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enabledBlackTheme) {
        for (id view in cell.contentView.subviews) {
            if ([@"MOCTLabel" isEqualToString:CLASS_NAME(view)]) {
                UIView *label = view;
                label.layer.backgroundColor = textBackgroundColor.CGColor;
                break;
            }
        }
    } else if (blackThemeWasEnabled) {
        for (id view in cell.contentView.subviews) {
            if ([@"MOCTLabel" isEqualToString:CLASS_NAME(view)]) {
                UIView *label = view;
                label.layer.backgroundColor = UIColor.clearColor.CGColor;
                break;
            }
        }
    }
    return cell;
}

#pragma  mark CountryCallingCodeController
CHDeclareClass(CountryCallingCodeController);
CHOptimizedMethod(2, self, UITableViewCell*, CountryCallingCodeController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, CountryCallingCodeController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enabledBlackTheme) {
        cell.backgroundView = nil;
        cell.backgroundColor = UIColor.lightBlackColor;
        tableView.backgroundView = nil;
        tableView.backgroundColor = UIColor.darkBlackColor;
    }
    return cell;
}

#pragma  mark SignupPhoneController
CHDeclareClass(SignupPhoneController);
CHOptimizedMethod(2, self, UITableViewCell*, SignupPhoneController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, SignupPhoneController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enabledBlackTheme) {
        cell.backgroundView = nil;
        cell.backgroundColor = UIColor.lightBlackColor;
        tableView.backgroundView = nil;
        tableView.backgroundColor = UIColor.darkBlackColor;
        
        [UITextField appearance].textColor = UIColor.lightGrayColor;
        
    }
    return cell;
}

#pragma  mark NewLoginController
CHDeclareClass(NewLoginController);
CHOptimizedMethod(2, self, UITableViewCell*, NewLoginController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, NewLoginController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enabledBlackTheme) {
        cell.backgroundView = nil;
        cell.backgroundColor = UIColor.lightBlackColor;
        tableView.backgroundView = nil;
        tableView.backgroundColor = UIColor.darkBlackColor;
        
        [UITextField appearance].textColor = UIColor.lightGrayColor;
    }
    return cell;
}

#pragma mark TextEditController
CHDeclareClass(TextEditController);
CHOptimizedMethod(1, self, void, TextEditController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, TextEditController, viewWillAppear, animated);
    if (enabled && enabledBlackTheme) {
        self.textView.backgroundColor = UIColor.darkBlackColor;
        self.textView.textColor = UIColor.lightGrayColor;
        
        for (id view in self.view.subviews) {
            if ([view isKindOfClass:UIView.class]) {
                for (UIView *subView in [view subviews]) {
                    if ([subView isKindOfClass:NSClassFromString(@"LayoutAwareView")]) {
                        for (UIView *subSubView in subView.subviews) {
                            if ([subSubView isKindOfClass:UIToolbar.class]) ((UIToolbar*)subSubView).barTintColor = UIColor.lightBlackColor;
                        }
                    }
                }
            }
        }
    }
}


#pragma mark User profile
CHDeclareClass(ProfileView);
CHOptimizedMethod(0, self, void, ProfileView, layoutSubviews)
{
    CHSuper(0, ProfileView, layoutSubviews);
    if (enabled && enabledBlackTheme) {
        if ([@"VKMAccessibilityTableView" isEqualToString:CLASS_NAME(self.superview)]) {
            if (![@"UITableViewHeaderFooterView" isEqualToString:CLASS_NAME(self)]) {
                self.backgroundColor = UIColor.lightBlackColor;
            }
        }
    }
}



#pragma mark VKMLiveController 
CHDeclareClass(VKMLiveController);
CHOptimizedMethod(2, self, UITableViewCell*, VKMLiveController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMLiveController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && enabledBlackTheme) {
        cell.backgroundColor = UIColor.lightBlackColor;
        tableView.separatorColor = UIColor.darkBlackColor;
        tableView.backgroundColor = UIColor.darkBlackColor;
        
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:UILabel.class]) {
                UILabel *label = (UILabel *)view;
                label.backgroundColor = UIColor.clearColor;
                label.textColor = UIColor.lightGrayColor;
                
            }
        }
        
        UIView *selectedBackView = [UIView new];
        selectedBackView.backgroundColor = UIColor.darkBlackColor;
        cell.selectedBackgroundView = selectedBackView;
    } else if (blackThemeWasEnabled) {
        tableView.separatorColor = kNewsTableViewSeparatorColor;
        tableView.backgroundColor = kNewsTableViewBackgroundColor;
        
    }
    
    
    return cell;
}


#pragma mark DetailController
CHDeclareClass(DetailController);
CHOptimizedMethod(2, self, UITableViewCell*, DetailController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, DetailController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    
    if (enabled && enabledBlackTheme) {
        tableView.backgroundView  = nil;
        tableView.separatorColor = UIColor.darkBlackColor;
        cell.contentView.backgroundColor = UIColor.lightBlackColor;
        
        for (UIView *view in cell.contentView.subviews) {
            NSString *class = CLASS_NAME(view);
            
            if ([@"UIView" isEqualToString:class]) view.backgroundColor = UIColor.blackColor;
            
            if ([@"TextKitLabelInteractive" isEqualToString:class]) {
                for (CALayer *layer in view.layer.sublayers) {
                    if ([layer isKindOfClass:NSClassFromString(@"TextKitLayer")]) {
                        layer.backgroundColor = textBackgroundColor.CGColor;
                        break;
                    }
                }
            }
            if ([@"UITextView" isEqualToString:class]) {
                UITextView *textView = (UITextView*)view;
                textView.backgroundColor = UIColor.lightBlackColor;
                textView.textColor = UIColor.lightGrayColor;
            }
            if ([@"UILabel" isEqualToString:class]) view.alpha = 0.5;
            if ([@"VKMLabel" isEqualToString:class]) view.layer.backgroundColor = textBackgroundColor.CGColor;
        }
    }

    
    return cell;
}

#pragma mark FeedController
CHDeclareClass(FeedController);
CHOptimizedMethod(2, self, UITableViewCell*, FeedController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, FeedController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && enabledBlackTheme) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (UIView *view in cell.contentView.subviews) {
                if ([view isKindOfClass:NSClassFromString(@"TapableComponentView")]) {
                    for (UIView *subview in view.subviews) {
                        if ([subview isKindOfClass:NSClassFromString(@"TextKitLabelInteractive")]) {
                            for (CALayer *layer in subview.layer.sublayers) {
                                if ([layer isKindOfClass:NSClassFromString(@"TextKitLayer")]) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        layer.backgroundColor = textBackgroundColor.CGColor;
                                    });
                                    break;
                                }
                            }
                        }
                    }
                }   
            }
        });
    } else if (blackThemeWasEnabled) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (UIView *view in cell.contentView.subviews) {
                if ([view isKindOfClass:NSClassFromString(@"TapableComponentView")]) {
                    for (UIView *subview in view.subviews) {
                        if ([subview isKindOfClass:NSClassFromString(@"TextKitLabelInteractive")]) {
                            for (CALayer *layer in subview.layer.sublayers) {
                                if ([layer isKindOfClass:NSClassFromString(@"TextKitLayer")]) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        layer.backgroundColor = UIColor.clearColor.CGColor;
                                    });
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        });
    }
    return cell;
}


//CHDeclareClass(VKRenderedText);
//CHOptimizedMethod(0, self, NSAttributedString*, VKRenderedText, text)
//{
//    NSAttributedString *string = CHSuper(0, VKRenderedText, text);
//    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:string.string attributes:@{}];
//    NSRange range = NSMakeRange(0, mutableString.string.length);
//    CHLog(@"%@", NSStringFromRange(range));
//    [mutableString addAttribute:NSForegroundColorAttributeName value:UIColor.redColor range:range];
//    string = [mutableString copy];
//    CHLog(@"%@", [mutableString copy]);
//    return [mutableString copy];
//}




#pragma mark NewsFeedPostCreationButton
CHDeclareClass(NewsFeedPostCreationButton);
CHOptimizedMethod(1, self, id, NewsFeedPostCreationButton, initWithFrame, CGRect, frame)
{
    UIButton *origButton = CHSuper(1, NewsFeedPostCreationButton, initWithFrame, frame);
    
    postCreationButton = origButton;
    setPostCreationButtonColor();
    
    return origButton;
}


CHDeclareClass(VKPPBadge);
CHOptimizedMethod(0, self, void, VKPPBadge, layoutSubviews)
{
    if ([self isKindOfClass:NSClassFromString(@"VKPPBadge")] && (enabled && enabledBlackTheme)) self.image = coloredImage([UIColor colorWithWhite:0.2 alpha:1], self.image);
    CHSuper(0, VKPPBadge, layoutSubviews);
}

#pragma mark BLACK THEME
#pragma mark -





#pragma mark VKMTableController
    // Настройка бара навигации
CHDeclareClass(VKMTableController);
CHOptimizedMethod(1, self, void, VKMTableController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMTableController, viewWillAppear, animated);
    BOOL shouldAddBlur = NO;
    if (enabled) {        
        if (enabledBlackTheme) shouldAddBlur = NO;
        else if (useMessagesBlur && ([CLASS_NAME(self) isEqualToString:@"MultiChatController"] || [CLASS_NAME(self) isEqualToString:@"SingleUserChatController"])) shouldAddBlur = YES;
        else if (useGroupsListBlur && [CLASS_NAME(self) isEqualToString:@"GroupsController"]) shouldAddBlur = YES;
        else if (useMessagesListBlur && [CLASS_NAME(self) isEqualToString:@"DialogsController"]) shouldAddBlur = YES;
        else if (useAudioBlur && [CLASS_NAME(self) isEqualToString:@"AudioAlbumController"]) shouldAddBlur = YES;
        else if (useAudioBlur && [CLASS_NAME(self) isEqualToString:@"AudioAlbumsController"]) shouldAddBlur = YES;
        else shouldAddBlur = NO;
    } else shouldAddBlur = NO;
    
    setBlur(self.navigationController.navigationBar, shouldAddBlur);
}

#pragma mark VKMToolbarController
    // Настройка тулбара
CHDeclareClass(VKMToolbarController);
CHOptimizedMethod(1, self, void, VKMToolbarController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMToolbarController, viewWillAppear, animated);
    if ([self respondsToSelector:@selector(toolbar)]) {
        BOOL shouldAddBlur = NO;
        if (enabled) {
            if (enabledBlackTheme) shouldAddBlur = NO;
            else if (useGroupsListBlur && [CLASS_NAME(self) isEqualToString:@"GroupsController"]) shouldAddBlur = YES;
            else shouldAddBlur = NO;
        } else shouldAddBlur = NO;
        
        setBlur(self.toolbar, shouldAddBlur);
    }
}

#pragma mark NewsFeedController
CHDeclareClass(NewsFeedController);
CHOptimizedMethod(0, self, BOOL, NewsFeedController, VKMScrollViewFullscreenEnabled)
{
    if (enabled && showBar) return NO;
    return CHSuper(0, NewsFeedController, VKMScrollViewFullscreenEnabled);
}
CHOptimizedMethod(2, self, UITableViewCell*, NewsFeedController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, NewsFeedController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    newsFeedTableView = tableView;
    return cell;
}

#pragma mark PhotoFeedController
CHDeclareClass(PhotoFeedController);
CHOptimizedMethod(0, self, BOOL, PhotoFeedController, VKMScrollViewFullscreenEnabled)
{
    if (enabled && showBar) return NO; 
    return CHSuper(0, PhotoFeedController, VKMScrollViewFullscreenEnabled);
}


#pragma mark GroupsController - список групп
CHDeclareClass(GroupsController);
CHOptimizedMethod(0, self, void, GroupsController, viewWillLayoutSubviews)
{
    CHSuper(0, GroupsController, viewWillLayoutSubviews);
    if (enabled && [self isKindOfClass:NSClassFromString(@"GroupsController")]) {
        if (enabledBlackTheme) {
            self.tableView.backgroundColor = UIColor.darkBlackColor;
            self.tableView.backgroundView = nil;
        } else if (enabledGroupsListImage) {
            [ColoredVKMainController setImageToTableView:self.tableView withName:@"groupsListBackgroundImage" blackout:groupsListImageBlackout parallaxEffect:useGroupsListParallax];
            self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
            self.tableView.separatorColor = (enabled && hideGroupsListSeparators)?UIColor.clearColor:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
            self.segment.alpha = 0.9;
            
            UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;search.backgroundImage = [UIImage new];
            search.scopeBarBackgroundImage = [UIImage new];
            for (UIView *field in search.subviews.lastObject.subviews){
                if ([field isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
                    field.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
                    UITextField *textField = (UITextField*)field;
                    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder
                                                                                      attributes:@{NSForegroundColorAttributeName:[UIColor.whiteColor colorWithAlphaComponent:0.7]}];
                }
            }
            
            if ([[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"] intValue] == 27) 
                for (UIView *view in self.view.subviews) if ([view isKindOfClass:UIToolbar.class] && useGroupsListBlur) {  setBlur(view, YES); break; }
        }
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, GroupsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, GroupsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"GroupsController")] && enabled) {
        if ([cell isKindOfClass:NSClassFromString(@"GroupCell")]) {
            GroupCell *groupCell = (GroupCell *)cell;
            if (enabledBlackTheme) {
                groupCell.backgroundColor = UIColor.lightBlackColor; 
            } else if (enabledGroupsListImage) {
                groupCell.backgroundColor =  UIColor.clearColor;
                groupCell.name.textColor = [UIColor colorWithWhite:1 alpha:0.9];
                groupCell.name.backgroundColor = UIColor.clearColor;
                groupCell.status.textColor = [UIColor colorWithWhite:0.8 alpha:0.9];
                groupCell.status.backgroundColor = UIColor.clearColor;
                
                UIView *backView = [UIView new];
                backView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
                groupCell.selectedBackgroundView = backView;
            }
            return groupCell;
        } else  if ([cell isKindOfClass:NSClassFromString(@"VKMRendererCell")]) {
            if (enabledBlackTheme) {
                cell.backgroundColor = UIColor.lightBlackColor; 
            } else if (enabledGroupsListImage) {
                cell.backgroundColor =  UIColor.clearColor;
                
                for (UIView *view in cell.contentView.subviews) {
                    if ([view isKindOfClass:NSClassFromString(@"UILabel")]) {
                        UILabel *label = (UILabel *)view;
                        label.textColor = [UIColor colorWithWhite:1 alpha:0.9];
                        label.backgroundColor = UIColor.clearColor;
                    }
                }
                
                UIView *backView = [UIView new];
                backView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
                cell.selectedBackgroundView = backView;
            }
        }
        
    }
    
    return cell;
}



#pragma mark DialogsController - список диалогов
CHDeclareClass(DialogsController);

CHOptimizedMethod(0, self, void, DialogsController, viewWillLayoutSubviews)
{
    CHSuper(0, DialogsController, viewWillLayoutSubviews);
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")] && (enabled && (!enabledBlackTheme && enabledMessagesListImage)) ) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"messagesListBackgroundImage" blackout:chatListImageBlackout parallaxEffect:useMessagesListParallax];
    }
}

CHOptimizedMethod(1, self, void, DialogsController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DialogsController, viewWillAppear, animated);
    dlopen([NSBundle.mainBundle.bundlePath stringByAppendingString:@"/FLEXDylib.dylib"].UTF8String, RTLD_LAZY);
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")] && enabled) {
        if (enabledBlackTheme) {
            self.tableView.backgroundColor = UIColor.darkBlackColor;
            self.tableView.backgroundView = nil;
        } else if (enabledMessagesListImage) {
            self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
            self.tableView.separatorColor = (enabled && hideMessagesListSeparators)?UIColor.clearColor:[self.tableView.separatorColor colorWithAlphaComponent:0.2];
            
            UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
            search.backgroundImage = [UIImage new];
            for (UIView *field in search.subviews.lastObject.subviews) {
                if ([field isKindOfClass:UITextField.class]) {
                    field.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
                    UITextField *textField = (UITextField*)field;
                    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder
                                                                                      attributes:@{NSForegroundColorAttributeName: [UIColor.whiteColor colorWithAlphaComponent:0.7]}];
                } else if (![field isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) field.hidden = YES;
            }
        }
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, DialogsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")] && enabled) {
        NewDialogCell *cell = (NewDialogCell *)CHSuper(2, DialogsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
        if (enabledBlackTheme) {
            cell.contentView.backgroundColor = UIColor.lightBlackColor; 
        } else if (enabledMessagesListImage) {
            cell.backgroundView.hidden = YES;
            cell.backgroundColor = UIColor.clearColor;
            if (!cell.dialog.head.read_state && cell.unread.hidden) cell.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
            else cell.contentView.backgroundColor = UIColor.clearColor;
            
            cell.name.textColor = [UIColor colorWithWhite:1 alpha:0.9];
            cell.time.textColor = cell.name.textColor;
            if ([cell respondsToSelector:@selector(dialogText)]) cell.dialogText.textColor = [UIColor colorWithWhite:0.95 alpha:0.9];
            if ([cell respondsToSelector:@selector(text)]) cell.text.textColor = [UIColor colorWithWhite:0.95 alpha:0.9];
            cell.attach.textColor = [UIColor colorWithWhite:0.95 alpha:0.9];
            
            UIView *backView = [UIView new];
            backView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
            cell.selectedBackgroundView = backView;

        }
        return cell;
    }
    return CHSuper(2, DialogsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
}



#pragma mark VKMSearchController
CHDeclareClass(VKMSearchController);
CHOptimizedMethod(1, self, void, VKMSearchController, searchDisplayControllerWillEndSearch, VKMSearchController*, controller)
{
    CHSuper(1, VKMSearchController, searchDisplayControllerWillEndSearch, controller);
    if ([controller isKindOfClass:NSClassFromString(@"DialogsSearchController")] && (enabled && enabledMessagesListImage)) {
        for (UIView *field in controller.searchBar.subviews.lastObject.subviews) 
            if ([field isKindOfClass:UITextField.class]) { field.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1]; break; }
    }
}

CHOptimizedMethod(1, self, void, VKMSearchController, searchDisplayControllerWillBeginSearch, VKMSearchController*, controller)
{
    CHSuper(1, VKMSearchController, searchDisplayControllerWillBeginSearch, controller);
    if ([controller isKindOfClass:NSClassFromString(@"DialogsSearchController")] && (enabled && enabledMessagesListImage)) {
        for (UIView *field in controller.searchBar.subviews.lastObject.subviews){
            if ([field isKindOfClass:UITextField.class]) {
                field.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
            } else if (![field isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) field.hidden = NO;
            if (enabledBlackTheme && [field isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) field.hidden = YES;
        }
        if (enabledBlackTheme) {
            controller.searchBar.scopeBarBackgroundImage = [UIImage imageWithColor:[UIColor colorWithWhite:0 alpha:1]];
        }
    }
}

#pragma mark BackgroundView
CHDeclareClass(BackgroundView);
CHOptimizedMethod(1, self, void, BackgroundView, drawRect, CGRect, rect)
{
    if (enabled) {
        self.layer.cornerRadius = self.cornerRadius;
        self.layer.masksToBounds = YES;
        if (enabledBlackTheme) self.layer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
        else if (enabledMessagesListImage) self.layer.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2].CGColor;
        else CHSuper(1, BackgroundView, drawRect, rect);
    } else CHSuper(1, BackgroundView, drawRect, rect);
}


#pragma mark ChatController
CHDeclareClass(ChatController);
CHOptimizedMethod(1, self, void, ChatController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, ChatController, viewWillAppear, animated);
    if (enabled) {
        if (enabledBlackTheme) {
            for (UIView *subview in self.inputPanel.subviews) {
                if ([subview respondsToSelector:@selector(setBackgroundColor:)]) subview.backgroundColor = UIColor.clearColor;
            }
        }
        else if (useMessagesBlur) setBlur(self.inputPanel, YES);
    }
}

CHOptimizedMethod(0, self, void, ChatController, viewWillLayoutSubviews)
{
    CHSuper(0, ChatController, viewWillLayoutSubviews);
    
    if ([self isKindOfClass:NSClassFromString(@"ChatController")] && enabled) {
        if (enabledBlackTheme) {
            self.tableView.backgroundColor = UIColor.darkBlackColor;
            self.tableView.backgroundView = nil;
        } else if (enabledMessagesImage) {
//      Эксклюзивно для  Артур Котов
//            self.headerImage.hidden = YES;
//            self.componentTitleView.hidden = YES;
//      Эксклюзивно для  Артур Котов
            self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
            [ColoredVKMainController setImageToTableView:self.tableView withName:@"messagesBackgroundImage" blackout:chatImageBlackout flip:YES parallaxEffect:useMessagesParallax];
        }
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, ChatController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ChatController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
     if (enabled && (enabledMessagesImage && !enabledBlackTheme) ) {
         for (id view in cell.contentView.subviews) { if ([view respondsToSelector:@selector(setTextColor:)]) [view setTextColor:[UIColor colorWithWhite:1 alpha:0.7]]; }
         
         if ([cell.contentView.subviews[0] isKindOfClass:UIImageView.class]) {
             UIImageView *bubbleView = cell.contentView.subviews[0];
             bubbleView.layer.shadowOffset = CGSizeMake(0.6, 0.8);
             bubbleView.layer.shadowOpacity = 0.3;
             bubbleView.layer.shadowRadius = 0.4;
             bubbleView.layer.shouldRasterize = YES;
             bubbleView.clipsToBounds = NO;
         }
         if ([CLASS_NAME(cell) isEqualToString:@"UITableViewCell"]) cell.backgroundColor = UIColor.clearColor;
    }
    
    return cell;
}

CHOptimizedMethod(0, self, UIButton*, ChatController, editForward)
{
    UIButton *forwardButton = CHSuper(0, ChatController, editForward);
    if (enabled && (!enabledBlackTheme && useMessagesBlur)) {
        [forwardButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [forwardButton setImage:coloredImage(UIColor.whiteColor, [forwardButton imageForState:UIControlStateNormal]) forState:UIControlStateNormal];
        for (UIView *subview in forwardButton.superview.subviews) if ([subview isKindOfClass:NSClassFromString(@"UIToolbar")]) { setBlur(subview, YES); break; }
    }
    return forwardButton;
}



#pragma mark MessageCell
CHDeclareClass(MessageCell);
CHOptimizedMethod(1, self, void, MessageCell, updateBackground, BOOL, animated)
{
    CHSuper(1, MessageCell, updateBackground, animated);
    if (enabled && (enabledMessagesImage || enabledBlackTheme)) {
        self.backgroundView = nil;
        if (!self.message.read_state) self.backgroundColor = enabledBlackTheme?[UIColor colorWithWhite:40.0/255.0f alpha:1.0]:[UIColor colorWithWhite:1 alpha:0.15];
        else self.backgroundColor = UIColor.clearColor;
    }
}




#pragma mark VKMMainController
CHDeclareClass(VKMMainController);
CHOptimizedMethod(0, self, NSArray*, VKMMainController, menu)
{
    NSArray *origMenu = CHSuper(0, VKMMainController, menu);
    NSMutableArray *tempArray = [origMenu mutableCopy];
    BOOL shouldInsert = NO;
    NSUInteger index;
    for (UITableViewCell *cell in tempArray) {
        if ([cell.textLabel.text isEqualToString:@"VKSettings"]) {
            shouldInsert = YES;
            index = [tempArray indexOfObject:cell];
            break;
        }
    }
    if (!cvkCell) cvkCell = [ColoredVKMainController createCustomCell];
    shouldInsert?[tempArray insertObject:cvkCell atIndex:index+1]:[tempArray addObject:cvkCell];
    origMenu = [tempArray copy];
    return origMenu;
}

CHOptimizedMethod(2, self, CGFloat, VKMMainController, tableView, UITableView*, tableView, heightForRowAtIndexPath, NSIndexPath*, indexPath)
{
    CGFloat height = CHSuper(2, VKMMainController, tableView, tableView, heightForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"VKMMainController")] && self.menu.count > 0) { 
        UITableViewCell *cell = self.menu[indexPath.row];
        if ([cell.textLabel.text isEqualToString:@"ColoredVK"]) height = 44;
        if ([cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)]) height = 35;
    }
    return height;
}

CHOptimizedMethod(2, self, UITableViewCell*, VKMMainController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMMainController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    menuTableView = tableView;
    
    NSDictionary *identifiers = @{@"customCell" : @228, @"cvkCell": @405};
    if ([identifiers.allKeys containsObject:cell.reuseIdentifier]) {
        UISwitch *switchView = [cell viewWithTag:[identifiers[cell.reuseIdentifier] integerValue]];
        if ([CLASS_NAME(switchView) isEqualToString:@"UISwitch"]) [switchView layoutSubviews];
    }
    
    
    if (enabled && hideMenuSeparators) tableView.separatorColor = UIColor.clearColor; 
    else if (enabled && !hideMenuSeparators) tableView.separatorColor = menuSeparatorColor; 
    else tableView.separatorColor = kMenuCellSeparatorColor;
    
    if (enabled && enabledBlackTheme) {
        cell.backgroundColor = UIColor.lightBlackColor;
        cell.contentView.backgroundColor = UIColor.lightBlackColor;
        cell.textLabel.textColor = UIColor.lightGrayColor;
        if ((indexPath.section == 1) && (indexPath.row == 0)) cell.backgroundColor = UIColor.darkBlackColor;
        
        UIView *selectedBackView = [UIView new];
        selectedBackView.backgroundColor = UIColor.darkBlackColor;
        cell.selectedBackgroundView = selectedBackView;
        
        if (![tableView.superview.subviews containsObject:[tableView.superview viewWithTag:23]]) {
            UIView *statusBarBack = [UIView new];
            statusBarBack.frame = CGRectMake(0, 0, tableView.frame.size.width, 20);
            statusBarBack.backgroundColor = UIColor.lightBlackColor;
            statusBarBack.tag = 23;
            [tableView.superview addSubview:statusBarBack]; 
        }
        
    } else if (enabled && enabledMenuImage) {
        cell.textLabel.textColor = kMenuCellTextColor;
        cell.backgroundColor = UIColor.clearColor;
        cell.contentView.backgroundColor = UIColor.clearColor;
        
        if ((indexPath.section == 0) && (indexPath.row == 0)) [ColoredVKMainController setupMenuBar:tableView];
        
        if (![tableView.superview.subviews containsObject: [tableView.superview viewWithTag:23] ]) {
            UIView *backgrondView = [[ColoredVKBackgroundImageView alloc] imageLayerWithFrame:tableView.superview.frame withImageName:@"menuBackgroundImage" blackout:menuImageBlackout parallaxEffect:useMenuParallax];
            [tableView.superview insertSubview:backgrondView atIndex:0];
            tableView.backgroundColor = UIColor.clearColor;
            tableView.backgroundView = nil;
        }        
        
        UIView *selectedBackView = [UIView new];
        if (menuSelectionStyle == CVKCellSelectionStyleTransparent) selectedBackView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        else if (menuSelectionStyle == CVKCellSelectionStyleBlurred) {
            selectedBackView.backgroundColor = UIColor.clearColor;
            if (![selectedBackView.subviews containsObject: [selectedBackView viewWithTag:100] ]) [selectedBackView addSubview:[ColoredVKMainController blurForView:selectedBackView withTag:100]];
            
        } else selectedBackView.backgroundColor = UIColor.clearColor;
        cell.selectedBackgroundView = selectedBackView;
        
        if (VKSettingsEnabled) {
            if ([cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)] && (menuSelectionStyle != CVKCellSelectionStyleNone)) 
                cell.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        }
        
    } else {
        cell.backgroundColor = kMenuCellBackgroundColor;
        cell.contentView.backgroundColor = kMenuCellBackgroundColor;
        cell.textLabel.textColor = kMenuCellTextColor;
        if (((indexPath.section == 1) && (indexPath.row == 0)) || (VKSettingsEnabled && [cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)])) {
            cell.backgroundColor = kMenuCellSelectedColor; 
            cell.contentView.backgroundColor = kMenuCellSelectedColor; 
        }
        
        UIView *selectedBackView = [UIView new];
        selectedBackView.backgroundColor = kMenuCellSelectedColor;
        cell.selectedBackgroundView = selectedBackView;
    }
    return cell;
}

CHOptimizedMethod(0, self, id, VKMMainController, VKMTableCreateSearchBar)
{
    if (enabled && hideMenuSearch) return nil;
    return CHSuper(0, VKMMainController, VKMTableCreateSearchBar);
}





#pragma mark  HintsSearchDisplayController
CHDeclareClass(HintsSearchDisplayController);
CHOptimizedMethod(1, self, void, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch, UISearchDisplayController*, controller)
{
    if (enabled && (enabledMenuImage && !enabledBlackTheme)) [ColoredVKMainController resetUISearchBar:controller.searchBar];
    return CHSuper(1, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch, controller);
}

CHOptimizedMethod(1, self, void, HintsSearchDisplayController, searchDisplayControllerDidEndSearch, UISearchDisplayController*, controller)
{
    if (enabled && (enabledMenuImage && !enabledBlackTheme)) [ColoredVKMainController setupUISearchBar:controller.searchBar];
    return CHSuper(1, HintsSearchDisplayController, searchDisplayControllerDidEndSearch, controller);
}



#pragma mark IOS7AudioController
CHDeclareClass(IOS7AudioController);
CHOptimizedMethod(0, self, UIStatusBarStyle, IOS7AudioController, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"IOS7AudioController")] && ( enabled && (!enabledBlackTheme && (enabledBarColor || enabledAudioImage)))) return UIStatusBarStyleLightContent;
    else return CHSuper(0, IOS7AudioController, preferredStatusBarStyle);
}

CHOptimizedMethod(1, self, void, IOS7AudioController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, IOS7AudioController, viewWillAppear, animated);
    
    if (enabled && [self isKindOfClass:NSClassFromString(@"IOS7AudioController")]) {
        if (enabledBlackTheme) {
            for (UIView *view in self.view.subviews) {
                if ([view isKindOfClass:[UIImageView class]]) {
                    view.backgroundColor = UIColor.blackColor;
                } else {
                    view.backgroundColor = [UIColor colorWithWhite:30/255.0f alpha:1.0];
                    for (id subView in  view.subviews) {
                        if ([subView respondsToSelector:@selector(setBackgroundColor:)]) [subView setBackgroundColor:UIColor.clearColor];
                        if ([subView respondsToSelector:@selector(setImage:forState:)]) {
                            [subView setImage:coloredImage(UIColor.buttonsTintColor, [subView imageForState:UIControlStateNormal]) forState:UIControlStateNormal];
                            [subView setImage:coloredImage(UIColor.lightGrayColor, [subView imageForState:UIControlStateSelected]) forState:UIControlStateSelected];
                        }
                    }
                    [self.pp setImage:coloredImage(UIColor.buttonsTintColor, [self.pp imageForState:UIControlStateSelected]) forState:UIControlStateSelected];
                }
            }
        } else if (changeAudioPlayerAppearance) {
            UINavigationBar *navBar = self.navigationController.navigationBar;
            if (minimizeAudioPlayer) {
                navBar.topItem.titleView.hidden = YES;
                navBar.shadowImage = [UIImage new];
                [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
                
                if (![navBar.subviews containsObject:[navBar viewWithTag:26]]) {
                    UIView *gradientView = [UIView new];
                    gradientView.frame = CGRectMake(0, -20, self.view.frame.size.width, 64);
                    gradientView.tag = 26;
                    CAGradientLayer *gradient = [CAGradientLayer layer];
                    gradient.frame = gradientView.bounds;
                    gradient.colors = @[ (id)[UIColor colorWithWhite:0 alpha:0.3].CGColor, (id)UIColor.clearColor.CGColor ];
                    gradient.locations = @[ @0.3, @1];
                    [gradientView.layer insertSublayer:gradient atIndex:0];

                    [navBar addSubview:gradientView];
                    [navBar sendSubviewToBack:gradientView];
                }
            } else {
                setBlur(self.navigationController.navigationBar, YES);
                if ([navBar.topItem.titleView isKindOfClass:[UILabel class]]) 
                    ((UILabel *)navBar.topItem.titleView).textColor = UIColor.whiteColor;
            }
            for (UIView *view in self.view.subviews) {
                if (view.tag != 23) {
                    view.backgroundColor = UIColor.clearColor;
                    for (id subView in  view.subviews) {
                        if ([subView respondsToSelector:@selector(setBackgroundColor:)]) [subView setBackgroundColor:UIColor.clearColor];
                        if ([subView respondsToSelector:@selector(setTextColor:)]) [subView setTextColor:UIColor.whiteColor];
                        if ([subView respondsToSelector:@selector(setImage:forState:)]) [subView setImage:coloredImage(UIColor.whiteColor, [subView imageForState:UIControlStateNormal]) forState:UIControlStateNormal];
                    }
                }
            }
            [self.pp setImage:coloredImage(UIColor.whiteColor, [self.pp imageForState:UIControlStateSelected]) forState:UIControlStateSelected];
            
            if (![self.pp.superview.subviews containsObject:[self.pp.superview viewWithTag:24]]) {
                UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:minimizeAudioPlayer?UIBlurEffectStyleLight:UIBlurEffectStyleDark]];
                blurEffectView.frame = self.pp.superview.bounds;
                blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                blurEffectView.tag = 24;
                UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, blurEffectView.frame.size.width, 1)];
                borderView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
                [blurEffectView addSubview:borderView];
                [self.pp.superview addSubview:blurEffectView];
                [self.pp.superview sendSubviewToBack:blurEffectView];
            }
            
            
             if (![self.view.subviews containsObject:[self.view viewWithTag:23]]) {
                  if (!cvkCoverView) cvkCoverView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CoverImage" inBundle:cvkBunlde compatibleWithTraitCollection:nil]];
                 cvkCoverView.tag = 23;
                 cvkCoverView.frame = self.view.frame;
                 cvkCoverView.contentMode = UIViewContentModeScaleAspectFill;
                 [ColoredVKMainController downloadCoverForArtist:self.actor.text song:self.song.text completionBlock:^(UIImage *image) {
                     if (image) [UIView transitionWithView:cvkCoverView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{ cvkCoverView.image = image; } completion:nil];
                 }];
                 [self.view addSubview:cvkCoverView];
                 [self.view sendSubviewToBack:cvkCoverView];
             }
            
            if (![self.view.subviews containsObject:[self.view viewWithTag:24]]) {
                if (!cvkLyricsView) cvkLyricsView = [[ColoredVKAudioLyricsView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.pp.superview.frame.origin.y - 64)];
                cvkLyricsView.tag = 24;
                [self.view addSubview:cvkLyricsView];
            }
        }
    }
}

CHOptimizedMethod(0, self, void, IOS7AudioController, updateCoverImage)
{
    CHSuper(0, IOS7AudioController, updateCoverImage);
    if (changeAudioPlayerAppearance) {
        UIImageView *imageView = [self.view viewWithTag:23];
        [ColoredVKMainController downloadCoverForArtist:self.actor.text song:self.song.text completionBlock:^(UIImage *image) {
            if (image) [UIView transitionWithView:imageView duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{ imageView.image = image; } completion:nil];
        }];
    }
}

CHOptimizedMethod(1, self, void, IOS7AudioController, playerChangedItem, AudioPlayer*, item)
{
    CHSuper(1, IOS7AudioController, playerChangedItem, item);
    
    if (changeAudioPlayerAppearance) {
        if (item.audio.lyrics_id) {
            NSString *const apiVersion = @"5.60";
            NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"/Library/Preferences/group.com.vk.vkclient.plist"]];
            NSString *url = [NSString stringWithFormat:@"https://api.vk.com/method/audio.getLyrics?lyrics_id=%@&access_token=%@&v=%@", item.audio.lyrics_id, dict[@"kVKMUDSessionKey"][@"token"], apiVersion];
            AFJSONRequestOperation *operation = [NSClassFromString(@"AFJSONRequestOperation") 
                                                 JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {                                                 
                                                     if (JSON[@"response"][@"text"]) cvkLyricsView.text = JSON[@"response"][@"text"];
                                                 } failure:nil];
            [operation start];
        } else [cvkLyricsView resetState];
    }
}




#pragma mark AudioAlbumController
CHDeclareClass(AudioAlbumController);
CHOptimizedMethod(1, self, void, AudioAlbumController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, AudioAlbumController, viewWillAppear, animated);
    
    if (enabled && [self isKindOfClass:NSClassFromString(@"AudioAlbumController")]) {
        if (enabledBlackTheme) {
            self.tableView.backgroundColor = UIColor.darkBlackColor;
//            self.tableView.backgroundView = nil;
        } else if (enabledAudioImage) {         
            UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
            search.backgroundImage = [UIImage new];
            for (UIView *field in search.subviews.lastObject.subviews) {
                if ([field isKindOfClass:[UITextField class]]) {
                    field.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
                    UITextField *textField = (UITextField*)field;
                    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder
                                                                                      attributes:@{NSForegroundColorAttributeName: [UIColor.whiteColor colorWithAlphaComponent:0.7]}];
                } else if (![field isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) field.hidden = YES;
            }
        }
    }
}
CHOptimizedMethod(0, self, void, AudioAlbumController, viewWillLayoutSubviews)
{
    CHSuper(0, AudioAlbumController, viewWillLayoutSubviews);
    
    if ((enabled && (!enabledBlackTheme && enabledAudioImage)) && [self isKindOfClass:NSClassFromString(@"AudioAlbumController")]) {
        [ColoredVKMainController setImageToTableView:self.tableView withName:@"audioBackgroundImage" blackout:audioImageBlackout parallaxEffect:useAudioParallax];
        self.tableView.separatorColor = [self.tableView.separatorColor colorWithAlphaComponent:0.2];
        self.rptr.tintColor = [UIColor colorWithWhite:1 alpha:0.8];
    }
}

CHOptimizedMethod(2, self, UITableViewCell*, AudioAlbumController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, AudioAlbumController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && [self isKindOfClass:NSClassFromString(@"AudioAlbumController")]) {
        if (enabledAudioImage && !enabledBlackTheme) {
            cell.backgroundColor = UIColor.clearColor;
            cell.contentView.backgroundColor = UIColor.clearColor;
            cell.textLabel.textColor = [UIColor colorWithWhite:1 alpha:0.9];
            cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.8 alpha:0.9];
            
            UIView *backView = [UIView new];
            backView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
            cell.selectedBackgroundView = backView;
        }
    }
    
    return cell;
}






#pragma mark PhotoBrowserController
CHDeclareClass(PhotoBrowserController);
CHOptimizedMethod(1, self, void, PhotoBrowserController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, PhotoBrowserController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"PhotoBrowserController")]) {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"dlIcon" inBundle:cvkBunlde compatibleWithTraitCollection:nil]  
                                                                          style:UIBarButtonItemStylePlain 
                                                                        handler:^(id  _Nonnull sender) {
                                                                            NSString *imageSource = @"";
                                                                            int indexOfPage = self.paging.contentOffset.x / self.paging.frame.size.width;
                                                                            VKPhotoSized *photo = [self photoForPage:indexOfPage];
                                                                            if (photo.variants != nil) {
                                                                                int maxVariantIndex = 0;
                                                                                for (VKImageVariant *variant in photo.variants.allValues) {
                                                                                    if (variant.type > maxVariantIndex) {
                                                                                        maxVariantIndex = variant.type;
                                                                                        imageSource = variant.src;
                                                                                    }
                                                                                }
                                                                            }
                                                                            VKHUD *hud = [objc_getClass("VKHUD") hud];
                                                                            BlockActionController *actionController = [objc_getClass("BlockActionController") actionSheetWithTitle:nil];
                                                                            NSArray *info = getInfoForActionController();
                                                                            for (NSDictionary *dict in info) {
                                                                                [actionController addButtonWithTitle:CVKLocalizedString(dict[@"title"]) 
                                                                                                               block:(id)^(id arg1) {
                                                                                                                   NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                                                                                                                       [ColoredVKMainController downloadImageWithSource:imageSource 
                                                                                                                                                          identificator:dict[@"identifier"]
                                                                                                                                                        completionBlock:^(BOOL success, NSString *message) {
                                                                                                                                                            success?[hud hideWithResult:success]:[hud hideWithResult:success message:message];
                                                                                                                                                            [hud performSelector:@selector(hide:) withObject:@YES afterDelay:3.0];
                                                                                                                                                        }];
                                                                                                                   }];
                                                                                                                   [hud showForOperation:operation];
                                                                                                                   [operation start];
                                                                                                               }];

                                                                            }
                                                                            [actionController setCancelButtonWithTitle:UIKitLocalizedString(@"Cancel") block:nil];
                                                                            [actionController showInViewController:self];
                                                                        }];

        NSMutableArray *buttons = [self.navigationItem.rightBarButtonItems mutableCopy];
        if (buttons.count < 2) [buttons addObject:saveButton];
        self.navigationItem.rightBarButtonItems = [buttons copy];
    }
}



#pragma mark VKMBrowserController
CHDeclareClass(VKMBrowserController);
CHOptimizedMethod(1, self, void, VKMBrowserController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMBrowserController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"VKMBrowserController")]) {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] bk_initWithImage:[UIImage imageNamed:@"dlIcon" inBundle:cvkBunlde compatibleWithTraitCollection:nil]  
                                                                          style:UIBarButtonItemStylePlain 
                                                                        handler:^(id  _Nonnull sender) {
                                                                            
                                                                            VKHUD *hud = [objc_getClass("VKHUD") hud];
                                                                            BlockActionController *actionController = [objc_getClass("BlockActionController") actionSheetWithTitle:nil];
                                                                            NSArray *info = getInfoForActionController();
                                                                            for (NSDictionary *dict in info) {
                                                                                [actionController addButtonWithTitle:CVKLocalizedString(dict[@"title"]) 
                                                                                                               block:(id)^(id arg1) {
                                                                                                                   NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                                                                                                                       [ColoredVKMainController downloadImageWithSource:self.target.url.absoluteString 
                                                                                                                                                          identificator:dict[@"identifier"]
                                                                                                                                                        completionBlock:^(BOOL success, NSString *message) {
                                                                                                                                                            success?[hud hideWithResult:success]:[hud hideWithResult:success message:message];
                                                                                                                                                            [hud performSelector:@selector(hide:) withObject:@YES afterDelay:3.0];
                                                                                                                                                        }];
                                                                                                                   }];
                                                                                                                   [hud showForOperation:operation];
                                                                                                                   [operation start];
                                                                                                               }];
                                                                            }
                                                                            [actionController setCancelButtonWithTitle:UIKitLocalizedString(@"Cancel") block:nil];
                                                                            [actionController showInViewController:self];
                                                                        }];
        self.navigationItem.rightBarButtonItem = saveButton;
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:self.target.url]
                                           queue:[NSOperationQueue mainQueue] 
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (![[response.MIMEType componentsSeparatedByString:@"/"].firstObject isEqualToString:@"image"]) saveButton.enabled = NO;
                               }];
    }
}

#pragma mark VKProfile
CHDeclareClass(VKProfile);
CHOptimizedMethod(0, self, BOOL, VKProfile, verified)
{
    if ([self.user.uid  isEqual: @89911723]) return YES;
    return CHSuper(0, VKProfile, verified);
}





#pragma mark Static methods
static void reloadPrefsNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    reloadPrefs();
}

static void reloadMenuNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    reloadPrefs();
    [ColoredVKMainController resetMenuTableView:menuTableView];
    [menuTableView reloadData];
}

//static void reloadMessagesNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
//{
//    chatTableView.backgroundView = nil;
//    [chatTableView reloadData];
//}



static void reloadTablesNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    [newsFeedTableView reloadData];
    setPostCreationButtonColor();
}

CHConstructor
{
    @autoreleasepool {
            if ([[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"] intValue] >= 27) {
                
                prefsPath = CVK_PREFS_PATH;
                cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
                vksBundle = [NSBundle bundleWithPath:VKS_BUNDLE_PATH];
                cvkFolder = CVK_FOLDER_PATH;
                
                NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:prefsPath];
                if (![[NSFileManager defaultManager] fileExistsAtPath:prefsPath]) prefs = [NSMutableDictionary new];
                [prefs setValue:[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"vkVersion"];
                [prefs setValue:kColoredVKVersion forKey:@"cvkVersion"]; 
                [prefs writeToFile:prefsPath atomically:YES];
                
                
                CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadPrefsNotify, CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadMenuNotify, CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
//                CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadMessagesNotify, CFSTR("com.daniilpashin.coloredvk.reload.messages"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadTablesNotify, CFSTR("com.daniilpashin.coloredvk.black.theme"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
                
                
                
                
                
                
                CHLoadLateClass(AppDelegate);
                CHHook(2,  AppDelegate, application, didFinishLaunchingWithOptions);
                
                CHLoadLateClass(UITableView);
                CHHook(0, UITableView, layoutSubviews);
                
                CHLoadLateClass(UITableViewIndex);
                CHHook(0, UITableViewIndex, layoutSubviews);
                
                
                CHLoadLateClass(PSListController);
                CHHook(2, PSListController, tableView, cellForRowAtIndexPath);
                
                
                CHLoadLateClass(UITableViewCell);
                CHHook(0, UITableViewCell, layoutSubviews);
                
                
                CHLoadLateClass(UITableViewCellSelectedBackground);
                CHHook(1, UITableViewCellSelectedBackground, drawRect);
                
                
                CHLoadLateClass(UINavigationBar);
                if (IS_IOS_10_OR_LATER) CHHook(0, UINavigationBar, setNeedsLayout);
                else                    CHHook(0, UINavigationBar, layoutSubviews);
                
                
                CHLoadLateClass(UIToolbar);
                if (IS_IOS_10_OR_LATER) CHHook(0, UIToolbar, setNeedsLayout);
                else                    CHHook(0, UIToolbar, layoutSubviews);
                
                
                CHLoadLateClass(UITextInputTraits);
                CHHook(0, UITextInputTraits, keyboardAppearance);
                
                
                CHLoadLateClass(UILabel);
                CHHook(1, UILabel, drawRect);
                
                
                CHLoadLateClass(UIButton);
                CHHook(0, UIButton, layoutSubviews);
                
                
                CHLoadLateClass(VKMSearchBar);
                CHHook(1, VKMSearchBar, setFrame);
                
                
                CHLoadLateClass(UIAlertController);
                CHHook(1, UIAlertController, viewWillAppear);
                
                
                CHLoadLateClass(UISwitch);
                CHHook(0, UISwitch, layoutSubviews);
                
                
                CHLoadLateClass(UISegmentedControl);
                CHHook(0, UISegmentedControl, layoutSubviews);
                
                
                CHLoadLateClass(UIRefreshControl);
                CHHook(0, UIRefreshControl, layoutSubviews);
                
                
                CHLoadLateClass(BackgroundView);
                CHHook(1, BackgroundView, drawRect);
                
                
                CHLoadLateClass(VKPPBadge);
                CHHook(0, VKPPBadge, layoutSubviews);
                
                
                
                
                
                
                
                CHLoadLateClass(FeedbackController);
                CHHook(2, FeedbackController, tableView, cellForRowAtIndexPath);
                
                
                CHLoadLateClass(CountryCallingCodeController);
                CHHook(2, CountryCallingCodeController, tableView, cellForRowAtIndexPath);
                
                
                CHLoadLateClass(SignupPhoneController);
                CHHook(2, SignupPhoneController, tableView, cellForRowAtIndexPath);
                
                
                CHLoadLateClass(NewLoginController);
                CHHook(2, NewLoginController, tableView, cellForRowAtIndexPath);
                
                CHLoadLateClass(TextEditController);
                CHHook(1, TextEditController, viewWillAppear);
                
                
                CHLoadLateClass(VKMGroupedCell);
                CHHook(2, VKMGroupedCell, initWithStyle, reuseIdentifier);
                
                
                
                
                CHLoadLateClass(FeedController);
                CHHook(2, FeedController, tableView, cellForRowAtIndexPath);
                
                
                
                
                CHLoadLateClass(IOS7AudioController);
                CHHook(1, IOS7AudioController, viewWillAppear);
                CHHook(0, IOS7AudioController, preferredStatusBarStyle);
                CHHook(0, IOS7AudioController, updateCoverImage);
                CHHook(1, IOS7AudioController, playerChangedItem);
                
                
                CHLoadLateClass(DetailController);
                CHHook(2, DetailController, tableView, cellForRowAtIndexPath);
                
                
                CHLoadLateClass(VKMTableController);
                CHHook(1, VKMTableController, viewWillAppear);
                
                
                CHLoadLateClass(DialogsController);
                CHHook(0, DialogsController, viewWillLayoutSubviews);
                CHHook(1, DialogsController, viewWillAppear);
                CHHook(2, DialogsController, tableView, cellForRowAtIndexPath);
                
                
                CHLoadLateClass(VKMSearchController);
                CHHook(1, VKMSearchController, searchDisplayControllerWillEndSearch);
                CHHook(1, VKMSearchController, searchDisplayControllerWillBeginSearch);
                
                
                CHLoadLateClass(VKMLiveController);
                CHHook(2, VKMLiveController, tableView, cellForRowAtIndexPath);
                
                CHLoadLateClass(GroupsController);
                CHHook(0, GroupsController, viewWillLayoutSubviews);
                CHHook(2, GroupsController, tableView, cellForRowAtIndexPath);
                
                
                CHLoadLateClass(ProfileView);
                CHHook(0, ProfileView, layoutSubviews);
                
                
                CHLoadLateClass(NewsFeedPostCreationButton);
                CHHook(1, NewsFeedPostCreationButton, initWithFrame);
                
                
                CHLoadLateClass(NewsFeedController);
                CHHook(0, NewsFeedController, VKMScrollViewFullscreenEnabled);
                CHHook(2, NewsFeedController, tableView, cellForRowAtIndexPath);
                
                
                CHLoadLateClass(PhotoFeedController);
                CHHook(0, PhotoFeedController, VKMScrollViewFullscreenEnabled);
                
                
                CHLoadLateClass(VKMMainController);
                CHHook(2, VKMMainController, tableView, cellForRowAtIndexPath);
                CHHook(2, VKMMainController, tableView, heightForRowAtIndexPath);
                CHHook(0, VKMMainController, VKMTableCreateSearchBar);
                CHHook(0, VKMMainController, menu);
                
                
                CHLoadLateClass(ChatController);
                CHHook(0, ChatController, viewWillLayoutSubviews);
                CHHook(2, ChatController, tableView, cellForRowAtIndexPath);
                CHHook(1, ChatController, viewWillAppear);
                CHHook(0, ChatController, editForward);
                
                CHLoadLateClass(MessageCell);
                CHHook(1, MessageCell, updateBackground);
                
                
                CHLoadLateClass(HintsSearchDisplayController);
                CHHook(1, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch);
                CHHook(1, HintsSearchDisplayController, searchDisplayControllerDidEndSearch);
                
                
//                CHLoadLateClass(VKRenderedText);
//                CHHook(0, VKRenderedText, text);
                
                
                
                CHLoadLateClass(PhotoBrowserController);
                CHHook(1, PhotoBrowserController, viewWillAppear);
                
                
                CHLoadLateClass(VKMBrowserController);
                CHHook(1, VKMBrowserController, viewWillAppear);
                
                
                CHLoadLateClass(VKMToolbarController);
                CHHook(1, VKMToolbarController, viewWillAppear);
                
                
                CHLoadLateClass(VKProfile);
                CHHook(0, VKProfile, verified);
                
                
                CHLoadLateClass(AudioAlbumController);
                CHHook(1, AudioAlbumController, viewWillAppear);
                CHHook(2, AudioAlbumController, tableView, cellForRowAtIndexPath);
                CHHook(0, AudioAlbumController, viewWillLayoutSubviews);
                
                
                VKSettingsEnabled = (NSClassFromString(@"VKSettings") != nil)?YES:NO;
                
            } else {
                showAlertWithMessage([NSString stringWithFormat: @"App version (%@) is too low. Please install VK App 2.5 or later or tweak will be disabled",  [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]);
            }
    }
}
