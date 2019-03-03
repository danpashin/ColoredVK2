//
//  TweakFunctions.h
//  ColoredVK2
//
//  Created by Даниил on 31.03.18.
//

@class VKSearchBar;
@class VKMBrowserController, VKMTableController, DialogsSearchResultsController;

extern void setupBlur(UIView *bar, UIColor *color, UIBlurEffectStyle style);
extern void removeBlur(UIView *bar, void(^completion)(void));
extern void setToolBar(UIToolbar *toolbar);

extern void setupTabbar(void);
extern void resetTabBar(void);
extern void setupHeaderFooterView(UITableViewHeaderFooterView *view, UITableView *tableView);

extern void performInitialCellSetup(UITableViewCell *cell);
extern void setupAudioPlayer(UIView *hostView, UIColor *color);
extern void actionChangeCornerRadius(UIWindow *window);

extern void resetUISearchBar(UISearchBar *searchBar);
extern void setupUISearchBar(UISearchBar *searchBar);
extern void resetNavigationBar(UINavigationBar *navBar);

extern void uncaughtExceptionHandler(NSException *exception);


#pragma GCC diagnostic push 
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
extern void setupSearchController(UISearchDisplayController *controller, BOOL reset);
extern void setupCellForSearchController(UITableViewCell *cell, UISearchDisplayController *searchController);
#pragma GCC diagnostic pop
extern void hideFastButtonForController(VKMBrowserController *browserController);

extern void setupExtraSettingsController(VKMTableController *controller);
extern void setupExtraSettingsCell(UITableViewCell *cell);

extern void setupNewSearchBar(VKSearchBar *searchBar, UIColor *tintColor, UIColor *blurTone, UIBlurEffectStyle blurStyle);
extern void resetNewSearchBar(VKSearchBar *searchBar);

extern UIVisualEffectView *blurForView(UIView *view, NSInteger tag);

extern void setupNewDialogsSearchController(DialogsSearchResultsController *controller);
extern void updateControllerBlurInfo(UIViewController *controller);


extern void updateNavBarColor(void);
extern void setupNewAppMenuCell(UITableViewCell *cell);

extern void setupQuickMenuController(void);
extern UIStatusBarStyle statusBarStyleForController(id self, UIStatusBarStyle defaultStyle);

extern UIColor *cvk_UINavigationBar_setBarTintColor(UINavigationBar *self, SEL _cmd, UIColor *barTintColor);
extern UIColor *cvk_UINavigationBar_setTintColor(UINavigationBar *self, SEL _cmd, UIColor *tintColor);
extern NSDictionary *cvk_UINavigationBar_setTitleTextAttributes(UINavigationBar *self, SEL _cmd, NSDictionary *attributes);
extern void cvk_UINavigationBar_setFrame(UINavigationBar *self, SEL _cmd, CGRect frame);
