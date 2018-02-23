//
//  ColoredVKNetworkController.h
//  ColoredVK2
//
//  Created by Даниил on 02.08.17.
//
//

#import <Foundation/Foundation.h>

@interface ColoredVKNetworkController : NSObject

+ (instancetype)controller;

@property (strong, nonatomic, readonly) NSURLSessionConfiguration *configuration;

/*
 *  Отсылает простой запрос на удаленный сервер. Ответ не меняет.
 */
- (void)sendRequestWithMethod:(NSString *)method url:(NSString *)url parameters:(id)parameters 
                      success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *rawData))sucess 
                      failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

/*
 *  Отсылает запрос с предполагаемым ответом в формате JSON и расшифровывает его при необходимости.
 */
- (void)sendJSONRequestWithMethod:(NSString *)method stringURL:(NSString *)stringURL parameters:(id)parameters 
                          success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json))sucess 
                          failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;
/*
 *  Отсылает любой запрос на удаленный сервер, указанный в этом запросе.
 */
- (void)sendRequest:(NSURLRequest *)request 
            success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *rawData))sucess 
            failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

/*
 *  Загружает данные на удаленный сервер методом POST.
 */
- (void)uploadData:(NSData *)dataToUpload toRemoteURL:(NSString *)remoteURL 
           success:(void(^)(NSHTTPURLResponse *response, NSData *rawData))sucess 
           failure:(void(^)(NSHTTPURLResponse *response, NSError *error))failure;


/*
 *  Скачивает данные большого объема во временную папку.
 */
- (void)downloadDataFromURL:(NSString *)stringURL
                    success:(void(^)(NSHTTPURLResponse *response, NSData *rawData))sucess 
                    failure:(void(^)(NSHTTPURLResponse *response, NSError *error))failure;

/*
 *  Формирует запрос из предоставленного URL, параметров и метода.
 */
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)urlString parameters:(id)parameters error:(NSError *__autoreleasing *)error;

@end
