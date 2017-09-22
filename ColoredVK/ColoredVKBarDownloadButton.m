//
//  ColoredVKBarDownloadButton.m
//  ColoredVK
//
//  Created by Даниил on 02/12/16.
//
//

#import "ColoredVKBarDownloadButton.h"
#import "PrefixHeader.h"
#import "UIImage+ResizeMagick.h"
#import "ColoredVKHUD.h"
#import "ColoredVKAlertController.h"
#import "ColoredVKNetworkController.h"

@interface ColoredVKBarDownloadButton ()

@property (strong, nonatomic) NSArray *downloadInfo;
@property (strong, nonatomic) ColoredVKNetworkController *networkController;

@end

@implementation ColoredVKBarDownloadButton

+ (instancetype)button
{
    return [[self alloc] initWithURL:nil rootController:nil];
}

+ (instancetype)buttonWithURL:(NSString *)url rootController:(UIViewController *)controller
{
    return [[self alloc] initWithURL:url rootController:controller];
}


- (instancetype)initWithURL:(NSString *)url rootController:(UIViewController *)controller
{
    UIImage *downloadIcon = [UIImage imageNamed:@"downloadCloudIcon" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil];
    self = [super initWithImage:downloadIcon style:UIBarButtonItemStylePlain target:self action:@selector(actionDownloadImage)];
    if (self)  {
        self.url = url;
        self.rootViewController = controller;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.networkController = [ColoredVKNetworkController controller];
            self.downloadInfo = self.downloadInfo;
        });
    }
    return self;
}

- (void)actionDownloadImage
{
    if (self.urlBlock && !self.url) self.url = self.urlBlock();  
    
    ColoredVKAlertController *actionController = [ColoredVKAlertController alertControllerWithTitle:@"" message:CVKLocalizedString(@"SET_THIS_IMAGE_TO") preferredStyle:UIAlertControllerStyleActionSheet];
    [actionController addAction:[UIAlertAction actionWithTitle:UIKitLocalizedString(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}]];
    
    for (NSDictionary *dict in self.downloadInfo) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:CVKLocalizedStringFromTable(dict[@"title"], @"ColoredVK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            ColoredVKHUD *hud = [ColoredVKHUD showHUD];
            [self downloadImageWithIdentifier:dict[@"identifier"] completionBlock:^(BOOL success) {
                success ? [hud showSuccess] : [hud showFailure];
            }];
        }];
        [actionController addAction:action image:dict[@"icon"]];
    }
    
    [actionController presentFromController:self.rootViewController];
}

- (void)downloadImageWithIdentifier:(NSString *)identifier completionBlock:( void(^)(BOOL success) )block
{
    [self.networkController downloadDataFromURL:self.url
                                          success:^(NSHTTPURLResponse *response, NSData *rawData) {
                                              NSString *imagePath = [CVK_FOLDER_PATH stringByAppendingString:[NSString stringWithFormat:@"/%@.png", identifier]];
                                              NSString *prevImagePath = [CVK_FOLDER_PATH stringByAppendingString:[NSString stringWithFormat:@"/%@_preview.png", identifier]];
                                              
                                              NSError *error = nil;
                                              [rawData writeToFile:imagePath options:NSDataWritingAtomic error:&error];
                                              if (!error) {
                                                  UIImage *imageToResize = [UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]];
                                                  UIImage *preview = [imageToResize resizedImageByMagick:@"40x40#"];
                                                  [UIImageJPEGRepresentation(preview, 1.0) writeToFile:prevImagePath options:NSDataWritingAtomic error:&error];
                                                  
                                                  CGSize screenSize = [UIScreen mainScreen].bounds.size;
                                                  if ([identifier isEqualToString:@"barImage"]) screenSize.height = 64;
                                                  UIImage *recizedImage = [imageToResize resizedImageByMagick:[NSString stringWithFormat:@"%fx%f#", screenSize.width, screenSize.height]];
                                                  [UIImageJPEGRepresentation(recizedImage, 1.0) writeToFile:imagePath options:NSDataWritingAtomic error:&error];
                                              }
                                              
                                              if (block) block(error ? NO : YES);
                                              
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.image.update" object:nil userInfo:@{@"identifier" : identifier}];
                                                  
                                                  if ([identifier isEqualToString:@"menuBackgroundImage"]) {
                                                      CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
                                                  }
                                              });
                                          }
                                          failure:^(NSHTTPURLResponse *response, NSError *error) { if (block) block(NO); }];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@" %@; url '%@'; rootViewController %@; ", super.description, self.url, self.rootViewController];
}

- (NSArray *)downloadInfo
{
    if (!_downloadInfo) {
        NSArray *downloadInfo = [NSArray array];
        NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle bundleWithPath:CVK_BUNDLE_PATH] pathForResource:@"AdvancedInfo" ofType:@"plist" inDirectory:@"plists"]];
        if (infoDict) {
            downloadInfo = infoDict[@"ImagesDLInfo"];
        }
        
        _downloadInfo = downloadInfo;
    }
    
    return _downloadInfo;
}
@end
