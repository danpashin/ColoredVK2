//
//  ColoredVKNetworkController.m
//  ColoredVK2
//
//  Created by Даниил on 02.08.17.
//
//

#import "ColoredVKNetworkController.h"
#import "ColoredVKCrypto.h"

NSString *const ColoredVKNetworkMethodPost = @"POST";
NSString *const ColoredVKNetworkMethodGet = @"GET";

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

- (void)sendJSONRequestWithURL:(NSURL *)url parameters:(NSString *)parameters success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json)) sucess failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    [self sendRequestWithMethod:ColoredVKNetworkMethodPost url:url parameters:parameters success:sucess failure:failure];
}

- (void)sendRequestWithMethod:(NSString *)method url:(NSURL *)url parameters:(NSString *)parameters success:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json)) sucess failure:(void(^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:self.session.configuration.requestCachePolicy timeoutInterval:self.session.configuration.timeoutIntervalForResource];
    request.HTTPBody = [parameters dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = method;
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
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

@end
