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

#import "ColoredVKPrefs.h"
#import "ColoredVKPrefsController.h"
#import "ColoredVKJailCheck.h"
#import "PrefixHeader.h"
#import "UIAlertView+Blocks.h"
#import "UIBarButtonItem+BlocksKit.h"
#import "VKMethods.h"
#import "UIImage+ResizeMagick.h"
#import "ColoredVKInstaller.h"



#define CLASS_NAME(obj) @(class_getName([obj class]))

#define kMenuCellBackgroundColor [UIColor colorWithRed:56.0/255.0f green:69.0/255.0f blue:84.0/255.0f alpha:1]
#define kMenuCellSelectedColor [UIColor colorWithRed:47.0/255.0f green:58.0/255.0f blue:71.0/255.0f alpha:1]
#define kMenuCellSeparatorColor [UIColor colorWithRed:72.0/255.0f green:86.0/255.0f blue:97.0/255.0f alpha:1]
#define kMenuCellTextColor [UIColor colorWithRed:233.0/255.0f green:234.0/255.0f blue:235.0/255.0f alpha:1]

#define kNewsTableViewBackgroundColor [UIColor colorWithRed:237.0/255.0f green:238.0/255.0f blue:240.0/255.0f alpha:1]
#define kNewsTableViewSeparatorColor [UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1]

#define textBackgroundColor [[UIColor redColor] colorWithAlphaComponent:0.3]


NSTimeInterval const daysCheckingInterval = 3.0;


typedef NS_ENUM(NSInteger, CVKCellSelectionStyle) {
    CVKCellSelectionStyleNone = 0,
    CVKCellSelectionStyleTransparent,
    CVKCellSelectionStyleBlurred
};

typedef NS_ENUM(NSInteger, CVKKeyboardStyle) {
    CVKKeyboardStyleWhite = 0,
    CVKKeyboardStyleBlack
};


BOOL tweakEnabled = YES;

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
BOOL hideSeparators;
BOOL enabledMessagesImage;
CGFloat menuImageBlackout;
CGFloat chatImageBlackout;

BOOL enabledBlackTheme;
BOOL blackThemeWasEnabled;

BOOL shouldCheckUpdates;

BOOL changeSBColors;
BOOL useMessagesBlur;
BOOL hideMenuSearch;
BOOL changeSwitchColor;

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
UIColor *switchesTintColor;
UIColor *switchesOnTintColor;

UIButton *postCreationButton;

CVKCellSelectionStyle menuSelectionStyle;
CVKKeyboardStyle keyboardStyle;

VKHUD *hud;

NSString *imageSource;



@interface ColoredVKMainController : NSObject

+ (void)setupMenuBar:(UITableView*)tableView;
+ (void)resetMenuTableView:(UITableView*)tableView;

+ (void)setupUISearchBar:(UISearchBar*)searchBar;
+ (void)resetUISearchBar:(UISearchBar*)searchBar;

+ (UIVisualEffectView *) blurForView:(UIView *)view withTag:(int)tag;

+ (MenuCell*) createCustomCell;

- (void)resetValue;

@end


#pragma mark Static methods

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
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
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
                                                           NSString *key = [ColoredVKJailCheck isInjected]?@"ipaURL":@"cydiaURL";
                                                           NSURL *url = [NSURL URLWithString:responseDict[key]];
                                                           if ([[UIApplication sharedApplication] canOpenURL:url]) [[UIApplication sharedApplication] openURL:url];
                                                        
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
    
    if (prefs && tweakEnabled) {
        enabled = [prefs[@"enabled"] boolValue];
        enabledBarColor = [prefs[@"enabledBarColor"] boolValue];
        showBar = [prefs[@"showBar"] boolValue];
        enabledToolBarColor = [prefs[@"enabledToolBarColor"] boolValue];
        enabledBarImage = [prefs[@"enabledBarImage"] boolValue];
        enabledMenuImage = [prefs[@"enabledMenuImage"] boolValue];
        enabledMessagesImage = [prefs[@"enabledMessagesImage"] boolValue];
        hideSeparators = [prefs[@"hideSeparators"] boolValue];
        enabledBlackTheme = [prefs[@"enabledBlackTheme"] boolValue];
        shouldCheckUpdates = prefs[@"checkUpdates"]?[prefs[@"checkUpdates"] boolValue]:YES;
        changeSBColors = [prefs[@"changeSBColors"] boolValue];
        useMessagesBlur = [prefs[@"useMessagesBlur"] boolValue];
        hideMenuSearch = [prefs[@"hideMenuSearch"] boolValue];
        changeSwitchColor = [prefs[@"changeSwitchColor"] boolValue];
        
        menuImageBlackout = [prefs[@"menuImageBlackout"] floatValue];
        chatImageBlackout = [prefs[@"chatImageBlackout"] floatValue];
        
        menuSelectionStyle = prefs[@"menuSelectionStyle"]?[prefs[@"menuSelectionStyle"] integerValue]:CVKCellSelectionStyleTransparent;
        keyboardStyle = prefs[@"keyboardStyle"]?[prefs[@"keyboardStyle"] intValue]:CVKKeyboardStyleBlack;
        
        separatorColor = prefs[@"MenuSeparatorColor"]?[UIColor colorFromString:prefs[@"MenuSeparatorColor"]]:[UIColor defaultColorForIdentifier:@"MenuSeparatorColor"];
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
                [theStatusBar performSelector:@selector(setForegroundColor:) withObject:[UIColor lightGrayColor] ];
                [theStatusBar performSelector:@selector(setBackgroundColor:) withObject:[UIColor darkBlackColor] ];
                
                blackThemeWasEnabled = YES;  
            } else {
                [theStatusBar performSelector:@selector(setForegroundColor:) withObject:nil];
                [theStatusBar performSelector:@selector(setBackgroundColor:) withObject:nil];
            }
        }
            
        if (blackThemeWasEnabled) {
            ColoredVKMainController *controller = [ColoredVKMainController new];
            [controller performSelector:@selector(resetValue) withObject:nil afterDelay:120.0];
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


static void setBlur(id bar, BOOL set)
{
    if (set) {
        if ([bar isKindOfClass:[UINavigationBar class]]) {
            UINavigationBar *navbar = bar;
            if ([navbar.subviews containsObject:[navbar viewWithTag:403]]) [[navbar viewWithTag:403] removeFromSuperview];
            navbar.barTintColor = [UIColor clearColor];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            blurEffectView.frame = CGRectMake(0, -20, navbar.frame.size.width, navbar.frame.size.height + 20);
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            blurEffectView.tag = 10;
            blurEffectView.layer.backgroundColor =  [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
            blurEffectView.userInteractionEnabled = NO;
            if (![navbar.subviews containsObject:[navbar viewWithTag:10]]) {                        
                [navbar addSubview:blurEffectView];
                [navbar sendSubviewToBack:blurEffectView];
                [navbar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
            }
        } 
        else if  ([bar isKindOfClass:[UIToolbar class]]) {
            UIToolbar *toolBar = bar;
            
            toolBar.barTintColor = [UIColor clearColor];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            blurEffectView.frame = CGRectMake(0, 0, toolBar.frame.size.width, toolBar.frame.size.height);
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            blurEffectView.tag = 10;
            blurEffectView.userInteractionEnabled = NO;
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
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightBlackColor]] forState:UIControlStateNormal];
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightBlackColor]] forState:UIControlStateHighlighted];
        
        for (CALayer *layer in postCreationButton.layer.sublayers) {
            if (layer.backgroundColor != nil) layer.backgroundColor = [UIColor darkBlackColor].CGColor;
        }
        
        for (UIView *view in postCreationButton.subviews) {
            if ([@"UIView" isEqualToString:CLASS_NAME(view)]) view.backgroundColor = [UIColor darkBlackColor];
        }
    } else {
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
        
        for (CALayer *layer in postCreationButton.layer.sublayers) {
            if (layer.backgroundColor == [UIColor darkBlackColor].CGColor) layer.backgroundColor = kNewsTableViewSeparatorColor.CGColor;
        }
        
        for (UIView *view in postCreationButton.subviews) {
            if ([@"UIView" isEqualToString:CLASS_NAME(view)]) view.backgroundColor = kNewsTableViewSeparatorColor;
        }
    }
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
    UIView *barBackground = searchBar.subviews[0].subviews[0];
    if (menuSelectionStyle == CVKCellSelectionStyleBlurred) {
        searchBar.backgroundColor = [UIColor clearColor];
        if (![barBackground.subviews containsObject: [barBackground viewWithTag:102] ]) [barBackground addSubview:[self blurForView:barBackground withTag:102]];
    } else if (menuSelectionStyle == CVKCellSelectionStyleTransparent) {
        if ([barBackground.subviews containsObject: [barBackground viewWithTag:102]]) [[barBackground viewWithTag:102] removeFromSuperview];
        searchBar.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    } else searchBar.backgroundColor = [UIColor clearColor];
    
    UIView *subviews = searchBar.subviews.lastObject;
    UITextField *barTextField = subviews.subviews[1];
    if ([barTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        barTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:barTextField.placeholder  
                                                                             attributes: @{ NSForegroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.5] }];
    }
    
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
    cell.tag = 450;
    cell.backgroundColor = kMenuCellBackgroundColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = @"ColoredVK";
    cell.textLabel.textColor = kMenuCellTextColor;
    cell.textLabel.font = [UIFont systemFontOfSize:17.0];    
    cell.imageView.image = [UIImage imageWithContentsOfFile:[cvkBunlde pathForResource:@"icon" ofType:@"png"]];
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = kMenuCellSelectedColor;
    cell.selectedBackgroundView = backgroundView;    
    
    UISwitch *switchView = [UISwitch new];
    switchView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/1.2 - switchView.frame.size.width, (cell.contentView.frame.size.height - switchView.frame.size.height)/2, 0, 0);
    switchView.tag = 404;
    switchView.on = enabled;
    switchView.onTintColor = [UIColor defaultColorForIdentifier:@"switchesOnTintColor"];
    [switchView addTarget:self action:@selector(switchTriggered:) forControlEvents:UIControlEventValueChanged];
    [cell addSubview:switchView];
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.select = (id)^(id arg1, id arg2, id arg3, id arg4) {
        ColoredVKPrefsController *cvkPrefs = [ColoredVKPrefsController new];
        id mainContext = [[objc_getClass("VKMNavContext") applicationNavRoot] rootNavContext];
        [mainContext reset:cvkPrefs];

        return nil; 
    };
    
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

- (void)resetValue {
    blackThemeWasEnabled = NO; 
}

+ (void)downloadImageWithSource:(NSString *)url andID:(NSString *)imageID
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:[NSOperationQueue mainQueue] 
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (!connectionError) {
                                       if (![[NSFileManager defaultManager] fileExistsAtPath:cvkFolder]) [[NSFileManager defaultManager] createDirectoryAtPath:cvkFolder withIntermediateDirectories:NO attributes:nil error:nil];
                                       NSString *imagePath = [cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@.png", imageID]];
                                       NSString *prevImagePath = [cvkFolder stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", imageID]];
                                       
                                       UIImage *image = [[UIImage imageWithData:data] resizedImageByMagick: [NSString stringWithFormat:@"%fx%f#", [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height]];
                                       
                                       BOOL success = [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:YES];
                                       if (success) {
                                           UIGraphicsBeginImageContext(CGSizeMake(40, 40));
                                           UIImage *preview = image;
                                           [preview drawInRect:CGRectMake(0, 0, 40, 40)];
                                           preview = UIGraphicsGetImageFromCurrentImageContext();
                                           [UIImagePNGRepresentation(preview) writeToFile:prevImagePath atomically:YES];
                                           UIGraphicsEndImageContext();
                                       }
                                       
                                       [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk.image.update" object:nil userInfo:@{@"identifier" : imageID}];
                                       
                                       if ([imageID isEqualToString:@"menuBackgroundImage"]) {
                                           CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
                                       }
                                       
                                       if ([imageID isEqualToString:@"messagesBackgroundImage"]) {
                                           CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.messages"), NULL, NULL, YES);
                                       }
                                       if (success) {
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                           [hud hideWithResult:YES message:NSLocalizedStringFromTableInBundle(@"IMAGE_SAVED_SUCCESSFULLY", nil, cvkBunlde, nil)];
                                           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                               [hud hide:YES];
                                           });
                                               });
                                       }
                                       
                                   } else {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                       [hud hideWithResult:NO message:connectionError.localizedDescription];
                                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                           [hud hide:YES];
                                       });
                                           });
                                   }
                               }];
        });
}
@end





#pragma mark - GLOBAL METHODS

#pragma mark AppDelegate
CHDeclareClass(AppDelegate);
CHOptimizedMethod(2, self, BOOL, AppDelegate, application, UIApplication*, application, didFinishLaunchingWithOptions, NSDictionary *, options)
{
//    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//        NSString *licencePath =  [ColoredVKJailCheck isInjected]?CVK_NON_JAIL_PREFS_PATH:CVK_JAIL_PREFS_PATH;
//        licencePath = [licencePath stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"];
//        
//        if (![[NSFileManager defaultManager] fileExistsAtPath:licencePath]) {
//            tweakEnabled = NO;
//            ColoredVKInstaller *installer = [[ColoredVKInstaller alloc] init];
//            [installer beginDownload];
//        } 
//        else {
//            NSData *decryptedData = [[NSData dataWithContentsOfFile:licencePath] AES128DecryptedDataWithKey:@"BE7555818BC236315C987C1D9B17F"];
//            NSDictionary *dict = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:decryptedData];
//            if ([dict[@"IS_PURCHASED"] boolValue] != YES) {
//               tweakEnabled = NO; 
//            }
//        }
//
//    }];
//    operation.queuePriority = NSOperationQueuePriorityHigh;
//    [operation start];
    reloadPrefs();
    
    
    CHSuper(2, AppDelegate, application, application, didFinishLaunchingWithOptions, options);
    
    if (shouldCheckUpdates) {
        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
        
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
CHOptimizedMethod(0, self, void, UINavigationBar, layoutSubviews)
{
    CHSuper(0, UINavigationBar, layoutSubviews);
    
    if (enabled) {
        if (enabledBlackTheme) {
            setBlur(self, NO);
            self.barTintColor = [UIColor darkBlackColor];
            self.tintColor = [UIColor lightGrayColor];
            self.titleTextAttributes = @{ NSForegroundColorAttributeName : [UIColor lightGrayColor] };
        }  else if (enabledBarColor || useMessagesBlur) {
            if (enabledBarColor) {
                if (enabledBarImage) self.barTintColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:[cvkFolder stringByAppendingString:@"/barImage.png"]]];
                else self.barTintColor = barBackgroundColor;
                self.tintColor = barForegroundColor;
                self.titleTextAttributes = @{ NSForegroundColorAttributeName : barForegroundColor };
            }
            NSArray *controllersToAddBlur = @[NSLocalizedStringFromTableInBundle(@"dialogs_chat", nil, [NSBundle mainBundle], nil),
                                              NSLocalizedStringFromTableInBundle(@"dialogs_group_chat", nil, [NSBundle mainBundle], nil)];
            if ([controllersToAddBlur containsObject:self.accessibilityIdentifier]) setBlur(self, useMessagesBlur);
            else setBlur(self, NO);

        } else setBlur(self, NO);
        
    } else setBlur(self, NO);
    
}



#pragma mark UIToolbar
CHDeclareClass(UIToolbar);
CHOptimizedMethod(0, self, void, UIToolbar, layoutSubviews)
{
    CHSuper(0, UIToolbar, layoutSubviews);
    
    if (enabled) {
        if (enabledBlackTheme) {
            setBlur(self, NO);
            self.translucent = NO;
            NSArray *controllersToChange = @[@"UIView", @"RootView"];
            if ([controllersToChange containsObject:CLASS_NAME(self.superview)]) {
                self.tintColor = [UIColor lightGrayColor];
                self.barTintColor = [UIColor darkBlackColor];
            }
            for (id view in self.subviews) {
                if ([view isKindOfClass:[UITextView class]]) {
                    UITextView *textView = view;
                    textView.backgroundColor = [UIColor lightBlackColor];
                    textView.textColor = [UIColor lightGrayColor];
                }
            }
        } else if (enabledToolBarColor) {
            NSArray *controllersToChange = @[@"UIView", @"RootView"];
            if ([controllersToChange containsObject:CLASS_NAME(self.superview)]) {
                BOOL canUseTint = YES;
                for (id view in self.subviews) {
                    if ([@"InputPanelViewTextView" isEqualToString:CLASS_NAME(view)]) {
                        canUseTint = NO;
                        break;
                    }
                }
                self.barTintColor = toolBarBackgroundColor;
                if (canUseTint) self.tintColor = toolBarForegroundColor;
                
            }
        } 
    } else setBlur(self, NO);
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



#pragma mark UITableViewCell
CHDeclareClass(UITableViewCell);
CHOptimizedMethod(0, self, void, UITableViewCell, layoutSubviews)
{
    CHSuper(0, UITableViewCell, layoutSubviews);
    if (enabled && enabledBlackTheme) {
        if (self.backgroundColor != [UIColor lightBlackColor]) self.backgroundColor = [UIColor lightBlackColor];
    }
}



#pragma mark UITableViewCellSelectedBackground
CHDeclareClass(UITableViewCellSelectedBackground);
CHOptimizedMethod(1, self, void, UITableViewCellSelectedBackground, drawRect, CGRect, rect)
{
    if (enabled && enabledBlackTheme) {
        if ([self respondsToSelector:@selector(setSelectionTintColor:)]) self.selectionTintColor = [UIColor darkBlackColor];
        
    }
    CHSuper(1, UITableViewCellSelectedBackground, drawRect, rect);
}

#pragma mark UITableViewIndex
CHDeclareClass(UITableViewIndex);
CHOptimizedMethod(0, self, void, UITableViewIndex, layoutSubviews)
{
    if (enabled && enabledBlackTheme) {
        if ([self respondsToSelector:@selector(setIndexBackgroundColor:)]) {
            self.indexColor = [UIColor lightGrayColor];
            self.indexBackgroundColor = [UIColor clearColor];
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
        self.separatorColor = [UIColor darkBlackColor];
        self.backgroundColor = [UIColor darkBlackColor];
    }
}



#pragma mark PSListController
CHDeclareClass(PSListController);
CHOptimizedMethod(2, self, UITableViewCell*, PSListController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, PSListController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && enabledBlackTheme) {
        tableView.backgroundView = nil;
        tableView.backgroundColor = [UIColor darkBlackColor];
        cell.backgroundColor = [UIColor lightBlackColor];
    } else if (blackThemeWasEnabled) {
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        cell.backgroundColor = [UIColor whiteColor]; 
    }
    
    return cell;
}


#pragma mark UILabel
CHDeclareClass(UILabel);
CHOptimizedMethod(1, self, void, UILabel, drawRect, CGRect, rect)
{
    if (enabled && enabledBlackTheme) self.textColor = [UIColor lightGrayColor];
    
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
    
    if (enabled && enabledBlackTheme) cell.contentView.backgroundColor = [UIColor lightBlackColor];
    
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
                field.backgroundColor = [UIColor lightBlackColor];
                field.textColor = [UIColor lightGrayColor];
                self.backgroundImage = [UIImage imageWithColor:[UIColor darkBlackColor]];
                self.tintColor = [UIColor lightGrayColor];
                break;
            }            
        }
    } else if (blackThemeWasEnabled) {
        if ([@"IOS7TableViewWithForcedBottomSeparator" isEqualToString:CLASS_NAME(self.superview)]) {
            for (id subview in self.subviews.lastObject.subviews) {
                if ([@"UISearchBarTextField" isEqualToString:CLASS_NAME([subview class])]) {
                    UITextField *field = subview;
                    field.backgroundColor = [UIColor clearColor];
                    field.textColor = [UIColor colorWithRed:233/255.0f green:234/255.0f blue:235/255.0f alpha:1];
                    self.backgroundImage = nil;
                    break;
                }
            }
        } else {
            for (id subview in self.subviews.lastObject.subviews) {
                if ([@"UISearchBarTextField" isEqualToString:CLASS_NAME(subview)]) {
                    UITextField *field = subview;
                    field.backgroundColor = [UIColor whiteColor];
                    field.textColor = [UIColor blackColor];
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
                            anyView.backgroundColor = [UIColor lightBlackColor];
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
    
    if ([self isKindOfClass:objc_getClass("UISwitch")]) {
        
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
            if (self.tag == 404) {
                self.onTintColor = [UIColor colorWithRed:90/255.0f green:130.0/255.0f blue:180.0/255.0f alpha:1.0];
            } else {
                self.onTintColor = nil;
            }
        }
    }
}


#pragma mark UISegmentedControl
CHDeclareClass(UISegmentedControl);
CHOptimizedMethod(0, self, void, UISegmentedControl, layoutSubviews)
{
    CHSuper(0, UISegmentedControl, layoutSubviews);
    
    if ([self isKindOfClass:objc_getClass("UISegmentedControl")]) {
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
        cell.backgroundColor = [UIColor lightBlackColor];
        tableView.backgroundView = nil;
        tableView.backgroundColor = [UIColor darkBlackColor];
        
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
        cell.backgroundColor = [UIColor lightBlackColor];
        tableView.backgroundView = nil;
        tableView.backgroundColor = [UIColor darkBlackColor];
        
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
        cell.backgroundColor = [UIColor lightBlackColor];
        tableView.backgroundView = nil;
        tableView.backgroundColor = [UIColor darkBlackColor];
        
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
        self.textView.backgroundColor = [UIColor darkBlackColor];
        self.textView.textColor = [UIColor lightGrayColor];
        
        for (id view in self.view.subviews) {
            if ([view isKindOfClass:[UIView class]]) {
                for (UIView *subView in [view subviews]) {
                    if ([subView isKindOfClass:objc_getClass("LayoutAwareView")]) {
                        for (UIView *subSubView in subView.subviews) {
                            if ([subSubView isKindOfClass:[UIToolbar class]]) {
                                [(UIToolbar*)subSubView setBarTintColor:[UIColor lightBlackColor]];
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
    if (enabled && showBar) return NO;
    return CHSuper(0, NewsFeedController, VKMScrollViewFullscreenEnabled);
}

CHDeclareClass(PhotoFeedController);
CHOptimizedMethod(0, self, BOOL, PhotoFeedController, VKMScrollViewFullscreenEnabled)
{
    if (enabled && showBar) return NO; 
    return CHSuper(0, PhotoFeedController, VKMScrollViewFullscreenEnabled);
}

#pragma mark NewsFeedController
CHOptimizedMethod(2, self, UITableViewCell*, NewsFeedController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, NewsFeedController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    newsFeedTableView = tableView;
    return cell;
}




#pragma mark User profile
CHDeclareClass(ProfileView);
CHOptimizedMethod(0, self, void, ProfileView, layoutSubviews)
{
    CHSuper(0, ProfileView, layoutSubviews);
    if (enabled && enabledBlackTheme) {
        if ([@"VKMAccessibilityTableView" isEqualToString:CLASS_NAME(self.superview)]) {
            if (![@"UITableViewHeaderFooterView" isEqualToString:CLASS_NAME(self)]) {
                self.backgroundColor = [UIColor lightBlackColor];
            }
        }
    }
}


#pragma mark DialogsController
CHDeclareClass(DialogsController);
CHOptimizedMethod(2, self, UITableViewCell*, DialogsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, DialogsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && enabledBlackTheme) {
        cell.contentView.backgroundColor = [UIColor lightBlackColor];
        tableView.backgroundColor = [UIColor darkBlackColor];
    } 
//    else if (enabled && enabledMessagesImage) {
//        cell.contentView.backgroundColor = [UIColor clearColor];
//        cell.backgroundColor = [UIColor clearColor];
//        
//        
//        for (id view in cell.contentView.subviews) {
//            if ([view isKindOfClass:[UILabel class]]) {
//                UILabel *label = view;
//                label.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
//                    //                if (!label.hidden) { label.hidden = YES; } // у прочитанных лейблов есть свойтово hidden
//            }
//            
//            if ([view respondsToSelector:@selector(setBackgroundColor:)]) {
//                [view setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.1]];
//            }
//        }
//        cell.subviews[0].hidden = YES;
//        
//        tableView.separatorColor = [tableView.separatorColor colorWithAlphaComponent:0.2];
//        
//        if (tableView.backgroundView == nil) {
//            UIView *backView = [UIView new];
//            backView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
//            
//            UIImageView *myImageView = [UIImageView new];
//            myImageView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
//            myImageView.image = [UIImage imageWithContentsOfFile:[cvkFolder stringByAppendingString:@"/messagesBackgroundImage.png"]];
//            myImageView.contentMode = UIViewContentModeScaleAspectFill;
//            [backView addSubview:myImageView];
//            
//            UIView *frontView = [UIView new];
//            frontView.frame = CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height);
//            frontView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:chatImageBlackout];
//            [backView addSubview:frontView];
//            
//            tableView.backgroundView = backView;
//        }
//    }
    
    return cell;
}



 // группы
#pragma mark VKMLiveController
CHDeclareClass(VKMLiveController);
CHOptimizedMethod(2, self, UITableViewCell*, VKMLiveController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMLiveController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && enabledBlackTheme) {
        cell.backgroundColor = [UIColor lightBlackColor];
        tableView.separatorColor = [UIColor darkBlackColor];
        tableView.backgroundColor = [UIColor darkBlackColor];
        
        for (UIView *view in cell.contentView.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                label.backgroundColor = [UIColor clearColor];
                label.textColor = [UIColor lightGrayColor];
                
            }
        }
        
        UIView *selectedBackView = [UIView new];
        selectedBackView.backgroundColor = [UIColor darkBlackColor];
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
        tableView.separatorColor = [UIColor darkBlackColor];
        cell.contentView.backgroundColor = [UIColor lightBlackColor];
        
        for (UIView *view in cell.contentView.subviews) {
            NSString *class = CLASS_NAME(view);
            
            if ([@"UIView" isEqualToString:class]) view.backgroundColor = [UIColor blackColor];
            
            if (indexPath.row == 0) {
                if ([@"TextKitLabelInteractive" isEqualToString:class]) {
                    for (CALayer *layer in view.layer.sublayers) {
                        if ([layer isKindOfClass:objc_getClass("TextKitLayer")]) {
                            layer.backgroundColor = textBackgroundColor.CGColor;
                            break;
                        }
                    }
                }
                if ([@"UITextView" isEqualToString:class]) {
                    UITextView *textView = (UITextView*)view;
                    textView.backgroundColor = [UIColor lightBlackColor];
                    textView.textColor = [UIColor lightGrayColor];
                }
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






//CHDeclareClass(VKRenderedText);
//CHOptimizedMethod(1, self, void, VKRenderedText, drawInContext, CGContextRef, context)
//{
//    NSMutableAttributedString *attrString = [self.text mutableCopy];
//    [attrString addAttribute:@"NSForegroundColorAttributeName" value:[UIColor redColor] range:NSMakeRange(0, attrString.string.length)];
//    self.text = [attrString copy];
//    CHSuper(1, VKRenderedText, drawInContext, context);
//}

    //CHDeclareClass(UITextView);
    //CHOptimizedMethod(0, self, void, UITextView, layoutSubviews)
    //{
    //    self.textColor = [UIColor redColor];
    //    self.backgroundColor = [UIColor blackColor];
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






#pragma mark ChatController
CHDeclareClass(ChatController);
CHOptimizedMethod(1, self, void, ChatController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, ChatController, viewWillAppear, animated);
    if (useMessagesBlur) setBlur(self.inputPanel, YES);
}


CHOptimizedMethod(2, self, UITableViewCell*, ChatController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    
    UITableViewCell *cell = CHSuper(2, ChatController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (indexPath.row == 0) { chatTableView = tableView; }
    
     if (enabled && enabledBlackTheme) {
         if (![ CLASS_NAME(cell) isEqualToString:@"UITableViewCell"]) {
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
        
        
        if (![ CLASS_NAME(cell) isEqualToString:@"UITableViewCell"]) {
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
            myImageView.frame = backView.frame;
            myImageView.image = [UIImage imageWithContentsOfFile:[cvkFolder stringByAppendingString:@"/messagesBackgroundImage.png"]];
            myImageView.contentMode = UIViewContentModeScaleAspectFill;
            float degrees = 180;
            myImageView.transform = CGAffineTransformMakeRotation(degrees * M_PI/180);
            [backView addSubview:myImageView];
            
            UIView *frontView = [UIView new];
            frontView.frame = backView.frame;
            frontView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:chatImageBlackout];
            [backView addSubview:frontView];
            
            tableView.backgroundView = backView;
        }
    }
    
    return cell;
}


#pragma mark VKMMainController
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
        if (cellFound == NO) [tempArray addObject:cell];
        self.menu = [tempArray copy];
        
        return self.menu.count;
    }
    return CHSuper(2, VKMMainController, tableView, tableView, numberOfRowsInSection, section);
}

CHOptimizedMethod(2, self, UITableViewCell*, VKMMainController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, VKMMainController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    menuTableView = tableView;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (id view in cell.subviews) {
            if ([view isKindOfClass:objc_getClass("UISwitch")]) {
                dispatch_async(dispatch_get_main_queue(), ^{ 
                    UISwitch *switchView = view;
                    [switchView layoutSubviews];
                });
            }
        }
    });
    
    if (enabled && hideSeparators) tableView.separatorColor = [UIColor clearColor]; 
    else if (enabled && !hideSeparators) tableView.separatorColor = separatorColor; 
    else tableView.separatorColor = kMenuCellSeparatorColor;
    
    if (enabled && enabledBlackTheme) {
        cell.backgroundColor = [UIColor lightBlackColor];
        cell.contentView.backgroundColor = [UIColor lightBlackColor];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        if ((indexPath.section == 1) && (indexPath.row == 0)) { cell.backgroundColor = [UIColor darkBlackColor]; }
        
        UIView *selectedBackView = [UIView new];
        selectedBackView.backgroundColor = [UIColor darkBlackColor];
        cell.selectedBackgroundView = selectedBackView;
        
        if (![tableView.superview.subviews containsObject:[tableView.superview viewWithTag:23]]) {
            UIView *statusBarBack = [UIView new];
            statusBarBack.frame = CGRectMake(0, 0, tableView.frame.size.width, 20);
            statusBarBack.backgroundColor = [UIColor lightBlackColor];
            statusBarBack.tag = 23;
            [tableView.superview addSubview:statusBarBack]; 
        }
        
    } else if (enabled && enabledMenuImage) {
        
        cell.textLabel.textColor = kMenuCellTextColor;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        if ((indexPath.section == 0) && (indexPath.row == 0)) [ColoredVKMainController setupMenuBar:tableView];
        
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
        if (menuSelectionStyle == CVKCellSelectionStyleTransparent) selectedBackView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
        else if (menuSelectionStyle == CVKCellSelectionStyleBlurred) {
            selectedBackView.backgroundColor = [UIColor clearColor];
            if (![selectedBackView.subviews containsObject: [selectedBackView viewWithTag:100] ]) [selectedBackView addSubview:[ColoredVKMainController  blurForView:selectedBackView withTag:100]];
            
        } else selectedBackView.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = selectedBackView;
        
        if (VKSettingsEnabled) {
            if ([cell.textLabel.text isEqualToString:NSLocalizedStringFromTableInBundle(@"GroupsAndPeople", nil, vksBundle, nil)]) {
                if (menuSelectionStyle != CVKCellSelectionStyleNone) {
                    cell.contentView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
                }
            }
        }
        
    } else {
        cell.backgroundColor = kMenuCellBackgroundColor;
        cell.contentView.backgroundColor = kMenuCellBackgroundColor;
        if ((indexPath.section == 1) && (indexPath.row == 0)) cell.backgroundColor = kMenuCellSelectedColor;
        
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



#pragma mark VKSettings
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
CHOptimizedMethod(1, self, void, AudioController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, AudioController, viewWillAppear, animated);
    
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
                        [subView setImage:coloredImage([UIColor buttonsTintColor], [subView imageForState:UIControlStateNormal]) forState:UIControlStateNormal];
                        [subView setImage:coloredImage([UIColor lightGrayColor], [subView imageForState:UIControlStateSelected]) forState:UIControlStateSelected];
                    }
                }
                [self.pp   setImage:coloredImage([UIColor buttonsTintColor], [self.pp imageForState:UIControlStateSelected]) forState:UIControlStateSelected];
                
            }
        }
    }
}


#pragma mark PhotoBrowserController
CHDeclareClass(PhotoBrowserController);
CHOptimizedMethod(1, self, void, PhotoBrowserController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, PhotoBrowserController, viewWillAppear, animated);
    if ([self isKindOfClass:objc_getClass("PhotoBrowserController")]) {
        
        UIImage *saveImage = [UIImage imageWithContentsOfFile:[cvkBunlde pathForResource:@"download" ofType:@"png"]];
//        UIImage *saveImage = [UIImage imageNamed:@"store_download_image" inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil];
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] bk_initWithImage:saveImage 
                                                                          style:UIBarButtonItemStylePlain 
                                                                        handler:^(id  _Nonnull sender) {
                                                                            hud = [objc_getClass("VKHUD") hud];
                                                                            BlockActionController *actionController = [objc_getClass("BlockActionController") actionSheetWithTitle:nil];
                                                                            [actionController addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"USE_IN_MENU", nil, cvkBunlde, nil) 
                                                                                                           block:(id)^(id arg1) {
                                                                                                               NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                                                                                                                   [ColoredVKMainController downloadImageWithSource:imageSource andID:@"menuBackgroundImage"];
                                                                                                               }];
                                                                                                               [hud showForOperation:operation];
                                                                                                               [operation start];
                                                                                                           }];
                                                                            
                                                                            [actionController addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"USE_IN_MESSAGES", nil, cvkBunlde, nil) 
                                                                                                           block:(id)^(id arg1) {
                                                                                                               NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                                                                                                                   [ColoredVKMainController downloadImageWithSource:imageSource andID:@"messagesBackgroundImage"];
                                                                                                               }];
                                                                                                               [hud showForOperation:operation];
                                                                                                               [operation start];
                                                                                                           }];
                                                                            [actionController setCancelButtonWithTitle:UIKitLocalizedString(@"Cancel") block:nil];
                                                                            [actionController showInViewController:self];
                                                                        }];

        self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItem, saveButton];
    }
}

CHOptimizedMethod(1, self, VKPhotoSized*, PhotoBrowserController, photoForPage, unsigned long long, page)
{
    VKPhotoSized *photo = CHSuper(1, PhotoBrowserController, photoForPage, page);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (photo.variants != nil) {
            int maxVariantIndex = 0;
            for (VKImageVariant *variant in photo.variants.allValues) {
                if (variant.type > maxVariantIndex) {
                    maxVariantIndex = variant.type;
                    imageSource = variant.src;
                }
            }
        }
    });
    return photo;
}



#pragma mark VKMBrowserController
CHDeclareClass(VKMBrowserController);
CHOptimizedMethod(1, self, void, VKMBrowserController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKMBrowserController, viewWillAppear, animated);
    if ([self isKindOfClass:objc_getClass("VKMBrowserController")]) {
        NSMutableArray *mutableItems = [self.toolbar.items mutableCopy];
        UIImage *saveImage = [UIImage imageWithContentsOfFile:[cvkBunlde pathForResource:@"download" ofType:@"png"]];
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] bk_initWithImage:saveImage 
                                                                          style:UIBarButtonItemStylePlain 
                                                                        handler:^(id  _Nonnull sender) {
                                                                            hud = [objc_getClass("VKHUD") hud];
                                                                            BlockActionController *actionController = [objc_getClass("BlockActionController") actionSheetWithTitle:nil];
                                                                            [actionController addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"USE_IN_MENU", nil, cvkBunlde, nil) 
                                                                                                           block:(id)^(id arg1) {
                                                                                                               NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                                                                                                                   [ColoredVKMainController downloadImageWithSource:self.target.url.absoluteString andID:@"menuBackgroundImage"];
                                                                                                               }];
                                                                                                               [hud showForOperation:operation];
                                                                                                               [operation start];
                                                                                                           }];
                                                                            
                                                                            [actionController addButtonWithTitle:NSLocalizedStringFromTableInBundle(@"USE_IN_MESSAGES", nil, cvkBunlde, nil) 
                                                                                                           block:(id)^(id arg1) {
                                                                                                               NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                                                                                                                   [ColoredVKMainController downloadImageWithSource:self.target.url.absoluteString andID:@"messagesBackgroundImage"];
                                                                                                               }];
                                                                                                               [hud showForOperation:operation];
                                                                                                               [operation start];
                                                                                                           }];
                                                                            [actionController setCancelButtonWithTitle:UIKitLocalizedString(@"Cancel") block:nil];
                                                                            [actionController showInViewController:self];
                                                                        }];

        [mutableItems addObject:saveButton];
        [self.toolbar setItems:[mutableItems copy] animated:YES];
    }
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

static void reloadMessagesNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    chatTableView.backgroundView = nil;
    [chatTableView reloadData];
}



static void reloadTablesNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    [newsFeedTableView reloadData];
    setPostCreationButtonColor();
}

CHConstructor
{
    @autoreleasepool {
            if ([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] intValue] >= 27) {
                
                BOOL injected = [ColoredVKJailCheck isInjected];
                prefsPath = injected?CVK_NON_JAIL_PREFS_PATH:CVK_JAIL_PREFS_PATH;
                cvkBunlde = injected?[NSBundle bundleWithPath:CVK_NON_JAIL_BUNDLE_PATH]:[NSBundle bundleWithPath:CVK_JAIL_BUNDLE_PATH];
                vksBundle = injected?[NSBundle bundleWithPath:VKS_NON_JAIL_BUNDLE_PATH]:[NSBundle bundleWithPath:VKS_JAIL_BUNDLE_PATH];
                cvkFolder = injected?CVK_NON_JAIL_FOLDER_PATH:CVK_JAIL_FOLDER_PATH;                
                
                NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithContentsOfFile:prefsPath];
                if (![[NSFileManager defaultManager] fileExistsAtPath:prefsPath]) prefs = [NSMutableDictionary new];
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
                CHHook(0, UINavigationBar, layoutSubviews);
                
                
                CHLoadLateClass(UIToolbar);
                CHHook(0, UIToolbar, layoutSubviews);
                
                
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
                
                
                
                
                CHLoadLateClass(AudioController);
                CHHook(1, AudioController, viewWillAppear);
                
                
                CHLoadLateClass(DetailController);
                CHHook(2, DetailController, tableView, cellForRowAtIndexPath);
                
                
                CHLoadLateClass(DialogsController);
                CHHook(2, DialogsController, tableView, cellForRowAtIndexPath);
                
                
                CHLoadLateClass(VKMLiveController);
                CHHook(2, VKMLiveController, tableView, cellForRowAtIndexPath);
                
                
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
                CHHook(0, VKMMainController, VKMTableCreateSearchBar);
                
                
                CHLoadLateClass(ChatController);
                CHHook(2, ChatController, tableView, cellForRowAtIndexPath);
                CHHook(1, ChatController, viewWillAppear);
                
                
                CHLoadLateClass(HintsSearchDisplayController);
                CHHook(1, HintsSearchDisplayController, searchDisplayControllerWillBeginSearch);
                CHHook(1, HintsSearchDisplayController, searchDisplayControllerDidEndSearch);
                
                
//                CHLoadLateClass(VKRenderedText);
//                CHHook(1, VKRenderedText, drawInContext);
                
                CHLoadLateClass(PhotoBrowserController);
                CHHook(1, PhotoBrowserController, viewWillAppear);
                CHHook(1, PhotoBrowserController, photoForPage);
                
                
                CHLoadLateClass(VKMBrowserController);
                CHHook(1, VKMBrowserController, viewWillAppear);
                
                
                
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