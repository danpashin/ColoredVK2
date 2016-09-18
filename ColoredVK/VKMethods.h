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





@interface InputPanelView : UIToolbar
@end
@interface ExtraInputPanelView : InputPanelView
@end
@interface ChatController : UIViewController
@property(retain, nonatomic) ExtraInputPanelView *inputPanel;
@end


//@interface VKRenderedText : NSObject
//@property(readwrite, copy, nonatomic) NSAttributedString *text;
//@end






@interface BlockActionController : UIAlertController
+ (id)actionSheetWithTitle:(NSString *)title;
- (void)showInViewController:(id)arg1;
- (void)addButtonWithTitle:(NSString *)title block:(id)arg2;
- (void)setCancelButtonWithTitle:(NSString *)title block:(id)arg2;
@end


@interface PhotoBrowserController : UIViewController
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
