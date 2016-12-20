//
//  ColoredVKBarDownloadButton.m
//  ColoredVK
//
//  Created by Даниил on 02/12/16.
//
//

#import "ColoredVKBarDownloadButton.h"
#import "PrefixHeader.h"
#import "VKMethods.h"
#import "LHProgressHUD.h"
#import "ColoredVKMainController.h"
#import "UIImage+ResizeMagick.h"

OBJC_EXPORT Class objc_getClass(const char *name) OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0);

@implementation ColoredVKBarDownloadButton

static NSArray *getInfoForActionController()
{
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleWithPath:CVK_BUNDLE_PATH] pathForResource:@"AdvancedInfo" ofType:@"plist" inDirectory:@"plists"]];
    if (dict) {
        NSArray *arr = dict[@"ImagesDLInfo"];
        if (arr) return arr;
        else return @[];
    } else return @[];
}

+ (instancetype)button
{
    return [[self alloc] initWithURL:@"" rootController:nil];
}

+ (instancetype)buttonWithURL:(NSString *)url
{
    return [[self alloc] initWithURL:url rootController:nil];
}

+ (instancetype)buttonWithURL:(NSString *)url rootController:(UIViewController *)controller
{
    return [[self alloc] initWithURL:url rootController:controller];
}


- (instancetype)initWithURL:(NSString *)url rootController:(UIViewController *)controller
{
    self = [super initWithImage:[UIImage imageNamed:@"dlIcon" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil]
                          style:UIBarButtonItemStylePlain target:self action:@selector(download)];
    if (self)  {
        self.url = url;
        if (controller) self.rootViewController = controller;
    }
    return self;
}

- (void)download
{
    if (self.urlBlock) self.url = self.urlBlock();    
    
    BlockActionController *actionController = [objc_getClass("BlockActionController") actionSheetWithTitle:nil];
    NSArray *info = getInfoForActionController();
    for (NSDictionary *dict in info) {
        [actionController addButtonWithTitle:CVKLocalizedString(dict[@"title"]) block:^id(id arg1) {
            LHProgressHUD *hud = [LHProgressHUD showAddedToView:UIApplication.sharedApplication.keyWindow.rootViewController.view];
            hud.centerBackgroundView.blurStyle = LHBlurEffectStyleExtraLight;
            hud.centerBackgroundView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
            hud.centerBackgroundView.layer.cornerRadius = 10;
            hud.infoColor = [UIColor colorWithWhite:0.55 alpha:1];
            hud.spinnerColor = hud.infoColor;
            [self downloadImageWithIdentificator:dict[@"identifier"]
                                 completionBlock:^(BOOL success, NSString *message) {
                                     if (success)[hud showSuccessWithStatus:@"" animated:YES];
                                     else [hud showFailureWithStatus:@"" animated:YES];
                                     [hud hideAfterDelay:1.5];
                                 }];
            return nil;
        }];
    }
    [actionController setCancelButtonWithTitle:UIKitLocalizedString(@"Cancel") block:nil];
    if (self.rootViewController) [actionController showInViewController:self.rootViewController];
}


- (void)downloadImageWithIdentificator:(NSString *)identificator completionBlock:( void(^)(BOOL success, NSString *message) )block
{
    AFImageRequestOperation *imageOperation = [NSClassFromString(@"AFImageRequestOperation") 
                                               imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]
                                               imageProcessingBlock:^UIImage *(UIImage *image) { return image; }
                                               cacheName:nil
                                               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                   NSString *cvkFolderPath = CVK_FOLDER_PATH;
                                                   if (![[NSFileManager defaultManager] fileExistsAtPath:cvkFolderPath]) [[NSFileManager defaultManager] createDirectoryAtPath:cvkFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
                                                   NSString *imagePath = [cvkFolderPath stringByAppendingString:[NSString stringWithFormat:@"/%@.png", identificator]];
                                                   NSString *prevImagePath = [cvkFolderPath stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", identificator]];
                                                   
                                                   UIImage *newImage = [image resizedImageByMagick: [NSString stringWithFormat:@"%fx%f#", UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height]];
                                                   
                                                   NSError *error = nil;
                                                   [UIImagePNGRepresentation(newImage) writeToFile:imagePath options:NSDataWritingAtomic error:&error];
                                                   if (!error) {
                                                       UIGraphicsBeginImageContext(CGSizeMake(40, 40));
                                                       UIImage *preview = newImage;
                                                       [preview drawInRect:CGRectMake(0, 0, 40, 40)];
                                                       preview = UIGraphicsGetImageFromCurrentImageContext();
                                                       [UIImagePNGRepresentation(preview) writeToFile:prevImagePath options:NSDataWritingAtomic error:&error];
                                                       UIGraphicsEndImageContext();
                                                   }
                                                   
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk.image.update" object:nil userInfo:@{@"identifier" : identificator}];
                                                   
                                                   if ([identificator isEqualToString:@"menuBackgroundImage"]) {
                                                       CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk.reload.menu"), NULL, NULL, YES);
                                                   }
                                                   dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(error?NO:YES, error?error.localizedDescription:@"");  });
                                                   
                                               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                   dispatch_async(dispatch_get_main_queue(), ^{ if (block) block(NO, error.localizedDescription); });
                                               }];
    [imageOperation start];
    
}

@end
