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
@property (strong, nonatomic) UIColor *cachedBackgroundColor;
@property (strong, nonatomic) UIView *cachedSelectedBackgroundView;
@end

@implementation ColoredVKPrefsCell

- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier
{
    [super refreshCellContentsWithSpecifier:specifier];
    
    if ([specifier.properties[@"shouldCenter"] boolValue])
        [self setAlignment:PSTableCellAlignmentCenter];
    
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

- (void)renderBackgroundWithColor:(UIColor *)backgroundColor forTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    if (!self.backgroundView) {
        ColoredVKCellBackgroundView *backgroundView = self.customBackgroundView;
        backgroundView.tableView = tableView;
        backgroundView.tableViewCell = self;
        backgroundView.indexPath = indexPath;
        
        self.selectedBackgroundView = self.cachedSelectedBackgroundView;
        self.backgroundColor = backgroundColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundView = backgroundView;
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
            backView.backgroundColor = selected ? backView.selectedBackgroundColor : self.cachedBackgroundColor;
            backView.separatorColor = backView.tableView.separatorColor;
        };
        if (animated) {
            [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction 
                             animations:animationBlock completion:nil];
        } else {
            animationBlock();
        }
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (!backgroundColor)
        backgroundColor = [UIColor whiteColor];
    
    self.cachedBackgroundColor = backgroundColor;
    
    if (self.backgroundRendered) {
        self.customBackgroundView.backgroundColor = backgroundColor;
    }
}

- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView
{
    self.cachedSelectedBackgroundView = selectedBackgroundView;
    
    if (self.backgroundRendered) {
        self.customBackgroundView.selectedBackgroundColor = selectedBackgroundView.backgroundColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    if (self.backgroundRendered) {
        ColoredVKCellBackgroundView *backView = self.customBackgroundView;
        backView.backgroundColor = highlighted ? backView.selectedBackgroundColor : self.cachedBackgroundColor;
        backView.separatorColor = backView.tableView.separatorColor;
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
            customBackgroundView = [[ColoredVKCellBackgroundView alloc] init];
            self.customBackgroundView = customBackgroundView;
        }
        return customBackgroundView;
    }
    
    ColoredVKCellBackgroundView *customBackgroundView = objc_getAssociatedObject(self, "cvkCellBackgroundView");
    if (!customBackgroundView) {
        customBackgroundView = [[ColoredVKCellBackgroundView alloc] init];
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

- (BOOL)cellEnabled
{
    NSNumber *specifierEnabled = [self.specifier propertyForKey:@"enabled"];
    if (specifierEnabled)
        return specifierEnabled.boolValue;
    
    return YES;
}

- (nullable UIViewController *)forceTouchPreviewController
{
    return nil;
}

@end
