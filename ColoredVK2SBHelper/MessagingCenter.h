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
static NSString *const kPackageNotificationWriteData =      @"ru.danpashin.coloredvk2.file.write";
static NSString *const kPackageNotificationRemoveFile =     @"ru.danpashin.coloredvk2.file.remove";
static NSString *const kPackageNotificationMoveFile =       @"ru.danpashin.coloredvk2.file.move";
static NSString *const kPackageNotificationCopyFile =       @"ru.danpashin.coloredvk2.file.copy";

static NSString *const kPackageNotificationCreateFolder =   @"ru.danpashin.coloredvk2.folder.create";
static NSString *const kPackageNotificationFolderContents = @"ru.danpashin.coloredvk2.folder.contents";

static NSString *const kPackageNotificationItemAttributes = @"ru.danpashin.coloredvk2.item.attributes";
NS_ASSUME_NONNULL_END

CPDistributedMessagingCenter *_Nullable cvk_notifyCenter(void);
#endif
