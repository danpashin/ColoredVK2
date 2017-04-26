//
//  ColoredVKCoreData.h
//  ColoredVK
//
//  Created by Даниил on 28/12/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface ColoredVKCoreData : NSObject

@property (strong, nonatomic, readonly) NSURL *cachePath;
@property (strong, nonatomic, readonly) NSManagedObjectContext *managedContext;

- (void)saveContext;

@end
