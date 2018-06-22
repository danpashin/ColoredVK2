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
                [specifier setProperty:@YES forKey:@"enabled"];
                
                NSString *key = specifier.properties[@"key"] ? specifier.properties[@"key"] : specifier.identifier;
                if (key) {
                    NSString *newKey = [self.specifier.properties[@"prefix"] stringByAppendingString:key];
                    specifier.identifier = newKey;
                    specifier.properties[@"key"] = newKey;
                }
            }
        } else specifiers = @[];
        
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
