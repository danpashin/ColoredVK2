//
//  ColoredVKCrypto.m
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

#import "ColoredVKCrypto.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

#define kDRMAuthorizeKey        @"ACBEBB5F70D0883E875DAA6E1C5C59ED"
#define kDRMLicenceKey          @"1D074B10BBA106699DD7D4AED9E595FA"

NSData *AES256Decrypt(NSData *data, NSString *key)
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    size_t bufferSize = data.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          NULL, data.bytes, data.length, buffer, bufferSize, &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

NSData *AES256Encrypt(NSData *data, NSString *key)
{
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    size_t bufferSize = data.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256, NULL,
                                          data.bytes, data.length, buffer, bufferSize, &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

NSString *AES256EncryptStringForAPI(NSString *string)
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [AES256Encrypt(data, kDRMAuthorizeKey) base64EncodedStringWithOptions:0];
}




NSData *encryptData(NSData *data, NSError * __autoreleasing *error)
{
    if (@available(iOS 10.0, *)) {
        NSString *domain = @"ru.danpashin.coloredvk2.licence.key";
        
        NSDictionary *attributes = @{ (id)kSecAttrKeyType: (id)kSecAttrKeyTypeECSECPrimeRandom,
                                      (id)kSecAttrKeySizeInBits: @521,
                                      (id)kSecPrivateKeyAttrs: @{
                                              (id)kSecAttrIsPermanent: @YES,
                                              (id)kSecAttrApplicationTag: [domain dataUsingEncoding:NSUTF8StringEncoding],
                                              },
                                      };
        
        NSError *keyError = nil;
        SecKeyRef privateKey = SecKeyCreateRandomKey((__bridge CFDictionaryRef)attributes, (void *)&keyError);
        SecKeyRef publicKey = SecKeyCopyPublicKey(privateKey);
        
        if (keyError) {
            if (error != NULL)
                *error = keyError;
            
            CFRelease(privateKey);
            CFRelease(publicKey);
            return nil;
        }
        
        NSMutableDictionary *keyItemAttributes = [@{ (id)kSecClass : (id)kSecClassKey,
                                                     (id)kSecAttrKeyType : (id)kSecAttrKeyTypeRSA,
                                                     (id)kSecAttrApplicationTag : domain,
                                                     } mutableCopy];
        
        SecItemDelete((__bridge CFDictionaryRef)keyItemAttributes);
        keyItemAttributes[(id)kSecValueRef] = (__bridge_transfer id)privateKey;
        SecItemAdd((__bridge CFDictionaryRef)keyItemAttributes, nil);
        
        NSError *encryptionError = nil;
        CFDataRef encrypted = SecKeyCreateEncryptedData(publicKey, kSecKeyAlgorithmECIESEncryptionStandardX963SHA1AESGCM, (__bridge CFDataRef)data, (void *)&encryptionError);
        CFRelease(publicKey);
        
        if (encryptionError) {
            if (encrypted)
                CFRelease(encrypted);
            if (error != NULL)
                *error = encryptionError;
            return nil;
        } else {
            return (__bridge_transfer NSData *)encrypted;
        }
    } else {
        return AES256Encrypt(data, kDRMLicenceKey);
    }
    
}

NSData *decryptData(NSData *data, NSError * __autoreleasing *error)
{
    if (@available(iOS 10.0, *)) {
        NSString *domain = @"ru.danpashin.coloredvk2.licence.key";
        
        NSDictionary *queryItemAttributes = @{ (id)kSecClass : (id)kSecClassKey,
                                               (id)kSecAttrKeyType : (id)kSecAttrKeyTypeRSA,
                                               (id)kSecAttrApplicationTag : domain,
                                               (id)kSecReturnData : @YES
                                               };
        CFTypeRef item = nil;
        OSStatus queryStatus = SecItemCopyMatching((__bridge CFDictionaryRef)queryItemAttributes, &item);
        
        if (queryStatus != noErr || !item) {
            if (error != NULL)
                *error = [NSError errorWithDomain:@"" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"Cannot get key from."}];
            
            return nil;
        }
        
        NSDictionary *keyAttributes = @{ (id)kSecAttrKeyType: (id)kSecAttrKeyTypeECSECPrimeRandom,
                                         (id)kSecAttrKeyClass : (id)kSecAttrKeyClassPrivate,
                                         (id)kSecAttrKeySizeInBits: @521,
                                         (id)kSecPrivateKeyAttrs: @{
                                                 (id)kSecAttrIsPermanent: @YES,
                                                 (id)kSecAttrApplicationTag: [domain dataUsingEncoding:NSUTF8StringEncoding]
                                                 }
                                         };
        NSError *keyError = nil;
        SecKeyRef privateKey = SecKeyCreateWithData(item, (__bridge CFDictionaryRef)keyAttributes, (void *)&keyError);
        
        if (keyError) {
            CFRelease(privateKey);
            if (error != NULL)
                *error = [NSError errorWithDomain:@"" code:1002 userInfo:@{NSLocalizedDescriptionKey: @"Cannot generate key."}];
            return nil;
        }
        
        NSError *decryptionError = nil;
        CFDataRef decrypted = SecKeyCreateDecryptedData(privateKey, kSecKeyAlgorithmECIESEncryptionStandardX963SHA1AESGCM, (__bridge CFDataRef)data, (void *)&decryptionError);
        CFRelease(privateKey);
        
        if (decryptionError) {
            if (error != NULL)
                *error = decryptionError;
            if (decrypted)
                CFRelease(decrypted);
            return nil;
        } else {
            return (__bridge_transfer NSData *)decrypted;
        }
    } else {
        return AES256Decrypt(data, kDRMLicenceKey);
    }
}

NSData *reencryptData(NSData *data)
{
    NSData *rawData = AES256Decrypt(data, kDRMLicenceKey);
    if (rawData) {
        return encryptData(rawData, nil);
    }
    return data;
}
