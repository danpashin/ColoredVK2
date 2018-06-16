//
//  VKCells.h
//  ColoredVK2
//
//  Created by Даниил on 16.06.18.
//

@interface VKMCell : UITableViewCell
@end

@interface MenuCell : UITableViewCell
@property (copy, nonatomic) __kindof UIViewController *(^select)(id model);
@end

@interface TitleMenuCell : MenuCell
@end

@interface MessageCell : UITableViewCell
@property (strong, nonatomic) VKMessage *message;
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

@interface GroupCell : VKMCell
@property (readonly, strong, nonatomic) UILabel *status;
@property (readonly, strong, nonatomic) UILabel *name;
@end

@interface VKMRendererCell : UITableViewCell
@property (strong, nonatomic) Renderer *renderer;
@end

@interface BaseUserCell : VKMCell
@property (readonly, strong, nonatomic) UILabel *last;
@property (readonly, strong, nonatomic) UILabel *first;
@end

@interface SourceCell : BaseUserCell
@end

@interface FriendBdayCell : VKMCell
@property (strong, nonatomic) UILabel *status;
@property (strong, nonatomic) UILabel *name;
@end

@interface VideoCell : VKMCell
@property (readonly, strong, nonatomic) UILabel *viewCountLabel;
@property (readonly, strong, nonatomic) UILabel *authorLabel;
@property (readonly, strong, nonatomic) UILabel *videoTitleLabel;
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

@interface AudioImageAndTitleItemCollectionCell : VKMCollectionCell
@property (strong, nonatomic) UILabel *titleLabel;
@end

@interface AudioOwnersBlockItemCollectionCell : AudioImageAndTitleItemCollectionCell
@end

@interface AudioAudiosBlockTableCell : VKMCell
@end

@interface AudioPlaylistCell : VKMCell
@property (readonly, strong, nonatomic) UILabel *subtitleLabel;
@property (readonly, strong, nonatomic) UILabel *artistLabel;
@property (readonly, strong, nonatomic) UILabel *titleLabel;
@end

@interface CommunityCommentsCell : UITableViewCell
@property (readonly, nonatomic) UILabel *subtitleLabel;
@property (readonly, nonatomic) UILabel *titleLabel;
@end

@interface MenuBirthdayCell : UITableViewCell
@property (readonly, strong, nonatomic) UILabel *status;
@property (readonly, strong, nonatomic) UILabel *name;
@end

@interface Node5TableViewCell : UITableViewCell
@end

@interface GiftsCatalogSectionCell : VKMCell
@end

@interface AudioAudiosBlockCell : VKMCell
@property (strong, nonatomic) AudioAudiosPagingView *audiosPagingView;
@end

@interface BaseMarketGalleryCell : VKMCollectionCell
@end

@interface ProductMarketCell : BaseMarketGalleryCell
@end

@interface ProductMarketCellForProfileGallery : ProductMarketCell
@end

@interface ChatCell : MessageCell
@property (strong, nonatomic) UIImageView *bg;
@end

@interface Node5CollectionViewCell : UICollectionViewCell
@end

@interface DialogSingleCell : NewDialogCell
@end
