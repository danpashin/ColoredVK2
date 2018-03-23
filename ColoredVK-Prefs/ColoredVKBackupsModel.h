//
//  ColoredVKBackupsModel.h
//  ColoredVK2
//
//  Created by Даниил on 23.03.18.
//

#import <Foundation/Foundation.h>

@class ColoredVKBackupsModel;
@protocol ColoredVKBackupsModelDelegate <NSObject>

@optional
- (void)backupsModel:(ColoredVKBackupsModel *)backupsModel didEndRestoringBackup:(NSString *)backupName;
- (void)backupsModel:(ColoredVKBackupsModel *)backupsModel didEndUpdatingBackups:(NSArray *)backups;

@end

@interface ColoredVKBackupsModel : NSObject

@property (nonatomic, readonly) NSArray <NSString *> *availableBackups;
@property (weak, nonatomic) id <ColoredVKBackupsModelDelegate> delegate;

- (NSString *)readableNameForBackup:(NSString *)backup;

- (void)updateBackups;

- (void)resetSettings;
- (void)createBackup;
- (void)restoreSettingsFromFile:(NSString *)file;

@end
