//
//  ColoredVKTextViewController.m
//  ColoredVK
//
//  Created by Даниил on 12/09/16.
//
//

#import "ColoredVKTextViewController.h"
#import "PrefixHeader.h"

@interface ColoredVKTextViewController ()
@property (strong, nonatomic) UITextView *textView;
@end

@implementation ColoredVKTextViewController

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (instancetype)initWithFile:(NSString *)fileName
{
    self = [super init];
    if (self) {        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSURL *path = [[NSBundle bundleWithPath:CVK_BUNDLE_PATH] URLForResource:fileName withExtension:@"rtf" subdirectory:@"plists"];
            self.textView.attributedText = [[NSAttributedString alloc] initWithFileURL:path 
                                                                               options:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType} 
                                                                    documentAttributes:nil error:nil];
        });
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupDefaultContentView];
    
    UINavigationBar *navBar = self.contentViewNavigationBar;
    [self.contentView addSubview:navBar];
    
    self.textView = [[UITextView alloc] initWithFrame:self.contentView.bounds];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.editable = NO;
    [self.contentView addSubview:self.textView];
    
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    navBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[textView]-|" options:0 metrics:nil views:@{@"textView":self.textView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[navBar]-|" options:0 metrics:nil views:@{@"navBar":navBar}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[navBar]-[textView]|" options:0 metrics:nil views:@{@"navBar":navBar, @"textView":self.textView}]];
}

@end
