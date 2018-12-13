//
//  VKModels.h
//  ColoredVK2
//
//  Created by Даниил on 16.06.18.
//

@interface VKAudio : NSObject
@property (strong, nonatomic) NSNumber *lyrics_id;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *performer;
@end

@interface AudioPlayer : NSObject
@property (strong, nonatomic) VKAudio *audio;
@property (assign, nonatomic) NSInteger state;
@end

@interface VKImageVariant : NSObject
@property (assign, nonatomic) NSInteger type;
@property (strong, nonatomic) NSString *src; 
@end

@interface VKPhoto : NSObject
@property (strong, nonatomic) NSMutableDictionary <id, VKImageVariant *> *variants;
@end

@interface VKMBrowserTarget : NSObject
@property (strong, nonatomic) NSURL *url;
@end

@interface VKMessage : NSObject
@property (assign, nonatomic) BOOL read_state;
@property (assign, nonatomic) BOOL incoming;
@end

@interface VKDialog : NSObject
@property (strong, nonatomic) VKMessage *head;
@end

@interface VKUser : NSObject
@property (strong, nonatomic) NSNumber *uid;
@end

@interface VKProfile : NSObject
@property (strong, nonatomic) VKUser *user;
@end

@interface Renderer : NSObject
@property (strong, nonatomic) NSArray *views;
@end

@interface AudioRenderer : Renderer
@property (strong, nonatomic) UILabel *durationLabel;
@property (strong, nonatomic) UIButton *playIndicator;
@property (strong, nonatomic) AudioPlayer *player;
@end

@interface VKAudioQueuePlayer : NSObject
@property (assign, nonatomic) NSInteger state;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *performer;
@end

@interface ProfileModel : NSObject
@property (readonly, strong, nonatomic) VKProfile *item;
@property (strong, nonatomic) NSNumber *owner;
@end


@interface VKGroup : NSObject
@property (strong, nonatomic) NSNumber *gid;
@end

@interface VKGroupProfile : NSObject
@property (strong, nonatomic) VKGroup *group;
@end

@interface WallModeRenderer : Renderer
@end

@interface VKSearchBarConfig : NSObject
@property (strong, nonatomic) UIColor *segmentBorderColor;
@property (strong, nonatomic) UIColor *segmentTintColor;
@property (strong, nonatomic) UIColor *textfieldTextColor;
@property (strong, nonatomic) UIColor *textfieldTintColor; 
@property (strong, nonatomic) UIColor *textfieldBackgroundColor;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *placeholderBackgroundColor;
@property (strong, nonatomic) UIColor *placeholderTextColor;
@property (strong, nonatomic) UIColor *clearButtonColor;
@property (strong, nonatomic) UIColor *searchIconColor;
@property (strong, nonatomic) UIColor *cancelButtonTitleColor;
@end

@interface ArticleWebViewManager : NSObject
- (void)enableDarkMode:(BOOL)enableDarkMode;
@end

@interface MenuItem : NSObject
@property (copy, nonatomic, readonly) NSString *statId; 
- (instancetype)initWithType:(NSInteger)type imageName:(NSString *)imageName title:(NSString *)title statId:(NSString *)statId;
@end



@interface VAAppearance : NSObject
- (NSUInteger)style;
@end

@interface VKAppearance : VAAppearance
+ (id)staticColorWithIdentifier:(id)arg1;
+ (id)dynamicColorWithIdentifier:(id)arg1;
@end

@interface VAColor : UIColor
+ (id)tabbarInactiveIcon;
+ (id)tabbarActiveIcon;
+ (id)backgroundContent;
@end

@interface VATabbarItemButton : UIControl
@property(nonatomic) __weak UIView *customView;
@end



typedef NS_ENUM(NSInteger, VKPollBackgroundType) {
    VKPollBackgroundTypePreview,
    VKPollBackgroundTypeGradient,
    VKPollBackgroundTypeColor
};

@interface VKPollBackground : NSObject
@property (strong, nonatomic) UIColor *color;
@property (assign, nonatomic) VKPollBackgroundType type;
@end
