//
//  TweakNightFunctions.m
//  ColoredVK2
//
//  Created by Даниил on 18.07.18.
//

#import "Tweak.h"

void setupNewDialogCellForNightTheme(NewDialogCell *dialogCell)
{
    if (enabled && enableNightTheme && [dialogCell isKindOfClass:objc_lookUpClass("NewDialogCell")]) {
        dialogCell.contentView.backgroundColor = [UIColor clearColor];
        dialogCell.backgroundView.hidden = YES;
        
        if ([dialogCell.dialog.head respondsToSelector:@selector(read_state)]) {
            if (!dialogCell.dialog.head.read_state && dialogCell.unread.hidden)
                dialogCell.backgroundColor = cvkMainController.nightThemeScheme.unreadBackgroundColor;
            else
                dialogCell.backgroundColor = cvkMainController.nightThemeScheme.foregroundColor;
        }
        
        dialogCell.name.textColor = cvkMainController.nightThemeScheme.textColor;
        
        NIGHT_THEME_DISABLE_CUSTOMISATION(dialogCell.attach);
        dialogCell.attach.textColor = cvkMainController.nightThemeScheme.detailTextColor;
        
        NIGHT_THEME_DISABLE_CUSTOMISATION(dialogCell.time);
        dialogCell.time.textColor = cvkMainController.nightThemeScheme.detailTextColor;
        
        if ([dialogCell respondsToSelector:@selector(dialogText)]) {
            NIGHT_THEME_DISABLE_CUSTOMISATION(dialogCell.dialogText);
            dialogCell.dialogText.textColor = cvkMainController.nightThemeScheme.detailTextColor;
        }
        if ([dialogCell respondsToSelector:@selector(text)]) {
            if (dialogCell.text) {
                NIGHT_THEME_DISABLE_CUSTOMISATION(dialogCell.text);
                dialogCell.text.textColor = cvkMainController.nightThemeScheme.detailTextColor;
            }
        }
    }
}

NSAttributedString *attributedStringForNightTheme(NSAttributedString *text)
{
    if (enabled && enableNightTheme) {
        NSMutableAttributedString *mutableText = [[NSMutableAttributedString alloc] initWithAttributedString:text];
        [mutableText enumerateAttributesInRange:NSMakeRange(0, mutableText.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            
            void (^setColor)(BOOL isLink, BOOL forMOCTLabel, BOOL detailed) = ^(BOOL isLink, BOOL forMOCTLabel, BOOL detailed) {
                NSString *attribute = forMOCTLabel ? @"CTForegroundColor" : NSForegroundColorAttributeName;
                
                id textColor = cvkMainController.nightThemeScheme.textColor;
                if (isLink)
                    textColor = cvkMainController.nightThemeScheme.linkTextColor;
                if (detailed)
                    textColor = cvkMainController.nightThemeScheme.detailTextColor;
                
                if (attribute.length == 0 || !textColor)
                    return;
                
                if (forMOCTLabel) {
                    textColor = (id)((UIColor *)textColor).CGColor;
                    if (attribute.length == 0 || !textColor)
                        return;
                    
                    if (isLink) {
                        [mutableText addAttribute:@"MOCTLinkInactiveAttributeName" value:@{@"CTForegroundColor": textColor} range:range];
                        [mutableText addAttribute:@"MOCTLinkActiveAttributeName" value:@{@"CTForegroundColor": textColor} range:range];
                    }
                }
                [mutableText addAttribute:attribute value:textColor range:range];
            };
            
            if (attrs[@"MOCTLinkAttributeName"])
                setColor(YES, YES, NO);
            else if (attrs[@"VKTextLink"] || attrs[@"NSLink"])
                setColor(YES, NO, NO);
            else {
                if (attrs[@"CTForegroundColor"])
                    setColor(NO, YES, NO);
                else if (attrs[@"CVKDetailed"])
                    setColor(NO, NO, YES);
                else if (attrs[NSFontAttributeName]) {
                    BOOL isMedium = [((UIFont *)attrs[NSFontAttributeName]).fontName.lowercaseString containsString:@"medium"];
                    BOOL isNumerical = (mutableText.string.integerValue != 0);
                    
                    if (isMedium)
                        setColor(!isNumerical, NO, isNumerical);
                    else
                        setColor(NO, NO, NO);
                    
                } else
                    setColor(NO, NO, NO);
            }
        }];
        return mutableText;
    }
    
    return text;
}


void setupNightSeparatorForView(UIView *view)
{
    if ([CLASS_NAME(view) isEqualToString:@"UIView"] || [CLASS_NAME(view) isEqualToString:@"VKReusableColorView"]) {
        if (enabled && enableNightTheme) {
            if ([cvkMainController.vkMainController respondsToSelector:@selector(tabBarShadowView)]) {
                if ([view isEqual:cvkMainController.vkMainController.tabBarShadowView])
                    return;
            }
            
            void (^setupBlock)(void) = ^{
                if ((CGRectGetHeight(view.frame) < 3.0f) && !CGSizeEqualToSize(CGSizeZero, view.frame.size))
                    view.backgroundColor = cvkMainController.nightThemeScheme.backgroundColor;
            };
            dispatch_async(dispatch_get_main_queue(), setupBlock);
        }
    }
}

void setupNightTextField(UITextField *textField)
{
    if (enabled && enableNightTheme) {
        textField.textColor = cvkMainController.nightThemeScheme.textColor;
        
        UILabel *placeholderLabel = [textField valueForKeyPath:@"_placeholderLabel"];
        if (placeholderLabel) {
            NIGHT_THEME_DISABLE_CUSTOMISATION(placeholderLabel);
            placeholderLabel.textColor = cvkMainController.nightThemeScheme.detailTextColor;
        }
    }
}
