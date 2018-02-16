//
//  ColoredVKColorMapView.h
//  ColoredVK2
//
//  Created by Даниил on 16.02.18.
//

#import <UIKit/UIKit.h>
#import "HRColorMapView.h"

@interface HRColorMapView (ColoredVK)
- (instancetype)initWithFrame:(CGRect)frame saturationUpperLimit:(CGFloat)saturationUpperLimit;
@end

@interface ColoredVKColorMapView : HRColorMapView

@end
