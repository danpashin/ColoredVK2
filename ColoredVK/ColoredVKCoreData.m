//
//  ColoredVKCoreData.m
//  ColoredVK
//
//  Created by Даниил on 28/12/16.
//
//

#import "ColoredVKCoreData.h"
#import "PrefixHeader.h"
#import <ColoredVKAlertController.h>

@interface ColoredVKCoreData ()

@property (strong, nonatomic) NSPersistentStoreCoordinator *coordinator;

@end

@implementation ColoredVKCoreData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cachePath = [NSURL fileURLWithPath:CVK_CACHE_PATH];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:CVK_CACHE_PATH])  [fileManager createDirectoryAtPath:CVK_CACHE_PATH withIntermediateDirectories:NO attributes:nil error:nil];
        
        NSURL *modelURL = [[NSBundle bundleWithPath:CVK_BUNDLE_PATH] URLForResource:@"ColoredVK2" withExtension:@"mom"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        NSURL *storeURL = [self.cachePath URLByAppendingPathComponent:@"ColoredVK2.sqlite"];
        NSError *error = nil;
        _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        if (![_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            CVKLog(@"Unresolved error %@, %@", error, error.userInfo);
            [self showWarningAlert:error.userInfo];
        }
        
        _managedContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _managedContext.persistentStoreCoordinator = self.coordinator;
    }
    return self;
}

- (void)saveContext
{
    NSError *error = nil;
    if (self.managedContext.hasChanges && ![self.managedContext save:&error]) {
        CVKLog(@"Unresolved error %@, %@", error, error.userInfo);
        [self showWarningAlert:error.userInfo];
    }
}

- (void)showWarningAlert:(NSDictionary *)dict
{
    ColoredVKAlertController *alertController = [ColoredVKAlertController alertControllerWithTitle:kPackageName
                                                                                           message:[NSString stringWithFormat:@"Unresolved error:\n\n%@", dict] 
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
    [alertController addCancelActionWithTitle:UIKitLocalizedString(@"OK")];
    [alertController present];
}

@end
