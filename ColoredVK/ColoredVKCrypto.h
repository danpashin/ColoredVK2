//
//  ColoredVKCrypto.h
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

@class NSString, NSData, NSError;


extern NSString *AES256EncryptStringForAPI(NSString *string);

extern NSData *reencryptData(NSData *data);
extern NSData *encryptData(NSData *data, NSError * __autoreleasing *error);
extern NSData *decryptData(NSData *data, NSError * __autoreleasing *error);
