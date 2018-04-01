//
//  TweakFunctions.h
//  ColoredVK2
//
//  Created by Даниил on 31.03.18.
//

@class NewDialogCell, VKSearchBar;
@class VKMBrowserController, VKMTableController;

void reloadPrefsNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
void reloadMenuNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
void updateCornerRadius(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);
void updateNightTheme(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo);

void setBlur(UIView *bar, BOOL set, UIColor *color, UIBlurEffectStyle style);
void setToolBar(UIToolbar *toolbar);
void setupTranslucence(UIView *view, UIColor *backColor, BOOL remove);

void setupTabbar(void);
void resetTabBar(void);
void setupHeaderFooterView(UITableViewHeaderFooterView *view, UITableView *tableView);
void setupNewDialogCellFromNightTheme(NewDialogCell *dialogCell);

void performInitialCellSetup(UITableViewCell *cell);
void setupAudioPlayer(UIView *hostView, UIColor *color);
void actionChangeCornerRadius(void);

void resetUISearchBar(UISearchBar *searchBar);
void setupUISearchBar(UISearchBar *searchBar);
void resetNavigationBar(UINavigationBar *navBar);

void uncaughtExceptionHandler(NSException *exception);

extern void setupSearchController(UISearchDisplayController *controller, BOOL reset);
void setupCellForSearchController(UITableViewCell *cell, UISearchDisplayController *searchController);
void hideFastButtonForController(VKMBrowserController *browserController);

void setupExtraSettingsController(VKMTableController *controller);
void setupExtraSettingsCell(UITableViewCell *cell);

void setupNightSeparatorForView(UIView *view);
void setupNightTextField(UITextField *textField);

void setupNewSearchBar(VKSearchBar *searchBar, UIColor *tintColor, UIColor *blurTone, UIBlurEffectStyle blurStyle);
void resetNewSearchBar(VKSearchBar *searchBar);

UIVisualEffectView *blurForView(UIView *view, NSInteger tag);
NSAttributedString *attributedStringForNightTheme(NSAttributedString * text);

void setupNewDialogsSearchController(DialogsSearchResultsController *controller);
void updateControllerBlurInfo(UIViewController *controller, void (^completion)(void) );