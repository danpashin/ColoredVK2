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

- (void)sendRequestWithMethod:(NSString *)method url:(NSString *)url parameters:(id)parameters 
                      success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *rawData))sucess 
                      failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;


- (void)sendJSONRequestWithMethod:(NSString *)method stringURL:(NSString *)stringURL parameters:(id)parameters 
                          success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json))sucess 
                          failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

- (void)sendRequest:(NSURLRequest *)request 
            success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *rawData))sucess 
            failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;


- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)urlString parameters:(id)parameters error:(NSError *__autoreleasing *)error;

@end
