//
//  ColoredVKApplicationModel.m
//  ColoredVK2
//
//  Created by Даниил on 09.03.18.
//

#import "ColoredVKApplicationModel.h"
#import <Foundation/Foundation.h>
#import "SCParser.h"

@implementation ColoredVKApplicationModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sellerName = @"theux";
        _teamIdentifier = @"";
        _teamName = @"";
        
        CFBundleRef mainBundle = CFBundleGetMainBundle();
        CFStringRef shortVersion = CFBundleGetValueForInfoDictionaryKey(mainBundle, CFSTR("CFBundleShortVersionString"));
        CFStringRef version = CFBundleGetValueForInfoDictionaryKey(mainBundle, CFSTR("CFBundleVersion"));
        
        _version = (__bridge NSString *)shortVersion;
        _detailedVersion = [NSString stringWithFormat:@"%@ (%@)", self.version, (__bridge NSString *)version];
        
        CFURLRef executableURL = CFBundleCopyExecutableURL(mainBundle);
        NSString *executableName = CFBridgingRelease(CFURLCopyLastPathComponent(executableURL));
        _isVKApp = [executableName.lowercaseString isEqualToString:@"vkclient"];
        CFRelease(executableURL);
        
        [self updateTeamInformation];
    }
    return self;
}

- (void)updateTeamInformation
{
#if (defined(__arm__) || defined(__arm64__))
    if (!self.isVKApp)        
        return;
    
    SCParser *parser = [SCParser new];
    [parser parseAppProvisionWithCompletion:^(NSDictionary * _Nullable provisionDict, NSError * _Nullable error) {
        if (!error) {
            self->_teamIdentifier = ((NSArray *)provisionDict[@"TeamIdentifier"]).firstObject;
            self->_teamName = provisionDict[@"TeamName"];
        }
        
        if (NSClassFromString(@"Activation") != nil) {
            self->_sellerName = @"iapps";
        } else if ([self.teamIdentifier isEqualToString:@"FL663S8EYD"]) {
            self->_sellerName = @"ishmv";
        }
    }];
#endif
}

- (ColoredVKVersionCompare)compareAppVersionWithVersion:(NSString *)second_version
{
    return [self compareVersion:self.version withVersion:second_version];
}

- (ColoredVKVersionCompare)compareVersion:(NSString *)first_version withVersion:(NSString *)second_version
{
    if ([first_version isEqualToString:second_version] || 
        CFStringGetLength((__bridge CFStringRef)first_version) == 0 || 
        CFStringGetLength((__bridge CFStringRef)second_version) == 0)
        return ColoredVKVersionCompareEqual;
    
    CFComparisonResult result = CFStringCompare((__bridge CFStringRef)first_version, (__bridge CFStringRef)second_version, kCFCompareNumerically);
    if (result == kCFCompareLessThan)
        return ColoredVKVersionCompareLess;
    else if (result == kCFCompareGreaterThan)
        return ColoredVKVersionCompareMore;
    
    return ColoredVKVersionCompareEqual;
}

@end
