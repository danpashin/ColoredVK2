//
//  UITableViewCell+ColoredVK.m
//  ColoredVK2
//
//  Created by Даниил on 04/02/2018.
//

#import "UITableViewCell+ColoredVK.h"
#import <objc/message.h>
#import "UIColor+ColoredVK.h"
#import "NSString+ColoredVK.h"
#import <PSTableCell.h>
#import <PSSpecifier.h>

@interface UITableViewCell (ColoredVK_Internal)
@property (assign, nonatomic, readonly) BOOL backgroundRendered;
@end

@implementation UITableViewCell (ColoredVK)

+ (void)load
{
    Method origSelected = class_getInstanceMethod(self, @selector(setSelected:animated:));
    Method swizzledSelected = class_getInstanceMethod(self, @selector(cvk_setSelected:animated:));
    method_exchangeImplementations(origSelected, swizzledSelected);
    
    Method origHighlighted = class_getInstanceMethod(self, @selector(setHighlighted:animated:));
    Method swizzledHighlighted = class_getInstanceMethod(self, @selector(cvk_setHighlighted:animated:));
    method_exchangeImplementations(origHighlighted, swizzledHighlighted);
}

- (void)renderBackgroundWithColor:(UIColor *)backgroundColor separatorColor:(UIColor *)separatorColor 
                     forTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    ColoredVKCellBackgroundView *backgroundView = self.customBackgroundView;
    self.backgroundView = backgroundView;
    
    if (!backgroundView.rendered) {
        backgroundView.tableView = tableView;
        backgroundView.tableViewCell = self;
        backgroundView.indexPath = indexPath;
        
        backgroundView.backgroundColor = backgroundColor;
        backgroundView.separatorColor = separatorColor;
        [backgroundView renderBackground];
    }
}

#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setCustomBackgroundView:(ColoredVKCellBackgroundView *)customBackgroundView
{
    if ([self respondsToSelector:@selector(specifier)]) {
        PSSpecifier *specifier = objc_msgSend(self, @selector(specifier));
        if ([specifier isKindOfClass:NSClassFromString(@"PSSpecifier")]) {
            [specifier setProperty:customBackgroundView forKey:@"cellBackgroundView"];
            return;
        }
    }
    
    objc_setAssociatedObject(self, "cellBackgroundView", customBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cvk_setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self cvk_setSelected:selected animated:animated];
    
    if (self.backgroundRendered) {
        ColoredVKCellBackgroundView *backView = self.customBackgroundView;
        void (^animationBlock)(void) = ^{
            backView.backgroundColor = selected ? backView.selectedBackgroundColor : nil;
            backView.separatorColor = nil;
        };
        if (animated) {
            [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction 
                             animations:animationBlock completion:nil];
        } else {
            animationBlock();
        }
    }
}

- (void)cvk_setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [self cvk_setHighlighted:highlighted animated:animated];
    
    if (self.backgroundRendered) {
        ColoredVKCellBackgroundView *backView = self.customBackgroundView;
        backView.backgroundColor = highlighted ? backView.selectedBackgroundColor : nil;
        backView.separatorColor = nil;
    }
}

#pragma mark -
#pragma mark Getters
#pragma mark -

- (BOOL)backgroundRendered
{
    if ([self respondsToSelector:@selector(specifier)]) {
        PSSpecifier *specifier = objc_msgSend(self, @selector(specifier));
        if ([specifier isKindOfClass:NSClassFromString(@"PSSpecifier")]) {
            return [specifier propertyForKey:@"cellBackgroundView"] ? YES : NO;
        }
    }
    
    return objc_getAssociatedObject(self, "cellBackgroundView") ? YES : NO;
}

- (ColoredVKCellBackgroundView *)customBackgroundView
{    
    if ([self respondsToSelector:@selector(specifier)]) {
        PSSpecifier *specifier = objc_msgSend(self, @selector(specifier));
        if ([specifier isKindOfClass:NSClassFromString(@"PSSpecifier")]) {
            ColoredVKCellBackgroundView *customBackgroundView = [specifier propertyForKey:@"cellBackgroundView"];
            if (!customBackgroundView) {
                customBackgroundView = [[ColoredVKCellBackgroundView alloc] initWithFrame:self.bounds];
                self.customBackgroundView = customBackgroundView;
            }
            return customBackgroundView;
        }
    }
    
    ColoredVKCellBackgroundView *customBackgroundView = objc_getAssociatedObject(self, "cellBackgroundView");
    if (!customBackgroundView) {
        customBackgroundView = [[ColoredVKCellBackgroundView alloc] initWithFrame:self.bounds];
        self.customBackgroundView = customBackgroundView;
    }
    return customBackgroundView;
}

@end
