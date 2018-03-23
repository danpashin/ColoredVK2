//
//  ChatSwizzle.m
//  ColoredVK2
//
//  Created by Даниил on 23.03.18.
//

#import "Tweak.h"


#pragma mark GroupsController - список групп
CHDeclareClass(GroupsController);
CHDeclareMethod(0, void, GroupsController, viewDidLoad)
{
    CHSuper(0, GroupsController, viewDidLoad);
    if ([self isKindOfClass:NSClassFromString(@"GroupsController")]) {
        if (enabled && !enableNightTheme && enabledGroupsListImage) {
            [ColoredVKMainController setImageToTableView:self.tableView withName:@"groupsListBackgroundImage" blackout:groupsListImageBlackout
                                          parallaxEffect:useGroupsListParallax blurBackground:groupsListUseBackgroundBlur];
            self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
            self.tableView.separatorColor = hideGroupsListSeparators ? [UIColor clearColor] : [self.tableView.separatorColor colorWithAlphaComponent:0.2f];
            self.segment.alpha = 0.9f;
            
            UIColor *textColor = changeGroupsListTextColor ? groupsListTextColor : [UIColor colorWithWhite:1.0f alpha:0.7f];
            UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
            if ([search isKindOfClass:NSClassFromString(@"VKSearchBar")]) {
                setupNewSearchBar((VKSearchBar *)search, textColor, groupsListBlurTone, groupsListBlurStyle);
            } else if ([search isKindOfClass:[UISearchBar class]] && [search respondsToSelector:@selector(setBackgroundImage:)]) {
                search.backgroundImage = [UIImage new];
                search.scopeBarBackgroundImage = [UIImage new];
                search.tag = 2;
                search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
                search.searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:search.searchBarTextField.placeholder 
                                                                                                  attributes:@{NSForegroundColorAttributeName:textColor}];
            }            
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, GroupsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, GroupsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"GroupsController")] && enabled && !enableNightTheme && enabledGroupsListImage) {
        if ([cell isKindOfClass:NSClassFromString(@"GroupCell")]) {
            GroupCell *groupCell = (GroupCell *)cell;
            performInitialCellSetup(groupCell);
            groupCell.name.textColor = changeGroupsListTextColor?groupsListTextColor:[UIColor colorWithWhite:1.0f alpha:0.9f];
            groupCell.name.backgroundColor = UITableViewCellBackgroundColor;
            groupCell.status.textColor = changeGroupsListTextColor?groupsListTextColor:[UIColor colorWithWhite:0.8f alpha:0.9f];
            groupCell.status.backgroundColor = UITableViewCellBackgroundColor;
        } else  if ([cell isKindOfClass:NSClassFromString(@"VKMRendererCell")]) {
            performInitialCellSetup(cell);
            
            for (UIView *view in cell.contentView.subviews) {
                if ([view isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)view;
                    label.textColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
                    label.backgroundColor = [UIColor clearColor];
                }
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
    ColoredVKVersionCompare compareResult = [[ColoredVKNewInstaller sharedInstaller].application compareAppVersionWithVersion:@"3.0"];
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")] && (compareResult < 0)) {
        if (enabled && !enableNightTheme && enabledMessagesListImage) {
            [ColoredVKMainController setImageToTableView:self.tableView withName:@"messagesListBackgroundImage" blackout:chatListImageBlackout 
                                          parallaxEffect:useMessagesListParallax blurBackground:messagesListUseBackgroundBlur];
        }
    }
}

CHDeclareMethod(1, void, DialogsController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DialogsController, viewWillAppear, animated);
    if (!enableNightTheme && [self isKindOfClass:NSClassFromString(@"DialogsController")]) {
        UISearchBar *search = (UISearchBar*)self.tableView.tableHeaderView;
        if ([search isKindOfClass:[UISearchBar class]]) {
            search.tag = 1;
        }
        
        ColoredVKVersionCompare compareResult = [[ColoredVKNewInstaller sharedInstaller].application compareAppVersionWithVersion:@"3.0"];
        UIColor *placeholderColor = (compareResult >= 0) ? UITableViewCellTextColor : [UIColor colorWithRed:0.556863f green:0.556863f blue:0.576471f alpha:1.0f];
        placeholderColor = (enabled && changeMessagesListTextColor) ? messagesListTextColor : placeholderColor;
        
        if (enabled && enabledMessagesListImage) {
            self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
            self.tableView.separatorColor =  hideMessagesListSeparators ? [UIColor clearColor] : [self.tableView.separatorColor colorWithAlphaComponent:0.2f];
            
            if ([search isKindOfClass:NSClassFromString(@"VKSearchBar")]) {
                setupNewSearchBar((VKSearchBar *)search, placeholderColor, messagesListBlurTone, messagesListBlurStyle);
            } else if ([search isKindOfClass:[UISearchBar class]]) {
                search.searchBarTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
                search.backgroundImage = [UIImage new];
                search._scopeBarBackgroundView.superview.hidden = YES;
            }
            
        } else if (compareResult >= 0) {
            self.rptr.tintColor = nil;
            self.tableView.separatorColor = [UIColor colorWithRed:215/255.0f green:216/255.0f blue:217/255.0f alpha:1.0f];
            if ([search isKindOfClass:NSClassFromString(@"VKSearchBar")]) {
                resetNewSearchBar((VKSearchBar *)search);
            } if ([search isKindOfClass:[UISearchBar class]]) {
                search.searchBarTextField.backgroundColor = nil;
                search._scopeBarBackgroundView.superview.hidden = NO;
                search.backgroundImage = [UIImage imageWithColor:[UIColor colorWithRed:235/255.0f green:237/255.0f blue:240/255.0f alpha:1.0f]];
            } else {
                objc_removeAssociatedObjects(search);
            }
        }
        
        if ([search isKindOfClass:[UISearchBar class]]) {
            NSMutableAttributedString *placeholder = [search.searchBarTextField.attributedPlaceholder mutableCopy];
            [placeholder addAttribute:NSForegroundColorAttributeName value:placeholderColor range:NSMakeRange(0, placeholder.string.length)];
            search.searchBarTextField.attributedPlaceholder = placeholder;
        }
        
        if (compareResult >= 0) {
            if (enabled && !enableNightTheme && enabledMessagesListImage) {
                [ColoredVKMainController setImageToTableView:self.tableView withName:@"messagesListBackgroundImage" blackout:chatListImageBlackout 
                                              parallaxEffect:useMessagesListParallax blurBackground:messagesListUseBackgroundBlur];
                [ColoredVKMainController forceUpdateTableView:self.tableView withBlackout:chatListImageBlackout blurBackground:messagesListUseBackgroundBlur];
            } else
                self.tableView.backgroundView = nil;
        }
    }
}

CHDeclareMethod(2, UITableViewCell*, DialogsController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    NewDialogCell *cell = (NewDialogCell *)CHSuper(2, DialogsController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if ([self isKindOfClass:NSClassFromString(@"DialogsController")]) {
        if (enabled && !enableNightTheme && enabledMessagesListImage ) {
            performInitialCellSetup(cell);
            cell.backgroundView.hidden = YES;
            
            if (!cell.dialog.head.read_state && cell.unread.hidden) cell.contentView.backgroundColor = useCustomDialogsUnreadColor?dialogsUnreadColor:[UIColor defaultColorForIdentifier:@"dialogsUnreadColor"];
            else cell.contentView.backgroundColor = [UIColor clearColor];
            
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
            self.layer.backgroundColor = useCustomDialogsUnreadColor ? dialogsUnreadColor.CGColor : [UIColor defaultColorForIdentifier:@"messageReadColor"].CGColor;
        else
            CHSuper(1, BackgroundView, drawRect, rect);
    } else CHSuper(1, BackgroundView, drawRect, rect);
}

#pragma mark DetailController + тулбар
CHDeclareClass(DetailController);
CHDeclareMethod(1, void, DetailController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, DetailController, viewWillAppear, animated);
    if ([self isKindOfClass:NSClassFromString(@"DetailController")]) setToolBar(self.inputPanel);
}


#pragma mark ChatController + тулбар
CHDeclareClass(ChatController);
CHDeclareMethod(1, void, ChatController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, ChatController, viewWillAppear, animated);
    
    if ([self isKindOfClass:NSClassFromString(@"ChatController")]) {
        if ([self respondsToSelector:@selector(root)])
            if ([self.root respondsToSelector:@selector(inputPanelView)])
                if ([self.root.inputPanelView respondsToSelector:@selector(gapToolbar)])
                    [self.root.inputPanelView.gapToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        
        setToolBar(self.inputPanel);
        if (enabled && !enableNightTheme && messagesUseBlur)
            setBlur(self.inputPanel, YES, messagesBlurTone, messagesBlurStyle);
        
        if (enabled) {
            if (enableNightTheme) {
                if ([self.inputPanel respondsToSelector:@selector(pushToTalkCoverView)])
                    self.inputPanel.pushToTalkCoverView.backgroundColor = cvkMainController.nightThemeScheme.navbackgroundColor;
            }
            else if (changeMessagesInput) {
                UIButton *inputViewButton = self.inputPanel.inputViewButton;
                [inputViewButton setImage:[[inputViewButton imageForState:UIControlStateNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                inputViewButton.imageView.tintColor = messagesInputTextColor;
                
                self.inputPanel.overlay.backgroundColor = messagesInputBackColor;
                self.inputPanel.overlay.layer.borderColor = messagesInputBackColor.CGColor;
                self.inputPanel.textPanel.textColor = messagesInputTextColor;
                self.inputPanel.textPanel.tintColor = messagesInputTextColor;
                self.inputPanel.textPanel.placeholderLabel.textColor = messagesInputTextColor;
            }
        }
        
    }
}


CHDeclareMethod(0, void, ChatController, viewDidLoad)
{
    CHSuper(0, ChatController, viewDidLoad);
    
    if ([self isKindOfClass:NSClassFromString(@"ChatController")]) {
        if (enabled) {
            if (hideMessagesNavBarItems) {
                self.headerImage.hidden = YES;
                self.navigationItem.titleView.hidden = YES;
            }
            if (enabledMessagesImage) {
                self.rptr.tintColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
                [ColoredVKMainController setImageToTableView:self.tableView withName:@"messagesBackgroundImage" blackout:chatImageBlackout 
                                                        flip:YES parallaxEffect:useMessagesParallax blurBackground:messagesUseBackgroundBlur];
            }
        }
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
        [forwardButton setImage:[[forwardButton imageForState:UIControlStateNormal] imageWithTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        for (UIView *subview in forwardButton.superview.subviews) {
            if ([subview isKindOfClass:[UIToolbar class]]) {
                setBlur(subview, YES, messagesBlurTone, messagesBlurStyle);
                break;
            }
        }
    }
    return forwardButton;
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
                self.backgroundColor = useCustomMessageReadColor ? messageUnreadColor : [UIColor defaultColorForIdentifier:@"messageReadColor"];
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
        dispatch_async(dispatch_get_main_queue(), bgHandler);
    }
    self.bg.alpha = 1.f;
}
