//
//  TweakNightTheme.m
//  ColoredVK2
//
//  Created by Даниил on 12.12.17.
//

#import "Tweak.h"

CHDeclareClass(ProfileView);
CHDeclareMethod(0, void, ProfileView, layoutSubviews)
{
    CHSuper(0, ProfileView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("ProfileView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        self.blocksScroll.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareMethod(1, void, ProfileView, setButtonStatus, UIButton *, buttonStatus)
{
    if (enabled && enableNightTheme) {
        [buttonStatus setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateNormal];
        [buttonStatus setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateSelected];
        [buttonStatus setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateHighlighted];
        
        [buttonStatus setBackgroundImage:[[buttonStatus backgroundImageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                                forState:UIControlStateNormal];
        [buttonStatus setBackgroundImage:[[buttonStatus backgroundImageForState:UIControlStateSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                                forState:UIControlStateSelected];
        [buttonStatus setBackgroundImage:[[buttonStatus backgroundImageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                                forState:UIControlStateHighlighted];
        
        if (cvkMainController.nightThemeScheme.type == CVKNightThemeTypeBlack)
            buttonStatus.tintColor = cvkMainController.nightThemeScheme.backgroundColor;
        else
            buttonStatus.tintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
    }
    
    
    CHSuper(1, ProfileView, setButtonStatus, buttonStatus);
}

CHDeclareMethod(1, void, ProfileView, setButtonEdit, UIButton *, buttonEdit)
{
    if (enabled && enableNightTheme) {
        NIGHT_THEME_DISABLE_CUSTOMISATION(buttonEdit);
        NIGHT_THEME_DISABLE_CUSTOMISATION(buttonEdit.titleLabel);
        [buttonEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [buttonEdit setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateSelected];
        [buttonEdit setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateHighlighted];
        
        [buttonEdit setBackgroundImage:[[buttonEdit backgroundImageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                              forState:UIControlStateNormal];
        [buttonEdit setBackgroundImage:[[buttonEdit backgroundImageForState:UIControlStateSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                              forState:UIControlStateSelected];
        [buttonEdit setBackgroundImage:[[buttonEdit backgroundImageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                              forState:UIControlStateHighlighted];
        
        switch (cvkMainController.nightThemeScheme.type) {
            case CVKNightThemeTypeBlack:
                buttonEdit.tintColor = cvkMainController.nightThemeScheme.backgroundColor;
                break;
                
            case CVKNightThemeTypeCustom:
                buttonEdit.tintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
                break;
                
            default:
                buttonEdit.tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
                break;
        }
    }
    
    
    CHSuper(1, ProfileView, setButtonEdit, buttonEdit);
}

CHDeclareMethod(1, void, ProfileView, setButtonMessage, UIButton *, buttonMessage)
{
    if (enabled && enableNightTheme) {
        NIGHT_THEME_DISABLE_CUSTOMISATION(buttonMessage);
        NIGHT_THEME_DISABLE_CUSTOMISATION(buttonMessage.titleLabel);
        [buttonMessage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [buttonMessage setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateSelected];
        [buttonMessage setTitleColor:cvkMainController.nightThemeScheme.textColor forState:UIControlStateHighlighted];
        
        [buttonMessage setBackgroundImage:[[buttonMessage backgroundImageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                                 forState:UIControlStateNormal];
        [buttonMessage setBackgroundImage:[[buttonMessage backgroundImageForState:UIControlStateSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                                 forState:UIControlStateSelected];
        [buttonMessage setBackgroundImage:[[buttonMessage backgroundImageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] 
                                 forState:UIControlStateHighlighted];
        
        switch (cvkMainController.nightThemeScheme.type) {
            case CVKNightThemeTypeBlack:
                buttonMessage.tintColor = cvkMainController.nightThemeScheme.backgroundColor;
                break;
                
            case CVKNightThemeTypeCustom:
                buttonMessage.tintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
                break;
                
            default:
                buttonMessage.tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
                break;
        }
    }
    
    
    CHSuper(1, ProfileView, setButtonMessage, buttonMessage);
}


CHDeclareClass(NewsFeedPostAndStoryCreationButtonBar);
CHDeclareMethod(0, void, NewsFeedPostAndStoryCreationButtonBar, layoutSubviews)
{
    CHSuper(0, NewsFeedPostAndStoryCreationButtonBar, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("NewsFeedPostAndStoryCreationButtonBar")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(Node5TableViewCell);
CHDeclareMethod(0, void, Node5TableViewCell, layoutSubviews)
{
    CHSuper(0, Node5TableViewCell, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("Node5TableViewCell")]) {
        
        for (UIView *subview in  self.contentView.subviews) {
            subview.backgroundColor = [UIColor clearColor];
        }
    }
}

CHDeclareClass(Node5CollectionViewCell);
CHDeclareMethod(0, void, Node5CollectionViewCell, layoutSubviews)
{
    CHSuper(0, Node5CollectionViewCell, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("Node5CollectionViewCell")]) {
        
        if (self.contentView.subviews > 0) {
            for (UIView *subview in  self.contentView.subviews.firstObject.subviews) {
                if ([CLASS_NAME(subview) isEqualToString:@"UIImageView"]) {
                    subview.hidden = YES;
                }
            }
        }
    }
}

CHDeclareClass(InputPanelView);
CHDeclareMethod(0, void, InputPanelView, didMoveToSuperview)
{
    CHSuper(0, InputPanelView, didMoveToSuperview);
    
    [NSObject cvk_runBlockOnMainThread:^{
        if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("InputPanelView")]) {
            self.overlay.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            self.overlay.layer.borderColor = cvkMainController.nightThemeScheme.backgroundColor.CGColor;
        }
    }];
}

CHDeclareClass(AdminInputPanelView);
CHDeclareMethod(0, void, AdminInputPanelView, layoutSubviews)
{
    CHSuper(0, AdminInputPanelView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("AdminInputPanelView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        if ([self respondsToSelector:@selector(gapToolbar)])
            [self.gapToolbar setBackgroundImage:[UIImage cvk_imageWithColor:cvkMainController.nightThemeScheme.backgroundColor] 
                             forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
}

CHDeclareClass(PollAnswerButton);
CHDeclareMethod(0, void, PollAnswerButton, layoutSubviews)
{
    CHSuper(0, PollAnswerButton, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("PollAnswerButton")]) {
        
        BOOL shouldChange = YES;
        if ([self respondsToSelector:@selector(lightTheme)])
            shouldChange = !self.lightTheme;
        
        if (shouldChange) {
            self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            self.progressView.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        }
    }
}

CHDeclareClass(VKAPBottomToolbar);
CHDeclareMethod(0, void, VKAPBottomToolbar, layoutToolbarInSuperView)
{
    CHSuper(0, VKAPBottomToolbar, layoutToolbarInSuperView);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("VKAPBottomToolbar")]) {
        self.hostView.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
    }
}

CHDeclareClass(WallModeRenderer);
CHDeclareMethod(0, UIButton *, WallModeRenderer, buttonAll)
{
    UIButton *buttonAll = CHSuper(0, WallModeRenderer, buttonAll);
    
    if (enabled && enableNightTheme) {
        [buttonAll setTitleColor:cvkMainController.nightThemeScheme.textColor forState:buttonAll.state];
        
        UIImage *selectedImage = [[buttonAll backgroundImageForState:UIControlStateSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [buttonAll setBackgroundImage:selectedImage forState:UIControlStateSelected];
        buttonAll.tintColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
    
    return buttonAll;
}

CHDeclareMethod(0, UIButton *, WallModeRenderer, buttonFilter)
{
    UIButton *buttonFilter = CHSuper(0, WallModeRenderer, buttonFilter);
    
    if (enabled && enableNightTheme) {
        [buttonFilter setTitleColor:cvkMainController.nightThemeScheme.textColor forState:buttonFilter.state];
        
        UIImage *selectedImage = [[buttonFilter backgroundImageForState:UIControlStateSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [buttonFilter setBackgroundImage:selectedImage forState:UIControlStateSelected];
        buttonFilter.tintColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
    
    return buttonFilter;
}


CHDeclareClass(SeparatorWithBorders);
CHDeclareMethod(0, void, SeparatorWithBorders, layoutSubviews)
{
    CHSuper(0, SeparatorWithBorders, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("SeparatorWithBorders")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        self.borderColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
}

CHDeclareClass(Component5HostView);
CHDeclareMethod(0, void, Component5HostView, layoutSubviews)
{
    CHSuper(0, Component5HostView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("Component5HostView")]) {
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(LookupAddressBookFriendsViewController);
CHDeclareMethod(0, void, LookupAddressBookFriendsViewController, viewDidLoad)
{
    CHSuper(0, LookupAddressBookFriendsViewController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        [NSObject cvk_runBlockOnMainThread:^{
            for (UIView *subview in self.lookupTeaserViewController.componentView.subviews) {
                subview.backgroundColor = [UIColor clearColor];
            }
        }];
    }
}

CHDeclareClass(MessageController);
CHDeclareMethod(0, void, MessageController, viewDidLoad)
{
    CHSuper(0, MessageController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
}

CHDeclareClass(ProductMarketCellForProfileGallery);
CHDeclareMethod(0, void, ProductMarketCellForProfileGallery, layoutSubviews)
{
    CHSuper(0, ProductMarketCellForProfileGallery, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("ProductMarketCellForProfileGallery")]) {
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(MarketGalleryDecoration);
CHDeclareMethod(0, void, MarketGalleryDecoration, layoutSubviews)
{
    CHSuper(0, MarketGalleryDecoration, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("MarketGalleryDecoration")]) {
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(StoreStockItemView);
CHDeclareMethod(0, void, StoreStockItemView, layoutSubviews)
{
    CHSuper(0, StoreStockItemView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("StoreStockItemView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(VKPhotoPicker);
CHDeclareMethod(0, void, VKPhotoPicker, viewDidLoad)
{
    CHSuper(0, VKPhotoPicker, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.pickerToolbar.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        self.pickerToolbar.bg.hidden = YES;
    }
}

CHDeclareClass(MainMenuPlayer);
CHDeclareMethod(0, void, MainMenuPlayer, highlightUpdated)
{
    CHSuper(0, MainMenuPlayer, highlightUpdated);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("MainMenuPlayer")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        if ([self respondsToSelector:@selector(titleLabel)]) {
            self.titleLabel.textColor = cvkMainController.nightThemeScheme.textColor;
        }
        if ([self respondsToSelector:@selector(playerTitle)]) {
            self.playerTitle.textColor = cvkMainController.nightThemeScheme.textColor;
        }
        
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:[UIToolbar class]]) {
                subview.hidden = YES;
            }
        }
    }
}

CHDeclareClass(VKMTableViewSearchHeaderView);
CHDeclareMethod(1, VKMTableViewSearchHeaderView*, VKMTableViewSearchHeaderView, initWithFrame, CGRect, frame)
{
    VKMTableViewSearchHeaderView *headerView = CHSuper(1, VKMTableViewSearchHeaderView, initWithFrame, frame);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("VKMTableViewSearchHeaderView")]) {
        [self setBackgroundImage:[UIImage cvk_imageWithColor:cvkMainController.nightThemeScheme.foregroundColor] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
    
    return headerView;
}

CHDeclareClass(VKMNavigationController);
CHDeclareMethod(0, void, VKMNavigationController, viewDidLoad)
{
    CHSuper(0, VKMNavigationController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
    }
}

CHDeclareClass(PersistentBackgroundColorView);
CHDeclareMethod(0, void, PersistentBackgroundColorView, layoutSubviews)
{
    CHSuper(0, PersistentBackgroundColorView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("PersistentBackgroundColorView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        self.persistentBackgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
}

CHDeclareClass(GiftSendController);
CHDeclareMethod(1, void, GiftSendController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, GiftSendController, viewWillAppear, animated);
    self.sendFooterView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
}

CHDeclareMethod(2, UITableViewCell*, GiftSendController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, GiftSendController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("GiftSendController")]) {
        cell.contentView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
    return cell;
}

CHDeclareClass(GiftsCatalogController);
CHDeclareMethod(2, UITableViewCell*, GiftsCatalogController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, GiftsCatalogController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("GiftsCatalogController")]) {
        cell.contentView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
    return cell;
}

CHDeclareClass(DefaultHighlightButton);
CHDeclareMethod(0, void, DefaultHighlightButton, layoutSubviews)
{
    CHSuper(0, DefaultHighlightButton, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("DefaultHighlightButton")]) {
        [NSObject cvk_runBlockOnMainThread:^{
            NIGHT_THEME_DISABLE_CUSTOMISATION(self);
            NIGHT_THEME_DISABLE_CUSTOMISATION(self.titleLabel);
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            if ([CLASS_NAME(self.superview) isEqualToString:@"UIView"])
                self.superview.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        }];
    }
}

CHDeclareClass(StoreController);
CHDeclareMethod(0, void, StoreController, viewDidLoad)
{
    CHSuper(0, StoreController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        [self.toolbar setBackgroundImage:[UIImage cvk_imageWithColor:cvkMainController.nightThemeScheme.foregroundColor] 
                      forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
}

CHDeclareClass(DiscoverLayoutMask);
CHDeclareMethod(0, void, DiscoverLayoutMask, layoutSubviews)
{
    CHSuper(0, DiscoverLayoutMask, layoutSubviews);
    
    self.hidden = (enabled && enableNightTheme);
}

CHDeclareClass(DiscoverLayoutShadow);
CHDeclareMethod(0, void, DiscoverLayoutShadow, layoutSubviews)
{
    CHSuper(0, DiscoverLayoutShadow, layoutSubviews);
    
    self.hidden = (enabled && enableNightTheme);
}

CHDeclareClass(VKP2PDetailedView);
CHDeclareMethod(0, void, VKP2PDetailedView, layoutSubviews)
{
    CHSuper(0, VKP2PDetailedView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("VKP2PDetailedView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(NewDialogCell);
CHDeclareMethod(0, void, NewDialogCell, layoutSubviews)
{
    CHSuper(0, NewDialogCell, layoutSubviews);
    setupNewDialogCellForNightTheme(self);
}

CHDeclareMethod(0, void, NewDialogCell, prepareForReuse)
{
    setupNewDialogCellForNightTheme(self);
    CHSuper(0, NewDialogCell, prepareForReuse);
}


CHDeclareClass(FreshNewsButton);
CHDeclareMethod(1, id, FreshNewsButton, initWithFrame, CGRect, frame)
{
    FreshNewsButton *button = CHSuper(1, FreshNewsButton, initWithFrame, frame);
    NIGHT_THEME_DISABLE_CUSTOMISATION(self.button);
    
    __weak typeof(button) weakButton = button;
    [[NSNotificationCenter defaultCenter] addObserverForName:kPackageNotificationReloadInternalPrefs object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if (!weakButton)
            return;
        
        if (enabled && enableNightTheme) {
            UIImage *newBackground = [[weakButton.button backgroundImageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [weakButton.button setBackgroundImage:newBackground forState:UIControlStateNormal];
            weakButton.button.imageView.tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
        } else {
            weakButton.button.imageView.tintColor = kVKMainColor;
        }
    }];
    
    return button;
}

CHDeclareClass(TouchHighlightControl);
CHDeclareMethod(1, id, TouchHighlightControl, initWithFrame, CGRect, frame)
{
    TouchHighlightControl *control = CHSuper(1, TouchHighlightControl, initWithFrame, frame);
    
    if (enabled && enableNightTheme) {
        [NSObject cvk_runBlockOnMainThread:^{
            for (UIView *subview in control.subviews) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    if ([imageView.image.imageAsset.assetName containsString:@"post/settings"]) {
                        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        imageView.tintColor = cvkMainController.nightThemeScheme.textColor;
                    }
                }
            }
        }];
    }
    
    return control;
}

CHDeclareClass(CommentSourcePickerController);
CHDeclareMethod(0, void, CommentSourcePickerController, viewDidLayoutSubviews)
{
    CHSuper(0, CommentSourcePickerController, viewDidLayoutSubviews);
    
    if (enabled && enableNightTheme && [self respondsToSelector:@selector(containerView)]) {
        if (self.containerView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.containerView.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            });
        }
    }
}

CHDeclareClass(NewsFeedPostCreationButton);
CHDeclareMethod(2, void, NewsFeedPostCreationButton, setBackgroundColor, UIColor *, color, forState, UIControlState, state)
{
    if (enabled && enableNightTheme) {
        if (state == UIControlStateNormal)
            color = cvkMainController.nightThemeScheme.foregroundColor;
        else if (state == UIControlStateHighlighted)
            color = cvkMainController.nightThemeScheme.backgroundColor;
    }
    
    CHSuper(2, NewsFeedPostCreationButton, setBackgroundColor, color, forState, state);
}

CHDeclareClass(LandingPageController);
CHDeclareMethod(0, void, LandingPageController, viewDidLoad)
{
    CHSuper(0, LandingPageController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        
        for (UIView *subview in self.view.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                [button setBackgroundImage:[[button backgroundImageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                [button setBackgroundImage:[[button backgroundImageForState:UIControlStateHighlighted] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateHighlighted];
                button.tintColor = cvkMainController.nightThemeScheme.foregroundColor;
            }
        }
    }
}

CHDeclareClass(SketchViewController);
CHDeclareMethod(0, void, SketchViewController, viewDidLoad)
{
    CHSuper(0, SketchViewController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        if ([self respondsToSelector:@selector(drawView)])
            self.drawView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        
        for (UIView *subview in self.view.subviews) {
            if ([CLASS_NAME(subview) isEqualToString:@"UIView"]) {
                subview.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
            }
        }
    }
}

CHDeclareClass(SketchController);
CHDeclareMethod(0, void, SketchController, viewDidLoad)
{
    CHSuper(0, SketchController, viewDidLoad);
    
    if (enabled && enableNightTheme && [self respondsToSelector:@selector(sketchView)]) {
        self.sketchView.drawView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        self.sketchView.colorPaletteView.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        self.sketchView.colorPaletteView.collectionView.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        self.sketchView.backgroundColor = [UIColor redColor];
        
        for (UIView *subview in self.sketchView.subviews) {
            if ([subview isKindOfClass:[UIToolbar class]]) {
                UIToolbar *toolbar = (UIToolbar *)subview;
                [toolbar setBackgroundImage:[UIImage cvk_imageWithColor:cvkMainController.nightThemeScheme.navbackgroundColor] 
                         forToolbarPosition:UIBarPositionAny 
                                 barMetrics:UIBarMetricsDefault];
            }
        }
    }
}

CHDeclareClass(EmojiSelectionView);
CHDeclareMethod(0, void, EmojiSelectionView, layoutSubviews)
{
    CHSuper(0, EmojiSelectionView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("EmojiSelectionView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(LicensesViewController);
CHDeclareMethod(0, void, LicensesViewController, viewDidLoad)
{
    CHSuper(0, LicensesViewController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
}

CHDeclareClass(VKAudioPlayerViewController);
CHDeclareMethod(0, UIStatusBarStyle, VKAudioPlayerViewController, preferredStatusBarStyle)
{
    if (enabled && (enableNightTheme))
        return UIStatusBarStyleLightContent;
    
    return CHSuper(0, VKAudioPlayerViewController, preferredStatusBarStyle);
}

CHDeclareMethod(0, void, VKAudioPlayerViewController, viewDidLoad)
{
    CHSuper(0, VKAudioPlayerViewController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        self.pageController.view.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        self.backgroundView.hidden = YES;
        
        UIView *effectView = [[UIView alloc] initWithFrame:self.toolbarView.bounds];
        effectView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.toolbarView.contentView addSubview:effectView];
        [self.toolbarView.contentView sendSubviewToBack:effectView];
        
        for (UIView *subview in self.view.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                subview.hidden = YES;
            }
        }
    }
}

CHDeclareClass(PopupWindowView);
CHDeclareMethod(0, UIView *, PopupWindowView, contentView)
{
    UIView *contentView = CHSuper(0, PopupWindowView, contentView);
    
    if (enabled && enableNightTheme) {
        contentView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
    
    return contentView;
}

CHDeclareClass(VKAudioPlayerControlsViewController);
CHDeclareMethod(0, void, VKAudioPlayerControlsViewController, viewDidLoad)
{
    CHSuper(0, VKAudioPlayerControlsViewController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        objc_setAssociatedObject(self.pp,   "shouldChangeImageColor", @1, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(self.prev, "shouldChangeImageColor", @1, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(self.next, "shouldChangeImageColor", @1, OBJC_ASSOCIATION_ASSIGN);
    }
}

CHDeclareClass(MasksController);
CHDeclareMethod(0, void, MasksController, viewDidLoad)
{
    CHSuper(0, MasksController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        objc_setAssociatedObject(self.collectionView, "shouldDisableBackgroundColor", @1, OBJC_ASSOCIATION_ASSIGN);
    }
}

CHDeclareMethod(2, UICollectionViewCell *, MasksController, collectionView, UICollectionView *, collectionView, cellForItemAtIndexPath, NSIndexPath *, indexPath)
{
    UICollectionViewCell *cell = CHSuper(2, MasksController, collectionView, collectionView, cellForItemAtIndexPath, indexPath);
    objc_setAssociatedObject(cell, "shouldDisableBackgroundColor", @1, OBJC_ASSOCIATION_ASSIGN);
    return cell;
}

CHDeclareClass(VKPPNoAccessView);
CHDeclareMethod(0, void, VKPPNoAccessView, layoutSubviews)
{
    CHSuper(0, VKPPNoAccessView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("VKPPNoAccessView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(VKSearchScrollTopBackgroundView);
CHDeclareMethod(0, void, VKSearchScrollTopBackgroundView, layoutSubviews)
{
    CHSuper(0, VKSearchScrollTopBackgroundView, layoutSubviews);
    
    if (enabled && [self isKindOfClass:objc_lookUpClass("VKSearchScrollTopBackgroundView")]) {
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(SendMessagePopupView);
CHDeclareMethod(0, void, SendMessagePopupView, layoutSubviews)
{
    CHSuper(0, SendMessagePopupView, layoutSubviews);
    
    if (enabled && enableNightTheme) {
        self.backgroundImageView.image = [self.backgroundImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.backgroundImageView.tintColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(StoryEditorSendViewController);
CHDeclareMethod(0, void, StoryEditorSendViewController, viewWillLayoutSubviews)
{
    CHSuper(0, StoryEditorSendViewController, viewWillLayoutSubviews);
    
    if (enabled && enableNightTheme) {
        self.sendButton.superview.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
    }
}

CHDeclareClass(StoryRepliesController);
CHDeclareMethod(0, void, StoryRepliesController, viewWillLayoutSubviews)
{
    CHSuper(0, StoryRepliesController, viewWillLayoutSubviews);
    
    if (enabled && enableNightTheme) {
        void (^changeBlock)(void) = ^(void){
            self.containerView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        };
        changeBlock();
        dispatch_async(dispatch_get_main_queue(), changeBlock);
    }
}

CHDeclareClass(StoryRepliesTipController);
CHDeclareMethod(0, void, StoryRepliesTipController, viewWillLayoutSubviews)
{
    CHSuper(0, StoryRepliesTipController, viewWillLayoutSubviews);
    
    if (enabled && enableNightTheme) {
        void (^changeBlock)(void) = ^(void){
            self.container.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        };
        changeBlock();
        dispatch_async(dispatch_get_main_queue(), changeBlock);
    }
}

CHDeclareClass(CameraCaptureButtonTip);
CHDeclareMethod(0, id, CameraCaptureButtonTip, init)
{
    CameraCaptureButtonTip *tip = CHSuper(0, CameraCaptureButtonTip, init);
    if (tip && enabled && enableNightTheme) {
        for (UIView *subview in tip.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView = (UIImageView *)subview;
                imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                imageView.tintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
            }
        }
    }
    return tip;
}

CHDeclareClass(InputPanelViewTextView);
CHDeclareMethod(0, void, InputPanelViewTextView, layoutSubviews)
{
    CHSuper(0, InputPanelViewTextView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("InputPanelViewTextView")]) {
        NIGHT_THEME_DISABLE_CUSTOMISATION(self.placeholderLabel);
        self.placeholderLabel.textColor = cvkMainController.nightThemeScheme.detailTextColor;
        self.layer.borderColor = cvkMainController.nightThemeScheme.backgroundColor.CGColor;
    }
}

CHDeclareClass(VKProfileInfoItem);
CHDeclareMethod(1, void, VKProfileInfoItem, setValue, NSAttributedString *, value)
{
    NSMutableAttributedString *mutableValue = [value mutableCopy];
    [mutableValue addAttribute:@"CVKDetailed" value:@1 range:NSMakeRange(0, mutableValue.length)];
    CHSuper(1, VKProfileInfoItem, setValue, mutableValue);
}

CHDeclareClass(_TtC3vkm17MessageController);
CHDeclareMethod(1, void, _TtC3vkm17MessageController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, _TtC3vkm17MessageController, viewWillAppear, animated);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(BKPasscodeViewController);
CHDeclareMethod(1, void, BKPasscodeViewController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, BKPasscodeViewController, viewWillAppear, animated);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(PopupIntroView);
CHDeclareMethod(0, void, PopupIntroView, layoutSubviews)
{
    CHSuper(0, PopupIntroView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("PopupIntroView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(MBProgressHUDBackgroundLayer);
CHDeclareMethod(1, void, MBProgressHUDBackgroundLayer, drawInContext, CGContextRef, context)
{
    if (enabled && enableNightTheme) {
        self.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor.CGColor;
        self.cornerRadius = 20.0f;
    } else {
        CHSuper(1, MBProgressHUDBackgroundLayer, drawInContext, context);
    }
}

CHDeclareClass(ArticlePageController);
CHDeclareMethod(1, void, ArticlePageController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, ArticlePageController, viewWillAppear, animated);
    
    if (enabled && enableNightTheme) {
        [self.webViewManager enableDarkMode:YES];
    }
}

CHDeclareMethod(2, void, ArticlePageController, articlePageModel, id, model, didToggleToDarkMode, BOOL, enableDarkMode)
{
    enableDarkMode = (enabled && enableNightTheme) ? YES : enableDarkMode;
    CHSuper(2, ArticlePageController, articlePageModel, model, didToggleToDarkMode, enableDarkMode);
}

CHDeclareClass(ArticleWebViewManager);
CHDeclareMethod(1, void, ArticleWebViewManager, setReady, BOOL, ready)
{
    CHSuper(1, ArticleWebViewManager, setReady, ready);
    
    if (enabled && enableNightTheme) {
        [self enableDarkMode:YES];
    }
}

CHDeclareMethod(1, void, ArticleWebViewManager, enableDarkMode, BOOL, enableDarkMode)
{
    enableDarkMode = (enabled && enableNightTheme) ? YES : enableDarkMode;
    CHSuper(1, ArticleWebViewManager, enableDarkMode, enableDarkMode);
}


CHDeclareClass(PostingComposePanel);
CHDeclareMethod(0, void, PostingComposePanel, layoutSubviews)
{
    CHSuper(0, PostingComposePanel, layoutSubviews);
    
    if (enabled && enableNightTheme) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(VKReusableButtonView);
CHDeclareMethod(0, void, VKReusableButtonView, layoutSubviews)
{
    CHSuper(0, VKReusableButtonView, layoutSubviews);
    
    if (enabled && enableNightTheme) {
        NIGHT_THEME_DISABLE_CUSTOMISATION(self.titleLabel);
        NIGHT_THEME_DISABLE_CUSTOMISATION(self);
        self.highlightBackgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
}

CHDeclareMethod(1, void, VKReusableButtonView, setBackgroundColor, UIColor *, color)
{
    if (enabled && enableNightTheme) {
        CGFloat blue = 0;
        [color getRed:nil green:nil blue:&blue alpha:nil];
        if (blue >= 0.7f && blue < 0.8f) {
            color = cvkMainController.nightThemeScheme.navbackgroundColor;
        } else {
            color = cvkMainController.nightThemeScheme.foregroundColor;
        }
    }
    
    CHSuper(1, VKReusableButtonView, setBackgroundColor, color);
}

CHDeclareClass(VKSegmentedControl);
CHDeclareMethod(0, void, VKSegmentedControl, layoutSubviews)
{
    CHSuper(0, VKSegmentedControl, layoutSubviews);
    
    if (enabled && enableNightTheme) {
        if ([self.superview isKindOfClass:[UINavigationBar class]] || [self.superview.superview isKindOfClass:[UINavigationBar class]])
            self.tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
        else
            self.tintColor = cvkMainController.nightThemeScheme.buttonColor;
        
        if ([self respondsToSelector:@selector(collectionView)])
            objc_setAssociatedObject(self.collectionView, "shouldDisableBackgroundColor", @1, OBJC_ASSOCIATION_ASSIGN);
    }
}

CHDeclareClass(VKSearchBar);
CHDeclareClassMethod(0, VKSearchBarConfig *, VKSearchBar, grayConfig)
{
    VKSearchBarConfig *config = CHSuper(0, VKSearchBar, grayConfig);
    if (enabled && enableNightTheme) {
        config.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        config.textfieldBackgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
    }
    return config;
}

CHDeclareClassMethod(0, VKSearchBarConfig *, VKSearchBar, navigationBlueConfig)
{
    VKSearchBarConfig *config = CHSuper(0, VKSearchBar, navigationBlueConfig);
    if (enabled && enableNightTheme) {
        config.textfieldBackgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        config.cancelButtonTitleColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
        config.searchIconColor = cvkMainController.nightThemeScheme.textColor;
        config.clearButtonColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
    } else if (enabled && enabledBarColor) {
        config.textfieldBackgroundColor = barBackgroundColor.cvk_darkerColor;
        config.placeholderTextColor = barForegroundColor;
        config.searchIconColor = barForegroundColor;
        config.clearButtonColor = barForegroundColor;
    }
    return config;
}

CHDeclareClass(LoadingFooterView);
CHDeclareMethod(0, void, LoadingFooterView, layoutSubviews)
{
    CHSuper(0, LoadingFooterView, layoutSubviews);
    
    if (enabled && enableNightTheme) {
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(VKP2PSendViewController);
CHDeclareMethod(1, void, VKP2PSendViewController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKP2PSendViewController, viewWillAppear, animated);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        self.bubble.image = [self.bubble.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.bubble.tintColor = cvkMainController.nightThemeScheme.incomingBackgroundColor;
        for (UIView *subview in self.sendButton.superview.subviews) {
                subview.backgroundColor = self.view.backgroundColor;
        }
    }
}

CHDeclareClass(PaymentsPopupView);
CHDeclareMethod(0, void, PaymentsPopupView, layoutSubviews)
{
    CHSuper(0, PaymentsPopupView, layoutSubviews);
    
    if (enabled && enableNightTheme) {
        self.topToolbar.barTintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
    }
}

CHDeclareClass(VideoThumbnailView);
CHDeclareMethod(1, void, VideoThumbnailView, setLabel, UILabel *, label)
{
    NIGHT_THEME_DISABLE_CUSTOMISATION(label);
    CHSuper(1, VideoThumbnailView, setLabel, label);
}


CHDeclareClass(PollEditTextCell);
CHDeclareMethod(0, void, PollEditTextCell, layoutSubviews)
{
    if (enabled && enableNightTheme) {
        self.backgroundView.tintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
    }
    
    CHSuper(0, PollEditTextCell, layoutSubviews);
}

CHDeclareMethod(1, UIImage *, PollEditTextCell, inputImageSelected, BOOL, selected)
{
    UIImage *image = CHSuper(1, PollEditTextCell, inputImageSelected, selected);
    if (enabled && enableNightTheme) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    return image;
}

CHDeclareClass(PollEditSelectionCell);
CHDeclareMethod(0, void, PollEditSelectionCell, layoutSubviews)
{
    if (enabled && enableNightTheme && [self.backgroundView isKindOfClass:[UIImageView class]]) {
        self.backgroundView.tintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
    }
    
    CHSuper(0, PollEditSelectionCell, layoutSubviews);
}

CHDeclareClassMethod(1, UIImage *, PollEditSelectionCell, backgroundImage, BOOL, selected)
{
    UIImage *image = CHSuper(1, PollEditSelectionCell, backgroundImage, selected);
    if (enabled && enableNightTheme) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    return image;
}

CHDeclareClassMethod(0, UIImage *, PollEditSelectionCell, highlightedImage)
{
    UIImage *image = CHSuper(0, PollEditSelectionCell, highlightedImage);
    if (enabled && enableNightTheme) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    return image;
}

CHDeclareClass(VKDatePickerController);
CHDeclareMethod(1, void, VKDatePickerController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKDatePickerController, viewWillAppear, animated);
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(VKReusableColorView);
CHDeclareMethod(0, void, VKReusableColorView, layoutSubviews)
{
    CHSuper(0, VKReusableColorView, layoutSubviews);
    if (enabled && enableNightTheme) {
        self.backgroundColor = self.superview.backgroundColor;
    }
}

CHDeclareClass(_TtC3vkm19PinnedMessageButton);
CHDeclareMethod(0, void, _TtC3vkm19PinnedMessageButton, layoutSubviews)
{
    CHSuper(0, _TtC3vkm19PinnedMessageButton, layoutSubviews);
    
    if (enabled && enableNightTheme) {
        self.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
    }
}

CHDeclareClass(VKAPPollViewController);
CHDeclareMethod(1, void, VKAPPollViewController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, VKAPPollViewController, viewWillAppear, animated);
    
    if (enabled && enableNightTheme) {
        self.view.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(_TtC3vkm20BotKeyboardInputView);
CHDeclareMethod(0, void, _TtC3vkm20BotKeyboardInputView, layoutSubviews)
{
    CHSuper(0, _TtC3vkm20BotKeyboardInputView, layoutSubviews);
    
    if (enabled && enableNightTheme) {
        self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
}

CHDeclareClass(VKMGradientView);
CHDeclareMethod(0, void, VKMGradientView, layoutSubviews)
{
    CHSuper(0, VKMGradientView, layoutSubviews);
    
    if (enabled && enableNightTheme) {
        self.hidden = YES;
    }
}


CHDeclareClass(ChatController);
CHDeclareMethod(1, void, ChatController, actionHistoryEdit, id, arg1)
{
    CHSuper(1, ChatController, actionHistoryEdit, arg1);
    
    if (enabled && enableNightTheme) {
        self.inputPanel.textPanel.textColor = cvkMainController.nightThemeScheme.textColor;
    }
}
