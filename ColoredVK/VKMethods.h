//
//  VKMethods.h
//  ColoredVK
//
//  Created by Даниил on 22.04.16.
//  
//
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@interface VKSession : NSObject
@property(readonly, copy, nonatomic) NSNumber *userId; 
@property(copy, nonatomic) NSString *token;
@end


@interface Model : NSObject
@end

@interface VKMController : UIViewController
@property(retain, nonatomic) Model *model;
@end

@interface VKMScrollViewController : VKMController
@property(retain, nonatomic) UIRefreshControl *rptr;
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
@property (nonatomic, readonly, strong) id VKMTableCreateSearchBar;
@end

@interface VKMLiveController : VKMTableController
@end


@interface VKMMainController : VKMLiveController
@property(retain, nonatomic) NSArray *menu;
@property(retain, nonatomic) UINavigationController *navMain;
@end



@interface MenuCell : UITableViewCell
@property (copy, nonatomic) id(^select)(id arg1, id arg2);
@end


@interface TitleMenuCell : MenuCell
+ (id)image:(id)arg1 statId:(id)arg2 title:(id)arg3 select:(id)arg4;
@property(retain, nonatomic) UIButton *badge;
@end

@interface VKMNavContext : NSObject 
+ (id)applicationNavRoot;
- (void)reset:(id)arg1;
@property (readonly, strong) VKMNavContext *rootNavContext;
@property(retain, nonatomic) UINavigationController *navController;
@end



@interface VKAudio : NSObject
@property(retain, nonatomic) NSNumber *lyrics_id;
@property(retain, nonatomic) NSString *title;
@property(retain, nonatomic) NSString *performer;
@end

@interface AudioPlayer : NSObject
@property(retain, nonatomic) UIImage *coverImage;
@property(retain, nonatomic) VKAudio *audio;
@property(retain) AVPlayer *player;
@property(nonatomic) int state;
@end

@interface AudioController : UIViewController
@property(retain, nonatomic) UIButton *pp;
@property(retain, nonatomic) UILabel *song;
@property(retain, nonatomic) UILabel *actor;
@property(retain, nonatomic) UISlider *seek;
- (void)done:(id)arg;
@end


@interface IOS7AudioController : AudioController
@property(retain, nonatomic) UIView *hostView;
@property(retain, nonatomic) UIImageView *cover;
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

@interface PhotoBrowserController : UIViewController
@property(retain, nonatomic) UIScrollView *paging;
- (VKPhotoSized *)photoForPage:(NSInteger)page;
@end

@interface VKMBrowserTarget : NSObject
@property(retain, nonatomic) NSURL *url;
@end

@interface VKMBrowserController : UIViewController 
@property(retain, nonatomic) VKMBrowserTarget *target;
@end



@interface VKMessage : NSObject
@property(nonatomic) BOOL read_state;
@property(nonatomic) _Bool incoming;
@end

@interface MessageCell : UITableViewCell
@property(retain, nonatomic) VKMessage *message;
@end

@interface ChatCell : MessageCell
@property (strong, nonatomic) UIImageView *bg;
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


@interface VKUser : NSObject
@property(retain, nonatomic) NSNumber *uid;
@end

@interface VKProfile : NSObject
@property(nonatomic) BOOL verified;
@property(retain, nonatomic) VKUser *user; 
@end



@interface AudioAlbumController : VKMLiveController
@end

@interface AudioPlaylistController : VKMLiveController
@end


@interface AFURLConnectionOperation : NSOperation
@end

@interface AFHTTPRequestOperation : AFURLConnectionOperation
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



@interface UIImageAsset ()
@property (nonatomic, copy) NSString *assetName;
@end


@interface MPVolumeSlider : UISlider
@end
@interface MPVolumeView ()
@property (nonatomic, readonly) MPVolumeSlider *volumeSlider;
@end




@interface Renderer : NSObject
@end
@interface VKMRendererCell : UITableViewCell
@property(retain, nonatomic) Renderer *renderer;
@end
@interface AudioRenderer : Renderer
@property(retain, nonatomic) UILabel *durationLabel;
@property(retain, nonatomic) UIButton *playIndicator;
@property(retain, nonatomic) AudioPlayer *player;
@end




@interface VKMNavigationController : UINavigationController
@end


@interface VKMViewControllerContainer : VKMController
@property(retain, nonatomic) UIViewController *currentViewController;
@end
@interface VKSelectorContainerController : VKMViewControllerContainer
@end
@interface VKSelectorContainerControllerDropdown : VKSelectorContainerController
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
@property(readonly, retain, nonatomic) UILabel *last;
@property(readonly, retain, nonatomic) UILabel *first;
@end

@interface SourceCell : BaseUserCell
@end


@interface MessageController : VKMController 
@end


@interface UIStatusBar : UIView
@property (nonatomic, retain) UIColor *foregroundColor;
@end


@interface DetailController : VKMLiveController
@property(retain, nonatomic) ExtraInputPanelView *inputPanel;
@end

