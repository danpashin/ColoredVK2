//
//  ColoredVKColorMapView.m
//  ColoredVK2
//
//  Created by Даниил on 16.02.18.
//

#import "ColoredVKColorMapView.h"
#import "HRHSVColorUtil.h"
#import "HRColorCursor.h"

@interface HRColorMapView (ColoredVK_Private)
- (void)createColorMapLayer;
- (void)_init;
- (void)updateColorCursor;

@property (atomic, strong) CALayer *colorMapLayer; // brightness 1.0
@property (atomic, strong) CALayer *colorMapBackgroundLayer; // brightness 0 (= black)
@end

@implementation ColoredVKColorMapView

- (void)_init
{
    self.tileSize = @1.0;
    self.saturationUpperLimit = @0.9;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 16.0f;
    
    [super _init];
}

- (CGSize)intrinsicContentSize
{
    if (CGRectIsEmpty(self.frame))
        return CGSizeZero;
    
    return super.intrinsicContentSize;
}

- (void)updateColorCursor
{
    if (!self.color)
        return;
    
    [super updateColorCursor];
}

- (void)createColorMapLayer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super createColorMapLayer];
    });
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect layerFrame = self.frame;
        layerFrame.origin = CGPointZero;
        self.colorMapLayer.frame = layerFrame;
        self.colorMapBackgroundLayer.frame = layerFrame;
    });
}

@end
