//
//  ColoredVKMainController.h
//  ColoredVK
//
//  Created by Даниил on 26/11/16.
//
//

#import "VKMethods.h"

@interface ColoredVKMainController : NSObject
+ (void)setupUISearchBar:(UISearchBar*)searchBar;
+ (void)resetUISearchBar:(UISearchBar*)searchBar;
+ (UIVisualEffectView *)blurForView:(UIView *)view withTag:(int)tag;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout parallaxEffect:(BOOL)parallaxEffect;
+ (void)setImageToTableView:(UITableView *)tableView withName:(NSString *)name blackout:(CGFloat)blackout flip:(BOOL)flip parallaxEffect:(BOOL)parallaxEffect;
+ (void)downloadImageWithSource:(NSString *)source identificator:(NSString *)identificator completionBlock:( void(^)(BOOL success, NSString *message) )block;

- (void)reloadSwitch;
- (void)switchTriggered:(UISwitch*)switchView;
@property (strong, nonatomic) MenuCell *cvkCell;
@end
