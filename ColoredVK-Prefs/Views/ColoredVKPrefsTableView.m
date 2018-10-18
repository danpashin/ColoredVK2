//
//  ColoredVKPrefsTableView.m
//  ColoredVK2
//
//  Created by Даниил on 18/10/2018.
//

#import "ColoredVKPrefsTableView.h"

@interface UITableView (ColoredVK_Private)
- (UIEdgeInsets)_sectionContentInset;
@end

@implementation ColoredVKPrefsTableView

- (UIEdgeInsets)_sectionContentInset
{
    UIEdgeInsets orig = [super _sectionContentInset];
    return UIEdgeInsetsMake(orig.top, 8.0f, orig.bottom, 8.0f);
}

@end
