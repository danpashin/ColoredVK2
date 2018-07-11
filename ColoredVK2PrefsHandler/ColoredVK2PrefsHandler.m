//
//  ColoredVK2PrefsHandler.m
//  ColoredVK2PrefsHandler
//
//  Created by Даниил on 11.07.18.
//  Copyright (c) 2018 Daniil Pashin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <CPDistributedMessagingCenter.h>
#import <dlfcn.h>
#import <objc/runtime.h>

@interface ColoredVKSBHandler : NSObject
@end
@implementation ColoredVKSBHandler

+ (void)handleMessageNamed:(NSString *)name userInfo:(NSDictionary *)userInfo
{
    if ([name isEqualToString:@"ru.danpashin.coloredvk2.write.prefs"]) {
        [self writePrefs:userInfo];
    }
}

+ (void)writePrefs:(NSDictionary *)notifyUserInfo
{
    if ([notifyUserInfo[@"prefs"] isKindOfClass:[NSDictionary class]]) {
        [((NSDictionary *)notifyUserInfo[@"prefs"]) writeToFile:CVK_PREFS_PATH atomically:YES];
        POST_CORE_NOTIFICATION(kPackageNotificationUpdateNightTheme);
    }
}

@end

CVK_CONSTRUCTOR
{
	@autoreleasepool {
        dlopen("/System/Library/PrivateFrameworks/AppSupport.framework/AppSupport", RTLD_NOW);
        
        CPDistributedMessagingCenter *center = [objc_lookUpClass("CPDistributedMessagingCenter") centerNamed:@"ru.danpashin.coloredvk2.notification-center"];
        rocketbootstrap_distributedmessagingcenter_apply(center);
        [center registerForMessageName:@"ru.danpashin.coloredvk2.write.prefs" target:[ColoredVKSBHandler class] selector:@selector(handleMessageNamed:userInfo:)];
        [center runServerOnCurrentThread];
	}
}
