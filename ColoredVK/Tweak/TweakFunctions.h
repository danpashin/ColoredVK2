//
//  TweakFunctions.h
//  ColoredVK2
//
//  Created by Даниил on 31.03.18.
//

@class VKSearchBar;
@class VKMBrowserController, VKMTableController, DialogsSearchResultsController;

void setupBlur(UIView *bar, UIColor *color, UIBlurEffectStyle style);
void removeBlur(UIView *bar, void(^completion)(void));
void setToolBar(UIToolbar *toolbar);

void setupTabbar(void);
void resetTabBar(void);
void setupHeaderFooterView(UITableViewHeaderFooterView *view, UITableView *tableView);

void performInitialCellSetup(UITableViewCell *cell);
void setupAudioPlayer(UIView *hostView, UIColor *color);
void actionChangeCornerRadius(UIWindow *window);

void resetUISearchBar(UISearchBar *searchBar);
void setupUISearchBar(UISearchBar *searchBar);
void resetNavigationBar(UINavigationBar *navBar);

void uncaughtExceptionHandler(NSException *exception);


#pragma GCC diagnostic push 
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
void setupSearchController(UISearchDisplayController *controller, BOOL reset);
void setupCellForSearchController(UITableViewCell *cell, UISearchDisplayController *searchController);
#pragma GCC diagnostic pop
void hideFastButtonForController(VKMBrowserController *browserController);

void setupExtraSettingsController(VKMTableController *controller);
void setupExtraSettingsCell(UITableViewCell *cell);

void setupNewSearchBar(VKSearchBar *searchBar, UIColor *tintColor, UIColor *blurTone, UIBlurEffectStyle blurStyle);
void resetNewSearchBar(VKSearchBar *searchBar);

UIVisualEffectView *blurForView(UIView *view, NSInteger tag);

void setupNewDialogsSearchController(DialogsSearchResultsController *controller);
void updateControllerBlurInfo(UIViewController *controller);


void updateNavBarColor(void);
void setupNewAppMenuCell(UITableViewCell *cell);
