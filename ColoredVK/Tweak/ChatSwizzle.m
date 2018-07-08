//
//  ChatSwizzle.m
//  ColoredVK2
//
//  Created by Даниил on 23.03.18.
//

#import "Tweak.h"
@import CoreText;

#pragma GCC diagnostic push 
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma mark DialogsSearchController
CHDeclareClass(DialogsSearchController);
CHDeclareMethod(1, void, DialogsSearchController, searchDisplayControllerWillBeginSearch, UISearchDisplayController*, controller)
{
    CHSuper(1, DialogsSearchController, searchDisplayControllerWillBeginSearch, controller);
    setupSearchController(controller, NO);
    if (enabled && !enableNightTheme && enabledMessagesImage)
        controller.searchResultsTableView.separatorColor = [controller.searchResultsTableView.separatorColor colorWithAlphaComponent:0.2f];
}

CHDeclareMethod(1, void, DialogsSearchController, searchDisplayControllerWillEndSearch, UISearchDisplayController*, controller)
{
    setupSearchController(controller, YES);
    CHSuper(1, DialogsSearchController, searchDisplayControllerWillEndSearch, controller);
}

CHDeclareMethod(2, UITableViewCell*, DialogsSearchController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, DialogsSearchController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    setupCellForSearchController(cell, self);
    return cell;
}
#pragma GCC diagnostic pop


#pragma mark DialogsSearchResultsController
CHDeclareClass(DialogsSearchResultsController);
CHDeclareMethod(1, void, DialogsSearchResultsController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DialogsSearchResultsController, viewWillAppear, animated);
    setupNewDialogsSearchController(self);
}

CHDeclareMethod(2, UITableViewCell*, DialogsSearchResultsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, DialogsSearchResultsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && !enableNightTheme && enabledMessagesListImage) {
        performInitialCellSetup (cell);
        cell.backgroundView.hidden = YES;
        UIColor *textColor = changeMessagesListTextColor ? messagesListTextColor : UITableViewCellTextColor;
        UIColor *detailedTextColor = changeMessagesListTextColor ? messagesListTextColor : UITableViewCellTextColor;
        
        if ([cell isKindOfClass:objc_lookUpClass("SourceCell")]) {
            SourceCell *sourceCell = (SourceCell *)cell;
            sourceCell.last.textColor = detailedTextColor;
            sourceCell.last.backgroundColor = [UIColor clearColor];
            sourceCell.first.textColor =  textColor;
            sourceCell.first.backgroundColor = [UIColor clearColor];
        }
        else if ([cell isKindOfClass:objc_lookUpClass("NewDialogCell")]) {
            NewDialogCell *dialogCell = (NewDialogCell *)cell;
            dialogCell.name.textColor = textColor;
            dialogCell.name.backgroundColor = [UIColor clearColor];
            dialogCell.time.textColor = textColor;
            dialogCell.time.backgroundColor = [UIColor clearColor];
            if ([dialogCell respondsToSelector:@selector(dialogText)]) {
                dialogCell.dialogText.textColor = detailedTextColor;
                dialogCell.dialogText.backgroundColor = [UIColor clearColor];
            }
        }
    }
    return cell;
}

#pragma mark DialogsController - список диалогов
CHDeclareClass(DialogsController);

CHDeclareMethod(0, void, DialogsController, viewDidLoad)
{
    CHSuper(0, DialogsController, viewDidLoad);
    
    if ([self isKindOfClass:objc_lookUpClass("DialogsController")] && !isNew3XClient) {
        if (enabled && !enableNightTheme && enabledMessagesListImage) {
            [cvkMainController setImageToTableView:self.tableView name:@"messagesListBackgroundImage" blackout:chatListImageBlackout 
                                    parallaxEffect:useMessagesListParallax blur:messagesListUseBackgroundBlur];
        }
    }
}

CHDeclareMethod(1, void, DialogsController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DialogsController, viewWillAppear, animated);
    
    if (!enableNightTheme && [self isKindOfClass:objc_lookUpClass("DialogsController")]) {
        
        UITableView *tableView = nil;
        if ([self respondsToSelector:@selector(listController)]) {
            tableView = self.listController.tableView;
        } else if ([self respondsToSelector:@selector(tableView)]) {
            tableView = self.tableView;
        }
        
        if (!tableView)
            return;
        
        UISearchBar *search = (UISearchBar*)tableView.tableHeaderView;
        if ([search isKindOfClass:[UISearchBar class]]) {
            search.tag = 1;
        }
        
        UIColor *placeholderColor = isNew3XClient ? UITableViewCellTextColor : [UIColor colorWithRed:0.556863f green:0.556863f blue:0.576471f alpha:1.0f];
        placeholderColor = (enabled && changeMessagesListTextColor) ? messagesListTextColor : placeholderColor;
        
        if (enabled && enabledMessagesListImage) {
            if ([self respondsToSelector:@selector(rptr)])
                self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
            
            tableView.separatorColor =  hideMessagesListSeparators ? [UIColor clearColor] : [tableView.separatorColor colorWithAlphaComponent:0.2f];
            
            if ([search isKindOfClass:objc_lookUpClass("VKSearchBar")]) {
                setupNewSearchBar((VKSearchBar *)search, placeholderColor, messagesListBlurTone, messagesListBlurStyle);
            } else if ([search isKindOfClass:[UISearchBar class]]) {
                search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
                search.backgroundImage = [UIImage new];
                search._scopeBarBackgroundView.superview.hidden = YES;
            }
            
        } else if (isNew3XClient) {
            if ([self respondsToSelector:@selector(rptr)])
                self.rptr.tintColor = nil;
            
            tableView.separatorColor = [UIColor colorWithRed:215/255.0f green:216/255.0f blue:217/255.0f alpha:1.0f];
            if ([search isKindOfClass:objc_lookUpClass("VKSearchBar")]) {
                resetNewSearchBar((VKSearchBar *)search);
            } if ([search isKindOfClass:[UISearchBar class]]) {
                search.searchBarTextField.backgroundColor = nil;
                search._scopeBarBackgroundView.superview.hidden = NO;
                search.backgroundImage = [UIImage cvk_imageWithColor:[UIColor colorWithRed:235/255.0f green:237/255.0f blue:240/255.0f alpha:1.0f]];
            } else {
                objc_removeAssociatedObjects(search);
            }
        }
        
        if ([search isKindOfClass:[UISearchBar class]]) {
            NSMutableAttributedString *placeholder = [search.searchBarTextField.attributedPlaceholder mutableCopy];
            [placeholder addAttribute:NSForegroundColorAttributeName value:placeholderColor range:NSMakeRange(0, placeholder.string.length)];
            search.searchBarTextField.attributedPlaceholder = placeholder;
        }
        
        if (isNew3XClient) {
            if (enabled && !enableNightTheme && enabledMessagesListImage) {
                [cvkMainController setImageToTableView:tableView name:@"messagesListBackgroundImage" blackout:chatListImageBlackout 
                                        parallaxEffect:useMessagesListParallax blur:messagesListUseBackgroundBlur];
                [cvkMainController forceUpdateTableView:tableView blackout:chatListImageBlackout blur:messagesListUseBackgroundBlur];
            } else
                tableView.backgroundView = nil;
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, DialogsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    NewDialogCell *cell = (NewDialogCell *)CHSuper(2, DialogsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:objc_lookUpClass("DialogsController")]) {
        if (enabled && !enableNightTheme && enabledMessagesListImage ) {
            performInitialCellSetup(cell);
            cell.backgroundView.hidden = YES;
            
            if (!cell.dialog.head.read_state && cell.unread.hidden)
                cell.contentView.backgroundColor = useCustomDialogsUnreadColor?dialogsUnreadColor:[UIColor cvk_defaultColorForIdentifier:@"dialogsUnreadColor"];
            else
                cell.contentView.backgroundColor = [UIColor clearColor];
            
            cell.name.textColor = changeMessagesListTextColor?messagesListTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
            cell.time.textColor = cell.name.textColor;
            cell.attach.textColor = changeMessagesListTextColor?messagesListTextColor:[UIColor colorWithWhite:0.95f alpha:0.9f];
            if ([cell respondsToSelector:@selector(dialogText)]) cell.dialogText.textColor = cell.attach.textColor;
            if ([cell respondsToSelector:@selector(text)]) cell.text.textColor = cell.attach.textColor;
        } else {
            if (!cell.dialog.head.read_state && cell.unread.hidden)
                cell.contentView.backgroundColor = [UIColor colorWithRed:0.92f green:0.94f blue:0.96f alpha:1.0f];
            else
                cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
    return cell;
}

#pragma mark DLVController
CHDeclareClass(DLVController);
CHDeclareMethod(2, UITableViewCell*, DLVController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    _TtC3vkm12PeerListCell *cell = (_TtC3vkm12PeerListCell *)CHSuper(2, DLVController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:objc_lookUpClass("DLVController")] && [cell isKindOfClass:objc_lookUpClass("vkm.PeerListCell")]) {
        if (enabled && !enableNightTheme && enabledMessagesListImage) {
            performInitialCellSetup(cell);
            if ([cell respondsToSelector:@selector(titleView)]) {
                cell.titleView.textColor = changeMessagesListTextColor?messagesListTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
                cell.timeView.textColor = cell.titleView.textColor;
                cell.bodyView.textColor = cell.titleView.textColor;
            } else {
                for (UIView *subview in cell.contentView.subviews) {
                    if ([subview isKindOfClass:[UILabel class]])
                        ((UILabel *)subview).textColor = changeMessagesListTextColor?messagesListTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
                }
            }
        } else if (enabled && enableNightTheme) {
            if ([cell respondsToSelector:@selector(titleView)]) {
                cell.contentView.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
                cell.titleView.textColor = cvkMainController.nightThemeScheme.textColor;
                cell.bodyView.textColor = cvkMainController.nightThemeScheme.detailTextColor;
                NIGHT_THEME_DISABLE_CUSTOMISATION(cell.bodyView);
                NIGHT_THEME_DISABLE_CUSTOMISATION(cell.titleView);
            } else {
                for (UIView *subview in cell.contentView.subviews) {
                    if ([subview isKindOfClass:[UILabel class]]) {
                        UILabel *label = (UILabel *)subview;
                        NIGHT_THEME_DISABLE_CUSTOMISATION(label);
                        
                        CTFontSymbolicTraits traits = CTFontGetSymbolicTraits((__bridge CTFontRef)label.font);
                        BOOL isBold = ((traits & kCTFontTraitBold) == kCTFontTraitBold);
                        label.textColor = isBold ? cvkMainController.nightThemeScheme.textColor : cvkMainController.nightThemeScheme.detailTextColor;
                    }
                }
            }
        } else {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
    return cell;
}

#pragma mark BackgroundView
CHDeclareClass(BackgroundView);
CHDeclareMethod(1, void, BackgroundView, drawRect, CGRect, rect)
{
    if (enabled) {
        self.layer.cornerRadius = self.cornerRadius;
        self.layer.masksToBounds = YES;
        if (enableNightTheme)
            self.layer.backgroundColor = cvkMainController.nightThemeScheme.unreadBackgroundColor.CGColor;
        else if (enabledMessagesListImage)
            self.layer.backgroundColor = useCustomDialogsUnreadColor ? dialogsUnreadColor.CGColor : [UIColor cvk_defaultColorForIdentifier:@"messageReadColor"].CGColor;
        else
            CHSuper(1, BackgroundView, drawRect, rect);
    } else CHSuper(1, BackgroundView, drawRect, rect);
}

#pragma mark DetailController + тулбар
CHDeclareClass(DetailController);
CHDeclareMethod(1, void, DetailController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DetailController, viewWillAppear, animated);
    if ([self isKindOfClass:objc_lookUpClass("DetailController")]) setToolBar(self.inputPanel);
}


#pragma mark ChatController + тулбар
CHDeclareClass(ChatController);
CHDeclareMethod(1, void, ChatController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, ChatController, viewWillAppear, animated);
    
    if (![self isKindOfClass:objc_lookUpClass("ChatController")])
        return;
    
    if ([self respondsToSelector:@selector(root)])
        if ([self.root respondsToSelector:@selector(inputPanelView)])
            if ([self.root.inputPanelView respondsToSelector:@selector(gapToolbar)]) {
                [self.root.inputPanelView.gapToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny 
                                                             barMetrics:UIBarMetricsDefault];
            }
    
    setToolBar(self.inputPanel);
    if (enabled && !enableNightTheme && messagesUseBlur)
        setupBlur(self.inputPanel, messagesBlurTone, messagesBlurStyle);
    
    if (!enabled)
        return;
    
    if (enableNightTheme) {
        if ([self.inputPanel respondsToSelector:@selector(pushToTalkCoverView)])
            self.inputPanel.pushToTalkCoverView.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.inputPanel.layer.borderColor = cvkMainController.nightThemeScheme.backgroundColor.CGColor;
        });
    }
    else if (changeMessagesInput) {
        UIButton *inputViewButton = self.inputPanel.inputViewButton;
        UIImage *normalImage = [inputViewButton imageForState:UIControlStateNormal];
        normalImage = [normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [inputViewButton setImage:normalImage forState:UIControlStateNormal];
        inputViewButton.imageView.tintColor = messagesInputTextColor;
        
        self.inputPanel.overlay.backgroundColor = messagesInputBackColor;
        self.inputPanel.overlay.layer.borderColor = messagesInputBackColor.CGColor;
        self.inputPanel.textPanel.textColor = messagesInputTextColor;
        self.inputPanel.textPanel.tintColor = messagesInputTextColor;
        self.inputPanel.textPanel.placeholderLabel.textColor = messagesInputTextColor;
    }
    
    if (self.childViewControllers.count == 0)
        return;
    UICollectionViewController *collectionViewController = self.childViewControllers.firstObject;
    if (![self.childViewControllers.firstObject isKindOfClass:objc_lookUpClass("vkm.HistoryCollectionViewController")])
        return;
    
    UIColor *backColor = enableNightTheme ? cvkMainController.nightThemeScheme.foregroundColor : [UIColor clearColor];
    collectionViewController.view.backgroundColor = backColor;
    collectionViewController.collectionView.backgroundColor = backColor;
}


CHDeclareMethod(0, void, ChatController, viewDidLoad)
{
    CHSuper(0, ChatController, viewDidLoad);
    
    if (![self isKindOfClass:objc_lookUpClass("ChatController")] || !enabled || (enabled && enableNightTheme))
        return;
    
    ColoredVKVersionCompare compareResult = [[ColoredVKNewInstaller sharedInstaller].application compareAppVersionWithVersion:@"3.5"];
    if (hideMessagesNavBarItems) {
        self.navigationItem.titleView.hidden = YES;
        if ([self respondsToSelector:@selector(headerImage)])
            self.headerImage.hidden = YES;
        else if (compareResult >= ColoredVKVersionCompareEqual) {
            UIBarButtonItem *rightBarItem = self.navigationItem.rightBarButtonItem;
            if ([rightBarItem.customView isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)rightBarItem.customView;
                for (UIView *subview in button.subviews) {
                    if ([subview isKindOfClass:objc_lookUpClass("vkm.URLImageView")]) {
                        subview.hidden = YES;
                        break;
                    }
                }
            }
        }
    }
    
    if (!enabled || !enabledMessagesImage)
        return;
    
    BOOL isTableView = [self respondsToSelector:@selector(tableView)];
    UIView *view = isTableView ? self.tableView : self.view;
    
    ColoredVKWallpaperView *wallView = [[ColoredVKWallpaperView alloc] initWithFrame:view.frame imageName:@"messagesBackgroundImage" 
                                                                            blackout:chatImageBlackout enableParallax:useMessagesParallax 
                                                                      blurBackground:messagesUseBackgroundBlur];
    wallView.flip = (compareResult == ColoredVKVersionCompareLess);
    
    if (isTableView) {
        if ([self respondsToSelector:@selector(rptr)])
            self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        
        if (((UITableView *)view).backgroundView.tag != 23)
            ((UITableView *)view).backgroundView = wallView;
    } else {
        [wallView addToBack:view animated:NO];
    }
}

CHDeclareMethod(2, UITableViewCell*, ChatController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, ChatController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && (enabledMessagesImage || enableNightTheme)) {
        if (!enableNightTheme) {
            for (id view in cell.contentView.subviews) {
                if ([view respondsToSelector:@selector(setTextColor:)])
                    [view setTextColor:changeMessagesTextColor?messagesTextColor:[UIColor colorWithWhite:1.0f alpha:0.7f]];
            }
        }
        if ([CLASS_NAME(cell) isEqualToString:@"UITableViewCell"]) cell.backgroundColor = [UIColor clearColor];
    }
    
    return cell;
}

CHDeclareMethod(0, UIButton*, ChatController, editForward)
{
    UIButton *forwardButton = CHSuper(0, ChatController, editForward);
    if (enabled && !enableNightTheme && messagesUseBlur) {
        [forwardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [forwardButton setImage:[[forwardButton imageForState:UIControlStateNormal] cvk_imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        for (UIView *subview in forwardButton.superview.subviews) {
            if ([subview isKindOfClass:[UIToolbar class]]) {
                setupBlur(subview, messagesBlurTone, messagesBlurStyle);
                break;
            }
        }
    }
    return forwardButton;
}

#pragma mark - MessageController
CHDeclareClass(MessageController);
CHDeclareMethod(1, void, MessageController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, MessageController, viewWillAppear, animated);
    resetNavigationBar(self.navigationController.navigationBar);
    resetTabBar();
}


#pragma mark MessageCell
CHDeclareClass(MessageCell);
CHDeclareMethod(1, void, MessageCell, updateBackground, BOOL, animated)
{
    CHSuper(1, MessageCell, updateBackground, animated);
    
    if (enabled && (enabledMessagesImage || enableNightTheme)) {
        self.backgroundView = nil;
        if (!self.message.read_state) {
            if (enableNightTheme)
                self.backgroundColor = cvkMainController.nightThemeScheme.unreadBackgroundColor;
            else
                self.backgroundColor = useCustomMessageReadColor ? messageUnreadColor : [UIColor cvk_defaultColorForIdentifier:@"messageReadColor"];
        } else
            self.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark ChatCell
CHDeclareClass(ChatCell);
CHDeclareMethod(0, void, ChatCell, setBG)
{
    self.bg.alpha = 0.f;
    
    CHSuper(0, ChatCell, setBG);
    
    if (enabled && (useMessageBubbleTintColor || enableNightTheme)) {
        void (^bgHandler)(void) = ^(void){
            if (self.bg.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                self.bg.image = [self.bg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
            if (enableNightTheme)
                self.bg.tintColor = self.message.incoming ? cvkMainController.nightThemeScheme.incomingBackgroundColor : cvkMainController.nightThemeScheme.outgoingBackgroundColor;
            else 
                self.bg.tintColor = self.message.incoming ? messageBubbleTintColor : messageBubbleSentTintColor;
        };
        
        bgHandler();
        [NSObject cvk_runBlockOnMainThread:bgHandler];
    }
    self.bg.alpha = 1.f;
}


#pragma mark _TtC3vkm17MessageBubbleView
CHDeclareClass(_TtC3vkm17MessageBubbleView);
CHDeclareMethod(0, void, _TtC3vkm17MessageBubbleView, layoutSubviews)
{
    CHSuper(0, _TtC3vkm17MessageBubbleView, layoutSubviews);
    
    if (enabled && (useMessageBubbleTintColor || enableNightTheme) && [self isKindOfClass:objc_lookUpClass("_TtC3vkm17MessageBubbleView")]) {
        CAShapeLayer *layer = (CAShapeLayer *)self.layer;
        
        UIColor *incomingColor = enableNightTheme ? cvkMainController.nightThemeScheme.incomingBackgroundColor : messageBubbleTintColor;
        UIColor *outgoingColor = enableNightTheme ? cvkMainController.nightThemeScheme.outgoingBackgroundColor : messageBubbleSentTintColor;
        
        const CGFloat *components = CGColorGetComponents(layer.fillColor);
        if (components[0] >= 0.9f) { // входящее
            layer.fillColor = incomingColor.CGColor;
        } else { // исходящее
            layer.fillColor = outgoingColor.CGColor;
        }
    }
}

CHDeclareClass(_TtC3vkm9BadgeView);
CHDeclareMethod(1, void, _TtC3vkm9BadgeView, willMoveToWindow, UIWindow *, newWindow)
{
    CHSuper(1, _TtC3vkm9BadgeView, willMoveToWindow, newWindow);
    
    if (newWindow) {
        [self addObserver:cvkMainController forKeyPath:@"layer.fillColor" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        [self removeObserver:cvkMainController forKeyPath:@"layer.fillColor"];
    }
}
