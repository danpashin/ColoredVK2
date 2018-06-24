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
#import <sys/ioctl.h>
#import <mach-o/dyld.h>
#import <libgen.h>

NSString *const kColoredVKServerKey = @"ACBEBB5F70D0883E875DAA6E1C5C59ED";
BOOL allowLibs;
NSString *cvkKey;


CVK_INLINE NSData *performLegacyCrypt(CCOperation operation, NSData *data, NSString *key)
{
    if (key.length == 0)
        return nil;
    
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

CVK_INLINE NSString *legacyEncryptServerString(NSString *string)
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [performLegacyCrypt(kCCEncrypt, data, kColoredVKServerKey) base64EncodedStringWithOptions:0];
}

CVK_INLINE NSData *encryptData(NSData *data, NSError * __autoreleasing *error)
{
    return performLegacyCrypt(kCCEncrypt, data, cvkKey);    
}

CVK_INLINE NSData *decryptData(NSData *data, NSError * __autoreleasing *error)
{
    return performLegacyCrypt(kCCDecrypt, data, cvkKey);
}

CVK_INLINE NSDictionary *decryptServerResponse(NSData *rawData, NSError *__autoreleasing *error)
{
    NSData *decrypted = performLegacyCrypt(kCCDecrypt, rawData, kColoredVKServerKey);
    if (!decrypted || decrypted.length == 0) {
        if (error)
            *error = [NSError errorWithDomain:@"ru.danpashin.coloredvk2.common.error" code:-1001 userInfo:@{NSLocalizedDescriptionKey:@"Cannot decrypt server data."}];
        return nil;
    }
    
    NSString *decryptedString = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    decryptedString = [decryptedString stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    
    NSData *jsonData = [decryptedString dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        if (error)
            *error = [NSError errorWithDomain:@"ru.danpashin.coloredvk2.common.error" code:-1002 userInfo:@{NSLocalizedDescriptionKey:@"Cannot decrypt server data."}];
        return nil;
    }
    
    NSError *jsonError = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
    
    if ([jsonDict isKindOfClass:[NSDictionary class]] && !jsonError) {
        return jsonDict;
    } else {
        *error = jsonError;
        return nil;
    }
}


#pragma mark Private Functions

CVK_INLINE void generateKey(void)
{
    uint64_t ramSize;
    size_t len = sizeof(ramSize);
    int memSizeName[] = {CTL_HW, HW_MEMSIZE};
    sysctl(memSizeName, 2, &ramSize, &len, NULL, 0);
    
    char machine[256];
    len = sizeof(machine);
    int machineName[] = {CTL_HW, HW_MACHINE};
    sysctl(machineName, 2, &machine, &len, NULL, 0);
    
    NSString *string = [NSString stringWithFormat:@"d=%s&r=%llu", machine, ramSize];
    NSData *keyData = [kColoredVKServerKey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *signatureData = [NSMutableData dataWithLength:CC_SHA512_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA512, keyData.bytes, keyData.length, encData.bytes, encData.length, signatureData.mutableBytes);
    NSString *encryptionKey = [signatureData.description stringByReplacingOccurrencesOfString:@" " withString:@""];
    encryptionKey = [encryptionKey stringByReplacingOccurrencesOfString:@"<" withString:@""];
    encryptionKey = [encryptionKey stringByReplacingOccurrencesOfString:@">" withString:@""];
    cvkKey = encryptionKey;
}

CVK_INLINE BOOL isDebugged(void)
{
#ifdef COMPILE_APP
    return NO;
#else
    int fd = STDERR_FILENO;
    
    if (fcntl(fd, F_GETFD, 0) < 0) {
        return NO;
    }
    
    char buf[MAXPATHLEN + 1];
    if (fcntl(fd, F_GETPATH, buf ) >= 0) {
        if (strcmp(buf, "/dev/null") == 0)
            return NO;
        if (strncmp(buf, "/dev/tty", 8) == 0)
            return YES;
    }
    
    int type;
    if (ioctl(fd, FIODTYPE, &type) < 0) {
        return NO;
    }
    
    return type != 2;
#endif
}

CVK_INLINE void checkLibs(void)
{
#ifdef COMPILE_APP
    allowLibs = YES;
#else
    char pathbuf[MAXPATHLEN + 1];
    uint32_t bufsize = sizeof(pathbuf);
    _NSGetExecutablePath(pathbuf, &bufsize);
    
    char *executable_name = basename(pathbuf);
    for(int i = 0; executable_name[i]; i++){
        executable_name[i] = (char)tolower(executable_name[i]);
    }
    
    int maxLibsCount = (strstr(executable_name, "vkclient") != NULL) ? 2 : 1;
    int libsCount = 0;
    for (uint32_t i=0; i<_dyld_image_count(); i++) {
        const char *imageName = _dyld_get_image_name(i);
        if (strstr(imageName, "ColoredVK2") != NULL) {
            libsCount++;
        } else if (strstr(imageName, "coloredvk2") != NULL) {
            libsCount++;
        } else if (strstr(imageName, "Crack") != NULL) {
            libsCount++;
        } else if (strstr(imageName, "crack") != NULL) {
            libsCount++;
        } else if (strstr(imageName, "Hack") != NULL) {
            libsCount++;
        } else if (strstr(imageName, "hack") != NULL) {
            libsCount++;
        }
    }
    
    allowLibs = (libsCount <= maxLibsCount);
#endif
}

CVK_CONSTRUCTOR
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        generateKey();
        checkLibs();
        
        if (isDebugged()) {
            allowLibs = NO;
            abort();
        }
    });
}
