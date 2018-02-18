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
@property (retain, nonatomic) Model *model;
@end

@interface VKMScrollViewController : VKMController
@property (retain, nonatomic) UIRefreshControl *rptr;
- (void)VKMScrollViewReloadData;
- (void)VKMScrollViewReset;
@end


@interface VKMSearchController : UISearchDisplayController
@end

@interface VKMTableController : VKMScrollViewController
@property (retain, nonatomic) UITableView *tableView;
@end

@interface VKMLiveController : VKMTableController
@end


@interface VKMMainController : VKMLiveController
@end

@interface VKMMainController ()
@property (retain, nonatomic) UIViewController *dialogsController;
@property (retain, nonatomic) UIViewController *newsController;
@property (retain, nonatomic) VKMController *discoverController;
@property (retain, nonatomic) UIView *tabBarShadowView;
@end



@interface MenuCell : UITableViewCell
@property (copy, nonatomic) id(^select)(id arg1, id arg2);
@end

@interface MenuViewController : VKMLiveController
@property (retain, nonatomic) NSArray *menu;
@end

@interface VKMNavContext : NSObject 
+ (id)applicationNavRoot;
- (void)reset:(UIViewController *)arg1;
- (void)push:(UIViewController *)arg1;
- (void)push:(UIViewController *)arg1 animated:(BOOL)arg2;
@property (readonly, strong) VKMNavContext *rootNavContext;
@property (retain, nonatomic) UINavigationController *navController;
@end



@interface VKAudio : NSObject
@property (retain, nonatomic) NSNumber *lyrics_id;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *performer;
@end

@interface AudioPlayer : NSObject
@property (retain, nonatomic) VKAudio *audio;
@property (nonatomic) int state;
@end

@interface AudioController : UIViewController
@property (retain, nonatomic) UIButton *pp;
@property (retain, nonatomic) UILabel *song;
@property (retain, nonatomic) UILabel *actor;
@property (retain, nonatomic) UISlider *seek;
- (void)done:(id)arg;
- (void)actionNext:(id)arg1;
- (void)actionPrev:(id)arg1;
- (void)actionPlaylist:(id)arg1;
@end


@interface IOS7AudioController : AudioController
@property (retain, nonatomic) UIView *hostView;
@property (retain, nonatomic) UIImageView *cover;
@end

@interface VKImageVariant : NSObject
@property (nonatomic) int type;
@property (retain, nonatomic) NSString *src; 
@end

@interface VKPhoto : NSObject
@property (retain, nonatomic) NSMutableDictionary *variants;
@end
@interface VKPhotoSized : VKPhoto
@end

@interface PhotoBrowserController : UIViewController
@property (retain, nonatomic) UIScrollView *paging;
- (VKPhotoSized *)photoForPage:(NSInteger)page;
@end

@interface VKMBrowserTarget : NSObject
@property (retain, nonatomic) NSURL *url;
@end

@interface VKMBrowserController : VKMController
@property (retain, nonatomic) UILabel *headerTitle;
@property (retain, nonatomic) VKMBrowserTarget *target;
@property (retain, nonatomic) UIToolbar *toolbar;
@property (retain, nonatomic) UIButton *safariButton;
@property (retain, nonatomic) UIScrollView *webScrollView;
@property (retain, nonatomic) UIWebView *webView;
@end



@interface VKMessage : NSObject
@property (nonatomic) BOOL read_state;
@property (nonatomic) BOOL incoming;
@end

@interface MessageCell : UITableViewCell
@property (retain, nonatomic) VKMessage *message;
@end

@interface ChatCell : MessageCell
@property (strong, nonatomic) UIImageView *bg;
@end


@interface VKDialog : NSObject
@property (retain, nonatomic) VKMessage *head;
@end

@interface BackgroundView : UILabel
@property (nonatomic) int cornerRadius;
@end
@interface NewDialogCell : UITableViewCell
@property (readonly, retain, nonatomic) BackgroundView *unread;
@property (readonly, retain, nonatomic) UILabel *attach;
@property (readonly, retain, nonatomic) UILabel *dialogText;
@property (readonly, retain, nonatomic) UILabel *time;
@property (readonly, retain, nonatomic) UILabel *name;
@property (retain, nonatomic) VKDialog *dialog;
@property (readonly, retain, nonatomic) UILabel *text;
@end


@interface VKMImageButton : UIButton
@end

@interface Component5HostView : UIView
@end


@interface DialogsController : VKMTableController
@end

@interface ExtrasInputView : UIView
@end


@interface MOTextView : UITextView
@property (retain, nonatomic) UILabel *placeholderLabel;
@property (retain, nonatomic) UIView *footerView;
@end

@interface InputPanelViewTextView : MOTextView
@property(retain, nonatomic) UILabel *placeholderLabel;
@end

@interface InputPanelView : UIToolbar
@property (retain, nonatomic) UIView *overlay;
@property (retain, nonatomic) UIToolbar *gapToolbar;
@property (retain, nonatomic) InputPanelViewTextView *textPanel;
@end
@interface ExtraInputPanelView : InputPanelView
@property (retain, nonatomic) UIView *pushToTalkCoverView;
@property (retain, nonatomic) UIButton *inputViewButton;
@end

@interface RootView : UIView
@property (retain, nonatomic) ExtraInputPanelView *inputPanelView;
@end

@interface ChatController : VKMTableController
@property (retain, nonatomic) RootView *root;
@property (retain, nonatomic) ExtraInputPanelView *inputPanel;
@property (retain, nonatomic) UIButton *editForward;
@property (retain, nonatomic) UIButton *editDelete;
@property (retain, nonatomic) UIView *editToolbar;
@property (retain, nonatomic) VKMImageButton *headerImage;
@property (retain, nonatomic) Component5HostView *componentTitleView;
@end



@interface VKMCell : UITableViewCell
@end
@interface GroupCell : VKMCell
@property (readonly, retain, nonatomic) UILabel *status;
@property (readonly, retain, nonatomic) UILabel *name;
@end


@interface VKMEditableController : VKMLiveController
@end
@interface VKMToolbarController : VKMEditableController
@property (readonly, retain, nonatomic) UISegmentedControl *segment;
@property (readonly, retain, nonatomic) UIToolbar *toolbar;
@end

@interface VKMMultiIndexController : VKMToolbarController
@end

@interface GroupsController : VKMMultiIndexController
@end


@interface DialogsSearchController : VKMSearchController
@end


@interface VKUser : NSObject
@property (retain, nonatomic) NSNumber *uid;
@end

@interface VKProfile : NSObject
@property (nonatomic) BOOL verified;
@property (retain, nonatomic) VKUser *user;
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
@property(retain, nonatomic) NSArray *views;
@end
@interface VKMRendererCell : UITableViewCell
@property (retain, nonatomic) Renderer *renderer;
@end
@interface AudioRenderer : Renderer
@property (retain, nonatomic) UILabel *durationLabel;
@property (retain, nonatomic) UIButton *playIndicator;
@property (retain, nonatomic) AudioPlayer *player;
@end



@interface FixedNavigationController : UINavigationController
@end
@interface VKMNavigationController : FixedNavigationController
@end


@interface VKMViewControllerContainer : VKMController
@property (retain, nonatomic) UIViewController *currentViewController;
@end
@interface VKSelectorContainerController : VKMViewControllerContainer
@end
@interface VKSelectorContainerControllerDropdown : VKSelectorContainerController
@property (retain, nonatomic) UIView *dimView;
@property (retain, nonatomic) UIViewController *selectorViewController; 
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
@property (setter=_setBackgroundView:, nonatomic, retain) UIView *_backgroundView;
@end


@interface BaseUserCell : VKMCell
@property (readonly, retain, nonatomic) UILabel *last;
@property (readonly, retain, nonatomic) UILabel *first;
@end

@interface SourceCell : BaseUserCell
@end


@interface MessageController : VKMController 
@property (retain, nonatomic) UIScrollView *scroll;
@end


@interface UIStatusBar : UIView
@property (nonatomic, retain) UIColor *foregroundColor;
@end


@interface DetailController : VKMLiveController
@property (retain, nonatomic) ExtraInputPanelView *inputPanel;
@end



@interface ProfileFriendsController : VKMMultiIndexController
@end

@interface FriendsBDaysController : VKMLiveController
@end

@interface FriendBdayCell : VKMCell
@property (retain, nonatomic) UILabel *status;
@property (retain, nonatomic) UILabel *name;
@end

@interface FriendsAllRequestsController : VKMToolbarController
@end


@interface VideoAlbumsInfoToolbar : UIToolbar
@property (retain, nonatomic) UISegmentedControl *segmentedControl;
@end

@interface VideoAlbumController : VKMLiveController
@property (retain, nonatomic) VideoAlbumsInfoToolbar *toolbar;
@end

@interface VideoCell : VKMCell
@property (readonly, retain, nonatomic) UILabel *viewCountLabel;
@property (readonly, retain, nonatomic) UILabel *authorLabel;
@property (readonly, retain, nonatomic) UILabel *videoTitleLabel;
@end




@interface VKMCollectionController : VKMScrollViewController
@end

@interface AudioPlaylistsInlineController : VKMCollectionController
@end


@interface AudioDashboardController : VKMLiveController
@end

@interface AudioPlaylistsCell : VKMCell
@property (readonly, retain, nonatomic) UIButton *showAllButton;
@property (readonly, retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UIView *hostedView;
@end

@interface VKMCollectionCell : UICollectionViewCell
@end

@interface AudioPlaylistInlineCell : VKMCollectionCell

@property (readonly, retain, nonatomic) UILabel *subtitleLabel;
@property (readonly, retain, nonatomic) UILabel *titleLabel;

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
@property (retain, nonatomic) UILabel *titleLabel;
@end

@interface AudioOwnersBlockItemCollectionCell : AudioImageAndTitleItemCollectionCell
@end


@interface AudioBlockCellHeaderView : UIView
@property (retain, nonatomic) UILabel *subtitleLabel;
@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UIButton *showAllButton;
@end

@interface BlockCellHeaderView : UIView
@property (retain, nonatomic) UILabel *subtitleLabel;
@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UIButton *actionButton;
@end

@interface AudioAudiosSpecialBlockView : UIView
@property (retain, nonatomic) UIButton *button;
@property (retain, nonatomic) UILabel *subtitleLabel;
@property (retain, nonatomic) UILabel *titleLabel;
@end


@interface AudioAudiosBlockTableCell : VKMCell
@end


@interface AudioPlaylistCell : VKMCell
@property (readonly, retain, nonatomic) UILabel *subtitleLabel;
@property (readonly, retain, nonatomic) UILabel *artistLabel;
@property (readonly, retain, nonatomic) UILabel *titleLabel;
@end


@interface AudioPlaylistView : UIView
@end



@interface AudioPlaylistDetailController : VKMLiveController
@end

@interface TeaserView : UIView
@property (retain, nonatomic) UILabel *labelText;
@property (retain, nonatomic) UILabel *labelTitle;
@end


@interface VKAudioQueuePlayer : NSObject
@property (nonatomic) int state;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *performer;
@end

@interface LoadingFooterView : UIView
@property (readonly, retain, nonatomic) UILabel *label;
@property (readonly, retain, nonatomic) UIActivityIndicatorView *anim;
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
@property (readonly, retain, nonatomic) VKProfile *item;
@end

@interface UserWallController : UIViewController
@property (retain, nonatomic) ProfileModel *profile;
@end

@interface VKGroup : NSObject
@property (retain, nonatomic) NSNumber *gid;
@end

@interface VKGroupProfile : NSObject
@property (retain, nonatomic) VKGroup *group;
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
@property (retain, nonatomic) MOTextView *textView;
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
@property (retain, nonatomic) UIView *separator;
@property (retain, nonatomic) UIImageView *verified;
@property (readonly, nonatomic) UIButton *online;
@property (readonly, retain, nonatomic) UILabel *status;
@property (readonly, retain, nonatomic) UILabel *name;
@end
@interface HintsCell : MenuSubtitleCell
@end
@interface MenuBirthdayCell : HintsCell
@property (retain, nonatomic) UIButton *giftButton;
@end

@interface TablePrimaryHeaderView : UITableViewHeaderFooterView
@property (retain, nonatomic) UIButton *button;
@property (retain, nonatomic) UIView *separator;
@end


@interface DiscoverFeedController : VKMScrollViewController
@property (retain, nonatomic) UICollectionView *collectionView;
@property(retain, nonatomic) UIView *topGradientBackgroundView;
@end



@interface Node5TableViewCell : UITableViewCell
@end

@interface ProfileView : UIView
@property (retain, nonatomic) UIButton *buttonStatus;
@property (retain, nonatomic) UIButton *buttonMessage;
@property (retain, nonatomic) UIScrollView *blocksScroll;
@end


@interface NewsFeedPostAndStoryCreationButtonBar : UIView
@property (retain, nonatomic) NSArray *separatorLines;
@end

@interface Node5CollectionViewCell : UICollectionViewCell
@end

@interface AdminInputPanelView : ExtraInputPanelView
@end

@interface PollAnswerButton : UIView
@property (retain, nonatomic) UIView *progressView;
@end


@interface VKAPBottomToolbar : UIView
@property (readonly, nonatomic) UIToolbar *bg;
@end

@interface WallModeRenderer : Renderer
@end



@interface AudioAudiosPagingView : UIView
@property (retain, nonatomic) UICollectionView *collectionView;
@end

@interface AudioAudiosBlockCell : VKMCell
@property (retain, nonatomic) AudioAudiosPagingView *audiosPagingView;
@end

@interface MOCTRender : NSObject
@property (retain, nonatomic) NSAttributedString *text;
@end

@interface SeparatorWithBorders : UIView
@property (retain, nonatomic) UIColor *borderColor;
@end


@interface LookupAddressbookTeaserViewController : VKMController
@property (retain, nonatomic) Component5HostView *componentView;
@end

@interface LookupFriendsViewController : VKMLiveController
@end
@interface LookupAddressBookFriendsViewController : LookupFriendsViewController
@property (retain, nonatomic) LookupAddressbookTeaserViewController *lookupTeaserViewController;
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
@property (readonly, retain, nonatomic) UIToolbar *bg;
@end

@interface VKPhotoPicker : UINavigationController
@property (retain, nonatomic) VKPPToolbar *pickerToolbar;
@end


@interface TouchHighlightControl : UIControl
@end

@interface MainMenuPlayer : UIView
@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UILabel *playerTitle;
@end

@interface VKMTableViewSearchHeaderView : UIToolbar
@end

@interface VKMAccessibilityTableView : UITableView
@end

@interface PersistentBackgroundColorView : UIView
@property (retain, nonatomic) UIColor *persistentBackgroundColor;
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
@property (retain, nonatomic) UIToolbar *toolbar;
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
@property (retain, nonatomic) UIButton *button;
@end

@interface VKLivePromoView : UIView
@end

@interface CommentSourcePickerController : UIViewController
@property (retain, nonatomic) UIView *containerView;
@end


@interface HighlightableBackgroundButton : UIButton
@end
@interface NewsFeedPostCreationButton : HighlightableBackgroundButton
@end

@interface LandingPageController : UIViewController
@end

@interface UITableViewIndex : UIControl
@property (retain, nonatomic) UIColor *indexBackgroundColor;
@end

@interface SketchDrawView : UIView
@end

@interface SketchViewController : UIViewController

@property (retain, nonatomic) UIButton *eraserButton;
@property (retain, nonatomic) UIButton *undoButton;
@property (retain, nonatomic) UIButton *sendButton;

@property (retain, nonatomic) NSArray *paletteButtons;
@property (retain, nonatomic) SketchDrawView *drawView;

@end



@interface DrawView : UIView
@end

@interface ColorPaletteView : UIView
@property (retain, nonatomic) UICollectionView *collectionView;
@end

@interface SketchView : UIView
@property (retain, nonatomic) ColorPaletteView *colorPaletteView;
@property (retain, nonatomic) DrawView *drawView;
@end

@interface SketchController : UIViewController
@property (retain, nonatomic) SketchView *sketchView;
@end



@interface EmojiSelectionView : UIView 
@property (retain, nonatomic) UIScrollView *scrollView;
@end

@interface LicensesViewController : VKMController
@end

@interface VKAudioPlayerViewController : VKMController
@property (retain, nonatomic) UIVisualEffectView *toolbarView;
@property (retain, nonatomic) UIVisualEffectView *backgroundView;
@property (retain, nonatomic) UIPageViewController *pageController;
@end

@interface PopupWindowView : UIView
@property (readonly, nonatomic) UIView *contentView;
@end


@interface VKAudioPlayerControlsViewController : VKMController
@property (retain, nonatomic) UIButton *next;
@property (retain, nonatomic) UIButton *prev;
@property (retain, nonatomic) UIButton *pp;
@end

@interface _UIAlertControllerTextFieldViewController : UICollectionViewController
@end

@interface MasksController : UICollectionViewController
@end

@interface VKPPNoAccessView : UIView
@end


@interface VKSearchBarConfig : NSObject
@property(retain, nonatomic) UIColor *segmentBorderColor;
@property(retain, nonatomic) UIColor *segmentTintColor;
@property(retain, nonatomic) UIColor *textfieldTextColor;
@property(retain, nonatomic) UIColor *textfieldTintColor; 
@property(retain, nonatomic) UIColor *textfieldBackgroundColor;
@property(retain, nonatomic) UIColor *backgroundColor;
@property(retain, nonatomic) UIColor *placeholderBackgroundColor;
@property(retain, nonatomic) UIColor *placeholderTextColor;
@end

@interface VKSearchBar : UIView

@property(retain, nonatomic) UIView *separator;
@property(retain, nonatomic) UILabel *placeholderLabel;
@property(retain, nonatomic) UITextField *textField;
@property(retain, nonatomic) UIView *textFieldBackground;
@property(retain, nonatomic) UIView *backgroundView;
@property(retain, nonatomic) UISegmentedControl *segmentedControl;
@property(readonly, nonatomic) VKSearchBarConfig *config;
@end

@interface VKSearchScrollTopBackgroundView : UIView
@end


@interface DialogsSearchResultsController : UIViewController
@property(retain, nonatomic) UITableView *tableView;
@end

@interface SendMessagePopupView : UIView
@property(retain, nonatomic) UIToolbar *headerToolBar;
@property(retain, nonatomic) UIImageView *backgroundImageView;
@end


@interface StoryEditorSendViewController : UIViewController
@property(retain, nonatomic) UIButton *sendButton;
@end

@interface StoryRepliesController : VKMController
@property(retain, nonatomic) UIView *containerView;
@end

@interface StoryRepliesTipController : UIViewController
@property(retain, nonatomic) UIView *container;
@end

@interface CameraCaptureButtonTip : UIView
@end



