//
//  ColoredVKLicencesController.m
//  ColoredVK
//
//  Created by Даниил on 12/09/16.
//
//

#import "ColoredVKLicencesController.h"
#import "PrefixHeader.h"

@interface ColoredVKLicencesController ()

@end

@implementation ColoredVKLicencesController

- (UIStatusBarStyle) preferredStatusBarStyle
{
    if ([NSStringFromClass([[UIApplication sharedApplication].keyWindow.rootViewController class]) isEqualToString:@"DeckController"]) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    NSString *path = [[NSBundle bundleWithPath:CVK_BUNDLE_PATH] pathForResource:@"Licences" ofType:@"plist" inDirectory:@"plists"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path][@"Licences"];
    
    NSString *text = @"";
    
    for (NSString *key in [dict.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]) {
        text = [text stringByAppendingFormat:@"%@\n\n%@\n\n\n", key, [dict valueForKey:key]];
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
