//
//  MessagingCenter.m
//  ColoredVK2
//
//  Created by Даниил on 11.07.18.
//

#import "MessagingCenter.h"

#import <rocketbootstrap/rocketbootstrap.h>
#import <objc/runtime.h>

CPDistributedMessagingCenter *cvk_notifyCenter(void)
{
    CPDistributedMessagingCenter *center = [objc_lookUpClass("CPDistributedMessagingCenter") centerNamed:@"ru.danpashin.coloredvk2.notification-center"];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (center)
            rocketbootstrap_distributedmessagingcenter_apply(center);
    });
    
    return center;
}
