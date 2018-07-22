//
//  SCDRM.h
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

@class NSDictionary, NSString, NSData, NSError;

extern NSString *RSAEncryptServerString(NSString *string);
extern NSDictionary *RSADecryptServerData(NSData *rawData, NSError *__autoreleasing *error);
extern NSDictionary *RSADecryptLicenceData(NSError *__autoreleasing *error);
extern BOOL RSAEncryptAndWriteLicenceData(NSDictionary *licence, NSError *__autoreleasing *error);

extern BOOL __suspiciousLibsDetected;
extern BOOL __deviceIsJailed;

FOUNDATION_EXTERN NSString *__udid;
FOUNDATION_EXTERN NSString *__deviceModel;
