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
@property (assign, nonatomic) BOOL backgroundRendered;
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

- (void)renderBackgroundForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    UIColor *backgroundColor = [UIColor whiteColor];
    UIColor *separatorColor = [UIColor colorWithRed:232/255.0f green:233/255.0f blue:234/255.0f alpha:1.0f];
    [self renderBackgroundWithColor:backgroundColor separatorColor:separatorColor forTableView:tableView indexPath:indexPath];
}

- (void)renderBackgroundWithColor:(UIColor *)backgroundColor separatorColor:(UIColor *)separatorColor 
                     forTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self respondsToSelector:@selector(specifier)]) {
        PSSpecifier *specifier = objc_msgSend(self, @selector(specifier));
        if ([specifier isKindOfClass:NSClassFromString(@"PSSpecifier")]) {
            UIView *backgroundView = [specifier propertyForKey:@"cellBackgroundView"];
            if ([backgroundView isKindOfClass:[UIView class]]) {
                self.backgroundView = backgroundView;
                return;
            }
        }
    }
    
    if (!self.backgroundRendered) {
        self.backgroundRendered = YES;
        
        CGFloat cornerRadius = 10.f;
        CGRect bounds = CGRectInset(self.bounds, 8, 0);
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = self.bounds;
        layer.fillColor = backgroundColor.CGColor;
        
        CGMutablePathRef pathRef = CGPathCreateMutable();
        BOOL addSeparatorLine = YES;
        if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            addSeparatorLine = NO;
        } else if (indexPath.row == 0) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
        } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
        } else {
            CGPathAddRect(pathRef, nil, bounds);
        }
        layer.path = pathRef;
        CFRelease(pathRef);
        
        if (addSeparatorLine) {
            CALayer *lineLayer = [CALayer layer];
            CGFloat lineHeight = (1.0f / [UIScreen mainScreen].scale);
            CGFloat margin = 8.0f;
            lineLayer.frame = CGRectMake(CGRectGetMinX(bounds) + margin, 0, CGRectGetWidth(bounds) - (margin * 2), lineHeight);
            lineLayer.backgroundColor = separatorColor.CGColor;
            [layer addSublayer:lineLayer];
        }
        
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, [UIScreen mainScreen].scale);
        [layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:bounds];
        backgroundView.image = [backgroundImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        backgroundView.tintColor = backgroundColor;
        backgroundView.contentMode = UIViewContentModeScaleToFill;
        self.backgroundView = backgroundView;
        
        if ([self respondsToSelector:@selector(specifier)]) {
            PSSpecifier *specifier = objc_msgSend(self, @selector(specifier));
            if ([specifier isKindOfClass:NSClassFromString(@"PSSpecifier")]) {
                [specifier setProperty:backgroundView forKey:@"cellBackgroundView"];
            }
        }
    }
}

- (void)updateRenderedBackgroundWithBackgroundColor:(UIColor *)backgroundColor separatorColor:(UIColor *)separatorColor
{
    UIView *backgroundView = self.backgroundView;
    
    if ([self respondsToSelector:@selector(specifier)]) {
        PSSpecifier *specifier = objc_msgSend(self, @selector(specifier));
        if ([specifier isKindOfClass:NSClassFromString(@"PSSpecifier")]) {
            UIView *backView = [specifier propertyForKey:@"cellBackgroundView"];
            if ([backView isKindOfClass:[UIImageView class]]) {
                backgroundView = backView;
            }
        }
    }
    
    if ([backgroundView isKindOfClass:[UIImageView class]]) {
        if (backgroundColor != nil)
            backgroundView.tintColor = backgroundColor;
        
        if ((separatorColor != nil) && (backgroundView.layer.sublayers.count == 1)) {
            CALayer *separatorLayer = backgroundView.layer.sublayers.firstObject;
            separatorLayer.backgroundColor = separatorColor.CGColor;
        }
    }
}


#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setBackgroundRendered:(BOOL)backgroundRendered
{
    if ([self respondsToSelector:@selector(specifier)]) {
        PSSpecifier *specifier = objc_msgSend(self, @selector(specifier));
        if ([specifier isKindOfClass:NSClassFromString(@"PSSpecifier")]) {
            [specifier setProperty:@(backgroundRendered) forKey:@"cellBackgroundRendered"];
            return;
        }
    }
    
    objc_setAssociatedObject(self, "backgroundRendered", @(backgroundRendered), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setRenderedBackroundColor:(UIColor *)renderedBackroundColor
{
    if ([self respondsToSelector:@selector(specifier)]) {
        PSSpecifier *specifier = objc_msgSend(self, @selector(specifier));
        if ([specifier isKindOfClass:NSClassFromString(@"PSSpecifier")]) {
            [specifier setProperty:renderedBackroundColor forKey:@"cellRenderedBackgroundColor"];
            return;
        }
    }
    
    objc_setAssociatedObject(self, "renderedBackroundColor", renderedBackroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setRenderedSeparatorColor:(UIColor *)renderedSeparatorColor
{
    if ([self respondsToSelector:@selector(specifier)]) {
        PSSpecifier *specifier = objc_msgSend(self, @selector(specifier));
        if ([specifier isKindOfClass:NSClassFromString(@"PSSpecifier")]) {
            [specifier setProperty:renderedSeparatorColor forKey:@"cellRenderedSeparatorColor"];
            return;
        }
    }
    
    objc_setAssociatedObject(self, "renderedSeparatorColor", renderedSeparatorColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setRenderedHighlightedColor:(UIColor *)renderedHighlightedColor
{
    if ([self respondsToSelector:@selector(specifier)]) {
        PSSpecifier *specifier = objc_msgSend(self, @selector(specifier));
        if ([specifier isKindOfClass:NSClassFromString(@"PSSpecifier")]) {
            [specifier setProperty:renderedHighlightedColor forKey:@"cellRenderedHighlightedColor"];
            return;
        }
    }
    
    objc_setAssociatedObject(self, "renderedHighlightedColor", renderedHighlightedColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cvk_setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self cvk_setSelected:selected animated:animated];
    
    if (self.backgroundRendered) {
        void (^animationBlock)(void) = ^{
            UIColor *backgroundColor = selected ? self.renderedHighlightedColor : self.renderedBackroundColor;
            [self updateRenderedBackgroundWithBackgroundColor:backgroundColor separatorColor:nil];
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
        UIColor *backgroundColor = highlighted ? self.renderedHighlightedColor : self.renderedBackroundColor;
        [self updateRenderedBackgroundWithBackgroundColor:backgroundColor separatorColor:nil];
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
            NSNumber *backgroundRendered = [specifier propertyForKey:@"cellBackgroundRendered"];
            if (backgroundRendered)
                return backgroundRendered.boolValue;
        }
    }
    
    NSNumber *backgroundRendered = objc_getAssociatedObject(self, "backgroundRendered");
    if (![backgroundRendered isKindOfClass:[NSNumber class]])
        backgroundRendered = @NO;
    
    return backgroundRendered.boolValue;
}

- (UIColor *)renderedBackroundColor
{
    if ([self respondsToSelector:@selector(specifier)]) {
        PSSpecifier *specifier = objc_msgSend(self, @selector(specifier));
        if ([specifier isKindOfClass:NSClassFromString(@"PSSpecifier")]) {
            UIColor *renderedBackroundColor = [specifier propertyForKey:@"cellRenderedBackgroundColor"];
            if (renderedBackroundColor)
                return renderedBackroundColor;
        }
    }
    
    UIColor *renderedBackroundColor = objc_getAssociatedObject(self, "renderedBackroundColor");
    if (![renderedBackroundColor isKindOfClass:[UIColor class]])
        renderedBackroundColor = [UIColor whiteColor];
    
    return renderedBackroundColor;
}

- (UIColor *)renderedSeparatorColor
{
    if ([self respondsToSelector:@selector(specifier)]) {
        PSSpecifier *specifier = objc_msgSend(self, @selector(specifier));
        if ([specifier isKindOfClass:NSClassFromString(@"PSSpecifier")]) {
            UIColor *separatorColor = [specifier propertyForKey:@"cellRenderedSeparatorColor"];
            if (separatorColor)
                return separatorColor;
        }
    }
    
    UIColor *renderedSeparatorColor = objc_getAssociatedObject(self, "renderedSeparatorColor");
    if (![renderedSeparatorColor isKindOfClass:[UIColor class]])
        renderedSeparatorColor = [UIColor colorWithRed:232/255.0f green:233/255.0f blue:234/255.0f alpha:1.0f];
    
    return renderedSeparatorColor;
}

- (UIColor *)renderedHighlightedColor
{
    if ([self respondsToSelector:@selector(specifier)]) {
        PSSpecifier *specifier = objc_msgSend(self, @selector(specifier));
        if ([specifier isKindOfClass:NSClassFromString(@"PSSpecifier")]) {
            UIColor *renderedHighlightedColor = [specifier propertyForKey:@"cellRenderedHighlightedColor"];
            if (renderedHighlightedColor)
                return renderedHighlightedColor;
        }
    }
    
    UIColor *renderedHighlightedColor = objc_getAssociatedObject(self, "renderedHighlightedColor");
    if (![renderedHighlightedColor isKindOfClass:[UIColor class]])
        renderedHighlightedColor = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f];
    
    return renderedHighlightedColor;
}

@end
