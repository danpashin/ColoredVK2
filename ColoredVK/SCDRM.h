//
//  SCDRM.h
//  ColoredVK2
//
//  Created by Даниил on 07.07.17.
//
//

@class NSDictionary, NSString, NSData, NSError, NSURLResponse;

NS_ASSUME_NONNULL_BEGIN

/**
 Зашифровывает строку для сервера.

 @param string Строка, которая должна быть зашифрована.
 @return Возвращает зашифрованную строку в формате Base64.
 */
extern NSString *RSAEncryptServerString(NSString *string);

/**
 Выполняет расшифровку ответа сервера .

 @param rawData Тело ответа.
 @param response Непосредственно сам ответ, содержащий заголовки.
 @param error Возвращает объект NSError, если произошла ошибка при расшифровке.
 @return Возвращает ответ в формате словаря, если не было ошибок. В ином случае возвращает nil.
 */
extern NSDictionary *_Nullable RSADecryptServerData(NSData *rawData, NSURLResponse *response, NSError *_Nullable *error);

/**
 Выполняет расшифровку лицензии.

 @param error Возвращает объект NSError, если произошла ошибка при расшифровке.
 @return Возвращает данные лицензии в формате словаря, если не было ошибок. В ином случае возвращает nil.
 */
extern NSDictionary *_Nullable RSADecryptLicenceData(NSError *_Nullable *error);

/**
 Выполняет шифрование лицензии.

 @param licence Данные лицензии в формате словаря.
 @param error Возвращает объект NSError, если произошла ошибка при шифрованиии.
 @return Возвращает YES, если ошибок не было. В ином случает возвратит NO.
 */
extern BOOL RSAEncryptAndWriteLicenceData(NSDictionary *licence, NSError *_Nullable *error);

extern BOOL __suspiciousLibsDetected;
extern BOOL __deviceIsJailed;

extern NSString * _Nullable __udid;
extern NSString *__deviceModel;

NS_ASSUME_NONNULL_END
