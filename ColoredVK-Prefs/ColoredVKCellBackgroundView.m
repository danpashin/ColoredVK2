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

@property (assign, nonatomic) CGRect backgroundFrame;
@property (assign, nonatomic) BOOL useExtendedLandscapeEdges;

@end

@implementation ColoredVKCellBackgroundView

@synthesize backgroundColor = _backgroundColor;
@synthesize separatorColor = _separatorColor;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGFloat height = (screenSize.height > screenSize.width) ? screenSize.height : screenSize.width;
    self.useExtendedLandscapeEdges = (height == 812.0f);
    
    [self renderBackground];
}

- (void)renderBackground
{
    if (!self.tableView || !self.tableViewCell)
        return;
    
    if (self.rendered)
        return;
    
    self.rendered = YES;
    
    self.backgroundLayer = [CAShapeLayer layer];
    self.backgroundLayer.frame = self.bounds;
    [self.layer addSublayer:self.backgroundLayer];
    
    self.separatorLayer = [CALayer layer];
    self.separatorLayer.backgroundColor = self.separatorColor.CGColor;
    [self.backgroundLayer addSublayer:self.separatorLayer];
    
    [self drawBackground];
}

- (void)drawBackground
{
    CGFloat cornerRadius = 10.f;
    CGRect bounds = self.backgroundFrame;
    BOOL drawSeparator = YES;
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    if (self.indexPath.row == 0 && self.indexPath.row == [self.tableView numberOfRowsInSection:self.indexPath.section]-1) {
        CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
        drawSeparator = NO;
    } else if (self.indexPath.row == 0) {
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
    } else if (self.indexPath.row == [self.tableView numberOfRowsInSection:self.indexPath.section]-1) {
        drawSeparator = NO;
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    } else {
        CGPathAddRect(pathRef, nil, bounds);
    }
    self.backgroundLayer.fillColor = self.backgroundColor.CGColor;
    self.backgroundLayer.frame = self.bounds;
    self.backgroundLayer.path = pathRef;
    CFRelease(pathRef);
    
    if (drawSeparator) {
        CGFloat separatorHeight = 0.5f;
        self.separatorLayer.frame = CGRectMake(CGRectGetMinX(self.backgroundFrame), CGRectGetMaxY(self.backgroundFrame) - separatorHeight / 2.0f, 
                                               CGRectGetWidth(self.backgroundFrame), separatorHeight);
        self.separatorLayer.backgroundColor = self.separatorColor.CGColor;
    }
}


#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setFrame:(CGRect)frame
{
    super.frame = frame;
    
    CGFloat xOffset = 0.0f;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) && self.useExtendedLandscapeEdges) {
        xOffset = 36.0f;
    }
    
    CGRect bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
    self.backgroundFrame = CGRectInset(bounds, 8.0f + xOffset, 0.0f);
    
    [self drawBackground];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.backgroundLayer.fillColor = self.backgroundColor.CGColor;
    });
}

- (void)setSeparatorColor:(UIColor *)separatorColor
{
    _separatorColor = separatorColor;
    
    dispatch_async(dispatch_get_main_queue(), ^{
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
            _separatorColor = nightScheme.backgroundColor;
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
            _selectedBackgroundColor = nightScheme.backgroundColor;
        else
            _selectedBackgroundColor = [UIColor colorWithRed:191/255.0f green:191/255.0f blue:191/255.0f alpha:1.0f];
    }
    
    return _selectedBackgroundColor;
}

@end
