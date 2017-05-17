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
    
    [self setupDefaultContentView];
    UINavigationBar *navBar = self.contentViewNavigationBar;
    
    NSString *path = [[NSBundle bundleWithPath:CVK_BUNDLE_PATH] pathForResource:@"Libraries" ofType:@"txt" inDirectory:@"plists"];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.contentView.bounds];
    textView.backgroundColor = [UIColor clearColor];
    textView.userInteractionEnabled = YES;
    textView.scrollEnabled = YES;
    textView.editable = NO;
    textView.text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.contentView addSubview:textView];
    
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    navBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view":textView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view":navBar}]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[topView]-[textView]-|" options:0 metrics:nil views:@{@"topView":navBar, @"textView":textView}]];
}

@end
