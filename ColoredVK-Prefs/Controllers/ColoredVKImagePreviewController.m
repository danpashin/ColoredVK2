//
//  ColoredVKImagePreviewController.m
//  ColoredVK2
//
//  Created by Даниил on 24/07/2018.
//

#import "ColoredVKImagePreviewController.h"
#import "ColoredVKNewInstaller.h"

@interface ColoredVKImagePreviewController ()

@property (strong, nonatomic, readonly) UIImageView *imageView;
@property (strong, nonatomic, readonly) NSArray <id <UIPreviewActionItem>> *previewActionItems;

@end

@implementation ColoredVKImagePreviewController
@synthesize previewActionItems = _previewActionItems;

- (UIStatusBarStyle)preferredStatusBarStyle
{
    BOOL vkApp = [ColoredVKNewInstaller sharedInstaller].application.isVKApp;
    return vkApp ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        [self commonInit];
        self.imageView.image = image;
    }
    return self;
}

- (instancetype)initWithImageAtPath:(NSString *)path
{
    return [self initWithImageAtPath:path previewActions:nil];
}

- (instancetype)initWithImageAtPath:(NSString *)path previewActions:(NSArray <id <UIPreviewActionItem>> *)previewActions
{
    self = [super init];
    if (self) {
        _previewActionItems = previewActions;
        [self commonInit];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            self.imageView.image = [UIImage imageWithContentsOfFile:path];
        });        
    }
    return self;
}

- (void)commonInit
{
    _imageView = [UIImageView new];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self.imageView.layer.cornerRadius = screenSize.height / 26.0f;
    
    self.preferredContentSize = screenSize;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.imageView];
    
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[imageView]-10-|" options:0 metrics:@{} views:@{@"imageView":self.imageView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:@{} views:@{@"imageView":self.imageView}]];
}

@end
