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
#import "ColoredVKAlertController.h"


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
    
    ColoredVKAlertController *actionController = [ColoredVKAlertController alertControllerWithTitle:@"" message:CVKLocalizedString(@"SET_THIS_IMAGE_TO") preferredStyle:UIAlertControllerStyleActionSheet];
    [actionController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    
    NSArray *info = getInfoForActionController();
    for (NSDictionary *dict in info) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:CVKLocalizedStringFromTable(dict[@"title"], @"ColoredVK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            ColoredVKHUD *hud = [ColoredVKHUD showHUD];
            hud.operation = [self downloadOperationWithIdentificator:dict[@"identifier"] completionBlock:^(BOOL success) {
                success?[hud showSuccess]:[hud showFailure];
            }];
        }];
        
        [action setValue:[UIImage imageNamed:dict[@"icon"] inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil] forKey:@"image"];
        [actionController addAction:action];
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
                                                   NSString *imagePath = [cvkFolderPath stringByAppendingString:[NSString stringWithFormat:@"/%@.png", identificator]];
                                                   NSString *prevImagePath = [cvkFolderPath stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", identificator]];
                                                   
                                                   NSError *error = nil;
                                                   [UIImageJPEGRepresentation(image, 1.0) writeToFile:imagePath options:NSDataWritingAtomic error:&error];
                                                   if (!error) {
                                                       UIImage *imageToResize = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
                                                       UIImage *preview = [imageToResize resizedImageByMagick:@"40x40#"];
                                                       [UIImageJPEGRepresentation(preview, 1.0) writeToFile:prevImagePath options:NSDataWritingAtomic error:&error];
                                                       
                                                       CGSize screenSize = [UIScreen mainScreen].bounds.size;
                                                       if ([identificator isEqualToString:@"barImage"]) screenSize.height = 64;
                                                       UIImage *recizedImage = [imageToResize resizedImageByMagick:[NSString stringWithFormat:@"%fx%f#", screenSize.width, screenSize.height]];
                                                       [UIImageJPEGRepresentation(recizedImage, 1.0) writeToFile:imagePath options:NSDataWritingAtomic error:&error];
                                                   }
                                                   
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.image.update" object:nil userInfo:@{@"identifier" : identificator}];
                                                   
                                                   if ([identificator isEqualToString:@"menuBackgroundImage"]) {
                                                       CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
                                                   }
                                                   if (block) block(error?NO:YES);
                                                   
                                               } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) { if (block) block(NO); }];
    return imageOperation;
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@" %@; url '%@'; rootViewController %@; ", [super description], self.url, self.rootViewController];
}
@end
