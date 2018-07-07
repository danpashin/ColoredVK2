//
//  ColoredVKUINotification.h
//  ColoredVK
//
//  Created by Даниил on 13.04.18.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColoredVKUINotification : UIView

+ (id)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;


+ (void)removeAllNotifications;

+ (void)showWithSubtitle:(NSString *)subtitle;
+ (void)showWithSubtitle:(NSString *)subtitle tapHandler:(void (^)(void))tapHandler;

+ (void)showWithTitle:(NSString *)title subtitle:(NSString *)subtitle;
+ (void)showWithTitle:(NSString *)title subtitle:(NSString *)subtitle tapHandler:(void (^)(void))tapHandler;

- (void)dismiss;
- (void)dismissAfterDelay:(NSTimeInterval)delay;

@end
