//
//  ColoredVKInstaller.h
//  ColoredVK
//
//  Created by Даниил on 11/09/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kDRMLicenceKey          @"BE7555818BC236315C987C1D9B17F"
#define kDRMAuthorizeKey        @"ACBEBB5F70D0883E875DAA6E1C5C59ED"
#define kDRMPackage             @"org.thebigboss.coloredvk2"
#define kDRMPackageName         @"ColoredVK 2"
#define kDRMPackageVersion      kColoredVKVersion
#define kDRMLicencePath         [CVK_PREFS_PATH stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"]
#define kDRMRemoteServerURL     [NSString stringWithFormat:@"http://danpashin.ru/api/v%@/", API_VERSION]

@interface ColoredVKInstaller : NSObject
- (void)install:( void(^)(BOOL disableTweak) )block;
+ (instancetype)sharedInstaller;
@end
