//
//  MessagingCenter.h
//  ColoredVK2
//
//  Created by Даниил on 11.07.18.
//

#import <Foundation/Foundation.h>


#ifdef COMPILE_FOR_JAIL
#import <AppSupport/CPDistributedMessagingCenter.h>

NS_ASSUME_NONNULL_BEGIN
static NSString *const kPackageNotificationWritePrefs = @"ru.danpashin.coloredvk2.prefs.write";
static NSString *const kPackageNotificationWriteData =  @"ru.danpashin.coloredvk2.data.write";
static NSString *const kPackageNotificationRemoveFile =  @"ru.danpashin.coloredvk2.file.remove";
static NSString *const kPackageNotificationCreateFolder =  @"ru.danpashin.coloredvk2.folder.create";
NS_ASSUME_NONNULL_END

CPDistributedMessagingCenter *_Nullable cvk_notifyCenter(void);
#endif
