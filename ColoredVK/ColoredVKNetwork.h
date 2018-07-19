//
//  ColoredVKNetwork.h
//  ColoredVK2
//
//  Created by Даниил on 02.08.17.
//
//

#import <Foundation/Foundation.h>

/**
 *  Блок, который вызывается при успешном запросе.
 *
 *  @param request Оригинальный запрос.
 *  @param httpResponse Ответ сервера, его заголовки.
 *  @param rawData Тело ответа. 
 */
typedef void(^ColoredVKNetworkSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSData *rawData);

/**
 *  Блок, который вызывается при неудачном запросе.
 *
 *  @param request Оригинальный запрос.
 *  @param httpResponse Ответ сервера, его заголовки.
 *  @param error Ошибка запроса. 
 */
typedef void(^ColoredVKNetworkFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSError *error);


@interface ColoredVKNetwork : NSObject

+ (instancetype)sharedNetwork;

@property (strong, nonatomic, readonly) NSString *defaultUserAgent;
@property (strong, nonatomic, readonly) NSURLSessionConfiguration *configuration;

/**
 *  Отсылает простой запрос на удаленный сервер.
 *
 *  @param method Метод запроса. На данный момент валиден POST и GET. Регистр значения не имеет.
 *  @param url Адрес удаленного сервера. Может быть уже отформатирован как GET запрос.
 *  @param parameters Параметры для построения запроса. Могут быть как в формате строки @"arg1=val1&arg2=val2", так и в формате массива. Другие форматы не предусмотрены.
 *  @param success Блок, который вызывается при успешном запросе. Содержит оригинальный запрос, ответ и данные ответа.
 *  @param failure Блок, который вызывается при неудачном запросе. Содержит оригинальный запрос, ответ и ошибку запроса.
 */
- (void)sendRequestWithMethod:(NSString *)method url:(NSString *)url parameters:(id)parameters 
                      success:(ColoredVKNetworkSuccessBlock)success 
                      failure:(ColoredVKNetworkFailureBlock)failure;

/**
 *  Отсылает запрос с предполагаемым ответом в формате JSON.
 *
 *  @param method Метод запроса. На данный момент валиден POST и GET. Регистр значения не имеет.
 *  @param stringURL Адрес удаленного сервера. Может быть уже отформатирован как GET запрос.
 *  @param parameters Параметры для построения запроса. Могут быть как в формате строки @"arg1=val1&arg2=val2", так и в формате массива. Другие форматы не предусмотрены.
 *  @param success Блок, который вызывается при успешном запросе. Содержит оригинальный запрос, ответ и данные ответа.
 *  @param failure Блок, который вызывается при неудачном запросе. Содержит оригинальный запрос, ответ и ошибку запроса.
 */
- (void)sendJSONRequestWithMethod:(NSString *)method stringURL:(NSString *)stringURL parameters:(id)parameters 
                          success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *httpResponse, NSDictionary *json))success 
                          failure:(ColoredVKNetworkFailureBlock)failure;
/**
 *  Отсылает любой запрос на удаленный сервер, указанный в этом запросе.
 *
 *  @param request Объект запроса. Должен быть построен и отформатирован.
 *  @param success Блок, который вызывается при успешном запросе. Содержит оригинальный запрос, ответ и данные ответа.
 *  @param failure Блок, который вызывается при неудачном запросе. Содержит оригинальный запрос, ответ и ошибку запроса.
 */
- (void)sendRequest:(NSURLRequest *)request success:(ColoredVKNetworkSuccessBlock)success failure:(ColoredVKNetworkFailureBlock)failure;

/**
 *  Загружает данные на удаленный сервер методом POST.
 *
 *  @param dataToUpload Данные для загрузки.
 *  @param remoteURL Адрес удаленного сервера.
 *  @param success Блок, который вызывается при успешном запросе. Содержит оригинальный запрос и данные ответа.
 *  @param failure Блок, который вызывается при неудачном запросе. Содержит оригинальный запрос и ошибку запроса.
 */
- (void)uploadData:(NSData *)dataToUpload toRemoteURL:(NSString *)remoteURL 
           success:(void(^)(NSHTTPURLResponse *httpResponse, NSData *rawData))success 
           failure:(void(^)(NSHTTPURLResponse *httpResponse, NSError *error))failure;


/**
 *  Выполняет скачивание данных.
 *
 *  @param stringURL Адрес удаленного сервера. Может быть уже отформатирован как GET запрос.
 *  @param success Блок, который вызывается при успешном запросе. Содержит оригинальный запрос и данные ответа.
 *  @param failure Блок, который вызывается при неудачном запросе. Содержит оригинальный запрос и ошибку запроса.
 */
- (void)downloadDataFromURL:(NSString *)stringURL
                    success:(void(^)(NSHTTPURLResponse *httpResponse, NSData *rawData))success 
                    failure:(void(^)(NSHTTPURLResponse *httpResponse, NSError *error))failure;

/**
 *  Выполняет построение запроса, используя указанные аргументы.
 *
 *  @param method Метод запроса. На данный момент валиден POST и GET. Регистр значения не имеет.
 *  @param urlString Адрес удаленного сервера. Может быть уже отформатирован как GET запрос.
 *  @param parameters Параметры для построения запроса. Могут быть как в формате строки @"arg1=val1&arg2=val2", так и в формате массива. Другие форматы не предусмотрены.
 *  @param error Возвращает ошибку при выполнении построения.
 *
 *  @return Возвращает запрос, если при построении не было никаких ошибок. В ином случае возвращает nil.
 */
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)urlString parameters:(id)parameters error:(NSError *__autoreleasing *)error;

@end
