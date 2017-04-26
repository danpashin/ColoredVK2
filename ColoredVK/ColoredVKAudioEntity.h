//
//  ColoredVKAudioEntity.h
//  ColoredVK
//
//  Created by Даниил on 25/04/17.
//  Copyright © 2016 Даниил. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ColoredVKAudioEntity : NSManagedObject

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *artist;
@property (copy, nonatomic) NSString *lyrics;

@end
