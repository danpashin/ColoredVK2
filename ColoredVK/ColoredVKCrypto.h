//
//  ColoredVKCrypto.h
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

#import <CommonCrypto/CommonCryptor.h>
@class NSString, NSData, NSError;

extern NSString *const kColoredVKServerKey;
extern NSData *performLegacyCrypt(CCOperation operation, NSData *data, NSString *key);
extern NSString *legacyEncryptServerString(NSString *string);

extern NSData *encryptData(NSData *data, NSError * __autoreleasing *error);
extern NSData *decryptData(NSData *data, NSError * __autoreleasing *error);

extern BOOL allowLibs;
