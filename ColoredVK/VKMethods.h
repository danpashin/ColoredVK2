//
//  VKMethods.h
//  ColoredVK
//
//  Created by Даниил on 22.04.16.
//  
//
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface UIView ()
@property (copy, nonatomic, readonly) NSString *recursiveDescription;
@end

@interface Model : NSObject
@end

@interface VKMController : UIViewController
@property (strong, nonatomic) Model *model;
@end

@interface VKMScrollViewController : VKMController
@property (strong, nonatomic) UIRefreshControl *rptr;
- (void)VKMScrollViewReloadData;
- (void)VKMScrollViewReset;
@end


@interface VKMSearchController : UISearchDisplayController
@end

@interface VKMTableController : VKMScrollViewController
@property (strong, nonatomic) UITableView *tableView;
@end

@interface VKMLiveController : VKMTableController
@end


@interface VKMMainController : VKMLiveController
@end

@interface VKMMainController ()
@property (strong, nonatomic) UIViewController *dialogsController;
@property (strong, nonatomic) UIViewController *newsController;
@property (strong, nonatomic) VKMController *discoverController;
@property (strong, nonatomic) UIView *tabBarShadowView;
@end



@interface MenuCell : UITableViewCell
@property (copy, nonatomic) id(^select)(id arg1, id arg2);
@end

@interface MenuViewController : VKMLiveController
@property (strong, nonatomic) NSArray *menu;
@end

@interface VKMNavContext : NSObject 
+ (id)applicationNavRoot;
- (void)reset:(UIViewController *)arg1;
- (void)push:(UIViewController *)arg1;
- (void)push:(UIViewController *)arg1 animated:(BOOL)arg2;
@property (readonly, strong) VKMNavContext *rootNavContext;
@property (strong, nonatomic) UINavigationController *navController;
@end



@interface VKAudio : NSObject
@property (strong, nonatomic) NSNumber *lyrics_id;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *performer;
@end

@interface AudioPlayer : NSObject
@property (strong, nonatomic) VKAudio *audio;
@property (assign, nonatomic) int state;
@end

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

@interface VKImageVariant : NSObject
@property (assign, nonatomic) int type;
@property (strong, nonatomic) NSString *src; 
@end

@interface VKPhoto : NSObject
@property (strong, nonatomic) NSMutableDictionary *variants;
@end
@interface VKPhotoSized : VKPhoto
@end

@interface PhotoBrowserController : UIViewController
@property (strong, nonatomic) UIScrollView *paging;
- (VKPhotoSized *)photoForPage:(NSInteger)page;
@end

@interface VKMBrowserTarget : NSObject
@property (strong, nonatomic) NSURL *url;
@end

@interface VKMBrowserController : VKMController
@property (strong, nonatomic) UILabel *headerTitle;
@property (strong, nonatomic) VKMBrowserTarget *target;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIButton *safariButton;
@property (strong, nonatomic) UIScrollView *webScrollView;
@property (strong, nonatomic) UIWebView *webView;
@end



@interface VKMessage : NSObject
@property (assign, nonatomic) BOOL read_state;
@property (assign, nonatomic) BOOL incoming;
@end

@interface MessageCell : UITableViewCell
@property (strong, nonatomic) VKMessage *message;
@end

@interface ChatCell : MessageCell
@property (strong, nonatomic) UIImageView *bg;
@end


@interface VKDialog : NSObject
@property (strong, nonatomic) VKMessage *head;
@end

@interface BackgroundView : UILabel
@property (assign, nonatomic) int cornerRadius;
@end
@interface NewDialogCell : UITableViewCell
@property (readonly, strong, nonatomic) BackgroundView *unread;
@property (readonly, strong, nonatomic) UILabel *attach;
@property (readonly, strong, nonatomic) UILabel *dialogText;
@property (readonly, strong, nonatomic) UILabel *time;
@property (readonly, strong, nonatomic) UILabel *name;
@property (strong, nonatomic) VKDialog *dialog;
@property (readonly, strong, nonatomic) UILabel *text;
@end

@interface vkmPeerListCell : UITableViewCell
@property (strong, nonatomic) UILabel *titleView;
@property (strong, nonatomic) UILabel *bodyView;
@property (strong, nonatomic) UILabel *timeView;
@end


@interface VKMImageButton : UIButton
@end

@interface Component5HostView : UIView
@end


@interface DLVController : UITableViewController
@end

@interface DialogsController : VKMTableController
@property(retain, nonatomic) DLVController *listController;
@end

@interface ExtrasInputView : UIView
@end


@interface MOTextView : UITextView
@property (strong, nonatomic) UILabel *placeholderLabel;
@property (strong, nonatomic) UIView *footerView;
@end

@interface InputPanelViewTextView : MOTextView
@property (strong, nonatomic) UILabel *placeholderLabel;
@end

@interface InputPanelView : UIToolbar
@property (strong, nonatomic) UIView *overlay;
@property (strong, nonatomic) UIToolbar *gapToolbar;
@property (strong, nonatomic) InputPanelViewTextView *textPanel;
@end
@interface ExtraInputPanelView : InputPanelView
@property (strong, nonatomic) UIView *pushToTalkCoverView;
@property (strong, nonatomic) UIButton *inputViewButton;
@end

@interface RootView : UIView
@property (strong, nonatomic) ExtraInputPanelView *inputPanelView;
@end

@interface ChatController : VKMTableController
@property (strong, nonatomic) RootView *root;
@property (strong, nonatomic) ExtraInputPanelView *inputPanel;
@property (strong, nonatomic) UIButton *editForward;
@property (strong, nonatomic) UIButton *editDelete;
@property (strong, nonatomic) UIView *editToolbar;
@property (strong, nonatomic) VKMImageButton *headerImage;
@property (strong, nonatomic) Component5HostView *componentTitleView;
@end



@interface VKMCell : UITableViewCell
@end
@interface GroupCell : VKMCell
@property (readonly, strong, nonatomic) UILabel *status;
@property (readonly, strong, nonatomic) UILabel *name;
@end


@interface VKMEditableController : VKMLiveController
@end
@interface VKMToolbarController : VKMEditableController
@property (readonly, strong, nonatomic) UISegmentedControl *segment;
@property (readonly, strong, nonatomic) UIToolbar *toolbar;
@end

@interface VKMMultiIndexController : VKMToolbarController
@end

@interface GroupsController : VKMMultiIndexController
@end


@interface DialogsSearchController : VKMSearchController
@end


@interface VKUser : NSObject
@property (strong, nonatomic) NSNumber *uid;
@end

@interface VKProfile : NSObject
@property (assign, nonatomic) BOOL verified;
@property (strong, nonatomic) VKUser *user;
@end



@interface AudioAlbumController : VKMLiveController
@end

@interface AudioPlaylistController : VKMLiveController
@end



@interface UIImageAsset ()
@property (nonatomic, copy) NSString *assetName;
@end


@interface MPVolumeSlider : UISlider
@end
@interface MPVolumeView ()
@property (nonatomic, readonly) MPVolumeSlider *volumeSlider;
@end




@interface Renderer : NSObject
@property (strong, nonatomic) NSArray *views;
@end
@interface VKMRendererCell : UITableViewCell
@property (strong, nonatomic) Renderer *renderer;
@end
@interface AudioRenderer : Renderer
@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) UIButton *playIndicator;
@property (strong, nonatomic) AudioPlayer *player;
@end



@interface FixedNavigationController : UINavigationController
@end
@interface VKMNavigationController : FixedNavigationController
@end


@interface VKMViewControllerContainer : VKMController
@property (strong, nonatomic) UIViewController *currentViewController;
@end
@interface VKSelectorContainerController : VKMViewControllerContainer
@end
@interface VKSelectorContainerControllerDropdown : VKSelectorContainerController
@property (strong, nonatomic) UIView *dimView;
@property (strong, nonatomic) UIViewController *selectorViewController; 
@end


@interface  VKMLiveSearchController : UISearchDisplayController
@end



@interface UISearchBarTextField : UITextField
@end
@interface UISearchBar ()
@property (getter=_searchBarTextField, nonatomic, readonly) UISearchBarTextField *searchBarTextField;
@property (nonatomic, readonly, strong) UIView *_scopeBarBackgroundView;
@property (nonatomic, readonly, strong) UIView *_backgroundView;
@end


@interface UINavigationBar ()
@property (nonatomic, readonly, strong) UIView *_backgroundView;
@end

@interface UIToolbar ()
@property (setter=_setBackgroundView:, nonatomic, strong) UIView *_backgroundView;
@end


@interface BaseUserCell : VKMCell
@property (readonly, strong, nonatomic) UILabel *last;
@property (readonly, strong, nonatomic) UILabel *first;
@end

@interface SourceCell : BaseUserCell
@end


@interface MessageController : VKMController 
@property (strong, nonatomic) UIScrollView *scroll;
@end


@interface UIStatusBar : UIView
@property (nonatomic, strong) UIColor *foregroundColor;
@end


@interface DetailController : VKMLiveController
@property (strong, nonatomic) ExtraInputPanelView *inputPanel;
@end



@interface ProfileFriendsController : VKMMultiIndexController
@end

@interface FriendsBDaysController : VKMLiveController
@end

@interface FriendBdayCell : VKMCell
@property (strong, nonatomic) UILabel *status;
@property (strong, nonatomic) UILabel *name;
@end

@interface FriendsAllRequestsController : VKMToolbarController
@end


@interface VideoAlbumsInfoToolbar : UIToolbar
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@end

@interface VideoAlbumController : VKMLiveController
@property (strong, nonatomic) VideoAlbumsInfoToolbar *toolbar;
@end

@interface VideoCell : VKMCell
@property (readonly, strong, nonatomic) UILabel *viewCountLabel;
@property (readonly, strong, nonatomic) UILabel *authorLabel;
@property (readonly, strong, nonatomic) UILabel *videoTitleLabel;
@end




@interface VKMCollectionController : VKMScrollViewController
@end

@interface AudioPlaylistsInlineController : VKMCollectionController
@end


@interface AudioDashboardController : VKMLiveController
@end

@interface AudioPlaylistsCell : VKMCell
@property (readonly, strong, nonatomic) UIButton *showAllButton;
@property (readonly, strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *hostedView;
@end

@interface VKMCollectionCell : UICollectionViewCell
@end

@interface AudioPlaylistInlineCell : VKMCollectionCell

@property (readonly, strong, nonatomic) UILabel *subtitleLabel;
@property (readonly, strong, nonatomic) UILabel *titleLabel;

@end

@interface AudioCatalogController : VKMLiveController
@end

@interface AudioCatalogAudiosListController : VKMLiveController
@end

@interface AudioCatalogOwnersListController : VKMLiveController
@end

@interface AudioPlaylistsController : VKMLiveController
@end


@interface AudioImageAndTitleItemCollectionCell : VKMCollectionCell
@property (strong, nonatomic) UILabel *titleLabel;
@end

@interface AudioOwnersBlockItemCollectionCell : AudioImageAndTitleItemCollectionCell
@end


@interface AudioBlockCellHeaderView : UIView
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *showAllButton;
@end

@interface BlockCellHeaderView : UIView
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *actionButton;
@end

@interface AudioAudiosSpecialBlockView : UIView
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UILabel *titleLabel;
@end


@interface AudioAudiosBlockTableCell : VKMCell
@end


@interface AudioPlaylistCell : VKMCell
@property (readonly, strong, nonatomic) UILabel *subtitleLabel;
@property (readonly, strong, nonatomic) UILabel *artistLabel;
@property (readonly, strong, nonatomic) UILabel *titleLabel;
@end


@interface AudioPlaylistView : UIView
@end



@interface AudioPlaylistDetailController : VKMLiveController
@end

@interface TeaserView : UIView
@property (strong, nonatomic) UILabel *labelText;
@property (strong, nonatomic) UILabel *labelTitle;
@end


@interface VKAudioQueuePlayer : NSObject
@property (assign, nonatomic) int state;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *performer;
@end

@interface LoadingFooterView : UIView
@property (readonly, strong, nonatomic) UILabel *label;
@property (readonly, strong, nonatomic) UIActivityIndicatorView *anim;
@end

@interface VKAudioPlayerListTableViewController : UITableViewController
@end



@interface BaseSettingsController : VKMTableController
@end

@interface ModernSettingsController : BaseSettingsController
@end

@interface BaseSectionedSettingsController : BaseSettingsController
@end



@interface ProfileModel : NSObject
@property (readonly, strong, nonatomic) VKProfile *item;
@end

@interface UserWallController : UIViewController
@property (strong, nonatomic) ProfileModel *profile;
@end

@interface VKGroup : NSObject
@property (strong, nonatomic) NSNumber *gid;
@end

@interface VKGroupProfile : NSObject
@property (strong, nonatomic) VKGroup *group;
@end


@interface ProfileBannedController : VKMLiveController
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


@interface PostEditController : UIViewController
@property (strong, nonatomic) MOTextView *textView;
@end
@interface ProfileInfoEditController : VKMTableController
@end
@interface OptionSelectionController : UITableViewController
@end
@interface VKRegionSelectionViewController : VKMLiveController
@end



@interface CommunityCommentsCell : VKMCell
@property (readonly, nonatomic) UILabel *subtitleLabel;
@property (readonly, nonatomic) UILabel *titleLabel;
@end

@interface VKSearchBarNoCancel : UISearchBar
@end



@interface MenuSubtitleCell : VKMCell
@property (strong, nonatomic) UIView *separator;
@property (strong, nonatomic) UIImageView *verified;
@property (readonly, nonatomic) UIButton *online;
@property (readonly, strong, nonatomic) UILabel *status;
@property (readonly, strong, nonatomic) UILabel *name;
@end
@interface HintsCell : MenuSubtitleCell
@end
@interface MenuBirthdayCell : HintsCell
@property (strong, nonatomic) UIButton *giftButton;
@end

@interface TablePrimaryHeaderView : UITableViewHeaderFooterView
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UIView *separator;
@end


@interface DiscoverFeedController : VKMScrollViewController
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIView *topGradientBackgroundView;
@end



@interface Node5TableViewCell : UITableViewCell
@end

@interface ProfileView : UIView
@property (strong, nonatomic) UIButton *buttonStatus;
@property (strong, nonatomic) UIButton *buttonMessage;
@property (strong, nonatomic) UIScrollView *blocksScroll;
@end


@interface NewsFeedPostAndStoryCreationButtonBar : UIView
@property (strong, nonatomic) NSArray *separatorLines;
@end

@interface Node5CollectionViewCell : UICollectionViewCell
@end

@interface AdminInputPanelView : ExtraInputPanelView
@end

@interface PollAnswerButton : UIView
@property (strong, nonatomic) UIView *progressView;
@end


@interface VKAPBottomToolbar : UIView
@property (readonly, nonatomic) UIToolbar *bg;
@end

@interface WallModeRenderer : Renderer
@end



@interface AudioAudiosPagingView : UIView
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@interface AudioAudiosBlockCell : VKMCell
@property (strong, nonatomic) AudioAudiosPagingView *audiosPagingView;
@end

@interface MOCTRender : NSObject
@property (strong, nonatomic) NSAttributedString *text;
@end

@interface SeparatorWithBorders : UIView
@property (strong, nonatomic) UIColor *borderColor;
@end


@interface LookupAddressbookTeaserViewController : VKMController
@property (strong, nonatomic) Component5HostView *componentView;
@end

@interface LookupFriendsViewController : VKMLiveController
@end
@interface LookupAddressBookFriendsViewController : LookupFriendsViewController
@property (strong, nonatomic) LookupAddressbookTeaserViewController *lookupTeaserViewController;
@end


@interface BaseMarketGalleryCell : VKMCollectionCell
@end
@interface ProductMarketCell : BaseMarketGalleryCell
@end
@interface ProductMarketCellForProfileGallery : ProductMarketCell
@end

@interface MarketGalleryDecoration : UICollectionReusableView
@end

@interface StoreStockItemView : UIScrollView
@end

@interface VKPPToolbar : UIView
@property (readonly, strong, nonatomic) UIToolbar *bg;
@end

@interface VKPhotoPicker : UINavigationController
@property (strong, nonatomic) VKPPToolbar *pickerToolbar;
@end


@interface TouchHighlightControl : UIControl
@end

@interface MainMenuPlayer : UIView
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *playerTitle;
@end

@interface VKMTableViewSearchHeaderView : UIToolbar
@end

@interface VKMAccessibilityTableView : UITableView
@end

@interface PersistentBackgroundColorView : UIView
@property (strong, nonatomic) UIColor *persistentBackgroundColor;
@end

@interface GiftsCatalogSectionCell : VKMCell
@end

@interface GiftSendController : VKMLiveController
@end

@interface DefaultHighlightButton : UIButton
@end

@interface HighlightableButton : UIButton
@end

@interface _UITableViewHeaderFooterContentView : UIView
@end



@interface GiftsCatalogController : VKMLiveController
@end

@interface StoreController : VKMLiveController
@property (strong, nonatomic) UIToolbar *toolbar;
@end

@interface DiscoverLayoutMask : UICollectionReusableView
@end

@interface DiscoverLayoutShadow : UICollectionReusableView
@end

@interface FeedController : VKMLiveController
@end

@interface NewsFeedController : FeedController
@end

@interface MainNewsFeedController : NewsFeedController
@end


@interface NewsSelectorController : VKSelectorContainerControllerDropdown
@end

@interface _UIAlertControlleriOSActionSheetCancelBackgroundView : UIView
@end

@interface _UIAlertControllerActionView : UIView
@end

@interface VKP2PDetailedView : UIView
@end

@interface DialogSingleCell : NewDialogCell
@end

@interface FreshNewsButton : UIView
@property (strong, nonatomic) UIButton *button;
@end

@interface VKLivePromoView : UIView
@end

@interface CommentSourcePickerController : UIViewController
@property (strong, nonatomic) UIView *containerView;
@end


@interface HighlightableBackgroundButton : UIButton
@end
@interface NewsFeedPostCreationButton : HighlightableBackgroundButton
@end

@interface LandingPageController : UIViewController
@end

@interface UITableViewIndex : UIControl
@property (strong, nonatomic) UIColor *indexBackgroundColor;
@end

@interface SketchDrawView : UIView
@end

@interface SketchViewController : UIViewController

@property (strong, nonatomic) UIButton *eraserButton;
@property (strong, nonatomic) UIButton *undoButton;
@property (strong, nonatomic) UIButton *sendButton;

@property (strong, nonatomic) NSArray *paletteButtons;
@property (strong, nonatomic) SketchDrawView *drawView;

@end



@interface DrawView : UIView
@end

@interface ColorPaletteView : UIView
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@interface SketchView : UIView
@property (strong, nonatomic) ColorPaletteView *colorPaletteView;
@property (strong, nonatomic) DrawView *drawView;
@end

@interface SketchController : UIViewController
@property (strong, nonatomic) SketchView *sketchView;
@end



@interface EmojiSelectionView : UIView 
@property (strong, nonatomic) UIScrollView *scrollView;
@end

@interface LicensesViewController : VKMController
@end

@interface VKAudioPlayerViewController : VKMController
@property (strong, nonatomic) UIVisualEffectView *toolbarView;
@property (strong, nonatomic) UIVisualEffectView *backgroundView;
@property (strong, nonatomic) UIPageViewController *pageController;
@end

@interface PopupWindowView : UIView
@property (readonly, nonatomic) UIView *contentView;
@end


@interface VKAudioPlayerControlsViewController : VKMController
@property (strong, nonatomic) UIButton *next;
@property (strong, nonatomic) UIButton *prev;
@property (strong, nonatomic) UIButton *pp;
@end

@interface _UIAlertControllerTextFieldViewController : UICollectionViewController
@end

@interface MasksController : UICollectionViewController
@end

@interface VKPPNoAccessView : UIView
@end


@interface VKSearchBarConfig : NSObject
@property (strong, nonatomic) UIColor *segmentBorderColor;
@property (strong, nonatomic) UIColor *segmentTintColor;
@property (strong, nonatomic) UIColor *textfieldTextColor;
@property (strong, nonatomic) UIColor *textfieldTintColor; 
@property (strong, nonatomic) UIColor *textfieldBackgroundColor;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *placeholderBackgroundColor;
@property (strong, nonatomic) UIColor *placeholderTextColor;
@end

@interface VKSearchBar : UIView

@property (strong, nonatomic) UIView *separator;
@property (strong, nonatomic) UILabel *placeholderLabel;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIView *textFieldBackground;
@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@property (readonly, nonatomic) VKSearchBarConfig *config;
@end

@interface VKSearchScrollTopBackgroundView : UIView
@end


@interface DialogsSearchResultsController : UIViewController
@property (strong, nonatomic) UITableView *tableView;
@end

@interface SendMessagePopupView : UIView
@property (strong, nonatomic) UIToolbar *headerToolBar;
@property (strong, nonatomic) UIImageView *backgroundImageView;
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

@interface CameraCaptureButtonTip : UIView
@end

@interface _TtC3vkm31HistoryCollectionViewController : UICollectionViewController
@end

@interface _TtC3vkm17MessageController : UIViewController
@end

@interface BKPasscodeViewController : UIViewController
@end

