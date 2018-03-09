//
//  ColoredVKApplicationModel.h
//  ColoredVK2
//
//  Created by Даниил on 09.03.18.
//

#import <Foundation/Foundation.h>

@interface ColoredVKApplicationModel : NSObject

@property (copy, nonatomic, readonly) NSString *teamIdentifier;
@property (copy, nonatomic, readonly) NSString *teamName;

- (void)updateInfo;

@end
