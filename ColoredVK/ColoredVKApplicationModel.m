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
        _version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        _detailedVersion = [NSString stringWithFormat:@"%@ (%@)", self.version, 
                            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
        _isVKApp = [[NSBundle mainBundle].executablePath.lastPathComponent.lowercaseString isEqualToString:@"vkclient"];
        
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
    if ([first_version isEqualToString:second_version])
        return ColoredVKVersionCompareEqual;
    
    NSArray *first_version_components = [first_version componentsSeparatedByString:@"."];
    NSArray *second_version_components = [second_version componentsSeparatedByString:@"."];
    NSInteger length = MIN(first_version_components.count, second_version_components.count);
    
    
    for (int i = 0; i < length; i++) {
        NSInteger first_component = [first_version_components[i] integerValue];
        NSInteger second_component = [second_version_components[i] integerValue];
        
        if (first_component > second_component)
            return ColoredVKVersionCompareMore;
        
        if (first_component < second_component)
            return ColoredVKVersionCompareLess;
    }
    
    
    if (first_version_components.count > second_version_components.count)
        return ColoredVKVersionCompareMore;
    
    if (first_version_components.count < second_version_components.count)
        return ColoredVKVersionCompareLess;
    
    
    return ColoredVKVersionCompareEqual;
}

@end
