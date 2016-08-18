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
#import "PSListController.h"

#import "ColoredVKPrefs.h"
#import "ColoredVKPrefsController.h"
#import "ColoredVKJailCheck.h"
#import "PrefixHeader.h"
#import "UIAlertView+Blocks.h"
#import "VKMethods.h"


#define kBarBackgroundColor [UIColor colorWithRed:60/255.0f green:112/255.0f blue:169/255.0f alpha:1]

#define kMenuCellBackgroundColor [UIColor colorWithRed:56.0/255.0f green:69.0/255.0f blue:84.0/255.0f alpha:1]
#define kMenuCellSelectedColor [UIColor colorWithRed:47.0/255.0f green:58.0/255.0f blue:71.0/255.0f alpha:1]
#define kMenuCellSeparatorColor [UIColor colorWithRed:72.0/255.0f green:86.0/255.0f blue:97.0/255.0f alpha:1]

#define kMenuCellTextColor [UIColor colorWithRed:233.0/255.0f green:234.0/255.0f blue:235.0/255.0f alpha:1]

#define kNewsTableViewBackgroundColor [UIColor colorWithRed:237.0/255.0f green:238.0/255.0f blue:240.0/255.0f alpha:1]
#define kNewsTableViewSeparatorColor [UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1]



#define lightBlackColor [UIColor colorWithRed:20.0/255.0f green:20.0/255.0f blue:20.0/255.0f alpha:1.0]
#define darkBlackColor [UIColor colorWithRed:10.0/255.0f green:10.0/255.0f blue:10.0/255.0f alpha:1.0]
#define textBackgroundColor [[UIColor redColor] colorWithAlphaComponent:0.3]
#define buttonsTintColor [UIColor colorWithRed:0.7 green:0 blue:0 alpha:1.0]
#define buttonsPressedTintColor [UIColor lightGrayColor]


BOOL useSpeed = NO;
BOOL VKSettingsEnabled;

NSString *prefsPath;
NSString *cvkFolder;
NSBundle *cvkBunlde;
NSBundle *vksBundle;

BOOL enabled;
BOOL enabledBarColor;
BOOL showBar;
BOOL enabledBlackKB;
BOOL enabledToolBarColor;
BOOL enabledBarImage;

BOOL enabledMenuImage;
BOOL menuBlurEnabled;
BOOL hideSeparators;
BOOL enabledMessagesImage;
CGFloat menuImageBlackout;
CGFloat chatImageBlackout;

BOOL enabledBlackTheme;
BOOL blackThemeWasEnabled;

BOOL shouldCheckUpdates;

BOOL changeSBColors;


UITableView *menuTableView;
UITableView *chatTableView;
UITableView *newsFeedTableView;

UIColor *separatorColor;
UIColor *barBackgroundColor;
UIColor *barForegroundColor;
UIColor *toolBarBackgroundColor;
UIColor *toolBarForegroundColor;
UIColor *SBBackgroundColor;
UIColor *SBForegroundColor;

UIButton *postCreationButton;

UISwitch *cvkSwitch;



@interface ColoredVKMainController : NSObject

+ (void)setupMenuBar:(UITableView*)tableView;
+ (void)resetMenuTableView:(UITableView*)tableView;

+ (void)setupUISearchBar:(UISearchBar*)searchBar;
+ (void)resetUISearchBar:(UISearchBar*)searchBar;

+ (UIVisualEffectView *) blurForView:(UIView *)view withTag:(int)tag;

+ (MenuCell*) createCustomCell;

+ (void)setPostCreationButtonColor;

- (void)resetValue;

@end


#pragma mark статичные методы

static UIImage *coloredImage(UIColor *color, UIImage *originalImage)
{
    UIImage *image;
    
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, originalImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextTranslateCTM(context, 0, originalImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, CGRectMake(0, 0, originalImage.size.width, originalImage.size.height), originalImage.CGImage);
    CGContextFillRect(context, CGRectMake(0, 0, originalImage.size.width, originalImage.size.height));
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


static BOOL compareNumbers(int *number, int *minValue, int *maxValue)
{
    return (number >= minValue && number <= maxValue)?YES:NO;
}

static void checkUpdates()
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *stringURL = [NSString stringWithFormat:@"http://danpashin.ru/api/v1.0/cvk/checkUpdates.php?userVers=%@", kColoredVKVersion];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:stringURL]];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest 
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                                   if (data != nil) {
                                       NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsPath];
                                       id responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                       if ([responseDict isKindOfClass:[NSDictionary class]]) {
                                           NSString *version = responseDict[@"version"];
                                           
                                           if (![prefs[@"skippedVersion"] isEqualToString:version]) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   NSString *message = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"YOUR_COPY_OF_TWEAK_NEEDS_TO_BE_UPGRADED_ALERT_MESSAGE", nil, cvkBunlde, nil), version];
                                                   NSString *skip = NSLocalizedStringFromTableInBundle(@"SKIP_THIS_VERSION_BUTTON_TITLE", nil, cvkBunlde, nil);
                                                   NSString *remindLater = NSLocalizedStringFromTableInBundle(@"REMIND_LATER_BUTTON_TITLE", nil, cvkBunlde, nil);
                                                   NSString *updateNow = NSLocalizedStringFromTableInBundle(@"UPADTE_BUTTON_TITLE", nil, cvkBunlde, nil);
                                                   
                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ColoredVK"
                                                                                                   message:message
                                                                                                  delegate:nil
                                                                                         cancelButtonTitle:remindLater
                                                                                         otherButtonTitles:skip, updateNow, nil];
                                                   alert.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                       NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
                                                       
                                                       if ([title isEqualToString:skip]) {
                                                           [prefs setValue:version forKey:@"skippedVersion"];
                                                           [prefs writeToFile:prefsPath atomically:YES];
                                                       } else if ([title isEqualToString:updateNow]) {
                                                           NSString *key;
#ifdef COMPILE_FOR_JAILBREAK
                                                           key = @"cydiaURL";
#else 
                                                           key = @"ipaURL";
#endif
                                                           NSURL *url = [NSURL URLWithString:responseDict[key]];
                                                           if ([[UIApplication sharedApplication] canOpenURL:url]) {
                                                               [[UIApplication sharedApplication] openURL:url];
                                                           }
                                                       }
                                                   };
                                                   
                                                   [alert show];
                                               });
                                           }
                                       }
                                       
                                       NSDateFormatter *dateFormatter = [NSDateFormatter new];
                                       dateFormatter.dateFormat = @"yyyy-MM-dd";
                                       NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
                                       [prefs setValue:dateString forKey:@"lastCheckForUpdates"];
                                       [prefs writeToFile:prefsPath atomically:YES];
                                   }
                               }];
    });
}


static void reloadPrefs()
{
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:prefsPath];
    
    if (prefs != nil) {
        enabled = [prefs[@"enabled"] boolValue];
        enabledBarColor = [prefs[@"enabledBarColor"] boolValue];
        showBar = [prefs[@"showBar"] boolValue];
        enabledBlackKB = [prefs[@"enabledBlackKB"] boolValue];
        enabledToolBarColor = [prefs[@"enabledToolBarColor"] boolValue];
        enabledBarImage = [prefs[@"enabledBarImage"] boolValue];
        enabledMenuImage = [prefs[@"enabledMenuImage"] boolValue];
        enabledMessagesImage = [prefs[@"enabledMessagesImage"] boolValue];
        menuBlurEnabled = [prefs[@"menuBlurEnabled"] boolValue];
        hideSeparators = [prefs[@"hideSeparators"] boolValue];
        enabledBlackTheme = [prefs[@"enabledBlackTheme"] boolValue];
        shouldCheckUpdates = prefs[@"checkUpdates"]?[prefs[@"checkUpdates"] boolValue]:YES;
        
        changeSBColors = [prefs[@"changeSBColors"] boolValue];
        
        menuImageBlackout = [prefs[@"menuImageBlackout"] floatValue];
        chatImageBlackout = [prefs[@"chatImageBlackout"] floatValue];
        
        separatorColor = prefs[@"MenuSeparatorColor"]?[UIColor colorFromString:prefs[@"MenuSeparatorColor"]]:kMenuCellSeparatorColor;
        barBackgroundColor = prefs[@"BarBackgroundColor"]?[UIColor colorFromString:prefs[@"BarBackgroundColor"]]:kBarBackgroundColor;
        barForegroundColor = prefs[@"BarForegroundColor"]?[UIColor colorFromString:prefs[@"BarForegroundColor"]]:[UIColor whiteColor];
        toolBarBackgroundColor = prefs[@"ToolBarBackgroundColor"]?[UIColor colorFromString:prefs[@"ToolBarBackgroundColor"]]:[UIColor colorWithRed:245.0/255.0f green:245.0/255.0f blue:248.0/255.0f alpha:1];
        toolBarForegroundColor = prefs[@"ToolBarForegroundColor"]?[UIColor colorFromString:prefs[@"ToolBarForegroundColor"]]:[UIColor colorWithRed:127.0/255.0f green:131.0/255.0f blue:137.0/255.0f alpha:1];
        
        SBBackgroundColor = prefs[@"SBBackgroundColor"]?[UIColor colorFromString:prefs[@"SBBackgroundColor"]]:[UIColor clearColor];
        SBForegroundColor = prefs[@"SBForegroundColor"]?[UIColor colorFromString:prefs[@"SBForegroundColor"]]:[UIColor whiteColor];

        
        
        id theStatusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
        if (theStatusBar != nil) {
            if (enabled && (!enabledBlackTheme && changeSBColors)) {
                [theStatusBar performSelector:@selector(setForegroundColor:) withObject:SBForegroundColor ];
                [theStatusBar performSelector:@selector(setBackgroundColor:) withObject:SBBackgroundColor ];
            } else if (enabled && enabledBlackTheme) {
                [theStatusBar performSelector:@selector(setForegroundColor:) withObject:[UIColor lightGrayColor] ];
                [theStatusBar performSelector:@selector(setBackgroundColor:) withObject:darkBlackColor ];
                
                blackThemeWasEnabled = YES;  
            } else {
                [theStatusBar performSelector:@selector(setForegroundColor:) withObject:[UIColor whiteColor] ];
                [theStatusBar performSelector:@selector(setBackgroundColor:) withObject:[UIColor clearColor] ];
            }
        }
            
        if (blackThemeWasEnabled) {  
            ColoredVKMainController *controller = [ColoredVKMainController new];
            [controller performSelector:@selector(resetValue) withObject:nil afterDelay:120.0];
        }
        
        
        if (cvkSwitch != nil) {
            cvkSwitch.on = enabled;
        }
    }
}


static void showAlertWithMessage(NSString *message)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ColoredVK"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    });
}







@implementation ColoredVKMainController

+ (void)setupMenuBar:(UITableView*)tableView
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // ищем бар поиска в таблице
        for (id view1 in tableView.subviews) {
            if ([view1 isKindOfClass:[UISearchBar class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UISearchBar *bar = view1;
                    [self setupUISearchBar:bar];
                });
                break;
            }
        }
        
    });
}

+ (void)resetMenuTableView:(UITableView*)tableView
{
    tableView.backgroundView = nil;
    tableView.backgroundColor = kMenuCellBackgroundColor;
    for (UIView *view in tableView.superview.subviews) { if (view.tag == 25) { [view removeFromSuperview];  break; } }
    for (UIView *view in tableView.superview.subviews) { if (view.tag == 23) { [view removeFromSuperview];  break; } }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            // ищем бар поиска в таблице
        for (id view in tableView.subviews) {
            if ([view isKindOfClass:[UISearchBar class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UISearchBar *bar = view;
                    [self resetUISearchBar:bar];
                });
                break;
            }
        }
    });
}




+ (void) setupUISearchBar:(UISearchBar*)searchBar
{
    UIView *subviews = (searchBar.subviews).lastObject;
    UITextField *barTextField = (id)subviews.subviews[1];
    barTextField.layer.cornerRadius = 4.0f;
    
    UIView *barBackground = searchBar.subviews[0].subviews[0];
    
    if (menuBlurEnabled) {
        searchBar.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
        
        UIVisualEffectView *blur = [self blurForView:barBackground withTag:102];
        if (![barBackground.subviews containsObject: [barBackground viewWithTag:102] ]) { [barBackground addSubview:blur]; }
    } else {
        if ([barBackground.subviews containsObject: [barBackground viewWithTag:102]]) { [[barBackground viewWithTag:20] removeFromSuperview]; }
        
        searchBar.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    }
    
        // настраиваем цвет текстового поля
    if ([barTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *placeHolderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:barTextField.placeholder  attributes:@{NSForegroundColorAttributeName: placeHolderColor}];
        barTextField.attributedPlaceholder = placeholder;
    }
    
}


+ (void)resetUISearchBar:(UISearchBar*)searchBar
{
    UIView *subviews = (searchBar.subviews).lastObject;
    UITextField *barTextField = (id)(subviews.subviews)[1];
    barTextField.layer.cornerRadius = 4.0f;
    
    searchBar.backgroundColor = kMenuCellBackgroundColor;
    
        // удаляем блюр
    UIView *barBackground = searchBar.subviews[0].subviews[0];
    if ([barBackground.subviews containsObject: [barBackground viewWithTag:102] ]) { [[barBackground viewWithTag:102] removeFromSuperview]; }
    
        // настраиваем цвет текстового поля
    if ([barTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *placeHolderColor = [UIColor colorWithRed:162/255.0f green:168/255.0f blue:173/255.0f alpha:1];
        NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:barTextField.placeholder  attributes:@{NSForegroundColorAttributeName: placeHolderColor}];
        barTextField.attributedPlaceholder = placeholder;
    }
}




+ (MenuCell *)createCustomCell
{    
    MenuCell *cell = [[objc_getClass("MenuCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"customCell"];
    cell.showsReorderControl = NO;
    cell.tag = 450;
    cell.backgroundColor = kMenuCellBackgroundColor;
    
    cell.textLabel.text = @"ColoredVK";
    cell.textLabel.textColor = kMenuCellTextColor;
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];    
    cell.imageView.image = [UIImage imageWithContentsOfFile:[cvkBunlde pathForResource:@"icon" ofType:@"png"]];
    
    cell.selectionStyle = 3;
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = kMenuCellSelectedColor;
    cell.selectedBackgroundView = backgroundView;    
    
//    UISwitch *switchView = [UISwitch new];
//    switchView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/1.2 - switchView.frame.size.width, (cell.contentView.frame.size.height - switchView.frame.size.height)/2, 0, 0);
//    switchView.tag = 451;
//    switchView.on = enabled;
//    switchView.onTintColor = [UIColor colorWithRed:90/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1.0];
//    [switchView addTarget:self action:@selector(switchTriggered:) forControlEvents:UIControlEventValueChanged];
//    [cell addSubview:switchView];
    
    cvkSwitch.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/1.2 - cvkSwitch.frame.size.width, (cell.contentView.frame.size.height - cvkSwitch.frame.size.height)/2, 0, 0);
    cvkSwitch.tag = 451;
    cvkSwitch.onTintColor = [UIColor colorWithRed:90/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1.0];
    [cvkSwitch addTarget:self action:@selector(switchTriggered:) forControlEvents:UIControlEventValueChanged];
    [cell addSubview:cvkSwitch];
    
    
#ifndef COMPILE_FOR_JAILBREAK
    cell.select = (id)^(id arg1, id arg2, id arg3, id arg4) {
        
        ColoredVKPrefsController *cvkPrefs = [ColoredVKPrefsController new];
        id mainContext = [[objc_getClass("VKMNavContext") applicationNavRoot] rootNavContext];
        [mainContext reset:cvkPrefs];

        return nil; 
    };
#endif
    
    return cell;
}

+ (void) switchTriggered:(UISwitch *)switchView
{
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsPath];
    prefs[@"enabled"] = @(switchView.on);
    [prefs writeToFile:prefsPath atomically:YES];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.messages"), NULL, NULL, YES);
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.black.theme"), NULL, NULL, YES);
}


+ (UIVisualEffectView *) blurForView:(UIView *)view withTag:(int)tag
{
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    blurEffectView.frame = view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurEffectView.tag = tag;
    
    return blurEffectView;
}


+ (void)setPostCreationButtonColor
{
    if (enabled && enabledBlackTheme) {
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:lightBlackColor] forState:UIControlStateNormal];
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:lightBlackColor] forState:UIControlStateHighlighted];
        
        for (CALayer *layer in postCreationButton.layer.sublayers) {
            if (layer.backgroundColor != nil) {
                layer.backgroundColor = darkBlackColor.CGColor;
            }
        }
        
        for (UIView *view in postCreationButton.subviews) {
            if ([@"UIView" isEqualToString:@(class_getName([view class]))]) { view.backgroundColor = darkBlackColor; }
        }
    } else {
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
        
        for (CALayer *layer in postCreationButton.layer.sublayers) {
            if (layer.backgroundColor == darkBlackColor.CGColor) { layer.backgroundColor = kNewsTableViewSeparatorColor.CGColor; }
        }
        
        for (UIView *view in postCreationButton.subviews) {
            if ([@"UIView" isEqualToString:@(class_getName([view class]))]) { view.backgroundColor = kNewsTableViewSeparatorColor; }
        }
    }
}

- (void)resetValue {
    blackThemeWasEnabled = NO; 
}
@end



#pragma mark ГЛОБАЛЬНЫЕ МЕТОДЫ

#pragma mark AppDelegate
CHDeclareClass(AppDelegate);
CHOptimizedMethod(2, self, BOOL, AppDelegate, application, UIApplication*, application, didFinishLaunchingWithOptions, NSDictionary *, options)
{
    CHSuper(2, AppDelegate, application, application, didFinishLaunchingWithOptions, options);
    reloadPrefs();
    
    if (shouldCheckUpdates) {
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
        NSTimeInterval daysCheckingInterval = 3.0;
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd";                
        NSDate *lastCheckForUpdatesDate = prefs[@"lastCheckForUpdates"] ? [dateFormatter dateFromString:prefs[@"lastCheckForUpdates"]] :[NSDate date];
        
        NSTimeInterval daysSinceCheckUpdates = [[NSDate date] timeIntervalSinceDate:lastCheckForUpdatesDate];
        if ((((NSInteger)daysSinceCheckUpdates / 3600) >= daysCheckingInterval * 24) || (prefs[@"lastCheckForUpdates"] == nil)) {
            checkUpdates();
        }
    }
    
    return YES;
}

#pragma mark UINavigationBar
CHDeclareClass(UINavigationBar);
CHOptimizedMethod(1, self, void, UINavigationBar, setBarTintColor, UIColor*, barTintColor)
{
    if (enabled && (!enabledBlackTheme && enabledBarColor) ) {
        if (enabledBarImage) {
            barTintColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[cvkFolder stringByAppendingString:@"/barImage.png"]]];
        } else {
            barTintColor = barBackgroundColor;
        }
    } else if (enabled && enabledBlackTheme) {
        barTintColor = darkBlackColor;
    }
    
    CHSuper(1, UINavigationBar, setBarTintColor, barTintColor);
}

CHOptimizedMethod(1, self, void, UINavigationBar, setTintColor, UIColor*, tintColor)
{
    if (enabled && (!enabledBlackTheme && enabledBarColor)) {
        tintColor = barForegroundColor;
    }    
    CHSuper(1, UINavigationBar, setTintColor, tintColor);
}

CHOptimizedMethod(1, self, void, UINavigationBar, setTitleTextAttributes, NSDictionary*, attributes)
{
    if (enabled && (!enabledBlackTheme && enabledBarColor)) {
        attributes = @{ NSForegroundColorAttributeName : barForegroundColor };
    } else if (enabled && enabledBlackTheme) {
        attributes = @{ NSForegroundColorAttributeName : [UIColor lightGrayColor] };
    } 
    
    CHSuper(1, UINavigationBar, setTitleTextAttributes, attributes);
}


#pragma mark UITextInputTraits
CHDeclareClass(UITextInputTraits);
CHOptimizedMethod(0, self, long long, UITextInputTraits, keyboardAppearance) 
{
    if (enabled && (enabledBlackTheme || enabledBlackKB)) {
        return 1;
    }
    return CHSuper(0, UITextInputTraits, keyboardAppearance);
}


#pragma mark UIToolbar
CHDeclareClass(UIToolbar);
CHOptimizedMethod(1, self, void, UIToolbar, setTintColor, UIColor*, tintColor)
{
    if (enabled && (!enabledBlackTheme && enabledToolBarColor)) { 
        tintColor = toolBarForegroundColor;
    }
    
    CHSuper(1, UIToolbar, setTintColor, tintColor);
}

CHOptimizedMethod(1, self, void, UIToolbar, setBarTintColor, UIColor*, barTintColor)
{
    if (enabled && (!enabledBlackTheme && enabledToolBarColor)) {
        barTintColor = toolBarBackgroundColor;
    } else if (enabled &&  enabledBlackTheme) {
        barTintColor = darkBlackColor;
    }
    
    CHSuper(1, UIToolbar, setBarTintColor, barTintColor);
}


#pragma mark UITableViewCell
CHDeclareClass(UITableViewCell);
CHOptimizedMethod(1, self, void, UITableViewCell, setBackgroundColor, UIColor*, color)
{
    if (enabled &&  enabledBlackTheme) {
        color = lightBlackColor;
    }
    CHSuper(1, UITableViewCell, setBackgroundColor, color);
}

#pragma mark UITableViewCellSelectedBackground
CHDeclareClass(UITableViewCellSelectedBackground);
CHOptimizedMethod(1, self, void, UITableViewCellSelectedBackground, setSelectionTintColor, UIColor*, tintColor)
{
    if (enabled && enabledBlackTheme) { 
        tintColor = darkBlackColor; 
    }
    CHSuper(1, UITableViewCellSelectedBackground, setSelectionTintColor, tintColor);
}

#pragma mark UITableView
CHDeclareClass(UITableView);
CHOptimizedMethod(1, self, void, UITableView, setBackgroundColor, UIColor*, color)
{
    if (enabled &&  enabledBlackTheme) {
        color = darkBlackColor;
    }
    CHSuper(1, UITableView, setBackgroundColor, color);
}


#pragma mark UITableViewIndex
CHDeclareClass(UITableViewIndex);
CHOptimizedMethod(1, self, void, UITableViewIndex, setIndexBackgroundColor, UIColor*, color)
{
    if (enabled &&  enabledBlackTheme) {
        color = [UIColor clearColor];
    }
    CHSuper(1, UITableViewIndex, setIndexBackgroundColor, color);
}

CHOptimizedMethod(1, self, void, UITableViewIndex, setIndexColor, UIColor*, color)
{
    if (enabled &&  enabledBlackTheme) {
        color = [UIColor lightGrayColor];
    }
    CHSuper(1, UITableViewIndex, setIndexColor, color);
}


 
CHOptimizedMethod(1, self, void, UITableView, setSeparatorColor, UIColor*, color)
{
    if (enabled &&  enabledBlackTheme) {
        color = darkBlackColor;
    }
    CHSuper(1, UITableView, setSeparatorColor, color);
}

#pragma mark PSListController
CHDeclareClass(PSListController);
CHOptimizedMethod(2, self, UITableViewCell*, PSListController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, PSListController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && enabledBlackTheme) {
        tableView.backgroundView = nil;
        tableView.backgroundColor = darkBlackColor;
        cell.backgroundColor = lightBlackColor;
    } else {
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        cell.backgroundColor = [UIColor whiteColor]; 
    }
    
    return cell;
}


#pragma mark UILabel
CHDeclareClass(UILabel);
CHOptimizedMethod(1, self, void, UILabel, setTextColor, UIColor*, textColor)
{
    if (enabled && enabledBlackTheme) {
        textColor = [UIColor lightGrayColor];
    }
    
    CHSuper(1, UILabel, setTextColor, textColor);
}


#pragma mark UIButton
CHDeclareClass(UIButton);
CHOptimizedMethod(1, self, void, UIButton, setTintColor, UIColor*, tintColor)
{
    if (enabled && enabledBlackTheme) {
        tintColor = [UIColor colorWithRed:0.7 green:0 blue:0 alpha:1.0];
    }
    
    CHSuper(1, UIButton, setTintColor, tintColor);
}


#pragma mark UIRefreshControl
CHDeclareClass(UIRefreshControl);
CHOptimizedMethod(1, self, void, UIRefreshControl, setTintColor, UIColor*, tintColor)
{
    if (enabled && enabledBlackTheme) {
        tintColor = lightBlackColor;
    }
    
    CHSuper(1, UIRefreshControl, setTintColor, tintColor);
}

#pragma mark VKMGroupedCell
CHDeclareClass(VKMGroupedCell);
CHOptimizedMethod(2, self, id, VKMGroupedCell, initWithStyle, UITableViewCellStyle, style, reuseIdentifier, NSString*, reuseIdentifier)
{
    VKMGroupedCell *cell = CHSuper(2, VKMGroupedCell, initWithStyle, style, reuseIdentifier, reuseIdentifier);
    
    if (enabled && enabledBlackTheme) {
        cell.backgroundView = nil;
        cell.contentView.backgroundColor = lightBlackColor;
    }
    
    return  cell;
}

#pragma mark ГЛОБАЛЬНЫЕ МЕТОДЫ











#pragma  mark FeedbackController
CHDeclareClass(FeedbackController);
CHOptimizedMethod(2, self, UITableViewCell*, FeedbackController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, FeedbackController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enabledBlackTheme) {
        for (id view in cell.contentView.subviews) {
            if ([@"MOCTLabel" isEqualToString:@(class_getName([view class]))]) {
                UIView *label = view;
                label.layer.backgroundColor = textBackgroundColor.CGColor;
                break;
            }
        }
    } else if (blackThemeWasEnabled) {
        for (id view in cell.contentView.subviews) {
            if ([@"MOCTLabel" isEqualToString:@(class_getName([view class]))]) {
                UIView *label = view;
                label.layer.backgroundColor = [UIColor clearColor].CGColor;
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
        cell.backgroundColor = lightBlackColor;
        tableView.backgroundView = nil;
        tableView.backgroundColor = darkBlackColor;
        
        self.navigationController.navigationBar.barTintColor = [UIColor redColor];
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
        cell.backgroundColor = lightBlackColor;
        tableView.backgroundView = nil;
        tableView.backgroundColor = darkBlackColor;
        
        [UITextField appearance].textColor = [UIColor lightGrayColor];
        
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
        cell.backgroundColor = lightBlackColor;
        tableView.backgroundView = nil;
        tableView.backgroundColor = darkBlackColor;
        
        [UITextField appearance].textColor = [UIColor lightGrayColor];
    }
    return cell;
}

#pragma mark TextEditController
CHDeclareClass(TextEditController);
CHOptimizedMethod(1, self, void, TextEditController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, TextEditController, viewWillAppear, animated);
    if (enabled && enabledBlackTheme) {
        self.textView.backgroundColor = darkBlackColor;
        self.textView.textColor = [UIColor lightGrayColor];
        
        for (id view in self.view.subviews) {
            if ([view isKindOfClass:[UIView class]]) {
                for (UIView *subView in [view subviews]) {
                    if ([subView isKindOfClass:objc_getClass("LayoutAwareView")]) {
                        for (UIView *subSubView in subView.subviews) {
                            if ([subSubView isKindOfClass:[UIToolbar class]]) {
                                [(UIToolbar*)subSubView setBarTintColor:lightBlackColor];
                            }
                        }
                    }
                }
            }
        }
    }
}


#pragma mark фуллскрин
CHDeclareClass(NewsFeedController);

CHOptimizedMethod(0, self, BOOL, NewsFeedController, VKMScrollViewFullscreenEnabled)
{
    if (enabled && showBar) { return NO; }
    return CHSuper(0, NewsFeedController, VKMScrollViewFullscreenEnabled);
}

CHDeclareClass(PhotoFeedController);
CHOptimizedMethod(0, self, BOOL, PhotoFeedController, VKMScrollViewFullscreenEnabled)
{
    if (enabled && showBar) { return NO; }
    return CHSuper(0, PhotoFeedController, VKMScrollViewFullscreenEnabled);
}

#pragma mark NewsFeedController
CHOptimizedMethod(2, self, UITableViewCell*, NewsFeedController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, NewsFeedController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    newsFeedTableView = tableView;
    return cell;
}




#pragma mark Профиль пользователя
CHDeclareClass(VKMAccessibilityTableView);
CHOptimizedMethod(0, self, void, VKMAccessibilityTableView, reloadData)
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:objc_getClass("ProfileView")]) {
            
            ProfileView *profView = (ProfileView*)view;
            if (enabled && enabledBlackTheme) {
                profView.backgroundColor = lightBlackColor;
                profView.name.textColor = [UIColor lightGrayColor];
            } else if (blackThemeWasEnabled) {
                profView.backgroundColor = [UIColor whiteColor];
                profView.name.textColor = [UIColor blackColor];
            }
            break;
        }
    }
    
    CHSuper(0, VKMAccessibilityTableView, reloadData);
}


#pragma mark DialogsController
CHDeclareClass(DialogsController);
CHOptimizedMethod(2, self, UITableViewCell*, DialogsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, DialogsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && enabledBlackTheme) {
        cell.contentView.backgroundColor = lightBlackColor;
        tableView.backgroundColor = darkBlackColor;
    }
    
    return cell;
}



 // группы
#pragma mark VKMLiveController
CHDeclareClass(VKMLiveController);
CHOptimizedMethod(2, self, UITableViewCell*, VKMLiveController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMLiveController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && enabledBlackTheme) {
        cell.backgroundColor = lightBlackColor;
        tableView.separatorColor = darkBlackColor;
        tableView.backgroundColor = darkBlackColor;
        
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor lightGrayColor];
                
            }
        }
        
        UIView *selectedBackView = [UIView new];
        selectedBackView.backgroundColor = darkBlackColor;
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
        tableView.separatorColor = darkBlackColor;
        cell.contentView.backgroundColor = lightBlackColor;
        
        for (UIView *view in cell.contentView.subviews) {
            NSString *class = @(class_getName([view class]));
            
           
            if ([@"UIView" isEqualToString:class]) {
                view.backgroundColor = [UIColor blackColor];
            }
            
            if (indexPath.row == 0) {
                if (!useSpeed) {
                    if ([@"TextKitLabelInteractive" isEqualToString:class]) {
                        for (CALayer *layer in view.layer.sublayers) {
                            if ([layer isKindOfClass:objc_getClass("TextKitLayer")]) {
                                layer.backgroundColor = textBackgroundColor.CGColor;
                                break;
                            }
                        }
                       
                        
                        
                        
                    }
                }
                
                if ([@"UITextView" isEqualToString:class]) {
                    UITextView *textView = (UITextView*)view;
                    textView.backgroundColor = lightBlackColor;
                    textView.textColor = [UIColor lightGrayColor];
                    
                }
            }
            if ([@"UILabel" isEqualToString:class]) { view.alpha = 0.5; }
            if ([@"VKMLabel" isEqualToString:class]) { view.layer.backgroundColor = textBackgroundColor.CGColor; }
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
                if ([view isKindOfClass:objc_getClass("TapableComponentView")]) {
                    for (UIView *subview in view.subviews) {
                        if ([subview isKindOfClass:objc_getClass("TextKitLabelInteractive")]) {
                            for (CALayer *layer in subview.layer.sublayers) {
                                if ([layer isKindOfClass:objc_getClass("TextKitLayer")]) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        layer.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3].CGColor;
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
                if ([view isKindOfClass:objc_getClass("TapableComponentView")]) {
                    for (UIView *subview in view.subviews) {
                        if ([subview isKindOfClass:objc_getClass("TextKitLabelInteractive")]) {
                            for (CALayer *layer in subview.layer.sublayers) {
                                if ([layer isKindOfClass:objc_getClass("TextKitLayer")]) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        layer.backgroundColor = [UIColor clearColor].CGColor;
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



/*CHDeclareClass(TextKitLabelInteractive);
CHOptimizedMethod(1, self, id, TextKitLabelInteractive, initWithFrame, CGRect, frame)
{
    id orig = CHSuper(1, TextKitLabelInteractive, initWithFrame, frame);
    
    if (enabled && enabledBlackTheme) {
        self.textLayer.backgroundColor = textBackgroundColor.CGColor;
    } else {
        self.textLayer.backgroundColor = [UIColor clearColor].CGColor;
    }
    
    return orig;
}*/



#pragma mark NewsFeedPostCreationButton
CHDeclareClass(NewsFeedPostCreationButton);
CHOptimizedMethod(1, self, id, NewsFeedPostCreationButton, initWithFrame, CGRect, frame)
{
    UIButton *origButton = CHSuper(1, NewsFeedPostCreationButton, initWithFrame, frame);
    
    postCreationButton = origButton;
    
    [ColoredVKMainController setPostCreationButtonColor];
    
    return origButton;
}



#pragma mark ChatController
CHDeclareClass(ChatController);
CHOptimizedMethod(2, self, UITableViewCell*, ChatController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    
    UITableViewCell *cell = CHSuper(2, ChatController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (indexPath.row == 0) { chatTableView = tableView; }
    
     if (enabled && enabledBlackTheme) {
         if (![ @(class_getName([cell class])) isEqualToString:@"UITableViewCell"]) {
             UIImageView *imageView = cell.subviews[0];  // typing image
             
             BOOL viewColor = imageView.backgroundColor == [UIColor clearColor];
             BOOL layerColor = imageView.layer.backgroundColor == [UIColor clearColor].CGColor;
             if (!viewColor || !layerColor) {
                 if (imageView.layer.sublayers.count == 0) {
                     imageView.hidden = YES;
                     cell.contentView.backgroundColor = [UIColor colorWithRed:40.0/255.0f green:40.0/255.0f blue:40.0/255.0f alpha:1.0];
                 }
             }
         }

     } else  if (enabled && (enabledMessagesImage && !enabledBlackTheme) ) {
        cell.backgroundColor = [UIColor clearColor];
        
        
        if (![ @(class_getName([cell class])) isEqualToString:@"UITableViewCell"]) {
            UIImageView *imageView = cell.subviews[0];  // typing image
            
            BOOL viewColor = imageView.backgroundColor == [UIColor clearColor];
            BOOL layerColor = imageView.layer.backgroundColor == [UIColor clearColor].CGColor;
            if (!viewColor || !layerColor) {
                if (imageView.layer.sublayers.count == 0) {
                    imageView.hidden = YES;
                    cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
                }
            }
        }
        
        for (id view in cell.contentView.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                if ([view respondsToSelector:@selector(setTextColor:)]) { [view setTextColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]]; }
                break;
            }
        }
            //        id returnedValue = object_getIvar(self, class_getInstanceVariable([self class], "_messageBody") );
        
        
        if (tableView.backgroundView == nil) {
            
            UIView *backView = [UIView new];
            backView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
            
            UIImageView *myImageView = [UIImageView new];
            myImageView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
            myImageView.image = [UIImage imageWithContentsOfFile:[cvkFolder stringByAppendingString:@"/messagesBackgroundImage.png"]];
            myImageView.contentMode = UIViewContentModeScaleAspectFill;
            float degrees = 180;
            myImageView.transform = CGAffineTransformMakeRotation(degrees * M_PI/180);
            
            [backView addSubview:myImageView];
            
            
            UIView *frontView = [UIView new];
            frontView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
            frontView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:chatImageBlackout];
            [backView addSubview:frontView];
            
            tableView.backgroundView = backView;
            
        }
    }
    
    return cell;
}


#pragma mark главное меню
CHDeclareClass(VKMMainController);

CHOptimizedMethod(2, self, NSInteger, VKMMainController, tableView, UITableView*, tableView, numberOfRowsInSection, NSInteger, section)
{
    NSMutableArray *tempArray = [self.menu mutableCopy];
    if (tempArray.count > 0 && section == 0) {
        MenuCell *cell = [ColoredVKMainController createCustomCell];
        BOOL  cellFound = NO;
        for (id arrCell in tempArray) {
            if ([arrCell tag] == 450) {
                cellFound = YES;
                break;
            }
        }
        if (cellFound == NO) { [tempArray addObject:cell]; }
        self.menu = [tempArray copy];
        
        return self.menu.count;
    }
    return CHSuper(2, VKMMainController, tableView, tableView, numberOfRowsInSection, section);
}

CHOptimizedMethod(2, self, UITableViewCell*, VKMMainController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMMainController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    menuTableView = tableView;
    
    if (enabled && hideSeparators) {  tableView.separatorColor = [UIColor clearColor]; }
    else if (enabled && !hideSeparators) { tableView.separatorColor = separatorColor; }
    else { tableView.separatorColor = kMenuCellSeparatorColor; }
    
    if (enabled && enabledBlackTheme) {
        cell.backgroundColor = lightBlackColor;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        if ((indexPath.section == 1) && (indexPath.row == 0)) { cell.backgroundColor = darkBlackColor; }
        
        UIView *selectedBackView = [UIView new];
        selectedBackView.backgroundColor = darkBlackColor;
        cell.selectedBackgroundView = selectedBackView;
        
        tableView.backgroundColor = lightBlackColor;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (UIView *view1 in tableView.subviews) {
                if ([view1 isKindOfClass:[UISearchBar class]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{ view1.backgroundColor = lightBlackColor; });
                    break;
                }
            }
        });
        
        if ([[UIDevice currentDevice].model isEqualToString:@"iPad"]) {
            UIView *statusBarBack = [UIView new];
            statusBarBack.frame = CGRectMake(0, 0, tableView.frame.size.width, 20);
            statusBarBack.backgroundColor = lightBlackColor;
            statusBarBack.tag = 23;
        
            if (![tableView.superview.subviews containsObject:[tableView.superview viewWithTag:23]]) { [tableView.superview addSubview:statusBarBack]; } 
        }
        
    } else if (enabled && (!enabledBlackTheme && enabledMenuImage)) {
        cell.textLabel.textColor = kMenuCellTextColor;
        cell.backgroundColor = [UIColor clearColor];
        
        if ((indexPath.section == 0) && (indexPath.row == 0)) { [ColoredVKMainController setupMenuBar:tableView];  } 
        
        if (![tableView.superview.subviews containsObject: [tableView.superview viewWithTag:25] ]) {
            UIView *backgrondView = [UIView new];
            backgrondView.frame = CGRectMake(0, 0, tableView.superview.frame.size.width, tableView.superview.frame.size.height);
            backgrondView.tag = 25;
            
            UIImageView *myImageView = [UIImageView new];
            myImageView.frame = CGRectMake(0, 0, tableView.superview.frame.size.width, tableView.superview.frame.size.height);
            myImageView.image = [UIImage imageWithContentsOfFile:[cvkFolder stringByAppendingString:@"/menuBackgroundImage.png"]];
            myImageView.contentMode = UIViewContentModeScaleAspectFill;
            [backgrondView addSubview:myImageView]; 
            
            UIView *frontView = [UIView new];
            frontView.frame = CGRectMake(0, 0, tableView.superview.frame.size.width, tableView.superview.frame.size.height);
            frontView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:menuImageBlackout];
            [backgrondView addSubview:frontView];
            
            [tableView.superview insertSubview:backgrondView atIndex:0];
            tableView.backgroundColor = [UIColor clearColor];
            tableView.backgroundView = nil;
        }
        
        UIView *selectedBackView = [UIView new];
        
        if (menuBlurEnabled) {
            selectedBackView.backgroundColor = [UIColor clearColor];
            UIVisualEffectView *blur = [ColoredVKMainController  blurForView:selectedBackView withTag:100];
            if (![selectedBackView.subviews containsObject: [selectedBackView viewWithTag:100] ]) { [selectedBackView addSubview:blur]; }
        } else {
            selectedBackView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
        }
        
        
        if (VKSettingsEnabled) {
            if ([cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)]) {
                cell.contentView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
            }
        }
        
        cell.selectedBackgroundView = selectedBackView;

        
    } else {
        cell.backgroundColor = kMenuCellBackgroundColor;
        if ((indexPath.section == 1) && (indexPath.row == 0)) { cell.backgroundColor = kMenuCellSelectedColor; }
        
        UIView *selectedBackView = [UIView new];
        selectedBackView.backgroundColor = kMenuCellSelectedColor;
        cell.selectedBackgroundView = selectedBackView;
        
        if (VKSettingsEnabled) {
            cell.textLabel.textColor = kMenuCellTextColor;
            if ([cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)]) {
                cell.contentView.backgroundColor = kMenuCellSelectedColor;
            }
        }
    }
    
    
    
    return cell;
}





#pragma mark  Правка бага с баром поиска в меню
CHDeclareClass(HintsSearchDisplayController);
CHOptimizedMethod(1, self, void, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch, UISearchDisplayController*, controller)
{
    if (enabled && (enabledMenuImage && !enabledBlackTheme)) {
        [ColoredVKMainController resetUISearchBar:controller.searchBar];
    }
    
    return CHSuper(1, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch, controller);
}

CHOptimizedMethod(1, self, void, HintsSearchDisplayController, searchDisplayControllerDidEndSearch, UISearchDisplayController*, controller)
{
    if (enabled && (enabledMenuImage && !enabledBlackTheme)) {
        [ColoredVKMainController setupUISearchBar:controller.searchBar];
    }
    
    return CHSuper(1, HintsSearchDisplayController, searchDisplayControllerDidEndSearch, controller);
}



#pragma mark Добавление ячейки в таблицу
CHDeclareClass(VKSettings);
CHOptimizedMethod(0, self, id, VKSettings, generateMenu)
{
    NSMutableArray *array = CHSuper(0, VKSettings, generateMenu);
    MenuCell *cell = [ColoredVKMainController createCustomCell];
    [array addObject:cell];
    return array;
}



#pragma mark AudioController
CHDeclareClass(AudioController);
CHOptimizedMethod(1, self, void, AudioController, viewWillAppear, id, appear)
{
    CHSuper(1, AudioController, viewWillAppear, appear);
    
    if (enabled && enabledBlackTheme) {
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                view.backgroundColor = [UIColor blackColor];
            } else {
                view.backgroundColor = [UIColor colorWithRed:30.0/255.0f green:30.0/255.0f blue:30.0/255.0f alpha:1.0];
                for (id subView in  view.subviews) {
                    if ([subView respondsToSelector:@selector(setBackgroundColor:)]) {
                        [subView setBackgroundColor:[UIColor clearColor]];
                    }
                    if ([subView respondsToSelector:@selector(setImage:forState:)]) {
                        [subView setImage:coloredImage(buttonsTintColor, [subView imageForState:UIControlStateNormal]) forState:UIControlStateNormal];
                        [subView setImage:coloredImage(buttonsPressedTintColor, [subView imageForState:UIControlStateSelected]) forState:UIControlStateSelected];
                    }
                }
                [self.pp   setImage:coloredImage(buttonsTintColor, [self.pp imageForState:UIControlStateSelected]) forState:UIControlStateSelected];
                
            }
        }
    }
}







#pragma mark Статичные методы
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

static void reloadMessagesNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    reloadPrefs();
    chatTableView.backgroundView = nil;
    [chatTableView reloadData];
}



static void reloadTablesNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    [newsFeedTableView reloadData];
    [ColoredVKMainController setPostCreationButtonColor];
}

CHConstructor
{
    @autoreleasepool {
        
        if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] intValue] >= 27) {
            
            cvkBunlde = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
            vksBundle = [NSBundle bundleWithPath:VKS_BUNDLE_PATH];
            prefsPath = CVK_PREFS_PATH;
            cvkFolder = CVK_FOLDER_PATH;
            
            cvkSwitch = [UISwitch new];
            
            NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:prefsPath];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:prefsPath]) { prefs = [NSMutableDictionary new]; }
            
            
            [prefs setValue:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"vkVersion"];
            [prefs setValue:kColoredVKVersion forKey:@"cvkVersion"]; 
            
            [prefs writeToFile:prefsPath atomically:YES];
            
            
            CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadPrefsNotify, CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
            CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadMenuNotify, CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
            CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadMessagesNotify, CFSTR("com.daniilpashin.coloredvk.reload.messages"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
            
            CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadTablesNotify, CFSTR("com.daniilpashin.coloredvk.black.theme"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
            
            
            
            CHLoadLateClass(AppDelegate);
            CHHook(2,  AppDelegate, application, didFinishLaunchingWithOptions);
            
            CHLoadLateClass(UITableView);
            CHHook(1, UITableView, setBackgroundColor);
            CHHook(1, UITableView, setSeparatorColor);
            
            CHLoadLateClass(UITableViewIndex);
            CHHook(1, UITableViewIndex, setIndexBackgroundColor);
            CHHook(1, UITableViewIndex, setIndexColor);
            
            
            CHLoadLateClass(PSListController);
            CHHook(2, PSListController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(UITableViewCell);
            CHHook(1, UITableViewCell, setBackgroundColor);
            
            
            CHLoadLateClass(UITableViewCellSelectedBackground);
            CHHook(1, UITableViewCellSelectedBackground, setSelectionTintColor);
            
            
            CHLoadLateClass(UINavigationBar);
            CHHook(1, UINavigationBar, setBarTintColor);
            CHHook(1, UINavigationBar, setTintColor);
            CHHook(1, UINavigationBar, setTitleTextAttributes);
            
            
            CHLoadLateClass(UIToolbar);
            CHHook(1, UIToolbar, setTintColor);
            CHHook(1, UIToolbar, setBarTintColor);
            
            
            CHLoadLateClass(UITextInputTraits);
            CHHook(0, UITextInputTraits, keyboardAppearance);
            
            
            CHLoadLateClass(UILabel);
            CHHook(1, UILabel, setTextColor);
            
            
            CHLoadLateClass(UIButton);
            CHHook(1, UIButton, setTintColor);
            
            
            CHLoadLateClass(UIRefreshControl);
            CHHook(1, UIRefreshControl, setTintColor);
            
            
            
            
            
            
            
            
            
            
            
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
            
            
            if (useSpeed) {
//                CHLoadLateClass(TextKitLabelInteractive);
//                CHHook(1, TextKitLabelInteractive, initWithFrame);
            } else {
                CHLoadLateClass(FeedController);
                CHHook(2, FeedController, tableView, cellForRowAtIndexPath);
            }
            
            
            CHLoadLateClass(AudioController);
            CHHook(1, AudioController, viewWillAppear);
            
            
            CHLoadLateClass(DetailController);
            CHHook(2, DetailController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(DialogsController);
            CHHook(2, DialogsController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(VKMLiveController);
            CHHook(2, VKMLiveController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(VKMAccessibilityTableView);
            CHHook(0, VKMAccessibilityTableView, reloadData);
            
            
            CHLoadLateClass(NewsFeedPostCreationButton);
            CHHook(1, NewsFeedPostCreationButton, initWithFrame);
            
            
            CHLoadLateClass(NewsFeedController);
            CHHook(0, NewsFeedController, VKMScrollViewFullscreenEnabled);
            CHHook(2, NewsFeedController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(PhotoFeedController);
            CHHook(0, PhotoFeedController, VKMScrollViewFullscreenEnabled);
            
            
            CHLoadLateClass(VKMMainController);
            CHHook(2, VKMMainController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(ChatController);
            CHHook(2, ChatController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(HintsSearchDisplayController);
            CHHook(1, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch);
            CHHook(1, HintsSearchDisplayController, searchDisplayControllerDidEndSearch);
            
            
            
            if (NSClassFromString(@"VKSettings") != nil ) {
                VKSettingsEnabled = YES;
                CHLoadLateClass(VKSettings);
                CHHook(0, VKSettings, generateMenu);
            } else {
                VKSettingsEnabled = NO;
                CHHook(2, VKMMainController, tableView, numberOfRowsInSection);
            }
            
        } else {
            showAlertWithMessage([NSString stringWithFormat: @"App version (%@) is too low. Please install VK App 2.5 or later or tweak will be disabled",  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]]);
        }
        
        
    }
}

