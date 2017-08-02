//
//  ColoredVKNetworkController.h
//  ColoredVK2
//
//  Created by Даниил on 02.08.17.
//
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const ColoredVKNetworkMethodPost;
FOUNDATION_EXPORT NSString *const ColoredVKNetworkMethodGet;

@interface ColoredVKNetworkController : NSObject

+ (instancetype)controller;

- (void)sendRequestWithMethod:(NSString *)method url:(NSURL *)url parameters:(NSString *)parameters 
                      success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json))sucess 
                      failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

- (void)sendJSONRequestWithURL:(NSURL *)url parameters:(NSString *)parameters 
                       success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json))sucess 
                       failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

@end
