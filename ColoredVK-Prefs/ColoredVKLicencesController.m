//
//  ColoredVKLicencesController.m
//  ColoredVK
//
//  Created by Даниил on 12/09/16.
//
//

#import "ColoredVKLicencesController.h"
#import "PrefixHeader.h"


@implementation ColoredVKLicencesController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if ([[NSBundle mainBundle].executablePath.lastPathComponent isEqualToString:@"vkclient"]) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSString *path = [[NSBundle bundleWithPath:CVK_BUNDLE_PATH] pathForResource:@"Libraries" ofType:@"txt" inDirectory:@"plists"];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.backgroundColor = [UIColor clearColor];
    textView.userInteractionEnabled = YES;
    textView.scrollEnabled = YES;
    textView.editable = NO;
    textView.text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.view addSubview:textView];
    
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]|" options:0 metrics:nil views:@{@"view":textView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":textView}]];
}

@end
