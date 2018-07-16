//
//  SystemClasses.h
//  ColoredVK2
//
//  Created by Даниил on 16.06.18.
//

@import MediaPlayer.MPVolumeView;


@interface UIView ()
@property (copy, nonatomic, readonly) NSString *recursiveDescription;
@end

@interface UIStatusBar : UIView
@property (nonatomic, strong) UIColor *foregroundColor;
@end

@interface UINavigationBar ()
@property (nonatomic, readonly, strong) UIView *_backgroundView;
@end

@interface UISearchBarTextField : UITextField
@end

@interface UISearchBar ()
@property (getter=_searchBarTextField, nonatomic, readonly) UISearchBarTextField *searchBarTextField;
@property (nonatomic, readonly, strong) UIView *_scopeBarBackgroundView;
@property (nonatomic, readonly, strong) UIView *_backgroundView;
@end

@interface UIToolbar ()
@property (setter=_setBackgroundView:, nonatomic, strong) UIView *_backgroundView;
@end

@interface UITabBar ()
@property (nonatomic, readonly, strong) UIView *_backgroundView;
@end

@interface UIImageAsset ()
@property (nonatomic, copy) NSString *assetName;
@end

@interface MPVolumeSlider : UISlider
@end

@interface MPVolumeView ()
@property (nonatomic, readonly) MPVolumeSlider *volumeSlider;
@end

@interface _UIAlertControlleriOSActionSheetCancelBackgroundView : UIView
@end

@interface _UIAlertControllerActionView : UIView
@end

@interface _UIAlertControllerTextFieldViewController : UICollectionViewController
@end

@interface UITableViewIndex : UIControl
@property (strong, nonatomic) UIColor *indexBackgroundColor;
@end

@interface _UITableViewHeaderFooterContentView : UIView
@end

@interface _UIVisualEffectSubview : UIView
@end

@interface _UIBackdropEffectView : UIView
@property (strong, nonatomic) CALayer *backdropLayer;
@end

@interface _UIPageViewControllerContentView : UIView
@end
