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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupDefaultContentView];
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UINavigationBar *navBar = self.contentViewNavigationBar;
    [self.contentView addSubview:navBar];
    
    NSString *path = [[NSBundle bundleWithPath:CVK_BUNDLE_PATH] pathForResource:@"Libraries" ofType:@"txt" inDirectory:@"plists"];
    NSString *text = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:self.contentView.bounds];
    textView.backgroundColor = [UIColor clearColor];
    textView.editable = NO;
    textView.text = text;
    [self.contentView addSubview:textView];
    
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    navBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view":textView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view":navBar}]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[topView]-[textView]-|" options:0 metrics:nil views:@{@"topView":navBar, @"textView":textView}]];
}

@end
