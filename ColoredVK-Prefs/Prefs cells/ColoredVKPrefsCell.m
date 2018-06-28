//
//  ColoredVKPrefsCell.m
//  ColoredVK2
//
//  Created by Даниил on 27.06.18.
//

#import "ColoredVKPrefsCell.h"
#import "ColoredVKCellBackgroundView.h"

#import <objc/runtime.h>
#import "ColoredVKPrefs.h"

@interface ColoredVKPrefsCell ()
@property (assign, nonatomic, readonly) BOOL backgroundRendered;
@end

@implementation ColoredVKPrefsCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self.specifier.properties[@"shouldCenter"] boolValue])
        self.titleLabel.center = self.contentView.center;
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier
{
    [super refreshCellContentsWithSpecifier:specifier];
    
    if ([specifier.properties[@"addDisclosureIndicator"] boolValue])
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (self.type == PSButtonCell) {
        if ([specifier.properties[@"style"] isEqualToString:@"Destructive"]) {
            self.titleLabel.textColor = [UIColor redColor];
        } else {
            self.titleLabel.textColor = CVKMainColor;
        }
    }
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
    if ([self.specifier isKindOfClass:[PSSpecifier class]]) {
        [self.specifier setProperty:customBackgroundView forKey:@"cvkCellBackgroundView"];
        return;
    }
    
    objc_setAssociatedObject(self, "cvkCellBackgroundView", customBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
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

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
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
    if ([self.specifier isKindOfClass:[PSSpecifier class]]) {
        return [self.specifier propertyForKey:@"cvkCellBackgroundView"] ? YES : NO;
    }
    
    return objc_getAssociatedObject(self, "cvkCellBackgroundView") ? YES : NO;
}

- (ColoredVKCellBackgroundView *)customBackgroundView
{
    if ([self.specifier isKindOfClass:[PSSpecifier class]]) {
        ColoredVKCellBackgroundView *customBackgroundView = [self.specifier propertyForKey:@"cvkCellBackgroundView"];
        if (!customBackgroundView) {
            customBackgroundView = [[ColoredVKCellBackgroundView alloc] initWithFrame:self.bounds];
            self.customBackgroundView = customBackgroundView;
        }
        return customBackgroundView;
    }
    
    ColoredVKCellBackgroundView *customBackgroundView = objc_getAssociatedObject(self, "cvkCellBackgroundView");
    if (!customBackgroundView) {
        customBackgroundView = [[ColoredVKCellBackgroundView alloc] initWithFrame:self.bounds];
        self.customBackgroundView = customBackgroundView;
    }
    return customBackgroundView;
}

- (SEL)defaultPrefsGetter
{
    return @selector(readPreferenceValue:);
}

- (id)currentPrefsValue
{
    if (self.specifier.hasValidGetter) {
        return self.specifier.performGetter;
    }
    
//    if ([self.specifier.target respondsToSelector:self.defaultPrefsGetter]) {
//        return objc_msgSend(self.specifier.target, self.defaultPrefsGetter, self.specifier);
//    }
    
    return nil;
}

@end
