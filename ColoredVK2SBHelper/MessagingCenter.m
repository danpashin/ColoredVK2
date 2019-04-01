//
//  MessagingCenter.m
//  ColoredVK2
//
//  Created by Даниил on 11.07.18.
//

#import "MessagingCenter.h"

#define ROCKETBOOTSTRAP_LOAD_DYNAMIC
#import <rocketbootstrap/rocketbootstrap.h>
#import <objc/runtime.h>

CPDistributedMessagingCenter *cvk_notifyCenter(void)
{
    static CPDistributedMessagingCenter *center;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [CPDistributedMessagingCenter centerNamed:@"ru.danpashin.coloredvk2.notification-center"];
        if (center)
            rocketbootstrap_distributedmessagingcenter_apply(center);
    });
    
    return center;
}
