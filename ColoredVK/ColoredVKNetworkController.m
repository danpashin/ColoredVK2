//
//  ColoredVKNetworkController.m
//  ColoredVK2
//
//  Created by Даниил on 02.08.17.
//
//

#import "ColoredVKNetworkController.h"
#import "ColoredVKCrypto.h"


@interface ColoredVKNetworkController  () <NSURLSessionDelegate>

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation ColoredVKNetworkController

+ (instancetype)controller
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForResource = 90.0f;
        configuration.allowsCellularAccess = YES;
        
        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        delegateQueue.name = @"com.daniilpashin.coloredvk2.network";
        
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:delegateQueue];
    }
    return self;
}

- (void)sendJSONRequestWithMethod:(NSString *)method stringURL:(NSString *)stringURL parameters:(id)parameters
                          success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json))sucess 
                          failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    NSError *requestError = nil;
    NSURLRequest *request = [self requestWithMethod:method URLString:stringURL parameters:parameters error:&requestError];
    if (requestError) {
        failure(request, nil, requestError);
        return;
    }
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (!error && data) {
                NSError *jsonError = nil;
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (jsonDict && !jsonError) {
                    if (sucess)
                        sucess(request, (NSHTTPURLResponse *)response, jsonDict);
                } else {
                    
                    NSData *decrypted = AES256Decrypt(data, kDRMAuthorizeKey);
                    NSString *decryptedString = [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding];
                    decryptedString = [decryptedString stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                    
                    
                    NSData *jsonData = [decryptedString dataUsingEncoding:NSUTF8StringEncoding];
                    if (!jsonData)
                        jsonData = [NSData data];
                    
                    jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
                    
                    if (jsonDict) {
                        if (sucess)
                            sucess(request, (NSHTTPURLResponse *)response, jsonDict);
                    } else {
                        if (failure)
                            failure(request, (NSHTTPURLResponse *)response, jsonError);
                    }
                }
            } else {
                if (failure)
                    failure(request, (NSHTTPURLResponse *)response, error);
            }
        });
    }];
    
    [task resume];
}

- (void)sendRequest:(NSURLRequest *)request 
            success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *rawData))sucess 
            failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (!error && data) {
                if (sucess)
                    sucess(request, (NSHTTPURLResponse *)response, data);
            } else {
                if (failure)
                    failure(request, (NSHTTPURLResponse *)response, error);
            }
        });
    }];
    [task resume];
}

- (void)sendRequestWithMethod:(NSString *)method url:(NSString *)url parameters:(id)parameters 
                      success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *rawData))sucess 
                      failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{    
    NSError *requestError = nil;
    NSURLRequest *request = [self requestWithMethod:method URLString:url parameters:parameters error:&requestError];
    if (requestError) {
        failure(request, nil, requestError);
        return;
    }
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (!error && data) {
                if (sucess)
                    sucess(request, (NSHTTPURLResponse *)response, data);
            } else {
                if (failure)
                    failure(request, (NSHTTPURLResponse *)response, error);
            }
        });
    }];
    [task resume];
}


- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)urlString parameters:(id)parameters error:(NSError *__autoreleasing *)error
{
    NSArray *methodsAvailable = @[@"GET", @"POST"];
    if (![methodsAvailable containsObject:method.uppercaseString]) {
        *error = [NSError errorWithDomain:NSCocoaErrorDomain code:100 userInfo:@{NSLocalizedDescriptionKey:@"Method is invalid. Must be 'POST' or 'GET'."}];
        return nil;
    }
    
    NSMutableString *stringParameters = [NSMutableString string];
    
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictParameters = (NSDictionary *)parameters;
        for (NSString *key in dictParameters.allKeys) {
            [stringParameters appendFormat:@"%@=%@&", key, dictParameters[key]];
        }
    } else if ([parameters isKindOfClass:[NSString class]]) {
        [stringParameters appendString:(NSString *)parameters];
    } else if (parameters) {
        *error = [NSError errorWithDomain:NSCocoaErrorDomain code:101 userInfo:@{NSLocalizedDescriptionKey:@"Parameters class is invalid. Use NSDictionary or NSString."}];
        return nil;
    }
    
    
    if ([stringParameters hasSuffix:@"&"])
        [stringParameters replaceCharactersInRange:NSMakeRange(stringParameters.length-1, 1) withString:@""];
    
    if ([method.uppercaseString isEqualToString:@"GET"])
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"?%@", stringParameters]];
    
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:self.session.configuration.requestCachePolicy
                                                       timeoutInterval:self.session.configuration.timeoutIntervalForResource];
    if ([method.uppercaseString isEqualToString:@"POST"])
        request.HTTPBody = [stringParameters dataUsingEncoding:NSUTF8StringEncoding];
    
    request.HTTPMethod = method.uppercaseString;
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    return request;
}

@end
