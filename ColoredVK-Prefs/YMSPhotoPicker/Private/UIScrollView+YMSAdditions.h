//
//  UIScrollView+YMSAdditions.h
//  YangMingShan
//
//  Copyright 2016 Yahoo Inc.
//  Licensed under the terms of the BSD license. Please see LICENSE file in the project root for terms.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, YMSScrollViewScrollDirection) {
    YMSScrollViewScrollDirectionUp,
    YMSScrollViewScrollDirectionDown,
    YMSScrollViewScrollDirectionLeft,
    YMSScrollViewScrollDirectionRight,
    YMSScrollViewScrollDirectionUnknown
};

@interface UIScrollView(YMSAdditions)

@property (nonatomic, readonly) YMSScrollViewScrollDirection scrollDirection;
@property (nonatomic, readonly) CGPoint lastContentOffset;

/** 
 * Put yms_scrollViewDidScroll inside scrollViewDidScroll: to update scrollDirection
 */
- (void)yms_scrollViewDidScroll;

@end
