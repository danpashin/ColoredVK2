//
//  ColoredVKCrypto.m
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

#import <Foundation/Foundation.h>
#import "ColoredVKCrypto.h"
#import <CommonCrypto/CommonHMAC.h>
#include <sys/sysctl.h>

NSString *const kColoredVKServerKey = @"ACBEBB5F70D0883E875DAA6E1C5C59ED";

NSData *performLegacyCrypt(CCOperation operation, NSData *data, NSString *key)
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    size_t bufferSize = data.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL, data.bytes, data.length, buffer, bufferSize, &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

NSString *legacyEncryptServerString(NSString *string)
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [performLegacyCrypt(kCCEncrypt, data, kColoredVKServerKey) base64EncodedStringWithOptions:0];
}


static NSString *encryptionKey()
{
    static NSString *encryptionKey = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uint64_t ramSize;
        size_t len = sizeof(ramSize);
        sysctlbyname("hw.memsize", &ramSize, &len, NULL, 0);
        
        char machine[256];
        len = sizeof(machine);
        sysctlbyname("hw.machine", &machine, &len, NULL, 0);
        
        NSString *string = [NSString stringWithFormat:@"device=%s&ramSize=%llu", machine, ramSize];
        NSData *keyData = [kColoredVKServerKey dataUsingEncoding:NSUTF8StringEncoding];
        NSData *encData = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableData *signatureData = [NSMutableData dataWithLength:CC_SHA512_DIGEST_LENGTH];
        CCHmac(kCCHmacAlgSHA512, keyData.bytes, keyData.length, encData.bytes, encData.length, signatureData.mutableBytes);
        encryptionKey = [signatureData.description stringByReplacingOccurrencesOfString:@" " withString:@""];
        encryptionKey = [encryptionKey stringByReplacingOccurrencesOfString:@"<" withString:@""];
        encryptionKey = [encryptionKey stringByReplacingOccurrencesOfString:@">" withString:@""];
    });
    
    return encryptionKey;
}

NSData *encryptData(NSData *data, NSError * __autoreleasing *error)
{
    return performLegacyCrypt(kCCEncrypt, data, encryptionKey());    
}

NSData *decryptData(NSData *data, NSError * __autoreleasing *error)
{
    return performLegacyCrypt(kCCDecrypt, data, encryptionKey());
}
