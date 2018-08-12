//
//  SystemNightTheme.m
//  ColoredVK2
//
//  Created by Даниил on 22.06.18.
//

#import "Tweak.h"
#import <CoreText/CoreText.h>
#import "ColoredVKAlertController.h"
@import SafariServices.SFSafariViewController;


CVKHook(CTFramesetterRef, CTFramesetterCreateWithAttributedString, CFAttributedStringRef string)
{
    CFAttributedStringRef newString = CFAttributedStringCreateCopy(kCFAllocatorDefault, string);
    
    if (enabled && enableNightTheme && newString != NULL && CFAttributedStringGetLength(newString) > 0) {
        NSAttributedString *attributed = CFBridgingRelease(newString);
        attributed = attributedStringForNightTheme(attributed);
        newString = (CFMutableAttributedStringRef)CFBridgingRetain(attributed);
    }
    
    CTFramesetterRef result = CVKHookSuper(CTFramesetterCreateWithAttributedString, newString);
    if (newString != NULL) {
        CFRelease(newString);
    }
    
    return result;
}

CHDeclareClass(UITableViewCell);
CHDeclareMethod(0, void, UITableViewCell, layoutSubviews)
{
    CHSuper(0, UITableViewCell, layoutSubviews);
    
    
    NSNumber *shouldChangeBackground = NIGHT_THEME_SHOULD_CUSTOMIZE(self);
    if (!shouldChangeBackground)
        shouldChangeBackground = @YES;
    
    if ([self isKindOfClass:objc_lookUpClass("ColoredVKPrefsCell")])
        return;
    
    if ([self isKindOfClass:objc_lookUpClass("MessageCell")])
        return;
    
    if ([self isKindOfClass:[UITableViewCell class]]) {
        if ((self.textLabel.textAlignment == NSTextAlignmentCenter) && [CLASS_NAME(self) isEqualToString:@"UITableViewCell"])
            self.backgroundColor = [UIColor clearColor];
        else {
            if (enabled && enableNightTheme && shouldChangeBackground.boolValue)
                self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        }
        
        if (enabled && enableNightTheme) {
            self.textLabel.textColor = cvkMainController.nightThemeScheme.textColor;
            self.textLabel.backgroundColor = [UIColor clearColor];
            
            if (self.detailTextLabel) {
                NIGHT_THEME_DISABLE_CUSTOMISATION(self.detailTextLabel);
                self.detailTextLabel.textColor = cvkMainController.nightThemeScheme.detailTextColor;
                self.detailTextLabel.backgroundColor = [UIColor clearColor];
            }
            
            if ([self isKindOfClass:objc_lookUpClass("GroupCell")]) {
                GroupCell *groupCell = (GroupCell *)self;
                if (groupCell.status) {
                    NIGHT_THEME_DISABLE_CUSTOMISATION(groupCell.status);
                    groupCell.status.textColor = cvkMainController.nightThemeScheme.detailTextColor;
                    groupCell.status.backgroundColor = [UIColor clearColor];
                }
            }
            
            if ([self isKindOfClass:objc_lookUpClass("VKMRendererCell")]) {
                VKMRendererCell *rendererCell = (VKMRendererCell *)self;
                if ([rendererCell.renderer isKindOfClass:objc_lookUpClass("CommentRenderer")]) {
                    BOOL firstLabelFound = NO;
                    for (UIView *subview in rendererCell.renderer.views) {
                        if ([subview isKindOfClass:[UILabel class]]) {
                            UILabel *label = (UILabel *)subview;
                            NIGHT_THEME_DISABLE_CUSTOMISATION(label);
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
        NSNumber *should_customize = NIGHT_THEME_SHOULD_CUSTOMIZE(self);
        if (!should_customize)
            should_customize = @YES;
        
        if (!should_customize.boolValue)
            return;
        
        if (![self isKindOfClass:objc_lookUpClass("VKMImageButton")] && 
            ![self isKindOfClass:objc_lookUpClass("HighlightableButton")] && 
            ![self isKindOfClass:objc_lookUpClass("LinkButton")] && 
            ![self isKindOfClass:objc_lookUpClass("BorderButton")] &&
            ![self isKindOfClass:objc_lookUpClass("VKReusableButtonView")] &&
            ![self isKindOfClass:objc_lookUpClass("_TtC3vkm17BotKeyboardButton")]
            ) {
            
            if (self.titleLabel) {
                if (self.currentImage || self.currentBackgroundImage)
                    NIGHT_THEME_DISABLE_CUSTOMISATION(self.titleLabel);
                
                if (!self.currentBackgroundImage) {
                    ColoredVKNightScheme *nightScheme = cvkMainController.nightThemeScheme;
                    [self setTitleColor:self.currentImage ? nightScheme.detailTextColor : nightScheme.buttonSelectedColor forState:UIControlStateNormal];
                }
            }
            
            NSNumber *changeImageColor = objc_getAssociatedObject(self, "shouldChangeImageColor");
            if (!changeImageColor)
                changeImageColor = @NO;
            
            NSArray <NSString *> *namesToExclude = @[@"attachments/remove", @"search/clear", @"scroll_to_bottom", @"dismiss_light_24"];
            if (![namesToExclude containsObject:[self imageForState:UIControlStateNormal].imageAsset.assetName] || changeImageColor.boolValue) {
                if ((CGRectGetWidth(self.imageView.frame) <= 44.0f && CGRectGetHeight(self.imageView.frame) <= 44.0f) || changeImageColor.boolValue) {
                    [self setImage:[[self imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                    
                    NSArray <NSString *> *buttonNavigationClasses = @[@"UINavigationButton", @"_UIModernBarButton"];
                    BOOL isNavigation = [buttonNavigationClasses containsObject:CLASS_NAME(self)];
                    self.imageView.tintColor = isNavigation ? cvkMainController.nightThemeScheme.buttonSelectedColor : cvkMainController.nightThemeScheme.buttonColor;
                }
            }
        } else if ([self isKindOfClass:objc_lookUpClass("HighlightableButton")]) {
            if ([self.currentBackgroundImage isKindOfClass:objc_lookUpClass("_UIResizableImage")]) {
                [self setBackgroundImage:[self.currentBackgroundImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:self.state];
                self.tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
            }
        }
    }
}

CHDeclareClass(UISegmentedControl);
CHDeclareMethod(0, void, UISegmentedControl, layoutSubviews)
{
    CHSuper(0, UISegmentedControl, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("UISegmentedControl")]) {
        self.tintColor = cvkMainController.nightThemeScheme.buttonColor;
        self.backgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(UILabel);
CHDeclareMethod(0, void, UILabel, layoutSubviews)
{
    CHSuper(0, UILabel, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("UILabel")] && 
        ![CLASS_NAME(self.superview) isEqualToString:@"HighlightableButton"] && 
        ![CLASS_NAME(self.superview) isEqualToString:@"VKPPBadge"]) {
        
        NSNumber *should_customize = NIGHT_THEME_SHOULD_CUSTOMIZE(self);
        if (!should_customize)
            should_customize = @YES;
        
        if (!should_customize.boolValue)
            return;
        
        if ([self isKindOfClass:objc_lookUpClass("HighlightableLabel")]) {
            self.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
            self.textColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
        } else {
            self.backgroundColor = [UIColor clearColor];
            
            if (![self.superview isKindOfClass:[UIButton class]] && 
                ![self isKindOfClass:objc_lookUpClass("_UITableViewHeaderFooterViewLabel")]) {
                self.textColor = cvkMainController.nightThemeScheme.textColor;
            } else if ([self.superview isKindOfClass:objc_lookUpClass("UINavigationItemView")]) {
                self.textColor = cvkMainController.nightThemeScheme.detailTextColor;
            }
        }
    }
}

CHDeclareMethod(1, void, UILabel, setTextColor, UIColor *, textColor)
{
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("UILabel")] && 
        ![CLASS_NAME(self.superview) isEqualToString:@"HighlightableButton"] && 
        ![CLASS_NAME(self.superview) isEqualToString:@"VKPPBadge"]) {
        
        NSNumber *should_customize = NIGHT_THEME_SHOULD_CUSTOMIZE(self);
        if (!should_customize)
            should_customize = @YES;
        
        if (should_customize.boolValue) {
            CGFloat white;
            [textColor getWhite:&white alpha:nil];
            if (white < 0.5f)
                textColor = cvkMainController.nightThemeScheme.textColor;
        }
        
    }
    
    CHSuper(1, UILabel, setTextColor, textColor);
}

CHDeclareMethod(1, void, UILabel, setAttributedText, NSAttributedString *, text)
{
    if (enabled && enableNightTheme) {
        NSNumber *should_customize = NIGHT_THEME_SHOULD_CUSTOMIZE(self);
        if (!should_customize)
            should_customize = @YES;
        
        if (should_customize.boolValue)
            text = attributedStringForNightTheme(text);
    }
    CHSuper(1, UILabel, setAttributedText, text);
}

CHDeclareClass(UITextView);
CHDeclareMethod(1, void, UITextView, setAttributedText, NSAttributedString *, text)
{
    if (enabled && enableNightTheme) {
        NSNumber *should_customize = NIGHT_THEME_SHOULD_CUSTOMIZE(self);
        if (!should_customize)
            should_customize = @YES;
        
        if (should_customize.boolValue) {
            text = attributedStringForNightTheme(text);
        }
    }
    CHSuper(1, UITextView, setAttributedText, text);
}

CHDeclareMethod(1, void, UITextView, setLinkTextAttributes, NSDictionary *, linkTextAttributes)
{
    if (enabled && enableNightTheme) {
        NSNumber *should_customize = NIGHT_THEME_SHOULD_CUSTOMIZE(self);
        if (!should_customize)
            should_customize = @YES;
        
        if (should_customize.boolValue) {
            linkTextAttributes = @{NSForegroundColorAttributeName: cvkMainController.nightThemeScheme.linkTextColor};
        }
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
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("UITextView")]) {
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = cvkMainController.nightThemeScheme.textColor;
        self.textColor = cvkMainController.nightThemeScheme.textColor;
    }
}

CHDeclareMethod(0, void, UITextView, deleteBackward)
{
    CHSuper(0, UITextView, deleteBackward);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("UITextView")]) {
        self.textColor = cvkMainController.nightThemeScheme.textColor;
    }
}

CHDeclareClass(UITextField);
CHDeclareMethod(0, void, UITextField, layoutSubviews)
{
    CHSuper(0, UITextField, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("UITextField")]) {
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
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("UICollectionView")]) {
        
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
    
    NSArray <NSString *> *forbiddenClasses = @[@"_UIAlertControllerTextFieldViewCollectionCell", @"vkm.MessageCell", 
                                               @"vkm.SelectionCollectionViewCell", @"VKSegmentCollectionViewCell"];
    BOOL forbiddenClass = [forbiddenClasses containsObject:CLASS_NAME(self)];
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("UICollectionViewCell")] && !forbiddenClass) {
        
        NSNumber *shouldDisableBackgroundColor = (NSNumber*)objc_getAssociatedObject(self, "shouldDisableBackgroundColor");
        if (!([shouldDisableBackgroundColor isKindOfClass:[NSNumber class]] && shouldDisableBackgroundColor.boolValue)) {
            self.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
            self.contentView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
            self.backgroundView.hidden = YES;
        }
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

CHDeclareClass(_UITableViewHeaderFooterContentView);
CHDeclareMethod(1, void, _UITableViewHeaderFooterContentView, setBackgroundColor, UIColor *, backgroundColor)
{
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("_UITableViewHeaderFooterContentView")]) {
        backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
    }
    
    CHSuper(1, _UITableViewHeaderFooterContentView, setBackgroundColor, backgroundColor);
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

CHDeclareClass(UIAlertController);
CHDeclareMethod(0, void, UIAlertController, viewDidLoad)
{
    CHSuper(0, UIAlertController, viewDidLoad);
    
    if (enabled && enableNightTheme) {
        self.view.tintColor = cvkMainController.nightThemeScheme.buttonSelectedColor;
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

CHDeclareClass(_UIAlertControlleriOSActionSheetCancelBackgroundView);
CHDeclareMethod(0, void, _UIAlertControlleriOSActionSheetCancelBackgroundView, layoutSubviews)
{
    CHSuper(0, _UIAlertControlleriOSActionSheetCancelBackgroundView, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("_UIAlertControlleriOSActionSheetCancelBackgroundView")]) {
        Ivar backgroundViewIvar = class_getInstanceVariable([self class], "backgroundView");
        if (backgroundViewIvar) {
            UIView *backgroundView = object_getIvar(self, backgroundViewIvar);
            if (backgroundView) {
                backgroundView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
            }
        }
    }
}

CHDeclareClass(UITableViewIndex);
CHDeclareMethod(0, void, UITableViewIndex, layoutSubviews)
{
    CHSuper(0, UITableViewIndex, layoutSubviews);
    
    if (enabled && enableNightTheme && [self isKindOfClass:objc_lookUpClass("UITableViewIndex")]) {
        self.indexBackgroundColor = [UIColor clearColor];
    }
}

CHDeclareClass(UIImage);
CHDeclareClassMethod(1, UIImage *, UIImage, imageNamed, NSString *, name)
{
    UIImage *orig = CHSuper(1, UIImage, imageNamed, name);
    
    if (enabled && enableNightTheme) {
        NSString *assetName = orig.imageAsset.assetName;
        if (isNew3XClient && [assetName containsString:@"badge"]) {
//            CVKLog(@"assetName: %@", assetName);
            orig = [orig cvk_imageWithTintColor:cvkMainController.nightThemeScheme.backgroundColor];
        }
    }
    
    return orig;
}

CHDeclareClass(SFSafariViewController);
CHDeclareMethod(0, void, SFSafariViewController, viewDidLoad)
{
    CHSuper(0, SFSafariViewController, viewDidLoad);
    
    if (ios_available(10.0)) {
        if (enabled && enableNightTheme) {
            self.preferredBarTintColor = cvkMainController.nightThemeScheme.navbackgroundColor;
            self.preferredControlTintColor = cvkMainController.nightThemeScheme.textColor;
        }
    }
}

CHDeclareMethod(1, void, SFSafariViewController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, SFSafariViewController, viewWillAppear, animated);
    
    UIStatusBar *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    if (enabled && enableNightTheme && statusBar != nil) {
        statusBar.foregroundColor = nil;
    }
}

CHDeclareMethod(1, void, SFSafariViewController, viewDidDisappear, BOOL, animated)
{
    CHSuper(1, SFSafariViewController, viewDidDisappear, animated);
    
    UIStatusBar *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    if (enabled && enableNightTheme && statusBar != nil) {
        statusBar.foregroundColor = [UIColor whiteColor];
    }
}

CHDeclareClass(_UIVisualEffectSubview);
CHDeclareMethod(0, void, _UIVisualEffectSubview, layoutSubviews)
{
    CHSuper(0, _UIVisualEffectSubview, layoutSubviews);
    self.backgroundColor = self.backgroundColor;
}

CHDeclareMethod(1, void, _UIVisualEffectSubview, setBackgroundColor, UIColor *, backgroundColor)
{
    if (enabled && enableNightTheme) {
        if ([self.superview.superview isKindOfClass:objc_lookUpClass("_UIBarBackground")])
            backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        else if (![self.superview isKindOfClass:objc_lookUpClass("AVPlayerViewControllerContentView")])
            backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
    }
    
    CHSuper(1, _UIVisualEffectSubview, setBackgroundColor, backgroundColor);
}

CHDeclareClass(_UIBackdropEffectView);
CHDeclareMethod(0, void, _UIBackdropEffectView, layoutSubviews)
{
    CHSuper(0, _UIBackdropEffectView, layoutSubviews);
    
    if (enabled && enableNightTheme && ![self.superview isKindOfClass:objc_lookUpClass("UIKBKeyView")] && 
        ![self.superview isKindOfClass:objc_lookUpClass("UICalloutBarBackground")]) {
        self.backdropLayer.hidden = YES;
    }
}

CHDeclareClass(_UIBackdropView);
CHDeclareMethod(0, void, _UIBackdropView, layoutSubviews)
{
    CHSuper(0, _UIBackdropView, layoutSubviews);
    self.backgroundColor = self.backgroundColor;
}

CHDeclareMethod(1, void, _UIBackdropView, setBackgroundColor, UIColor *, backgroundColor)
{
    if (enabled && enableNightTheme) {
        if ([self.superview isKindOfClass:objc_lookUpClass("_UINavigationBarBackground")])
            backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        else if (![self.superview isKindOfClass:objc_lookUpClass("UIKBKeyView")] && 
                 ![self.superview isKindOfClass:objc_lookUpClass("_UIBackdropContentView")] &&
                 ![self isKindOfClass:objc_lookUpClass("UICalloutBarBackground")]) {
            backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        }
    }
    
    CHSuper(1, _UIBackdropView, setBackgroundColor, backgroundColor);
}

CHDeclareClass(_UIPageViewControllerContentView);
CHDeclareMethod(0, void, _UIPageViewControllerContentView, layoutSubviews)
{
    CHSuper(0, _UIPageViewControllerContentView, layoutSubviews);
    if (enabled && enableNightTheme)
        self.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
}
