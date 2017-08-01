//
//  ColoredVKInstaller.h
//  ColoredVK
//
//  Created by Даниил on 11/09/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//FOUNDATION_EXPORT void(^installerCompletionBlock)(BOOL disableTweak);
//FOUNDATION_EXPORT NSData *AES256EncryptStringForAPI(NSString *string);
//FOUNDATION_EXPORT BOOL licenceContainsKey(NSString *key);
//FOUNDATION_EXPORT id licenceValueForKey(NSString *key);

@interface ColoredVKInstaller : NSObject
+ (instancetype)sharedInstaller;
@end
