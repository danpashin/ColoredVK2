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

//@interface ChatController : UIViewController
//
//@property(retain, nonatomic) UIBarButtonItem *headerButtonItem;
//@property(retain, nonatomic) UIButton *editForward;
//@property(retain, nonatomic) UIButton *editDelete;
//@property(retain, nonatomic) UIView *editToolbar;
//
//@end


@interface TextKitLayer : CALayer
- (void)drawInContext:(struct CGContext *)arg1;
- (instancetype)init;
@property(retain, nonatomic) id text; // @synthesize text=_text;
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




