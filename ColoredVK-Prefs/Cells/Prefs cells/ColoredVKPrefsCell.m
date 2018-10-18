//
//  ColoredVKPrefsCell.m
//  ColoredVK2
//
//  Created by Даниил on 27.06.18.
//

#import "ColoredVKPrefsCell.h"

@interface UITableViewCell (ColoredVK_Private)
- (int)sectionLocation;
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


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIRectCorner roundCornersMask = 0;
    int sectionLocation = self.sectionLocation;
    if (sectionLocation == 4)
        roundCornersMask = UIRectCornerAllCorners;
    else if (sectionLocation == 3)
        roundCornersMask = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    else if (sectionLocation == 2)
        roundCornersMask = UIRectCornerTopLeft | UIRectCornerTopRight;
    
    if (roundCornersMask != 0) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = self.bounds;
        
        CGFloat cornerRadius = self.cornerRadius;
        maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:roundCornersMask 
                                                     cornerRadii:CGSizeMake(cornerRadius, cornerRadius)].CGPath;
        self.layer.mask = maskLayer;
    }
}

- (CGFloat)cornerRadius
{
    return 10.0f;
}


#pragma mark -
#pragma mark Getters
#pragma mark -

- (SEL)defaultPrefsGetter
{
    return @selector(readPreferenceValue:);
}

- (id)currentPrefsValue
{
    if (self.specifier.hasValidGetter) {
        return self.specifier.performGetter;
    }
    
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
