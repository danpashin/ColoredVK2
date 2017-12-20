//
//  TweakNightTheme.m
//  ColoredVK2
//
//  Created by Даниил on 12.12.17.
//

#import "Tweak.h"


CHDeclareClass(VKRenderedText);
CHDeclareClassMethod(2, id, VKRenderedText, renderedText, NSAttributedString *, text, withSettings, id, withSettings)
{
    NSAttributedString *newText = attributedStringForNightTheme(text);
    return CHSuper(2, VKRenderedText, renderedText, newText, withSettings, withSettings);
}


CHDeclareClass(MOCTRender);
CHDeclareClassMethod(2, id, MOCTRender, render, NSAttributedString *, text, width, double, width)
{
    NSAttributedString *newText = attributedStringForNightTheme(text);
    return CHSuper(2, MOCTRender, render, newText, width, width);
}

CHDeclareClass(VKMLabelRender);
CHDeclareClassMethod(4, id, VKMLabelRender, renderForText, NSString *, text, attributes, NSDictionary*, attributes, width, double, width, height, double, height)
{
    NSMutableDictionary *mutableAttributes = [attributes mutableCopy];
    
    if (mutableAttributes[@"CTForegroundColor"]) {
        if (!mutableAttributes[NSLinkAttributeName])
            mutableAttributes[@"CTForegroundColor"] = cvkMainController.nightThemeScheme.textColor;
        else
            mutableAttributes[@"CTForegroundColor"] = cvkMainController.nightThemeScheme.linkTextColor;
    }
    
    return CHSuper(4, VKMLabelRender, renderForText, text, attributes, mutableAttributes, width, width, height, height);
}

CHDeclareClass(ProfileView);
CHDeclareMethod(0, void, ProfileView, layoutSubviews)
{
    CHSuper(0, ProfileView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"ProfileView")]) {
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
        objc_setAssociatedObject(buttonEdit, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(buttonEdit.titleLabel, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
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
        objc_setAssociatedObject(buttonMessage, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
        objc_setAssociatedObject(buttonMessage.titleLabel, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
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


CHDeclareClass(UITableViewCell);
CHDeclareMethod(0, void, UITableViewCell, layoutSubviews)
{
    CHSuper(0, UITableViewCell, layoutSubviews);
    
    if ([self isKindOfClass:[PSTableCell class]]) {
        if ([((PSTableCell *)self).cellTarget isKindOfClass:[ColoredVKPrefs class]])
            return;
    }
    if ([self isKindOfClass:NSClassFromString(@"MessageCell")])
        return;
    
    if ([self isKindOfClass:[UITableViewCell class]]) {
        if ((self.textLabel.textAlignment == NSTextAlignmentCenter) && [CLASS_NAME(self) isEqualToString:@"UITableViewCell"])
            self.backgroundColor = [UIColor clearColor];
        else {
            if (enabled && enableNightTheme)
                self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        }
        
        if (enabled && enableNightTheme) {
            self.textLabel.textColor = cvkMainController.nightThemeScheme.textColor;
            self.textLabel.backgroundColor = [UIColor clearColor];
            
            if (self.detailTextLabel) {
                objc_setAssociatedObject(self.detailTextLabel, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
                self.detailTextLabel.textColor = cvkMainController.nightThemeScheme.detailTextColor;
                self.detailTextLabel.backgroundColor = [UIColor clearColor];
            }
            
            if ([self isKindOfClass:NSClassFromString(@"GroupCell")]) {
                GroupCell *groupCell = (GroupCell *)self;
                if (groupCell.status) {
                    objc_setAssociatedObject(groupCell.status, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
                    groupCell.status.textColor = cvkMainController.nightThemeScheme.detailTextColor;
                    groupCell.status.backgroundColor = [UIColor clearColor];
                }
            }
            
            if ([self isKindOfClass:NSClassFromString(@"VKMRendererCell")]) {
                VKMRendererCell *rendererCell = (VKMRendererCell *)self;
                if ([rendererCell.renderer isKindOfClass:NSClassFromString(@"CommentRenderer")]) {
                    BOOL firstLabelFound = NO;
                    for (UIView *subview in rendererCell.renderer.views) {
                        if ([subview isKindOfClass:[UILabel class]]) {
                            UILabel *label = (UILabel *)subview;
                            objc_setAssociatedObject(label, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
                            label.textColor = firstLabelFound ? cvkMainController.nightThemeScheme.detailTextColor : cvkMainController.nightThemeScheme.linkTextColor;
                            label.backgroundColor = [UIColor clearColor];
                            firstLabelFound = YES;
                        }
                    }
                }
            }
            
            
        }
    }
}

CHDeclareMethod(1, void, UITableViewCell, setSelectedBackgroundView, UIView *, view)
{
    if (enabled && enableNightTheme) {
        view.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
    CHSuper(1, UITableViewCell, setSelectedBackgroundView, view);
}


CHDeclareClass(UIButton);
CHDeclareMethod(0, void, UIButton, layoutSubviews)
{
    CHSuper(0, UIButton, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:[UIButton class]]) {
        NSNumber *should_customize = objc_getAssociatedObject(self, "should_customize");
        if (!should_customize)
            should_customize = @YES;
        
        if (!should_customize.boolValue)
            return;
        
        if (![self isKindOfClass:NSClassFromString(@"VKMImageButton")] && ![self isKindOfClass:NSClassFromString(@"HighlightableButton")] && ![self isKindOfClass:NSClassFromString(@"LinkButton")] && ![self isKindOfClass:NSClassFromString(@"BorderButton")]) {
            if ([CLASS_NAME(self) containsString:@"UINavigation"] || [CLASS_NAME(self.superview) containsString:@"UINavigation"])
                [self setTitleColor:cvkMainController.nightThemeScheme.buttonSelectedColor forState:UIControlStateNormal];
            else {
                [self setTitleColor:cvkMainController.nightThemeScheme.detailTextColor forState:UIControlStateNormal];
            }
            
            NSNumber *changeImageColor = objc_getAssociatedObject(self, "shouldChangeImageColor");
            if (!changeImageColor)
                changeImageColor = @NO;
            
            NSArray <NSString *> *namesToExclude = @[@"attachments/remove", @"search/clear"];
            if (![namesToExclude containsObject:[self imageForState:UIControlStateNormal].imageAsset.assetName] || changeImageColor.boolValue) {
                if ((CGRectGetWidth(self.imageView.frame) <= 40.0f && CGRectGetHeight(self.imageView.frame) <= 40.0f) || changeImageColor.boolValue) {
                    [self setImage:[[self imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                    self.imageView.tintColor = cvkMainController.nightThemeScheme.buttonColor;
                }
            }
        }
    }
}

CHDeclareClass(UISegmentedControl);
CHDeclareMethod(0, void, UISegmentedControl, layoutSubviews)
{
    CHSuper(0, UISegmentedControl, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"UISegmentedControl")]) {
        self.tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(UILabel);
CHDeclareMethod(0, void, UILabel, layoutSubviews)
{
    CHSuper(0, UILabel, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"UILabel")] && ![CLASS_NAME(self.superview) isEqualToString:@"HighlightableButton"] && ![CLASS_NAME(self.superview) isEqualToString:@"VKPPBadge"]) {
        
        NSNumber *should_customize = objc_getAssociatedObject(self, "should_customize");
        if (!should_customize)
            should_customize = @YES;
        
        if (!should_customize.boolValue)
            return;
        
        if ([self isKindOfClass:NSClassFromString(@"HighlightableLabel")]) {
            self.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
            self.textColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
        } else {
            self.backgroundColor = [UIColor clearColor];
            
            if ([self.superview isKindOfClass:[UIButton class]] || [self isKindOfClass:NSClassFromString(@"_UITableViewHeaderFooterViewLabel")]) {
                self.textColor = cvkMainController.nightThemeScheme.detailTextColor;
            } else {
                self.textColor = cvkMainController.nightThemeScheme.textColor;
            }
        }
    }
}

CHDeclareClass(UITextView);
CHDeclareMethod(1, void, UITextView, setAttributedText, NSAttributedString *, text)
{
    if (enabled && enableNightTheme) {
        text = attributedStringForNightTheme(text);
    }
    CHSuper(1, UITextView, setAttributedText, text);
}

CHDeclareMethod(1, void, UITextView, setLinkTextAttributes, NSDictionary *, linkTextAttributes)
{
    if (enabled && enableNightTheme) {
        linkTextAttributes = @{NSForegroundColorAttributeName: cvkMainController.nightThemeScheme.linkTextColor};
    }
    CHSuper(1, UITextView, setLinkTextAttributes, linkTextAttributes);
}

CHDeclareMethod(1, void, UITextView, insertText, id, text)
{
    CHSuper(1, UITextView, insertText, text);
    
    if (enabled && enableNightTheme) {
        self.textColor = cvkMainController.nightThemeScheme.textColor;
    }
}

CHDeclareMethod(1, void, UITextView, paste, id, text)
{
    CHSuper(1, UITextView, paste, text);
    
    if (enabled && enableNightTheme) {
        self.textColor = cvkMainController.nightThemeScheme.textColor;
    }
}

CHDeclareMethod(0, void, UITextView, layoutSubviews)
{
    CHSuper(0, UITextView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"UITextView")]) {
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = cvkMainController.nightThemeScheme.textColor;
    }
}

CHDeclareClass(UITextField);
CHDeclareMethod(0, void, UITextField, layoutSubviews)
{
    CHSuper(0, UITextField, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"UITextField")]) {
        self.tintColor = cvkMainController.nightThemeScheme.textColor;
        
        if ([CLASS_NAME(self) isEqualToString:@"UITextField"])
            self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareMethod(1, void, UITextField, paste, id, paste)
{
    setupNightTextField(self);
    CHSuper(1, UITextField, paste, paste);
}

CHDeclareMethod(0, void, UITextField, _updateLabel)
{
    setupNightTextField(self);
    CHSuper(0, UITextField, _updateLabel);
}

CHDeclareClass(UIImageView);
CHDeclareMethod(0, void, UIImageView, layoutSubviews)
{
    CHSuper(0, UIImageView, layoutSubviews);
    
    if (enabled && enableNightTheme) {
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(UICollectionView);
CHDeclareMethod(0, void, UICollectionView, layoutSubviews)
{
    CHSuper(0, UICollectionView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"UICollectionView")]) {
        
        NSNumber *shouldDisableBackgroundColor = (NSNumber*)objc_getAssociatedObject(self, "shouldDisableBackgroundColor");
        if ([shouldDisableBackgroundColor isKindOfClass:[NSNumber class]] && shouldDisableBackgroundColor.boolValue)
            self.backgroundColor = [UIColor clearColor];
        else
            self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(UICollectionViewCell);
CHDeclareMethod(0, void, UICollectionViewCell, layoutSubviews)
{
    CHSuper(0, UICollectionViewCell, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"UICollectionViewCell")] && ![self isKindOfClass:NSClassFromString(@"_UIAlertControllerTextFieldViewCollectionCell")]) {
        
        NSNumber *shouldDisableBackgroundColor = (NSNumber*)objc_getAssociatedObject(self, "shouldDisableBackgroundColor");
        if (!([shouldDisableBackgroundColor isKindOfClass:[NSNumber class]] && shouldDisableBackgroundColor.boolValue)) {
            self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
            self.contentView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
            self.backgroundView.hidden = YES;
        }
    }
}

CHDeclareClass(NewsFeedPostAndStoryCreationButtonBar);
CHDeclareMethod(0, void, NewsFeedPostAndStoryCreationButtonBar, layoutSubviews)
{
    CHSuper(0, NewsFeedPostAndStoryCreationButtonBar, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"NewsFeedPostAndStoryCreationButtonBar")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(Node5TableViewCell);
CHDeclareMethod(0, void, Node5TableViewCell, layoutSubviews)
{
    CHSuper(0, Node5TableViewCell, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"Node5TableViewCell")]) {
        
        for (UIView *subview in  self.contentView.subviews) {
            subview.backgroundColor = [UIColor clearColor];
        }
    }
}

CHDeclareClass(Node5CollectionViewCell);
CHDeclareMethod(0, void, Node5CollectionViewCell, layoutSubviews)
{
    CHSuper(0, Node5CollectionViewCell, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"Node5CollectionViewCell")]) {
        
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
CHDeclareMethod(0, void, InputPanelView, layoutSubviews)
{
    CHSuper(0, InputPanelView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"InputPanelView")]) {
        self.overlay.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        self.overlay.layer.borderColor = cvkMainController.nightThemeScheme.backgroundColor.CGColor;
    }
}

CHDeclareClass(AdminInputPanelView);
CHDeclareMethod(0, void, AdminInputPanelView, layoutSubviews)
{
    CHSuper(0, AdminInputPanelView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"AdminInputPanelView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        if ([self respondsToSelector:@selector(gapToolbar)])
            [self.gapToolbar setBackgroundImage:[UIImage imageWithColor:cvkMainController.nightThemeScheme.backgroundColor] 
                             forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
}

CHDeclareClass(UIView);
CHDeclareMethod(1, void, UIView, setFrame, CGRect, frame)
{
    CHSuper(1, UIView, setFrame, frame);
    
    setupNightSeparatorForView(self);
}

CHDeclareMethod(0, void, UIView, layoutSubviews)
{
    CHSuper(0, UIView, layoutSubviews);
    
    setupNightSeparatorForView(self);
}


CHDeclareClass(UIToolbar);
CHDeclareMethod(1, void, UIToolbar, setFrame, CGRect, frame)
{
    CHSuper(1, UIToolbar, setFrame, frame);
    
    setupTranslucence(self, cvkMainController.nightThemeScheme.navbackgroundColor, !(enabled && enableNightTheme));
}

CHDeclareClass(PollAnswerButton);
CHDeclareMethod(0, void, PollAnswerButton, layoutSubviews)
{
    CHSuper(0, PollAnswerButton, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"PollAnswerButton")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        self.progressView.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
    }
}

CHDeclareClass(VKAPBottomToolbar);
CHDeclareMethod(0, void, VKAPBottomToolbar, layoutSubviews)
{
    CHSuper(0, VKAPBottomToolbar, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"VKAPBottomToolbar")]) {
        self.bg.barTintColor = cvkMainController.nightThemeScheme.backgroundColor;
        self.bg.tintColor = cvkMainController.nightThemeScheme.textColor;
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
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"SeparatorWithBorders")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        self.borderColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
}

CHDeclareClass(Component5HostView);
CHDeclareMethod(0, void, Component5HostView, layoutSubviews)
{
    CHSuper(0, Component5HostView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"Component5HostView")]) {
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(LookupAddressBookFriendsViewController);
CHDeclareMethod(0, void, LookupAddressBookFriendsViewController, viewDidLoad)
{
    CHSuper(0, LookupAddressBookFriendsViewController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (UIView *subview in self.lookupTeaserViewController.componentView.subviews) {
                subview.backgroundColor = [UIColor clearColor];
            }
        });
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
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"ProductMarketCellForProfileGallery")]) {
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(MarketGalleryDecoration);
CHDeclareMethod(0, void, MarketGalleryDecoration, layoutSubviews)
{
    CHSuper(0, MarketGalleryDecoration, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"MarketGalleryDecoration")]) {
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(StoreStockItemView);
CHDeclareMethod(0, void, StoreStockItemView, layoutSubviews)
{
    CHSuper(0, StoreStockItemView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"StoreStockItemView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(VKPhotoPicker);
CHDeclareMethod(0, UIStatusBarStyle, VKPhotoPicker, preferredStatusBarStyle)
{
    if ([self isKindOfClass:NSClassFromString(@"VKPhotoPicker")] && enabled && (enabledBarColor || enableNightTheme || enabledBarImage))
        return UIStatusBarStyleLightContent;
    else return CHSuper(0, VKPhotoPicker, preferredStatusBarStyle);
}

CHDeclareMethod(0, void, VKPhotoPicker, viewDidLoad)
{
    CHSuper(0, VKPhotoPicker, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.pickerToolbar.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        self.pickerToolbar.bg._backgroundView.hidden = YES;
        self.navigationBar.tintColor = self.navigationBar.tintColor;
    }
}

CHDeclareClass(MainMenuPlayer);
CHDeclareMethod(0, void, MainMenuPlayer, highlightUpdated)
{
    CHSuper(0, MainMenuPlayer, highlightUpdated);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"MainMenuPlayer")]) {
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
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"VKMTableViewSearchHeaderView")]) {
        [self setBackgroundImage:[UIImage imageWithColor:cvkMainController.nightThemeScheme.foregroundColor] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
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
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"PersistentBackgroundColorView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
        self.persistentBackgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
}

CHDeclareClass(GiftSendController);
CHDeclareMethod(2, UITableViewCell*, GiftSendController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, GiftSendController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"GiftSendController")]) {
        cell.contentView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
    return cell;
}

CHDeclareClass(GiftsCatalogController);
CHDeclareMethod(2, UITableViewCell*, GiftsCatalogController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, GiftsCatalogController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"GiftsCatalogController")]) {
        cell.contentView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
    return cell;
}

CHDeclareClass(DefaultHighlightButton);
CHDeclareMethod(0, void, DefaultHighlightButton, layoutSubviews)
{
    CHSuper(0, DefaultHighlightButton, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"DefaultHighlightButton")]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([CLASS_NAME(self.superview) isEqualToString:@"UIView"])
                self.superview.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        });
    }
}

CHDeclareClass(_UITableViewHeaderFooterContentView);
CHDeclareMethod(1, void, _UITableViewHeaderFooterContentView, setBackgroundColor, UIColor *, backgroundColor)
{
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"_UITableViewHeaderFooterContentView")]) {
        backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
    
    CHSuper(1, _UITableViewHeaderFooterContentView, setBackgroundColor, backgroundColor);
}

CHDeclareClass(StoreController);
CHDeclareMethod(0, void, StoreController, viewDidLoad)
{
    CHSuper(0, StoreController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        [self.toolbar setBackgroundImage:[UIImage imageWithColor:cvkMainController.nightThemeScheme.foregroundColor] 
                      forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
}

CHDeclareClass(UIRefreshControl);
CHDeclareMethod(0, void, UIRefreshControl, layoutSubviews)
{
    CHSuper(0, UIRefreshControl, layoutSubviews);
    
    if (enabled && enableNightTheme)
        self.tintColor = cvkMainController.nightThemeScheme.buttonColor;
}


CHDeclareClass(UIActivityIndicatorView);
CHDeclareMethod(0, void, UIActivityIndicatorView, layoutSubviews)
{
    CHSuper(0, UIActivityIndicatorView, layoutSubviews);
    
    if (enabled && enableNightTheme)
        self.color = cvkMainController.nightThemeScheme.buttonColor;
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

CHDeclareClass(UIVisualEffectView);
CHDeclareMethod(0, void, UIVisualEffectView, didMoveToSuperview)
{
    CHSuper(0, UIVisualEffectView, didMoveToSuperview);
    
    if (enabled && enableNightTheme && [self.effect isKindOfClass:[UIBlurEffect class]]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *className = CLASS_NAME(self.superview.superview);
            if ([className containsString:@"_UIAlertController"] || [className containsString:@"_UIPopoverView"]) {
                self.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.6f];
            }
        });
    }
}

CHDeclareClass(_UIAlertControlleriOSActionSheetCancelBackgroundView);
CHDeclareMethod(0, void, _UIAlertControlleriOSActionSheetCancelBackgroundView, layoutSubviews)
{
    CHSuper(0, _UIAlertControlleriOSActionSheetCancelBackgroundView, layoutSubviews);
    
    if (enabled && enableNightTheme && self.subviews.count > 0)
        self.subviews.firstObject.backgroundColor = [UIColor clearColor];
}

CHDeclareClass(UIAlertController);
CHDeclareMethod(0, void, UIAlertController, viewDidLoad)
{
    CHSuper(0, UIAlertController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.tintColor = [UIColor colorWithRed:0.1f green:0.59f blue:0.94f alpha:1.0f];
    }
}

CHDeclareMethod(1, void, UIAlertController, addTextFieldWithConfigurationHandler, id, handler)
{
    if (![self isKindOfClass:[ColoredVKAlertController class]]) {
        void (^newHandler)(UITextField * _Nonnull textField) = ^(UITextField * _Nonnull textField){
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIView *viewToRoundSuperView = textField.superview.superview;
                if (viewToRoundSuperView) {
                    for (UIView *subview in textField.superview.superview.subviews) {
                        subview.backgroundColor = [UIColor clearColor];
                        if ([subview isKindOfClass:[UIVisualEffectView class]])
                            subview.hidden = YES;
                    }
                    UIView *viewToRound = textField.superview;
                    textField.backgroundColor = (enabled && enableNightTheme) ? cvkMainController.nightThemeScheme.backgroundColor : [UIColor whiteColor];
                    viewToRound.backgroundColor = (enabled && enableNightTheme) ? cvkMainController.nightThemeScheme.backgroundColor : [UIColor whiteColor];
                    viewToRound.layer.cornerRadius = 5.0f;
                    viewToRound.layer.borderWidth = 0.5f;
                    viewToRound.layer.borderColor = (enabled && enableNightTheme) ? [UIColor clearColor].CGColor : [UIColor colorWithWhite:0.85f alpha:1.0f].CGColor;
                    viewToRound.layer.masksToBounds = YES;
                }
            });
            
            void (^configurationHandler)(UITextField *textField) = handler;
            
            configurationHandler(textField);
        };
        CHSuper(1,  UIAlertController, addTextFieldWithConfigurationHandler, newHandler);
        
    } else {
        CHSuper(1,  UIAlertController, addTextFieldWithConfigurationHandler, handler);
    }
}

CHDeclareClass(_UIAlertControllerTextFieldViewController);
CHDeclareMethod(0, void, _UIAlertControllerTextFieldViewController, viewDidLoad)
{
    CHSuper(0, _UIAlertControllerTextFieldViewController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        objc_setAssociatedObject(self.collectionView, "shouldDisableBackgroundColor", @1, OBJC_ASSOCIATION_ASSIGN);
    }
}



CHDeclareClass(VKP2PDetailedView);
CHDeclareMethod(0, void, VKP2PDetailedView, layoutSubviews)
{
    CHSuper(0, VKP2PDetailedView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"VKP2PDetailedView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(NewDialogCell);
CHDeclareMethod(0, void, NewDialogCell, layoutSubviews)
{
    CHSuper(0, NewDialogCell, layoutSubviews);
    setupNewDialogCellFromNightTheme(self);
}

CHDeclareMethod(0, void, NewDialogCell, prepareForReuse)
{
    setupNewDialogCellFromNightTheme(self);
    CHSuper(0, NewDialogCell, prepareForReuse);
}


CHDeclareClass(FreshNewsButton);
CHDeclareMethod(1, id, FreshNewsButton, initWithFrame, CGRect, frame)
{
    FreshNewsButton *button = CHSuper(1, FreshNewsButton, initWithFrame, frame);
    if (enabled && enableNightTheme) {
        [button.button setBackgroundImage:[[button.button backgroundImageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        button.button.imageView.tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
    }
    
    return button;
}

CHDeclareClass(TouchHighlightControl);
CHDeclareMethod(1, id, TouchHighlightControl, initWithFrame, CGRect, frame)
{
    TouchHighlightControl *control = CHSuper(1, TouchHighlightControl, initWithFrame, frame);
    
    if (enabled && enableNightTheme) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (UIView *subview in control.subviews) {
                if ([subview isKindOfClass:[UIImageView class]]) {
                    UIImageView *imageView = (UIImageView *)subview;
                    if ([imageView.image.imageAsset.assetName containsString:@"post/settings"]) {
                        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                        imageView.tintColor = cvkMainController.nightThemeScheme.textColor;
                    }
                }
            }
        });
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

CHDeclareClass(UITableViewIndex);
CHDeclareMethod(0, void, UITableViewIndex, layoutSubviews)
{
    CHSuper(0, UITableViewIndex, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"UITableViewIndex")]) {
        self.indexBackgroundColor = [UIColor clearColor];
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
                [toolbar setBackgroundImage:[UIImage imageWithColor:cvkMainController.nightThemeScheme.navbackgroundColor] 
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
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"EmojiSelectionView")]) {
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
    if (enabled && enableNightTheme)
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
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"VKPPNoAccessView")]) {
        self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
}

CHDeclareClass(UIImage);
CHDeclareClassMethod(1, UIImage *, UIImage, imageNamed, NSString *, name)
{
    UIImage *orig = CHSuper(1, UIImage, imageNamed, name);
    
    if (enabled && enableNightTheme) {
        NSString *assetName = orig.imageAsset.assetName;
        if (([cvkMainController compareAppVersionWithVersion:@"3.0"] == ColoredVKVersionCompareMore) && [assetName containsString:@"badge"]) {
//            CVKLog(@"assetName: %@", assetName);
            orig = [orig imageWithTintColor:cvkMainController.nightThemeScheme.backgroundColor];
        }
    }
    
    return orig;
}

CHDeclareClass(VKSearchScrollTopBackgroundView);
CHDeclareMethod(0, void, VKSearchScrollTopBackgroundView, layoutSubviews)
{
    CHSuper(0, VKSearchScrollTopBackgroundView, layoutSubviews);
    
    if (enabled && [self isKindOfClass:NSClassFromString(@"VKSearchScrollTopBackgroundView")]) {
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
CHDeclareMethod(0, UIStatusBarStyle, StoryEditorSendViewController, preferredStatusBarStyle)
{
    if (enabled && enableNightTheme)
        return UIStatusBarStyleLightContent;
    
    return CHSuper(0, StoryEditorSendViewController, preferredStatusBarStyle);
}
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
    
    if (enabled && enableNightTheme && [self isKindOfClass:NSClassFromString(@"InputPanelViewTextView")]) {
        objc_setAssociatedObject(self.placeholderLabel, "should_customize", @NO, OBJC_ASSOCIATION_ASSIGN);
        self.placeholderLabel.textColor = cvkMainController.nightThemeScheme.detailTextColor;
    }
}

CHDeclareClass(VKProfileInfoItem);
CHDeclareMethod(1, void, VKProfileInfoItem, setValue, NSAttributedString *, value)
{
    NSMutableAttributedString *mutableValue = [value mutableCopy];
    [mutableValue addAttribute:@"CVKDetailed" value:@1 range:NSMakeRange(0, mutableValue.length)];
    CHSuper(1, VKProfileInfoItem, setValue, mutableValue);
}
