//
//  ColoredVKPrefsCell.m
//  ColoredVK2
//
//  Created by Даниил on 27.06.18.
//

#import "ColoredVKPrefsCell.h"

#import "CaptainHook/CaptainHook.h"

#import <objc/runtime.h>
#import "ColoredVKPrefs.h"

@interface ColoredVKPrefsCell ()
@property (assign, nonatomic, readonly) BOOL backgroundRendered;
@end

@implementation ColoredVKPrefsCell

+ (Class)cellClassForSpecifier:(PSSpecifier *)specifier
{
    if (![specifier propertyForKey:@"cellClass"]) {
        return [ColoredVKPrefsCell class];
    }
    
    return [super cellClassForSpecifier:specifier];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self.specifier.properties[@"shouldCenter"] boolValue])
        self.titleLabel.center = self.contentView.center;
    
    if ([self.specifier.properties[@"addDisclosureIndicator"] boolValue])
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (self.type == PSButtonCell) {
        if ([self.specifier.properties[@"style"] isEqualToString:@"Destructive"]) {
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
    [self.specifier setProperty:customBackgroundView forKey:@"cvkCellBackgroundView"];
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
    return [self.specifier propertyForKey:@"cvkCellBackgroundView"] ? YES : NO;
}

- (ColoredVKCellBackgroundView *)customBackgroundView
{
    ColoredVKCellBackgroundView *customBackgroundView = [self.specifier propertyForKey:@"cvkCellBackgroundView"];
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
