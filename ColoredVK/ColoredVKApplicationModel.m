//
//  ColoredVKApplicationModel.m
//  ColoredVK2
//
//  Created by Даниил on 09.03.18.
//

#import "ColoredVKApplicationModel.h"

@implementation ColoredVKApplicationModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _teamIdentifier = @"";
        _teamName = @"";
        
        [self updateInfo];
    }
    return self;
}

- (void)updateInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSError *error = nil;
        NSString *provisionPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
        NSString *provisionString = [NSString stringWithContentsOfFile:provisionPath encoding:NSISOLatin1StringEncoding error:&error];
        
        if (!error) {         
            NSString *provisionDictString = @"";
            
            NSScanner *scanner = [NSScanner scannerWithString:provisionString];
            [scanner scanUpToString:@"<plist" intoString:nil];
            [scanner scanUpToString:@"</plist>" intoString:&provisionDictString];
            provisionDictString = [@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" stringByAppendingString:provisionDictString];
            provisionDictString = [provisionDictString stringByAppendingString:@"</plist>"];
            
            NSString *tempPath = [NSTemporaryDirectory() stringByAppendingString:@"/embedded_mobileprovision.plist"];
            [[provisionDictString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:tempPath atomically:YES];
            
            NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:tempPath];
            if (dict) {
                self->_teamIdentifier = ((NSArray *)dict[@"TeamIdentifier"]).firstObject;
                self->_teamName = dict[@"TeamName"];
            }
            [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
        }
    });
}

@end
