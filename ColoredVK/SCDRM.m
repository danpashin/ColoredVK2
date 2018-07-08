//
//  SCDRM.m
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

#import <Foundation/Foundation.h>
#import "SCDRM.h"

#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonHMAC.h>

#import <mach-o/dyld.h>
#import <libgen.h>

#import <sys/sysctl.h>
#import <sys/ioctl.h>
#import <sys/utsname.h>



NSString *const kDRMServerKey = @"ACBEBB5F70D0883E875DAA6E1C5C59ED";
NSString *const KDRMErrorKey = @"ru.danpashin.coloredvk2.drm.error";

BOOL __suspiciousLibsDetected;
BOOL __deviceIsJailed;

NSString *__cvkKey;
NSString *__udid;
NSString *__deviceModel;

NSData *_performCryptOperation(CCOperation operation, NSData *data, NSString *key);
CFPropertyListRef MGCopyAnswer(CFStringRef property);



CVK_INLINE NSString *RSAEncryptServerString(NSString *string)
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [_performCryptOperation(kCCEncrypt, data, kDRMServerKey) base64EncodedStringWithOptions:0];
}

CVK_INLINE NSDictionary *RSADecryptServerData(NSData *rawData, NSError *__autoreleasing *error)
{
    NSData *decrypted = _performCryptOperation(kCCDecrypt, rawData, kDRMServerKey);
    if (!decrypted || decrypted.length == 0) {
        if (error)
            *error = [NSError errorWithDomain:KDRMErrorKey code:-1001 userInfo:@{NSLocalizedDescriptionKey:@"Cannot decrypt server data."}];
        return nil;
    }
    
    NSString *decryptedString = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
    decryptedString = [decryptedString stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    
    NSData *jsonData = [decryptedString dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        if (error)
            *error = [NSError errorWithDomain:KDRMErrorKey code:-1002 userInfo:@{NSLocalizedDescriptionKey:@"Cannot decrypt server data."}];
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


CVK_INLINE NSDictionary *RSADecryptLicenceData(NSString *licencePath, NSError *__autoreleasing *error)
{
    NSData *licenceData = [NSData dataWithContentsOfFile:licencePath];
    if (!licenceData) {
        if (error)
            *error = [NSError errorWithDomain:KDRMErrorKey code:0 userInfo:@{NSLocalizedDescriptionKey:@"Licence does not exist"}];
        
        return nil;
    }
    
    NSData *decryptedLicenceData = _performCryptOperation(kCCDecrypt, licenceData, __cvkKey);
    NSDictionary *licence = [NSKeyedUnarchiver unarchiveObjectWithData:decryptedLicenceData];
    
    if (![licence isKindOfClass:[NSDictionary class]] || (licence.allKeys.count == 0)) {
        if (error)
            *error = [NSError errorWithDomain:KDRMErrorKey code:0 userInfo:@{NSLocalizedDescriptionKey:@"Licence file is not valid"}];
        
        return nil;
    }
    
    return licence;
}

CVK_INLINE BOOL RSAEncryptAndWriteLicenceData(NSDictionary *licence, NSString *licencePath, NSError *__autoreleasing *error)
{
    NSData *rawData = [NSKeyedArchiver archivedDataWithRootObject:licence];
    NSData *encryptedLicence = _performCryptOperation(kCCEncrypt, rawData, __cvkKey);
    
    return [encryptedLicence writeToFile:licencePath options:NSDataWritingAtomic error:error];
}


#pragma mark - Private Functions -

CVK_INLINE NSData *_performCryptOperation(CCOperation operation, NSData *data, NSString *key)
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

CVK_INLINE NSString *deviceModel()
{
    char machine[256];
    size_t length = sizeof(machine);
    int machineName[] = {CTL_HW, HW_MACHINE};
    sysctl(machineName, 2, &machine, &length, NULL, 0);
    if (strlen(machine) >= 5) {
        return @(machine);
    }
    
    struct utsname deviceInfo;
    uname(&deviceInfo);
    
    return @(deviceInfo.machine);
}

CVK_INLINE void generateKey(void)
{
    __deviceModel = deviceModel();
    
    uint64_t ramSize;
    size_t len = sizeof(ramSize);
    int memSizeName[] = {CTL_HW, HW_MEMSIZE};
    sysctl(memSizeName, 2, &ramSize, &len, NULL, 0);
    
    NSString *string = [NSString stringWithFormat:@"d=%@&r=%llu", __deviceModel, ramSize];
    NSData *keyData = [kDRMServerKey dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *signatureData = [NSMutableData dataWithLength:CC_SHA512_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA512, keyData.bytes, keyData.length, encData.bytes, encData.length, signatureData.mutableBytes);
    NSString *encryptionKey = [signatureData.description stringByReplacingOccurrencesOfString:@" " withString:@""];
    encryptionKey = [encryptionKey stringByReplacingOccurrencesOfString:@"<" withString:@""];
    encryptionKey = [encryptionKey stringByReplacingOccurrencesOfString:@">" withString:@""];
    __cvkKey = encryptionKey;
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
    __suspiciousLibsDetected = NO;
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
        } 
//        else if (strstr(imageName, "Crack") != NULL) {
//            libsCount++;
//        } else if (strstr(imageName, "crack") != NULL) {
//            libsCount++;
//        } else if (strstr(imageName, "Hack") != NULL) {
//            libsCount++;
//        } else if (strstr(imageName, "hack") != NULL) {
//            libsCount++;
//        }
    }
    
    __suspiciousLibsDetected = (libsCount > maxLibsCount);
#endif
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
        generateKey();
        checkLibs();
        
        if (isDebugged()) {
            __suspiciousLibsDetected = YES;
            abort();
        }
    });
}
