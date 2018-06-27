//
//  ColoredVKNewInstaller.h
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

#import "ColoredVKUserModel.h"
#import "ColoredVKApplicationModel.h"
#import "SCDRM.h"

@interface ColoredVKNewInstaller : NSObject

FOUNDATION_EXPORT void(^installerCompletionBlock)(BOOL purchased);
FOUNDATION_EXPORT BOOL installerShouldOpenPrefs;

+ (instancetype)sharedInstaller;

@property (strong, nonatomic, readonly) ColoredVKUserModel *user;
@property (strong, nonatomic, readonly) ColoredVKApplicationModel *application;

- (void)createFolders;
- (void)checkStatus;

@end
