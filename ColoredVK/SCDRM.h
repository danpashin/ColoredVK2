//
//  SCDRM.h
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

#import <Foundation/Foundation.h>
@class NSDictionary, NSString, NSData, NSError;

//static struct DRMDeviceInfo {
//    bool jailed;
//    char udid[40];
//    
//    bool debugged;
//    bool suspiciousLibsDetected;
//    
//    char deviceModelIdentifier[256];
//};

extern NSString *RSAEncryptServerString(NSString *string);
extern NSDictionary *RSADecryptServerData(NSData *rawData, NSError *__autoreleasing *error);
extern NSDictionary *RSADecryptLicenceData(NSString *licencePath, NSError *__autoreleasing *error);
extern BOOL RSAEncryptAndWriteLicenceData(NSDictionary *licence, NSString *licencePath, NSError *__autoreleasing *error);

extern BOOL __allowLibs;
extern BOOL __deviceIsJailed;

FOUNDATION_EXTERN NSString *__udid;
FOUNDATION_EXTERN NSString *__deviceModel;
