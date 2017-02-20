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
#import "ColoredVKMainController.h"
#import "UIImage+ResizeMagick.h"
#import "PrefixHeader.h"
#import "ColoredVKHUD.h"


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
    return [[self alloc] initWithURL:nil rootController:nil];
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
    self = [super initWithImage:[UIImage imageNamed:@"downloadCloudIcon" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil]
                          style:UIBarButtonItemStylePlain target:self action:@selector(download)];
    if (self)  {
        self.url = url;
        self.rootViewController = controller;
    }
    return self;
}

- (void)download
{
    if (self.urlBlock && !self.url) self.url = self.urlBlock();  
    
    UIAlertController *actionController = [UIAlertController alertControllerWithTitle:@"" message:CVKLocalizedString(@"SET_THIS_IMAGE_TO") preferredStyle:UIAlertControllerStyleActionSheet];
    [actionController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    
    NSArray *info = getInfoForActionController();
    for (NSDictionary *dict in info) {
        [actionController addAction:[UIAlertAction actionWithTitle:CVKLocalizedStringFromTable(dict[@"title"], @"ColoredVK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            ColoredVKHUD *hud = [ColoredVKHUD showHUD];
            hud.operation = [self downloadOperationWithIdentificator:dict[@"identifier"] completionBlock:^(BOOL success) {
                success?[hud showSuccess]:[hud showFailure];
            }];
        }]];
    }
    
    if (IS_IPAD) {
        actionController.modalPresentationStyle = UIModalPresentationPopover;
        actionController.popoverPresentationController.permittedArrowDirections = 0;
        actionController.popoverPresentationController.sourceView = self.rootViewController.view;
        actionController.popoverPresentationController.sourceRect = self.rootViewController.view.bounds;
    }
    
    [self.rootViewController presentViewController:actionController animated:YES completion:nil];
}


- (AFImageRequestOperation *)downloadOperationWithIdentificator:(NSString *)identificator completionBlock:( void(^)(BOOL success) )block
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
                                                   
                                                   CGSize size = [UIScreen mainScreen].bounds.size;
                                                   UIImage *newImage = [image resizedImageByMagick:[NSString stringWithFormat:@"%fx%f#", size.width, size.height]];
                                                   
                                                   NSError *error = nil;
                                                   [UIImagePNGRepresentation(newImage) writeToFile:imagePath options:NSDataWritingAtomic error:&error];
                                                   if (!error) {
                                                       UIGraphicsBeginImageContext(CGSizeMake(40, 40));
                                                       UIImage *preview = newImage;
                                                       [preview drawInRect:CGRectMake(0, 0, 40, 40)];
                                                       preview = UIGraphicsGetImageFromCurrentImageContext();
                                                       [UIImagePNGRepresentation(preview) writeToFile:prevImagePath atomically:YES];
                                                       UIGraphicsEndImageContext();
                                                   }
                                                   
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.image.update" object:nil userInfo:@{@"identifier" : identificator}];
                                                   
                                                   if ([identificator isEqualToString:@"menuBackgroundImage"]) {
                                                       CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
                                                   }
                                                   if (block) block(error?NO:YES);
                                                   
                                               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) { if (block) block(NO); }];
    return imageOperation;
    
}

@end
