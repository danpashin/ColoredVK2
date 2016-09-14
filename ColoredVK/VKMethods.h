//
//  VKMethods.h
//  ColoredVK
//
//  Created by Даниил on 22.04.16.
//  
//


@interface VKMMainController : UIViewController
+ (id)rootMainControllerForSession:(id)arg1;
+ (id)rootMainController;
@property(retain, nonatomic) NSArray *menu;
@property(retain, nonatomic) UINavigationController *navMain;
@end



@interface MenuCell : UITableViewCell 
@property(copy, nonatomic) id select;
@end

@interface VKMNavContext : NSObject 
+ (id)applicationNavRoot;
- (void)reset:(id)arg1;
@property (readonly, strong) VKMNavContext *rootNavContext;
@property(retain, nonatomic) UINavigationController *navController;
@end


@interface VKMAccessibilityTableView : UITableView
@end


@interface ProfileView : UIView
@property(retain, nonatomic) UILabel *status; 
@property(retain, nonatomic) UILabel *subtitle;
@property(retain, nonatomic) UILabel *name;
@end

@interface VKMGroupedCell : UITableViewCell
@end


@interface TextKitLayer : CALayer
- (void)drawInContext:(struct CGContext *)arg1;
- (instancetype)init;
@property(retain, nonatomic) id text;
@end

@interface TextKitLabelInteractive : UIView
@property(readonly, nonatomic) CALayer *textLayer;
@end


@interface AudioController : UIViewController
@property(retain, nonatomic) UIButton *pp;
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


@interface MessageCell : UITableViewCell
{
    BOOL unread;
    BOOL pendingRead;
    BOOL _multidialog;
    BOOL _selfdialog;
    UIButton *_checkmark;
}

@property(retain, nonatomic) UIButton *checkmark; // @synthesize checkmark=_checkmark;
@property(readonly, nonatomic) BOOL selfdialog; // @synthesize selfdialog=_selfdialog;
@property(readonly, nonatomic) BOOL multidialog; // @synthesize multidialog=_multidialog;
- (void)copyMessage:(id)arg1;
- (void)deleteMessage:(id)arg1;
- (void)replyMessage:(id)arg1;
- (void)selectMessage:(id)arg1;
- (void)deattach;
- (void)messageUpdated:(id)arg1;
- (id)retrieveUserById:(id)arg1;
- (void)transitionToReadState;
- (void)updateReadState;
- (void)didMoveToWindow;
- (void)actionMarkRead:(id)arg1;
- (void)attach:(id)arg1 expectedReuse:(double)arg2;
- (void)updateChecked:(BOOL)arg1;
- (void)updateBackground:(BOOL)arg1;
- (void)didTransitionToState:(unsigned long long)arg1;
- (void)willTransitionToState:(unsigned long long)arg1;
- (void)prepareForReuse;
- (void)dealloc;
- (instancetype)initWithDelegate:(id)arg1 multidialog:(BOOL)arg2 selfdialog:(BOOL)arg3 identifier:(id)arg4;

@end

@interface ChatCell : MessageCell
@end




@interface InputPanelView : UIToolbar
@end
@interface ExtraInputPanelView : InputPanelView
@end
@interface RootView : UIView
@property(retain, nonatomic) ExtraInputPanelView *inputPanelView;
@end

@interface ChatController : UIViewController
@property(retain, nonatomic) RootView *root;
@property(retain, nonatomic) ExtraInputPanelView *inputPanel;
@end


@interface VKRenderedText : NSObject
@property(readwrite, copy, nonatomic) NSAttributedString *text;
@end

@interface InputPanelViewTextView : UITextView
@end






@interface PhotoBrowserController : UIViewController
@property(retain, nonatomic) NSArray *hosts;
@property(retain, nonatomic) NSArray *photos;
@end


@interface BlockActionController : UIAlertController
+ (id)actionSheetWithTitle:(NSString *)title;
- (void)showInViewController:(id)arg1;
- (void)addButtonWithTitle:(NSString *)title block:(id)arg2;
- (void)setCancelButtonWithTitle:(NSString *)title block:(id)arg2;
@end




@interface VKImageVariant : NSObject
@property(nonatomic) int type;
@property(nonatomic) int height; 
@property(nonatomic) int width;
@property(retain, nonatomic) NSString *src; 
@end


@interface PhotoHostView : UIView 
@property(retain, nonatomic) VKImageVariant *maxVariant;
@property(retain, nonatomic) VKImageVariant *initialVariant;
@property(retain, nonatomic) VKImageVariant *currentVariant;
@end
@interface VKPhoto : NSObject
@property(retain, nonatomic) NSNumber *user_id;
@property(retain, nonatomic) NSNumber *aid;
@property(nonatomic) double ratio;
@property(retain, nonatomic) NSMutableDictionary *variants;
@end

@interface VKPhotoSized : VKPhoto
@property(nonatomic) int sizeType;
@end






@interface MBProgressHUD : UIView
- (void)hideDelayed:(id)arg1;
- (void)hide:(BOOL)arg1 afterDelay:(double)delay;
- (void)hide:(BOOL)animated;
- (void)done;
@end


@interface VKHUD : MBProgressHUD
+ (instancetype)hudForDialogModification:(BOOL)arg1;
+ (void)runInBackgroundWithHUD:(id)arg1;
+ (void)API;
+ (void)NYI;
+ (void)success:(id)arg1;
+ (void)info:(id)arg1;
+ (void)error:(id)arg1;
+ (void)closeAll;
+ (instancetype)hud;
- (void)showForOperation:(id)arg1;
- (void)hideWithResult:(BOOL)arg1 message:(NSString *)arg2;
- (void)hideWithResult:(BOOL)arg1;
- (void)hideWithErrorResult:(int)arg1;
- (void)hideWithInfo:(id)arg1;
- (void)hideWithTitle:(id)arg1;
- (void)hideWithError:(id)arg1;
- (void)hide:(BOOL)arg1 afterDelay:(double)arg2;
- (void)actionClose:(id)arg1;

@end



@class VKMBrowserController;
@interface VKMBrowserTarget : NSObject

@property(nonatomic) _Bool simpleChrome; // @synthesize simpleChrome=_simpleChrome;
@property(retain, nonatomic) NSURL *url; // @synthesize url=_url;
@property(nonatomic) VKMBrowserController *weakBrowser; // @synthesize weakBrowser=_weakBrowser;
- (void)fillShareActions:(id)arg1;
- (_Bool)canShare;
- (id)targetURL;
- (id)title;
- (void)reload;
- (void)render;
- (void)stop;
- (void)load;
- (void)dealloc;

@end


@interface VKMBrowserController : UIViewController 

@property(retain, nonatomic) UIBarButtonItem *buttonForward; // @synthesize buttonForward=_buttonForward;
@property(retain, nonatomic) UIBarButtonItem *buttonBack; // @synthesize buttonBack=_buttonBack;
@property(retain, nonatomic) UIToolbar *toolbar; // @synthesize toolbar=_toolbar;
@property(retain, nonatomic) UIButton *safariButton; // @synthesize safariButton=_safariButton;
@property(retain, nonatomic) UIButton *toolbarButton; // @synthesize toolbarButton=_toolbarButton;
@property(retain, nonatomic) UIScrollView *webScrollView; // @synthesize webScrollView=_webScrollView;
@property(retain, nonatomic) UILabel *headerLoading; // @synthesize headerLoading=_headerLoading;
@property(retain, nonatomic) UILabel *headerURL; // @synthesize headerURL=_headerURL;
@property(retain, nonatomic) UILabel *headerTitle; // @synthesize headerTitle=_headerTitle;
@property(retain, nonatomic) VKMBrowserTarget *target; // @synthesize target=_target;
@property(retain, nonatomic) NSMutableArray *stack; // @synthesize stack=_stack;
@property(nonatomic) _Bool hideToolbar; // @synthesize hideToolbar=_hideToolbar;
@property(nonatomic) _Bool keepDefaultStyle; // @synthesize keepDefaultStyle=_keepDefaultStyle;
@property(retain, nonatomic) UIWebView *webView; // @synthesize webView=_webView;
@end




@interface VKDoc : NSObject

@property(nonatomic) _Bool saved; // @synthesize saved=_saved;
@property(nonatomic) double ratio; // @synthesize ratio=_ratio;
@property(retain, nonatomic) NSNumber *date; // @synthesize date=_date;
@property(retain, nonatomic) NSString *url; // @synthesize url=_url;
@property(retain, nonatomic) NSString *ext; // @synthesize ext=_ext;
@property(nonatomic) int size; // @synthesize size=_size;
@property(retain, nonatomic) NSString *title; // @synthesize title=_title;
@property(retain, nonatomic) NSMutableDictionary *variants; // @synthesize variants=_variants;
- (_Bool)isVideo;
- (id)thumbnailUrl;
- (id)messagesPlaceholder;
- (id)messagesVariant;
- (id)fullVariant;
- (int)fullVariantType;
- (id)thumbnailVariant;
- (id)attachmentIco;
- (id)attachmentImage;
- (id)attachmentStatus:(_Bool)arg1;
- (id)attachmentTitle;
- (id)attachmentPlaceholder;
- (id)sizeString;
@end



@interface VKMURLDocTarget : VKMBrowserTarget
@property(readonly, retain, nonatomic) VKDoc *document;
- (void)fillShareActions:(id)arg1;
- (_Bool)canShare;
- (void)reload;
- (id)targetURL;
- (id)title;
- (void)stop;
- (void)load;
- (id)description;
- (void)dealloc;

@end


