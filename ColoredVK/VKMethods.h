//
//  VKMethods.h
//  ColoredVK
//
//  Created by Даниил on 22.04.16.
//  
//


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
- (id)initWithAttribute:(id)arg1 value:(id)arg2 range:(struct _NSRange)arg3;
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


@interface BackgroundView : UILabel
@property(nonatomic) int cornerRadius;
@end
@interface NewDialogCell : UITableViewCell
@property(readonly, retain, nonatomic) BackgroundView *unread;
@property(readonly, retain, nonatomic) UILabel *attach;
@property(readonly, retain, nonatomic) UILabel *dialogText;
@property(readonly, retain, nonatomic) UILabel *time;
@property(readonly, retain, nonatomic) UILabel *name;
@end


@interface VKMSearchController : UISearchDisplayController
@end
@interface VKSearchController : UISearchController
@end

@interface VKMTableController : UIViewController
@property(retain, nonatomic) VKSearchController *search80;
@property(retain, nonatomic) VKMSearchController *search;
@property(retain, nonatomic) UIColor *separatorColor;
@property(retain, nonatomic) UITableView *tableView;
- (void)redrawSectionFooters;
- (void)redrawSectionHeaders;
- (id)VKMTableCreateSearchBar;
@end



@interface DialogsController : VKMTableController
@end

@interface InputPanelView : UIToolbar
@end
@interface ExtraInputPanelView : InputPanelView
@end
@interface ChatController : VKMTableController
@property(retain, nonatomic) ExtraInputPanelView *inputPanel;
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

@interface Model : NSObject
@end
@interface MainModel : Model
@end


@interface VKPPBadge : UIImageView
@end




@interface VKUser : NSObject
@property(nonatomic) BOOL verified;
@property(retain, nonatomic) NSNumber *uid;
@end

@interface VKProfile : NSObject
@property(nonatomic) BOOL verified;
@property(retain, nonatomic) NSString *status;
@property(retain, nonatomic) VKUser *user; 
@end

