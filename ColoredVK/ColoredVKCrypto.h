//
//  ColoredVKCrypto.h
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

#import <Foundation/Foundation.h>

#define kDRMAuthorizeKey        @"ACBEBB5F70D0883E875DAA6E1C5C59ED"

FOUNDATION_EXPORT NSData *AES256Decrypt(NSData *data, NSString *key);
FOUNDATION_EXPORT NSData *AES256Encrypt(NSData *data, NSString *key);
FOUNDATION_EXPORT NSData *AES256EncryptString(NSString *string, NSString *key);
FOUNDATION_EXPORT NSString *AES256EncryptStringForAPI(NSString *string);
