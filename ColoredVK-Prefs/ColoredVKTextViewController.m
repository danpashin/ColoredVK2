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
@property (strong, nonatomic) NSAttributedString *attributedText;
@end

@implementation ColoredVKTextViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithFile:@"" localized:NO];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithFile:@"" localized:NO];
}

- (instancetype)initWithFile:(NSString *)fileName localized:(BOOL)localized
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {        
        if (fileName) {
            NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
            NSString *extension = @"rtf";
            
            NSURL *path = nil;
            if (localized)
                path = [cvkBundle URLForResource:fileName withExtension:extension];
            else
                path = [cvkBundle URLForResource:fileName withExtension:extension subdirectory:@"plists"];
            
            _attributedText = [[NSAttributedString alloc] initWithFileURL:path 
                                                                  options:@{NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType} 
                                                       documentAttributes:nil error:nil];
        }
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
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
    self.textView.attributedText = self.attributedText;
    [self.contentView addSubview:self.textView];
    
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    navBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[textView]-|" options:0 metrics:nil views:@{@"textView":self.textView}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[navBar]-|" options:0 metrics:nil views:@{@"navBar":navBar}]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[navBar]-[textView]|" options:0 metrics:nil views:@{@"navBar":navBar, @"textView":self.textView}]];
}

@end
