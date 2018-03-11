//
//  ColoredVKCellBackgroundView.m
//  ColoredVK-Prefs
//
//  Created by Даниил on 11.03.18.
//

#import "ColoredVKCellBackgroundView.h"
#import "ColoredVKNightThemeColorScheme.h"

@interface ColoredVKCellBackgroundView ()

@property (strong, nonatomic) CAShapeLayer *backgroundLayer;
@property (strong, nonatomic) CALayer *separatorLayer;

@end

@implementation ColoredVKCellBackgroundView

@synthesize backgroundColor = _backgroundColor;
@synthesize separatorColor = _separatorColor;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self renderBackground];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self renderBackground];
    }
    return self;
}

- (void)renderBackground
{
    if (!self.tableView || !self.tableViewCell)
        return;
    
    if (self.rendered)
        return;
    
    self.rendered = YES;
    CGFloat cornerRadius = 10.f;
    CGRect bounds = CGRectInset(self.bounds, 8.0f, 0.0f);
    
    self.backgroundLayer = [CAShapeLayer layer];
    self.backgroundLayer.frame = self.bounds;
    self.backgroundLayer.fillColor = self.backgroundColor.CGColor;
    [self.layer addSublayer:self.backgroundLayer];
        
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    BOOL addSeparatorLine = YES;
    if (self.indexPath.row == 0 && self.indexPath.row == [self.tableView numberOfRowsInSection:self.indexPath.section]-1) {
        CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
        addSeparatorLine = NO;
    } else if (self.indexPath.row == 0) {
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
    } else if (self.indexPath.row == [self.tableView numberOfRowsInSection:self.indexPath.section]-1) {
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    } else {
        CGPathAddRect(pathRef, nil, bounds);
    }
    self.backgroundLayer.path = pathRef;
    CFRelease(pathRef);
    
    if (addSeparatorLine) {
        self.separatorLayer = [CALayer layer];
        self.separatorLayer.frame = CGRectMake(CGRectGetMinX(bounds) + 8.0f, 0.0f, CGRectGetWidth(bounds) - 16.0f, 1.0f / [UIScreen mainScreen].scale);
        self.separatorLayer.backgroundColor = self.separatorColor.CGColor;
        [self.backgroundLayer addSublayer:self.separatorLayer];
    }
}


#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    self.backgroundLayer.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
    
    CGRect bounds = CGRectInset(self.backgroundLayer.frame, 8.0f, 0.0f);
    CGRect separatorLayerFrame = self.separatorLayer.frame;
    separatorLayerFrame.origin.x = CGRectGetMinX(bounds) + 8.0f;
    separatorLayerFrame.size.width = CGRectGetWidth(bounds) - 16.0f;
    self.separatorLayer.frame = separatorLayerFrame;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    if (!self.backgroundLayer)
        return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.backgroundLayer.fillColor = self.backgroundColor.CGColor;
    });
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    _separatorColor = separatorColor;
    if (!self.separatorLayer)
        return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.separatorLayer.backgroundColor = self.separatorColor.CGColor;
    });
}


#pragma mark -
#pragma mark Getters
#pragma mark -

- (UIColor *)backgroundColor
{
    if (!_backgroundColor) {
        ColoredVKNightThemeColorScheme *nightScheme = [ColoredVKNightThemeColorScheme sharedScheme];
        if (nightScheme.enabled)
            _backgroundColor = nightScheme.foregroundColor;
        else
            _backgroundColor = [UIColor whiteColor];
    }
    
    return _backgroundColor;
}

- (UIColor *)separatorColor
{
    if (!_separatorColor)  {
        ColoredVKNightThemeColorScheme *nightScheme = [ColoredVKNightThemeColorScheme sharedScheme];
        if (nightScheme.enabled)
            _backgroundColor = nightScheme.backgroundColor;
        else
            _separatorColor = [UIColor colorWithRed:232/255.0f green:233/255.0f blue:234/255.0f alpha:1.0f];
    }
    return _separatorColor;
}

- (UIColor *)selectedBackgroundColor
{
    if (!_selectedBackgroundColor) {
        ColoredVKNightThemeColorScheme *nightScheme = [ColoredVKNightThemeColorScheme sharedScheme];
        if (nightScheme.enabled)
            _backgroundColor = nightScheme.backgroundColor;
        else
            _selectedBackgroundColor = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f];
    }
    
    return _selectedBackgroundColor;
}

@end
