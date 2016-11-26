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

OBJC_EXPORT Class objc_getClass(const char *name) OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0);

@implementation ColoredVKMainController

static void *const kcvkMenuSwitch = (void*)&kcvkMenuSwitch;

+ (void) setupUISearchBar:(UISearchBar*)searchBar
{
    dispatch_async(dispatch_get_main_queue(), ^{
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

- (MenuCell *)cvkCell
{
    if (!_cvkCell) {
        MenuCell *cell = [[objc_getClass("MenuCell") alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cvkCell"];
        cell.backgroundColor = kMenuCellBackgroundColor;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.textLabel.text = @"ColoredVK";
        cell.textLabel.textColor = kMenuCellTextColor;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0];
        cell.imageView.image = [UIImage imageNamed:@"VKMenuIcon" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil];
        
        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = kMenuCellSelectedColor;
        cell.selectedBackgroundView = backgroundView;
        
        UISwitch *switchView = [UISwitch new];
        switchView.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width/1.2 - switchView.frame.size.width, (cell.contentView.frame.size.height - switchView.frame.size.height)/2, 0, 0);
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
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.prefs.changed"), NULL, NULL, YES);
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.black.theme"), NULL, NULL, YES);
    });
}

- (void)reloadSwitch
{
    ((UISwitch *)objc_getAssociatedObject(self, kcvkMenuSwitch)).on = enabled;
}


+ (UIVisualEffectView *) blurForView:(UIView *)view withTag:(int)tag
{
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    blurEffectView.frame = view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurEffectView.tag = tag;
    
    return blurEffectView;
}

+ (void)downloadImageWithSource:(NSString *)source identificator:(NSString *)identificator completionBlock:( void(^)(BOOL success, NSString *message) )block
{
    AFImageRequestOperation *imageOperation = [NSClassFromString(@"AFImageRequestOperation") 
                                               imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:source]]
                                               imageProcessingBlock:^UIImage *(UIImage *image) { return image; }
                                               cacheName:nil
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   NSString *cvkFolderPath = CVK_FOLDER_PATH;
                                                   if (![[NSFileManager defaultManager] fileExistsAtPath:cvkFolderPath]) [[NSFileManager defaultManager] createDirectoryAtPath:cvkFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
                                                   NSString *imagePath = [cvkFolderPath stringByAppendingString:[NSString stringWithFormat:@"/%@.png", identificator]];
                                                   NSString *prevImagePath = [cvkFolderPath stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", identificator]];
                                                   
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
                                                   
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk.image.update" object:nil userInfo:@{@"identifier" : identificator}];
                                                   
                                                   if ([identificator isEqualToString:@"menuBackgroundImage"]) {
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
    if (tableView.backgroundView == nil)
        tableView.backgroundView = [[ColoredVKBackgroundImageView alloc] imageLayerWithFrame:tableView.frame withImageName:name blackout:blackout flip:flip parallaxEffect:parallaxEffect];
}
@end
