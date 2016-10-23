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
- (void)startWithUserInfo:(NSDictionary*)userInfo;
- (void)startWithCompletionBlock:( void(^)(BOOL disableTweak) )block;
- (void)startWithUserInfo:(NSDictionary*)userInfo completionBlock:( void(^)(BOOL disableTweak) )block;
@end
