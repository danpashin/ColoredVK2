//
//  VKControllers.h
//  ColoredVK2
//
//  Created by Даниил on 16.06.18.
//

//  Основные
@interface VKMController : UIViewController
@property (strong, nonatomic) NSObject *model;
@end

@interface VKMScrollViewController : VKMController
@property (strong, nonatomic) UIRefreshControl *rptr;
- (void)VKMScrollViewReloadData;
- (void)VKMScrollViewReset;
@end

@interface VKMTableController : VKMScrollViewController
@property (strong, nonatomic) UITableView *tableView;
@end

@interface VKMCollectionController : VKMScrollViewController
@end

@interface VKMLiveController : VKMTableController
@end

@interface VKMToolbarController : VKMLiveController
@property (readonly, strong, nonatomic) UISegmentedControl *segment;
@property (readonly, strong, nonatomic) UIToolbar *toolbar;
@end

#pragma GCC diagnostic push 
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
@interface VKMSearchController : UISearchDisplayController
@end
#pragma GCC diagnostic pop

@interface VKMNavigationController : UINavigationController
@end

@interface VKSelectorContainerControllerDropdown : VKMController
@property (strong, nonatomic) UIView *dimView;
@property (strong, nonatomic) UIViewController *selectorViewController; 
@property (strong, nonatomic) UIViewController *currentViewController;
@end

#pragma GCC diagnostic push 
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
@interface  VKMLiveSearchController : UISearchDisplayController
@end
#pragma GCC diagnostic pop

//  Меню
@interface MenuViewController : VKMLiveController
@property (strong, nonatomic) NSArray *menu;
@end

@interface VKMMainController : VKMLiveController
@property (strong, nonatomic) UIViewController *dialogsController;
@property (strong, nonatomic) UIViewController *newsController;
@property (strong, nonatomic) VKMController *discoverController;
@property (strong, nonatomic) UIView *tabBarShadowView;
@end

//  Аудио
@interface AudioController : UIViewController
@property (strong, nonatomic) UIButton *pp;
@property (strong, nonatomic) UILabel *song;
@property (strong, nonatomic) UILabel *actor;
@property (strong, nonatomic) UISlider *seek;
- (void)done:(id)arg;
- (void)actionNext:(id)arg1;
- (void)actionPrev:(id)arg1;
- (void)actionPlaylist:(id)arg1;
@end

@interface IOS7AudioController : AudioController
@property (strong, nonatomic) UIView *hostView;
@property (strong, nonatomic) UIImageView *cover;
@end

@interface AudioPlaylistsInlineController : VKMCollectionController
@end

@interface AudioDashboardController : VKMLiveController
@end

@interface VKAudioPlayerListTableViewController : UITableViewController
@end

@interface AudioPlaylistController : VKMLiveController
@end

@interface AudioCatalogController : VKMLiveController
@end

@interface AudioCatalogAudiosListController : VKMLiveController
@end

@interface AudioCatalogOwnersListController : VKMLiveController
@end

@interface AudioPlaylistsController : VKMLiveController
@end

@interface VKAudioPlayerViewController : VKMController
@property (strong, nonatomic) UIVisualEffectView *toolbarView;
@property (strong, nonatomic) UIVisualEffectView *backgroundView;
@property (strong, nonatomic) UIPageViewController *pageController;
@end

@interface VKAudioPlayerControlsViewController : VKMController
@property (strong, nonatomic) UIButton *next;
@property (strong, nonatomic) UIButton *prev;
@property (strong, nonatomic) UIButton *pp;
@end

@interface AudioAlbumController : VKMLiveController
@end

@interface AudioPlaylistDetailController : VKMLiveController
@end

//  Диалоги и сообщения 
@interface ChatController : VKMTableController
@property (strong, nonatomic) RootView *root;
@property (strong, nonatomic) ExtraInputPanelView *inputPanel;
@property (strong, nonatomic) UIButton *editForward;
@property (strong, nonatomic) UIButton *editDelete;
@property (strong, nonatomic) UIView *editToolbar;
@property (strong, nonatomic) VKMImageButton *headerImage;
@property (strong, nonatomic) Component5HostView *componentTitleView;
@end

@interface DialogsSearchController : VKMSearchController
@end

@interface MessageController : VKMController 
@property (strong, nonatomic) UIScrollView *scroll;
@end

@interface DialogsSearchResultsController : UIViewController
@property (strong, nonatomic) UITableView *tableView;
@end

@interface _TtC3vkm31HistoryCollectionViewController : UICollectionViewController
@end

@interface _TtC3vkm17MessageController : UIViewController
@end

@interface DLVController : UITableViewController
@end

@interface DialogsController : VKMTableController
@property (strong, nonatomic) DLVController *listController;
@end

//  Друзья
@interface ProfileFriendsController : VKMToolbarController
@end

@interface FriendsBDaysController : VKMLiveController
@end

@interface FriendsAllRequestsController : VKMToolbarController
@end

@interface LookupAddressbookTeaserViewController : VKMController
@property (strong, nonatomic) Component5HostView *componentView;
@end

@interface LookupFriendsViewController : VKMLiveController
@end

@interface LookupAddressBookFriendsViewController : LookupFriendsViewController
@property (strong, nonatomic) LookupAddressbookTeaserViewController *lookupTeaserViewController;
@end

//  Настройки
@interface BaseSettingsController : VKMTableController
@end

@interface ModernSettingsController : BaseSettingsController
@end

@interface BaseSectionedSettingsController : BaseSettingsController
@end

@interface SettingsPrivacyController : VKMLiveController
@end

@interface PaymentsBalanceController : VKMLiveController
@end

@interface SubscriptionsSettingsViewController : VKMLiveController
@end

@interface ModernPushSettingsController : VKMTableController
@end

@interface VKP2PViewController : VKMLiveController
@end

@interface LicensesViewController : VKMController
@end

//  Новости
@interface FeedController : VKMLiveController
@end

@interface NewsFeedController : FeedController
@end

@interface MainNewsFeedController : NewsFeedController
@end

@interface NewsSelectorController : VKSelectorContainerControllerDropdown
@end

@interface PostEditController : UIViewController
@property (strong, nonatomic) MOTextView *textView;
@end

//  Истории
@interface MasksController : UICollectionViewController
@end

@interface StoryEditorSendViewController : UIViewController
@property (strong, nonatomic) UIButton *sendButton;
@end

@interface StoryRepliesController : VKMController
@property (strong, nonatomic) UIView *containerView;
@end

@interface StoryRepliesTipController : UIViewController
@property (strong, nonatomic) UIView *container;
@end

@interface SketchViewController : UIViewController
@property (strong, nonatomic) UIView *drawView;
@end

//  Группы и комментарии
@interface GroupsController : VKMToolbarController
@end

@interface CommentSourcePickerController : UIViewController
@property (strong, nonatomic) UIView *containerView;
@end

@interface DetailController : VKMLiveController
@property (strong, nonatomic) ExtraInputPanelView *inputPanel;
@end

//  Профиль
@interface UserWallController : UIViewController
@property (strong, nonatomic) ProfileModel *profile;
@end

@interface ProfileBannedController : VKMLiveController
@end

@interface ProfileInfoEditController : VKMTableController
@end

@interface VKP2PSendViewController : VKMScrollViewController
@property (strong, nonatomic) UIImageView *bubble;
@property (strong, nonatomic) UIButton *sendButton;
@end

//  Остальное
@interface PhotoBrowserController : VKMController
@property (strong, nonatomic) UIScrollView *paging;
- (__kindof VKPhoto *)photoForPage:(NSUInteger)page;
@end

@interface VKMBrowserController : VKMController
@property (strong, nonatomic) UILabel *headerTitle;
@property (strong, nonatomic) VKMBrowserTarget *target;
@property (strong, nonatomic) UIButton *safariButton;
@property (strong, nonatomic) UIScrollView *webScrollView;
@property (strong, nonatomic) UIWebView *webView;
@end

@interface VideoAlbumController : VKMLiveController
@property (strong, nonatomic) UIToolbar *toolbar;
@end

@interface DiscoverFeedController : VKMScrollViewController
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIView *topGradientBackgroundView;
@end

@interface OptionSelectionController : UITableViewController
@end
@interface VKRegionSelectionViewController : VKMLiveController
@end

@interface VKPhotoPicker : UINavigationController
@property (strong, nonatomic) VKPPToolbar *pickerToolbar;
@end

@interface GiftsCatalogController : VKMLiveController
@end

@interface StoreController : VKMLiveController
@property (strong, nonatomic) UIToolbar *toolbar;
@end

@interface LandingPageController : UIViewController
@end

@interface BKPasscodeViewController : UIViewController
@end

@interface ArticlePageController : VKMController
@property (strong, nonatomic) ArticleWebViewManager *webViewManager;
- (void)updateAppearance;
@end

@interface GiftSendController : VKMLiveController
@property (strong, nonatomic) UIView *sendFooterView;
@end

@interface SketchController : UIViewController
@property (strong, nonatomic) SketchView *sketchView;
@end

@interface VKDatePickerController : UIViewController
@end
