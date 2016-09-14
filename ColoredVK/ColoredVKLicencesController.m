//
//  ColoredVKLicencesController.m
//  ColoredVK
//
//  Created by Даниил on 12/09/16.
//
//

#import "ColoredVKLicencesController.h"
#import "ColoredVKJailCheck.h"
#import "PrefixHeader.h"

@interface ColoredVKLicencesController ()

@end

@implementation ColoredVKLicencesController

- (UIStatusBarStyle) preferredStatusBarStyle
{
    if ([ColoredVKJailCheck isInjected]) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *bundlePath = [ColoredVKJailCheck isInjected]?CVK_NON_JAIL_BUNDLE_PATH:CVK_JAIL_BUNDLE_PATH;
    NSString *path = [[NSBundle bundleWithPath:bundlePath] pathForResource:@"Licences" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path][@"Licences"];
    
    NSString *text = @"";
    
    for (NSString *key in dict.allKeys) {
        NSString *value = [dict valueForKey:key];
//        value = [value stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        text = [text stringByAppendingFormat:@"%@\n\n%@\n\n\n", key, value];
    }
    
    UITextView *textView = [UITextView new];
    textView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height + 20, 
                                self.navigationController.view.frame.size.width, 
                                self.navigationController.view.frame.size.height - 20);
    textView.backgroundColor = [UIColor clearColor];
    textView.userInteractionEnabled = YES;
    textView.scrollEnabled = YES;
    textView.editable = NO;
    textView.text = text;
    [self.view addSubview:textView];
    
    self.navigationItem.title = @"Licences";
    
}

@end
