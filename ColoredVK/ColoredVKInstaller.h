//
//  ColoredVKInstaller.h
//  ColoredVK
//
//  Created by Даниил on 11/09/16.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kDRMLicenceKeyOld       @"BE7555818BC236315C987C1D9B17F"
#define kDRMLicenceKey          @"1D074B10BBA106699DD7D4AED9E595FA"
#define kDRMAuthorizeKey        @"ACBEBB5F70D0883E875DAA6E1C5C59ED"
#define kDRMPackage             @"org.thebigboss.coloredvk2"
#define kDRMPackageName         @"ColoredVK 2"
#define kDRMPackageVersion      kColoredVKVersion
#define kDRMLicencePath         [CVK_PREFS_PATH stringByReplacingOccurrencesOfString:@"plist" withString:@"licence"]
#define kDRMRemoteServerURL     [NSString stringWithFormat:@"http://danpashin.ru/api/v%@/index-new.php", API_VERSION]

FOUNDATION_EXPORT void(^installerCompletionBlock)(BOOL disableTweak);

@interface ColoredVKInstaller : NSObject
+ (instancetype)startInstall;
@end
