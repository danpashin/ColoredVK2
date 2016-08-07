//
//  ColoredVKDebugController.m
//  ColoredVK
//
//  Created by Даниил on 26.06.16.
//
//

#import "ColoredVKDebugController.h"

@implementation ColoredVKDebugController

+ (NSString*) uploadDebug:(NSData *)debugData filename:(NSString *)filename{
	
	
	NSString *urlString = @"http://danpashin.ru/cvk_backend/debug.php";
	
	
	NSMutableString *datastr = [[NSMutableString alloc] initWithFormat:@"filename=%@", filename];
	[datastr appendFormat:@"%@", debugData];
	NSData *data = [urlString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
	[request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:data];
	
	NSURLResponse *response;
	NSError *error;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
	
	return responseString;
}

@end
