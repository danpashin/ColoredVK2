//
//  SCDRM.m
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

#import <Foundation/Foundation.h>
#import "SCDRM.h"
#import "NSError+ColoredVK.h"

#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonHMAC.h>

#import <mach-o/dyld.h>
#import <libgen.h>

#import <sys/sysctl.h>
#import <sys/ioctl.h>
#import <sys/utsname.h>

NSString *const kDRMServerKey = @"ACBEBB5F70D0883E875DAA6E1C5C59ED";
NSString *const KDRMErrorDomain = @"ru.danpashin.coloredvk2.drm.error";

BOOL __suspiciousLibsDetected;
BOOL __deviceIsJailed;

NSString *__cvkNewKey;
NSString *__udid;
NSString *__deviceModel;

NSData *_performCryptOperation(CCOperation operation, NSData *data, NSString *key);
NSData *_performNewCryptOperation(CCOperation operation, NSData *data, NSString *key);
CFPropertyListRef MGCopyAnswer(CFStringRef property);


CVK_INLINE NSString *RSAEncryptServerString(NSString *string)
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [_performCryptOperation(kCCEncrypt, data, kDRMServerKey) base64EncodedStringWithOptions:0];
}

CVK_INLINE NSDictionary *RSADecryptServerData(NSData *rawData, NSURLResponse *response, NSError *__autoreleasing *error)
{
    if (![response.MIMEType isEqualToString:@"multipart/encrypted"]) {
        if (error)
            *error = [NSError cvk_localizedErrorWithDomain:KDRMErrorDomain code:-1000 description:@"Response has invalid header: %@", @"'Content-Type'"];
        return nil;
    }
    
    NSData *decrypted = _performCryptOperation(kCCDecrypt, rawData, kDRMServerKey);
    if (!decrypted || decrypted.length == 0) {
        if (error)
            *error = [NSError cvk_localizedErrorWithDomain:KDRMErrorDomain code:-1001 description:@"Response data can not be decrypted."];
        return nil;
    }
    
    NSString *decryptedString = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    decryptedString = [decryptedString stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    
    NSData *jsonData = [decryptedString dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        if (error)
            *error = [NSError cvk_localizedErrorWithDomain:KDRMErrorDomain code:-1002 description:@"Response data can not be decrypted."];
        return nil;
    }
    
    NSError *jsonError = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
    
    if ([jsonDict isKindOfClass:[NSDictionary class]] && !jsonError) {
        return jsonDict;
    } else {
        if (error)
            *error = jsonError;
        return nil;
    }
}


CVK_INLINE NSDictionary *RSADecryptLicenceData(NSError *__autoreleasing *error)
{
    NSData *licenceData = [NSData dataWithContentsOfFile:CVK_LICENSE_PATH];
    
    if (!licenceData) {
        if (error)
            *error = [NSError cvk_localizedErrorWithDomain:KDRMErrorDomain code:0 description:@"Licence file does not exist."];

        return nil;
    }
    
    NSData *decryptedLicenceData = _performCryptOperation(kCCDecrypt, licenceData, __cvkNewKey);
    NSDictionary *licence = [NSKeyedUnarchiver unarchiveObjectWithData:decryptedLicenceData];
    
    if (![licence isKindOfClass:[NSDictionary class]] || (licence.allKeys.count == 0)) {
        if (error)
            *error = [NSError cvk_localizedErrorWithDomain:KDRMErrorDomain code:0 description:@"Licence file is damaged."];
        
        return nil;
    }
    
    return licence;
}

CVK_INLINE BOOL RSAEncryptAndWriteLicenceData(NSDictionary *licence, NSError *__autoreleasing *error)
{
    NSData *rawData = [NSKeyedArchiver archivedDataWithRootObject:licence];
    NSData *encryptedLicence = _performCryptOperation(kCCEncrypt, rawData, __cvkNewKey);
    
    return cvk_writeData(encryptedLicence, CVK_LICENSE_PATH, error);
}


#pragma mark - Private Functions -

CVK_INLINE NSData *_performCryptOperation(CCOperation operation, NSData *data, NSString *key)
{
    if (key.length == 0)
        return nil;
    
    void *cryptKey = NULL;
    if ([key isEqualToString:__cvkNewKey] || [key isEqualToString:kDRMServerKey]) {
        size_t keySize = kCCKeySizeAES256;
        
        cryptKey = malloc(keySize);
        memset(cryptKey, 0, keySize);
        memcpy(cryptKey, key.UTF8String, keySize);
    } else {
        char keyPtr[kCCKeySizeAES256+1];
        bzero(keyPtr, sizeof(keyPtr));
        [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
        cryptKey = keyPtr;
    }
    
    
    size_t bufferSize = data.length + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          cryptKey, kCCKeySizeAES256,
                                          NULL, data.bytes, data.length, buffer, bufferSize, &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

CVK_INLINE void generateNewKey(void)
{
    char machineName[256];
    size_t machineLength = sizeof(machineName);
    int machineNameID[] = {CTL_HW, HW_MACHINE};
    sysctl(machineNameID, 2, &machineName, &machineLength, NULL, 0);
    if (strlen(machineName) < 5) {
        struct utsname deviceInfo;
        uname(&deviceInfo);
        strlcpy(machineName, deviceInfo.machine, sizeof(deviceInfo.machine));
    }
    __deviceModel = @(machineName);
    
    uint64_t ramSize;
    size_t ramLength = sizeof(ramSize);
    int ramSizeID[] = {CTL_HW, HW_MEMSIZE};
    sysctl(ramSizeID, 2, &ramSize, &ramLength, NULL, 0);
    
    char *rawKey;
    asprintf(&rawKey, "%s%s%llu", kDRMServerKey.UTF8String, machineName, ramSize);
    
    size_t derivedKeyBufferLen = kCCKeySizeAES256;
    uint8_t *derivedKeyBuffer = malloc(derivedKeyBufferLen);
    
    uint8_t *salt = (uint8_t *)&ramSize;
    CCKeyDerivationPBKDF(kCCPBKDF2, rawKey, strlen(rawKey), salt, sizeof(salt), kCCPRFHmacAlgSHA256, 10000, derivedKeyBuffer, derivedKeyBufferLen);
    
    NSData *derivedKey = [NSData dataWithBytesNoCopy:derivedKeyBuffer length:derivedKeyBufferLen];
    __cvkNewKey = [derivedKey base64EncodedStringWithOptions:0];
}


CVK_CONSTRUCTOR
{
    __deviceModel = @"";
    
    __deviceIsJailed = (access("/var/mobile/Library/Preferences/", W_OK) == 0);
    if (__deviceIsJailed) {
        __udid = CFBridgingRelease(MGCopyAnswer(CFSTR("re6Zb+zwFKJNlkQTUeT+/w")));
        __deviceIsJailed = __deviceIsJailed && (__udid.length == 40);
    }
    
    
    if (!__udid || __udid.length != 40) {
        __udid = @"";
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        generateNewKey();
    });
}
