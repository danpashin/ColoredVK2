//
//  ColoredVKFileSystem.h
//  ColoredVK2
//
//  Created by Даниил on 12.07.18.
//


NS_ASSUME_NONNULL_BEGIN

BOOL cvk_writePrefs(NSDictionary *prefs, NSString *_Nullable notificationName);
BOOL cvk_writeData(NSData *data, NSString *path, NSError *__autoreleasing *error);

BOOL cvk_removeItem(NSString *path, NSError *__autoreleasing *error);
BOOL cvk_createFolder(NSString *path, NSError *__autoreleasing *error);
BOOL cvk_moveItem(NSString *oldPath, NSString *newPath, NSError *__autoreleasing *error);
BOOL cvk_copyItem(NSString *path, NSString *copyPath, NSError *__autoreleasing *error);

NSArray <NSString *> *cvk_folderContents(NSString *path, NSError *__autoreleasing *error);
NSDictionary <NSString *, id> *cvk_itemAttributes(NSString *path, NSError *__autoreleasing *error);

NS_ASSUME_NONNULL_END
