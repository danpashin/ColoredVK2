//
//  ColoredVKNetworkController.m
//  ColoredVK2
//
//  Created by Даниил on 02.08.17.
//
//

#import "ColoredVKNetworkController.h"
#import "ColoredVKCrypto.h"
#import "PrefixHeader.h"


@interface ColoredVKNetworkController  () <NSURLSessionDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSOperationQueue *operationQueue;

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
        _configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _configuration.timeoutIntervalForResource = 90.0f;
        _configuration.allowsCellularAccess = YES;
        _configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
        
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.name = @"com.daniilpashin.coloredvk2.network";
        
        _session = [NSURLSession sessionWithConfiguration:_configuration delegate:self delegateQueue:_operationQueue];
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
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [task resume];
}

- (void)sendRequest:(NSURLRequest *)request 
            success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSData *rawData))sucess 
            failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [task resume];
}

- (void)uploadData:(NSData *)dataToUpload toRemoteURL:(NSString *)remoteURL 
           success:(void(^)(NSHTTPURLResponse *response, NSData *rawData))sucess 
           failure:(void(^)(NSHTTPURLResponse *response, NSError *error))failure
{
    if (dataToUpload) {
        NSError *requestError = nil;        
        NSMutableURLRequest *request = [self requestWithMethod:@"POST" URLString:remoteURL parameters:nil error:&requestError];
        if (requestError) {
            if (failure)
                failure(nil, requestError);
        }
        
        NSURLSessionDataTask *task = [self.session uploadTaskWithRequest:request fromData:dataToUpload 
                                                       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                           [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                           if (!error) {
                                                               if (sucess)
                                                                   sucess((NSHTTPURLResponse *)response, data);
                                                           } else {
                                                               if (failure)
                                                                   failure((NSHTTPURLResponse *)response, error);
                                                           }
                                                       }];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [task resume];
    }
}

- (void)downloadDataFromURL:(NSString *)stringURL
                    success:(void(^)(NSHTTPURLResponse *response, NSData *rawData))sucess 
                    failure:(void(^)(NSHTTPURLResponse *response, NSError *error))failure
{
    NSError *requestError = nil;        
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" URLString:stringURL parameters:nil error:&requestError];
    if (requestError) {
        if (failure)
            failure(nil, requestError);
    }
    
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request
                                                         completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                             if (!error) {
                                                                 NSData *data = [NSData dataWithContentsOfURL:location];
                                                                 if (sucess)
                                                                     sucess((NSHTTPURLResponse *)response, data);
                                                                 [[NSFileManager defaultManager] removeItemAtURL:location error:nil];
                                                             } else {
                                                                 if (failure)
                                                                     failure((NSHTTPURLResponse *)response, error);
                                                             }
                                                         }];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [task resume];
}


- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)urlString parameters:(id)parameters error:(NSError *__autoreleasing *)error
{
    NSArray *methodsAvailable = @[@"GET", @"POST"];
    if (![methodsAvailable containsObject:method.uppercaseString]) {
        if (error != NULL)
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:100 userInfo:@{NSLocalizedDescriptionKey:@"Method is invalid. Must be 'POST' or 'GET'."}];
        return nil;
    }
    
    NSMutableString *stringParameters = [NSMutableString string];
    
    if ([parameters isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictParameters = (NSDictionary *)parameters;
        for (NSString *key in [dictParameters.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
            [stringParameters appendFormat:@"%@=%@&", key, dictParameters[key]];
        }
    } else if ([parameters isKindOfClass:[NSString class]]) {
        [stringParameters appendString:(NSString *)parameters];
    } else if (parameters) {
        if (error != NULL)
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
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"ColoredVK2/%@ (%@/%@ | %@/%@)", 
                       kPackageVersion, [NSBundle mainBundle].bundleIdentifier, 
                       [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [UIDevice currentDevice].model, 
                       [UIDevice currentDevice].systemVersion] forHTTPHeaderField:@"User-Agent"];
    
    return request;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    }
}

@end
