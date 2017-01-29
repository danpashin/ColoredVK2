//
//  BlackTheme.m
//  ColoredVK
//
//  Created by Даниил on 20/11/16.
//
//

#import "PrefixHeader.h"

#ifdef COMPILE_WITH_BLACK_THEME

#import <Foundation/Foundation.h>
#import "CaptainHook/CaptainHook.h"
#import <UIKit/UIKit.h>
#import "VKMethods.h"
#import "Tweak.h"

#define textBackgroundColor [UIColor.redColor colorWithAlphaComponent:0.3]
#define kNewsTableViewSeparatorColor [UIColor colorWithRed:220.0/255.0f green:221.0/255.0f blue:222.0/255.0f alpha:1]

@interface VKPPBadge : UIImageView
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



UIButton *postCreationButton;

static void setPostCreationButtonColor()
{
    if (enabled && enabledBlackTheme) {
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightBlackColor]] forState:UIControlStateNormal];
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:[UIColor lightBlackColor]] forState:UIControlStateHighlighted];
        
        for (CALayer *layer in postCreationButton.layer.sublayers) {
            if (layer.backgroundColor != nil) layer.backgroundColor = [UIColor darkBlackColor].CGColor;
        }
        
        for (UIView *view in postCreationButton.subviews) {
            if ([@"UIView" isEqualToString:CLASS_NAME(view)]) view.backgroundColor = [UIColor darkBlackColor];
        }
    } else {
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [postCreationButton setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateHighlighted];
        
        for (CALayer *layer in postCreationButton.layer.sublayers) {
            if (layer.backgroundColor == [UIColor darkBlackColor].CGColor) layer.backgroundColor = kNewsTableViewSeparatorColor.CGColor;
        }
        
        for (UIView *view in postCreationButton.subviews) {
            if ([@"UIView" isEqualToString:CLASS_NAME(view)]) view.backgroundColor = kNewsTableViewSeparatorColor;
        }
    }
}



#pragma mark - BLACK THEME
#pragma mark UITableViewCell
CHDeclareClass(UITableViewCell);
CHOptimizedMethod(0, self, void, UITableViewCell, layoutSubviews)
{
    CHSuper(0, UITableViewCell, layoutSubviews);
    if (enabled && enabledBlackTheme) {
        if (self.backgroundColor != [UIColor lightBlackColor]) self.backgroundColor = [UIColor lightBlackColor];
    }
}



#pragma mark UITableViewCellSelectedBackground
CHDeclareClass(UITableViewCellSelectedBackground);
CHOptimizedMethod(1, self, void, UITableViewCellSelectedBackground, drawRect, CGRect, rect)
{
    if (enabled && enabledBlackTheme) {
        if ([self respondsToSelector:@selector(setSelectionTintColor:)]) self.selectionTintColor = [UIColor darkBlackColor];
        
    }
    CHSuper(1, UITableViewCellSelectedBackground, drawRect, rect);
}

#pragma mark UITableViewIndex
CHDeclareClass(UITableViewIndex);
CHOptimizedMethod(0, self, void, UITableViewIndex, layoutSubviews)
{
    if (enabled && enabledBlackTheme) {
        if ([self respondsToSelector:@selector(setIndexBackgroundColor:)]) {
            self.indexColor = [UIColor lightGrayColor];
            self.indexBackgroundColor = [UIColor clearColor];
        }
    }
    CHSuper(0, UITableViewIndex, layoutSubviews);
}

#pragma mark UITableView
CHDeclareClass(UITableView);
CHOptimizedMethod(0, self, void, UITableView, layoutSubviews)
{
    CHSuper(0, UITableView, layoutSubviews);
    
    if (enabled && enabledBlackTheme) {
        self.separatorColor = [UIColor darkBlackColor];
        self.backgroundColor = [UIColor darkBlackColor];
    }
}



#pragma mark PSListController
CHDeclareClass(PSListController);
CHOptimizedMethod(2, self, UITableViewCell*, PSListController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, PSListController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && enabledBlackTheme) {
        tableView.backgroundView = nil;
        tableView.backgroundColor = [UIColor darkBlackColor];
        cell.backgroundColor = [UIColor lightBlackColor];
    } else if (blackThemeWasEnabled) {
        tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        cell.backgroundColor = [UIColor whiteColor]; 
    }
    
    return cell;
}


#pragma mark UILabel
CHDeclareClass(UILabel);
CHOptimizedMethod(1, self, void, UILabel, drawRect, CGRect, rect)
{
    if (enabled && enabledBlackTheme) { 
        self.textColor = [UIColor lightGrayColor];
        self.alpha = 0.8;
    } else if (blackThemeWasEnabled) self.alpha = 1;
    
    CHSuper(1, UILabel, drawRect, rect);
}


#pragma mark UIButton
CHDeclareClass(UIButton);
CHOptimizedMethod(0, self, void, UIButton, layoutSubviews)
{
    CHSuper(0, UIButton, layoutSubviews);
    if (enabled && enabledBlackTheme) self.tintColor = [UIColor colorWithRed:0.7 green:0 blue:0 alpha:1.0];
}

#pragma mark VKMGroupedCell
CHDeclareClass(VKMGroupedCell);
CHOptimizedMethod(2, self, id, VKMGroupedCell, initWithStyle, UITableViewCellStyle, style, reuseIdentifier, NSString*, reuseIdentifier)
{
    VKMGroupedCell *cell = CHSuper(2, VKMGroupedCell, initWithStyle, style, reuseIdentifier, reuseIdentifier);
    
    if (enabled && enabledBlackTheme) cell.contentView.backgroundColor = [UIColor lightBlackColor];
    
    return  cell;
}

#pragma mark VKMSearchBar
CHDeclareClass(VKMSearchBar);
CHOptimizedMethod(1, self, void, VKMSearchBar, setFrame, CGRect, frame)
{
    CHSuper(1, VKMSearchBar, setFrame, frame);
    
    if (enabled && enabledBlackTheme) {
        for (id subview in self.subviews.lastObject.subviews) {
            if ([@"UISearchBarTextField" isEqualToString:CLASS_NAME([subview class])]) {
                UITextField *field = subview;
                field.backgroundColor = [UIColor lightBlackColor];
                field.textColor = [UIColor lightGrayColor];
                self.backgroundImage = [UIImage imageWithColor:[UIColor darkBlackColor]];
                self.tintColor = [UIColor lightGrayColor];
                break;
            }            
        }
    } else if (blackThemeWasEnabled) {
        if ([@"IOS7TableViewWithForcedBottomSeparator" isEqualToString:CLASS_NAME(self.superview)]) {
            for (id subview in self.subviews.lastObject.subviews) {
                if ([@"UISearchBarTextField" isEqualToString:CLASS_NAME([subview class])]) {
                    UITextField *field = subview;
                    field.backgroundColor = [UIColor clearColor];
                    field.textColor = [UIColor colorWithRed:233/255.0f green:234/255.0f blue:235/255.0f alpha:1];
                    self.backgroundImage = nil;
                    break;
                }
            }
        } else {
            for (id subview in self.subviews.lastObject.subviews) {
                if ([@"UISearchBarTextField" isEqualToString:CLASS_NAME(subview)]) {
                    UITextField *field = subview;
                    field.backgroundColor = [UIColor whiteColor];
                    field.textColor = [UIColor blackColor];
                    break;
                }
            }
        }
    }
}

#pragma mark UIAlertController
CHDeclareClass(UIAlertController);
CHOptimizedMethod(1, self, void, UIAlertController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, UIAlertController, viewWillAppear, animated);
    
    if (enabled && enabledBlackTheme) {
        for (UIView *view in self.view.subviews.lastObject.subviews) {
            if ([@"UIView" isEqualToString:CLASS_NAME(view)]) {
                for (UIView *subView in view.subviews) {
                    for (UIView *subSubView in subView.subviews) {
                        for (UIView *anyView in subSubView.subviews) {
                            anyView.backgroundColor = [UIColor lightBlackColor];
                        }
                    }
                }
            }
        }
    }
}

#pragma mark UISegmentedControl
CHDeclareClass(UISegmentedControl);
CHOptimizedMethod(0, self, void, UISegmentedControl, layoutSubviews)
{
    CHSuper(0, UISegmentedControl, layoutSubviews);
    
    if ([self isKindOfClass:NSClassFromString(@"UISegmentedControl")]) {
        if (enabled && enabledBlackTheme) self.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    }
}

#pragma mark UISegmentedControl
CHDeclareClass(UIRefreshControl);
CHOptimizedMethod(0, self, void, UIRefreshControl, layoutSubviews)
{
    CHSuper(0, UIRefreshControl, layoutSubviews);
    
    if ([self isKindOfClass:NSClassFromString(@"UIRefreshControl")]) {
        if (enabled && enabledBlackTheme) self.tintColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    }
}

#pragma mark GLOBAL METHODS
#pragma mark -


#pragma  mark FeedbackController
CHDeclareClass(FeedbackController);
CHOptimizedMethod(2, self, UITableViewCell*, FeedbackController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, FeedbackController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enabledBlackTheme) {
        for (id view in cell.contentView.subviews) {
            if ([@"MOCTLabel" isEqualToString:CLASS_NAME(view)]) {
                UIView *label = view;
                label.layer.backgroundColor = textBackgroundColor.CGColor;
                break;
            }
        }
    } else if (blackThemeWasEnabled) {
        for (id view in cell.contentView.subviews) {
            if ([@"MOCTLabel" isEqualToString:CLASS_NAME(view)]) {
                UIView *label = view;
                label.layer.backgroundColor = [UIColor clearColor].CGColor;
                break;
            }
        }
    }
    return cell;
}

#pragma  mark CountryCallingCodeController
CHDeclareClass(CountryCallingCodeController);
CHOptimizedMethod(2, self, UITableViewCell*, CountryCallingCodeController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, CountryCallingCodeController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enabledBlackTheme) {
        cell.backgroundView = nil;
        cell.backgroundColor = [UIColor lightBlackColor];
        tableView.backgroundView = nil;
        tableView.backgroundColor = [UIColor darkBlackColor];
    }
    return cell;
}

#pragma  mark SignupPhoneController
CHDeclareClass(SignupPhoneController);
CHOptimizedMethod(2, self, UITableViewCell*, SignupPhoneController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, SignupPhoneController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enabledBlackTheme) {
        cell.backgroundView = nil;
        cell.backgroundColor = [UIColor lightBlackColor];
        tableView.backgroundView = nil;
        tableView.backgroundColor = [UIColor darkBlackColor];
        
        [UITextField appearance].textColor = [UIColor lightGrayColor];
        
    }
    return cell;
}

#pragma  mark NewLoginController
CHDeclareClass(NewLoginController);
CHOptimizedMethod(2, self, UITableViewCell*, NewLoginController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, NewLoginController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    if (enabled && enabledBlackTheme) {
        cell.backgroundView = nil;
        cell.backgroundColor = [UIColor lightBlackColor];
        tableView.backgroundView = nil;
        tableView.backgroundColor = [UIColor darkBlackColor];
        
        [UITextField appearance].textColor = [UIColor lightGrayColor];
    }
    return cell;
}

#pragma mark TextEditController
CHDeclareClass(TextEditController);
CHOptimizedMethod(1, self, void, TextEditController, viewWillAppear, BOOL, animated)
{
    CHSuper(1, TextEditController, viewWillAppear, animated);
    if (enabled && enabledBlackTheme) {
        self.textView.backgroundColor = [UIColor darkBlackColor];
        self.textView.textColor = [UIColor lightGrayColor];
        
        for (id view in self.view.subviews) {
            if ([view isKindOfClass:UIView.class]) {
                for (UIView *subView in [view subviews]) {
                    if ([subView isKindOfClass:NSClassFromString(@"LayoutAwareView")]) {
                        for (UIView *subSubView in subView.subviews) {
                            if ([subSubView isKindOfClass:UIToolbar.class]) ((UIToolbar*)subSubView).barTintColor = [UIColor lightBlackColor];
                        }
                    }
                }
            }
        }
    }
}


#pragma mark User profile
CHDeclareClass(ProfileView);
CHOptimizedMethod(0, self, void, ProfileView, layoutSubviews)
{
    CHSuper(0, ProfileView, layoutSubviews);
    if (enabled && enabledBlackTheme) {
        if ([@"VKMAccessibilityTableView" isEqualToString:CLASS_NAME(self.superview)]) {
            if (![@"UITableViewHeaderFooterView" isEqualToString:CLASS_NAME(self)]) {
                self.backgroundColor = [UIColor lightBlackColor];
            }
        }
    }
}








#pragma mark DetailController
CHDeclareClass(DetailController);
CHOptimizedMethod(2, self, UITableViewCell*, DetailController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, DetailController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    
    if (enabled && enabledBlackTheme) {
        tableView.backgroundView  = nil;
        tableView.separatorColor = [UIColor darkBlackColor];
        cell.contentView.backgroundColor = [UIColor lightBlackColor];
        
        for (UIView *view in cell.contentView.subviews) {
            NSString *class = CLASS_NAME(view);
            
            if ([@"UIView" isEqualToString:class]) view.backgroundColor = [UIColor blackColor];
            
            if ([@"TextKitLabelInteractive" isEqualToString:class]) {
                for (CALayer *layer in view.layer.sublayers) {
                    if ([layer isKindOfClass:NSClassFromString(@"TextKitLayer")]) {
                        layer.backgroundColor = textBackgroundColor.CGColor;
                        break;
                    }
                }
            }
            if ([@"UITextView" isEqualToString:class]) {
                UITextView *textView = (UITextView*)view;
                textView.backgroundColor = [UIColor lightBlackColor];
                textView.textColor = [UIColor lightGrayColor];
            }
            if ([@"UILabel" isEqualToString:class]) view.alpha = 0.5;
            if ([@"VKMLabel" isEqualToString:class]) view.layer.backgroundColor = textBackgroundColor.CGColor;
        }
    }
    
    
    return cell;
}

#pragma mark FeedController
CHDeclareClass(FeedController);
CHOptimizedMethod(2, self, UITableViewCell*, FeedController, tableView, UITableView*, tableView, cellForRowAtIndexPath, NSIndexPath*, indexPath)
{
    UITableViewCell *cell = CHSuper(2, FeedController, tableView, tableView, cellForRowAtIndexPath, indexPath);
    
    if (enabled && enabledBlackTheme) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (UIView *view in cell.contentView.subviews) {
                if ([view isKindOfClass:NSClassFromString(@"TapableComponentView")]) {
                    for (UIView *subview in view.subviews) {
                        if ([subview isKindOfClass:NSClassFromString(@"TextKitLabelInteractive")]) {
                            for (CALayer *layer in subview.layer.sublayers) {
                                if ([layer isKindOfClass:NSClassFromString(@"TextKitLayer")]) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        layer.backgroundColor = textBackgroundColor.CGColor;
                                    });
                                    break;
                                }
                            }
                        }
                    }
                }   
            }
        });
    } else if (blackThemeWasEnabled) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            for (UIView *view in cell.contentView.subviews) {
                if ([view isKindOfClass:NSClassFromString(@"TapableComponentView")]) {
                    for (UIView *subview in view.subviews) {
                        if ([subview isKindOfClass:NSClassFromString(@"TextKitLabelInteractive")]) {
                            for (CALayer *layer in subview.layer.sublayers) {
                                if ([layer isKindOfClass:NSClassFromString(@"TextKitLayer")]) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        layer.backgroundColor = [UIColor clearColor].CGColor;
                                    });
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        });
    }
    return cell;
}


    //CHDeclareClass(VKRenderedText);
    //CHOptimizedMethod(0, self, NSAttributedString*, VKRenderedText, text)
    //{
    //    NSAttributedString *string = CHSuper(0, VKRenderedText, text);
    //    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithString:string.string attributes:@{}];
    //    NSRange range = NSMakeRange(0, mutableString.string.length);
    //    CHLog(@"%@", NSStringFromRange(range));
    //    [mutableString addAttribute:NSForegroundColorAttributeName value:UIColor.redColor range:range];
    //    string = [mutableString copy];
    //    CHLog(@"%@", [mutableString copy]);
    //    return [mutableString copy];
    //}




#pragma mark NewsFeedPostCreationButton
CHDeclareClass(NewsFeedPostCreationButton);
CHOptimizedMethod(1, self, id, NewsFeedPostCreationButton, initWithFrame, CGRect, frame)
{
    UIButton *origButton = CHSuper(1, NewsFeedPostCreationButton, initWithFrame, frame);
    
    postCreationButton = origButton;
    setPostCreationButtonColor();
    
    return origButton;
}


CHDeclareClass(VKPPBadge);
CHOptimizedMethod(0, self, void, VKPPBadge, layoutSubviews)
{
    if ([self isKindOfClass:NSClassFromString(@"VKPPBadge")] && (enabled && enabledBlackTheme)) self.image = [self.image imageWithTintColor:[UIColor colorWithWhite:0.2 alpha:1]];
    CHSuper(0, VKPPBadge, layoutSubviews);
}

#pragma mark BLACK THEME
#pragma mark -


CHConstructor
{
    @autoreleasepool {
        if (VKVersion() >= 22) {
            
            CHLoadLateClass(UITableView);
            CHHook(0, UITableView, layoutSubviews);
            
            CHLoadLateClass(UITableViewIndex);
            CHHook(0, UITableViewIndex, layoutSubviews);
            
            
            CHLoadLateClass(PSListController);
            CHHook(2, PSListController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(UITableViewCell);
            CHHook(0, UITableViewCell, layoutSubviews);
            
            
            CHLoadLateClass(UITableViewCellSelectedBackground);
            CHHook(1, UITableViewCellSelectedBackground, drawRect);
            
            
            CHLoadLateClass(UILabel);
            CHHook(1, UILabel, drawRect);
            
            
            CHLoadLateClass(UIButton);
            CHHook(0, UIButton, layoutSubviews);
            
            
            CHLoadLateClass(VKMSearchBar);
            CHHook(1, VKMSearchBar, setFrame);
            
            
            CHLoadLateClass(UIAlertController);
            CHHook(1, UIAlertController, viewWillAppear);
            
            
            CHLoadLateClass(UISegmentedControl);
            CHHook(0, UISegmentedControl, layoutSubviews);
            
            
            CHLoadLateClass(UIRefreshControl);
            CHHook(0, UIRefreshControl, layoutSubviews);
            
            CHLoadLateClass(VKPPBadge);
            CHHook(0, VKPPBadge, layoutSubviews);
            
            
            CHLoadLateClass(FeedbackController);
            CHHook(2, FeedbackController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(CountryCallingCodeController);
            CHHook(2, CountryCallingCodeController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(SignupPhoneController);
            CHHook(2, SignupPhoneController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(NewLoginController);
            CHHook(2, NewLoginController, tableView, cellForRowAtIndexPath);
            
            CHLoadLateClass(TextEditController);
            CHHook(1, TextEditController, viewWillAppear);
            
            
            CHLoadLateClass(VKMGroupedCell);
            CHHook(2, VKMGroupedCell, initWithStyle, reuseIdentifier);
            
            CHLoadLateClass(FeedController);
            CHHook(2, FeedController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(DetailController);
            CHHook(2, DetailController, tableView, cellForRowAtIndexPath);
            
            
            CHLoadLateClass(ProfileView);
            CHHook(0, ProfileView, layoutSubviews);
            
            
            CHLoadLateClass(NewsFeedPostCreationButton);
            CHHook(1, NewsFeedPostCreationButton, initWithFrame);
//                                CHLoadLateClass(VKRenderedText);
//                                CHHook(0, VKRenderedText, text);
        }
    }
}

#endif

