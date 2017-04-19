//
//  ColoredVKBlurPrefsController.m
//  ColoredVK
//
//  Created by Даниил on 19.04.17.
//
//

#import "ColoredVKBlurPrefsController.h"


@implementation ColoredVKBlurPrefsController

- (NSArray *)specifiers
{
    if (!_specifiers) {
        NSArray *specifiers = [self specifiersForPlistName:@"plists/BlurPrefs" localize:YES];
        
        if (self.specifier.properties[@"prefix"]) {
            for (PSSpecifier *specifier in specifiers) {
                NSString *postfix = specifier.properties[@"key"] ? specifier.properties[@"key"] : specifier.identifier;
                NSString *key = [self.specifier.properties[@"prefix"] stringByAppendingString:postfix];
                specifier.identifier = key;
                if (specifier.properties[@"key"]) specifier.properties[@"key"] = key;
            }
        } else specifiers = @[self.errorMessage];
        
        _specifiers = specifiers;
    }
    return _specifiers;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"";
}

@end
