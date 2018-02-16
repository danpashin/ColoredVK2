//
//  ColoredVKColorMapView.m
//  ColoredVK2
//
//  Created by Даниил on 16.02.18.
//

#import "ColoredVKColorMapView.h"

@interface HRColorMapView (ColoredVK_Private)
- (void)createColorMapLayer;
@end

@implementation ColoredVKColorMapView

- (void)createColorMapLayer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super createColorMapLayer];
    });
}

@end
