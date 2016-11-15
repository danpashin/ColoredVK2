//
//  ColoredVKInstaller.h
//  ColoredVK
//
//  Created by Даниил on 11/09/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ColoredVKInstaller : NSObject
- (void)startWithCompletionBlock:( void(^)(BOOL disableTweak) )block;
@end
