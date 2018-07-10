//
//  VKViews.h
//  ColoredVK2
//
//  Created by Даниил on 16.06.18.
//

@interface BackgroundView : UILabel
@property (assign, nonatomic) NSInteger cornerRadius;
@end

@interface VKMImageButton : UIButton
@end

@interface Component5HostView : UIView
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

@interface AudioPlaylistView : UIView
@end

@interface TeaserView : UIView
@property (strong, nonatomic) UILabel *labelText;
@property (strong, nonatomic) UILabel *labelTitle;
@end

@interface LoadingFooterView : UIView
@property (readonly, strong, nonatomic) UILabel *label;
@property (readonly, strong, nonatomic) UIActivityIndicatorView *anim;
@end

@interface VKSearchBarNoCancel : UISearchBar
@end

@interface TablePrimaryHeaderView : UITableViewHeaderFooterView
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UIView *separator;
@end

@interface ProfileView : UIView
@property (strong, nonatomic) UIButton *buttonStatus;
@property (strong, nonatomic) UIButton *buttonMessage;
@property (strong, nonatomic) UIScrollView *blocksScroll;
@end


@interface NewsFeedPostAndStoryCreationButtonBar : UIView
@property (strong, nonatomic) NSArray *separatorLines;
@end

@interface AdminInputPanelView : ExtraInputPanelView
@end

@interface PollAnswerButton : UIView
@property (strong, nonatomic) UIView *progressView;
@property (assign, nonatomic) BOOL lightTheme; // VK 4.6
@end

@interface VKAPBottomToolbar : UIView
@property (readonly, nonatomic) UIToolbar *bg;
@property (readonly, nonatomic) UIView *hostView;
@end

@interface AudioAudiosPagingView : UIView
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@interface SeparatorWithBorders : UIView
@property (strong, nonatomic) UIColor *borderColor;
@end

@interface MarketGalleryDecoration : UICollectionReusableView
@end

@interface StoreStockItemView : UIScrollView
@end

@interface VKPPToolbar : UIView
@property (readonly, strong, nonatomic) UIToolbar *bg;
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

@interface DefaultHighlightButton : UIButton
@end

@interface HighlightableButton : UIButton
@end

@interface DiscoverLayoutMask : UICollectionReusableView
@end

@interface DiscoverLayoutShadow : UICollectionReusableView
@end

@interface VKP2PDetailedView : UIView
@end



@interface FreshNewsButton : UIView
@property (strong, nonatomic) UIButton *button;
@end

@interface VKLivePromoView : UIView
@end

@interface NewsFeedPostCreationButton : UIButton
@end

@interface ColorPaletteView : UIView
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@interface SketchView : UIView
@property (strong, nonatomic) ColorPaletteView *colorPaletteView;
@property (strong, nonatomic) UIView *drawView;
@end

@interface EmojiSelectionView : UIView 
@property (strong, nonatomic) UIScrollView *scrollView;
@end

@interface PopupWindowView : UIView
@property (readonly, nonatomic) UIView *contentView;
@end

@interface VKPPNoAccessView : UIView
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

@interface SendMessagePopupView : UIView
@property (strong, nonatomic) UIImageView *backgroundImageView;
@end

@interface CameraCaptureButtonTip : UIView
@end

@interface PopupIntroView : UIView
@end

@interface MBProgressHUDBackgroundLayer : CALayer
@end

@interface PostingComposePanel : UIView
@end

@interface VKReusableButtonView : UIButton
@property (strong, nonatomic) UIColor *highlightBackgroundColor;
@end

@interface VKSegmentedControl : UIControl
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@interface PaymentsPopupView : UIView
@property (strong, nonatomic) UIToolbar *topToolbar;
@end

@interface _TtC3vkm9BadgeView : UIView
@property (strong, nonatomic, readonly) CAShapeLayer *layer;
@end

@interface VKReusableColorView  : UIView
@end

@interface _TtC3vkm17MessageBubbleView : UIView
@property (strong, nonatomic, readonly) CAShapeLayer *layer;
@end

@interface DiscoverFeedTitleView : UIView
@property(retain, nonatomic) UIToolbar *toolbar;
@end
