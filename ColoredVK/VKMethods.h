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





//@interface VKPhoto : NSObject
//@property(retain, nonatomic) NSNumber *user_id;
//@property(retain, nonatomic) NSNumber *aid;
//@property(nonatomic) double ratio;
//@property(retain, nonatomic) NSMutableDictionary *variants;
//@end
//
//@interface VKPhotoSized : VKPhoto
//@property(nonatomic) int sizeType;
//@end

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

