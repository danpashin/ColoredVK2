//
//  VKMethods.h
//  ColoredVK
//
//  Created by Даниил on 22.04.16.
//  
//
#import <AVFoundation/AVFoundation.h>


@interface VKMMainController : UIViewController
{
    NSArray *_menu;
}
@property(retain, nonatomic) NSArray *menu;
@property(retain, nonatomic) UINavigationController *navMain;
@end



@class MainModel;
@interface MenuCell : UITableViewCell 
@property (copy, nonatomic) id(^select)(MainModel *model, id arg2);
@end


@interface TitleMenuCell : MenuCell
+ (id)image:(id)arg1 statId:(id)arg2 title:(id)arg3 select:(id)arg4;
@property(retain, nonatomic) UIButton *badge;
@end

@interface VKMNavContext : NSObject 
+ (id)applicationNavRoot;
- (void)reset:(id)arg1;
- (void)replace:(id)arg1;
- (void)push:(id)arg1 animated:(BOOL)arg2;
@property (readonly, strong) VKMNavContext *rootNavContext;
@property(retain, nonatomic) UINavigationController *navController;
@end


@interface VKMAccessibilityTableView : UITableView
@end


@interface ProfileView : UIView
@end

@interface VKMGroupedCell : UITableViewCell
@end



@interface VKAudio : NSObject
@property(retain, nonatomic) NSNumber *lyrics_id;
@end

@interface AudioPlayer : NSObject
@property(retain, nonatomic) UIImage *coverImage;
@property(retain, nonatomic) VKAudio *audio;
@property(retain) AVPlayerItem *playerItem;
@property(retain) AVPlayer *player;
@end

@interface AudioController : UIViewController
@property(retain, nonatomic) UIButton *pp;
@property(retain, nonatomic) UILabel *song;
@property(retain, nonatomic) UILabel *actor;
@end


@interface IOS7AudioController : AudioController
@property(retain, nonatomic) UIView *hostView;
@property(retain, nonatomic) UIImageView *cover;
@end




@interface TextEditController : UIViewController
@property(retain, nonatomic) UITextView *textView;
@end

@interface CountryCallingCodeController : UITableViewController
@end

@interface VKMSearchBar : UISearchBar
@end

@interface UITableViewIndex : UIControl
@property (nonatomic, retain) UIColor *indexBackgroundColor;
@property (nonatomic, retain) UIColor *indexColor;
@end

@interface UITableViewCellSelectedBackground : UIView 
@property (nonatomic, retain) UIColor *selectionTintColor;
@end





@interface VKMScrollViewController : UIViewController
@property(retain, nonatomic) UIRefreshControl *rptr;
@end








@interface VKRenderedText : NSObject
{
    NSAttributedString *_text;
}
@property(readonly, copy, nonatomic) NSAttributedString *text;
@end

@interface TextKitLayer : CALayer
@property(retain, nonatomic) VKRenderedText *text;
@end

@interface VKRenderedTextAttributeValue : NSObject
+ (id)attribute:(id)arg1 value:(id)arg2 range:(struct _NSRange)arg3;
@property(readonly, nonatomic) id value;
@property(readonly, nonatomic) struct _NSRange range;
@property(readonly, nonatomic) NSString *attribute;
- (instancetype)initWithAttribute:(id)arg1 value:(id)arg2 range:(struct _NSRange)arg3;
@end





@interface BlockActionController : UIAlertController
+ (id)actionSheetWithTitle:(NSString *)title;
- (void)showInViewController:(id)arg1;
- (void)addButtonWithTitle:(NSString *)title block:(id)arg2;
- (void)setCancelButtonWithTitle:(NSString *)title block:(id)arg2;
@end


@class VKPhotoSized;
@interface PhotoBrowserController : UIViewController
@property(retain, nonatomic) UIScrollView *paging;
- (VKPhotoSized *)photoForPage:(NSInteger)page;
@end

@interface VKImageVariant : NSObject
@property(nonatomic) int type;
@property(retain, nonatomic) NSString *src; 
@end

@interface VKPhoto : NSObject
@property(retain, nonatomic) NSMutableDictionary *variants;
@end

@interface VKPhotoSized : VKPhoto
@end

@interface VKMBrowserTarget : NSObject
@property(retain, nonatomic) NSURL *url;
@end

@interface VKMBrowserController : UIViewController 
@property(retain, nonatomic) VKMBrowserTarget *target;
@end




@interface MBProgressHUD : UIView
- (void)hide:(BOOL)animated;
@end

@interface VKHUD : MBProgressHUD
+ (instancetype)hud;
- (void)showForOperation:(id)arg1;
- (void)hideWithResult:(BOOL)arg1 message:(NSString *)arg2;
- (void)hideWithResult:(BOOL)arg1;
@end





@interface VKMessage : NSObject
@property(nonatomic) BOOL read_state;
@end

@interface MessageCell : UITableViewCell
@property(retain, nonatomic) VKMessage *message;
@end


@interface VKDialog : NSObject
@property(retain, nonatomic) VKMessage *head;
@end

@interface BackgroundView : UILabel
@property(nonatomic) int cornerRadius;
@end
@interface NewDialogCell : UITableViewCell
@property(readonly, retain, nonatomic) BackgroundView *unread;
@property(readonly, retain, nonatomic) UILabel *attach;
@property(readonly, retain, nonatomic) UILabel *dialogText;
@property(readonly, retain, nonatomic) UILabel *time;
@property(readonly, retain, nonatomic) UILabel *name;
@property(retain, nonatomic) VKDialog *dialog;
@property(readonly, retain, nonatomic) UILabel *text;
@end




@interface VKMSearchController : UISearchDisplayController
@end
@interface VKSearchController : UISearchController
@end

@interface VKMTableController : VKMScrollViewController
@property(retain, nonatomic) VKSearchController *search80;
@property(retain, nonatomic) VKMSearchController *search;
@property(retain, nonatomic) UIColor *separatorColor;
@property(retain, nonatomic) UITableView *tableView;
- (void)redrawSectionFooters;
- (void)redrawSectionHeaders;
@property (nonatomic, readonly, strong) id VKMTableCreateSearchBar;
@end



@interface VKMImageButton : UIButton
@end

@interface Component5HostView : UIView

@end


@interface DialogsController : VKMTableController
@end

@interface InputPanelView : UIToolbar
@end
@interface ExtraInputPanelView : InputPanelView
@end
@interface ChatController : VKMTableController
@property(retain, nonatomic) ExtraInputPanelView *inputPanel;
@property(retain, nonatomic) UIButton *editForward;
@property(retain, nonatomic) UIButton *editDelete;
@property(retain, nonatomic) UIView *editToolbar;
@property(retain, nonatomic) VKMImageButton *headerImage;
@property(retain, nonatomic) Component5HostView *componentTitleView;
@end



@interface VKMCell : UITableViewCell
@end
@interface GroupCell : VKMCell
@property(readonly, retain, nonatomic) UILabel *status;
@property(readonly, retain, nonatomic) UILabel *name;
@end


@interface VKMLiveController : VKMTableController
@end



@interface VKMEditableController : VKMLiveController
@end
@interface VKMToolbarController : VKMEditableController
@property(readonly, retain, nonatomic) UISegmentedControl *segment;
@property(readonly, retain, nonatomic) UIToolbar *toolbar;
@end

@interface VKMMultiIndexController : VKMToolbarController
@end

@interface GroupsController : VKMMultiIndexController
@end



@interface DialogsSearchController : VKMSearchController
@end


@interface VKPPBadge : UIImageView
@end




@interface VKUser : NSObject
@property(retain, nonatomic) NSNumber *uid;
@end

@interface VKProfile : NSObject
@property(nonatomic) BOOL verified;
@property(retain, nonatomic) VKUser *user; 
@end



@interface AudioAlbumController : VKMLiveController
@end





@interface AFURLConnectionOperation : NSOperation
@property(copy, nonatomic) NSString *responseString;
@property(retain, nonatomic) NSData *responseData;
@property(retain, nonatomic) NSError *error;
@property(retain, nonatomic) NSURLResponse *response;
@property(retain, nonatomic) NSURLRequest *request;
@property(retain, nonatomic) NSURLConnection *connection;
@end

@interface AFHTTPRequestOperation : AFURLConnectionOperation
@property(retain, nonatomic) NSError *HTTPError;
@end

@interface AFJSONRequestOperation : AFHTTPRequestOperation
+ (instancetype)JSONRequestOperationWithRequest:(NSURLRequest *)request 
                              success:( void(^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) )success 
                              failure:( void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) )failure;
@end


@interface AFImageRequestOperation : AFHTTPRequestOperation
+ (instancetype)imageRequestOperationWithRequest:(NSURLRequest *)urlRequest
                            imageProcessingBlock:( UIImage *(^)(UIImage *image) )imageProcessingBlock
                                       cacheName:(NSString *)cacheNameOrNil
                                         success:( void(^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) )success
                                         failure:( void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) )failure;

@end

