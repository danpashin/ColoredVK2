//
//  ColoredVKCellBackgroundView.m
//  ColoredVK-Prefs
//
//  Created by Даниил on 11.03.18.
//

#import "ColoredVKCellBackgroundView.h"
#import "ColoredVKNightScheme.h"

@interface ColoredVKCellBackgroundView ()

@property (strong, nonatomic, readonly) CAShapeLayer *layer; 
@property (strong, nonatomic) CALayer *separatorLayer;

@property (assign, nonatomic) BOOL useExtendedLandscapeEdges;

@end

@implementation ColoredVKCellBackgroundView
@synthesize backgroundColor = _backgroundColor;
@synthesize separatorColor = _separatorColor;
@dynamic layer;

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat height = (screenSize.height > screenSize.width) ? screenSize.height : screenSize.width;
        self.useExtendedLandscapeEdges = (height == 812.0f);
        
        self.separatorLayer = [CALayer layer];
        self.separatorLayer.backgroundColor = self.separatorColor.CGColor;
        [self.layer addSublayer:self.separatorLayer];
    }
    return self;
}

- (void)drawBackground
//:(BOOL)animated
{
    if (!self.tableView || !self.tableViewCell)
        return;
    
    CGFloat xOffset = 0.0f;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) && self.useExtendedLandscapeEdges) {
        xOffset = 36.0f;
    }
    
    CGRect selfBounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    CGRect frame = CGRectInset(selfBounds, 8.0f + xOffset, 0.0f);
    
    CGFloat cornerRadius = 10.f;
    BOOL drawSeparator = YES;
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    if (self.indexPath.row == 0 && self.indexPath.row == [self.tableView numberOfRowsInSection:self.indexPath.section]-1) {
        CGPathAddRoundedRect(pathRef, nil, frame, cornerRadius, cornerRadius);
        drawSeparator = NO;
    } else if (self.indexPath.row == 0) {
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(frame), CGRectGetMaxY(frame));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetMidX(frame), CGRectGetMinY(frame), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(frame), CGRectGetMinY(frame), CGRectGetMaxX(frame), CGRectGetMidY(frame), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(frame), CGRectGetMaxY(frame));
    } else if (self.indexPath.row == [self.tableView numberOfRowsInSection:self.indexPath.section]-1) {
        drawSeparator = NO;
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(frame), CGRectGetMinY(frame));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(frame), CGRectGetMaxY(frame), CGRectGetMidX(frame), CGRectGetMaxY(frame), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(frame), CGRectGetMaxY(frame), CGRectGetMaxX(frame), CGRectGetMidY(frame), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(frame), CGRectGetMinY(frame));
    } else {
        CGPathAddRect(pathRef, nil, frame);
    }
    self.layer.fillColor = self.backgroundColor.CGColor;
    self.layer.frame = self.bounds;
    self.layer.path = pathRef;
    CFRelease(pathRef);
    
    if (drawSeparator) {
        CGFloat separatorHeight = 0.5f;
        self.separatorLayer.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame) - separatorHeight / 2.0f, 
                                               CGRectGetWidth(frame), separatorHeight);
        self.separatorLayer.backgroundColor = self.separatorColor.CGColor;
    }
}


#pragma mark -
#pragma mark Setters
#pragma mark -

- (void)setFrame:(CGRect)frame
{
    if (CGRectEqualToRect(frame, CGRectZero) || CGRectEqualToRect(frame, self.frame))
        return;
    
    super.frame = frame;
    [self drawBackground];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.layer.fillColor = self.backgroundColor.CGColor;
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
        ColoredVKNightScheme *nightScheme = [ColoredVKNightScheme sharedScheme];
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
        ColoredVKNightScheme *nightScheme = [ColoredVKNightScheme sharedScheme];
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
        ColoredVKNightScheme *nightScheme = [ColoredVKNightScheme sharedScheme];
        if (nightScheme.enabled)
            _selectedBackgroundColor = nightScheme.backgroundColor;
        else
            _selectedBackgroundColor = [UIColor colorWithRed:191/255.0f green:191/255.0f blue:191/255.0f alpha:1.0f];
    }
    
    return _selectedBackgroundColor;
}

@end
