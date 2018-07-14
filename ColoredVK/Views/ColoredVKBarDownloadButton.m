//
//  ColoredVKBarDownloadButton.m
//  ColoredVK
//
//  Created by Даниил on 02/12/16.
//
//

#import "ColoredVKBarDownloadButton.h"
#import "ColoredVKHUD.h"
#import "ColoredVKAlertController.h"
#import "ColoredVKImageProcessor.h"


@interface ColoredVKBarDownloadButton ()
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSArray *downloadInfo;
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
    UIImage *downloadIcon = CVKImage(@"vkapp/downloadCloudIcon");
    self = [super initWithImage:downloadIcon style:UIBarButtonItemStylePlain target:self action:@selector(actionDownloadImage)];
    if (self)  {
        _url = url;
        _rootViewController = controller;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSBundle *cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
            NSString *path = [cvkBundle pathForResource:@"AdvancedInfo" ofType:@"plist" inDirectory:@"plists"];
            NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:path];
            self.downloadInfo = infoDict ? infoDict[@"ImagesDLInfo"] : @[];
        });
    }
    return self;
}

- (void)actionDownloadImage
{
    if (self.urlBlock && !self.url)
        self.url = self.urlBlock(); 
    
    ColoredVKAlertController *actionController = [ColoredVKAlertController actionSheetWithMessage:CVKLocalizedString(@"SET_THIS_IMAGE_TO")];
    [actionController addCancelAction];
    
    for (NSDictionary *dict in self.downloadInfo) {
        NSString *identifier = dict[@"identifier"];
        NSString *title = CVKLocalizedStringFromTable(dict[@"title"], @"ColoredVK");
        UIAlertAction *downloadAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            ColoredVKHUD *hud = [ColoredVKHUD showHUD];
            
            NSURL *url = [NSURL URLWithString:self.url];
            NSURL *urlToSave = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.png", CVK_FOLDER_PATH, identifier]];
            [[ColoredVKImageProcessor new] processImageFromURL:url identifier:identifier saveTo:urlToSave completion:^(BOOL success, NSError *error) {
                success ? [hud showSuccess] : [hud showFailureWithStatus:error.localizedDescription];
                
                if ([identifier isEqualToString:@"menuBackgroundImage"])
                    POST_CORE_NOTIFICATION(kPackageNotificationReloadMenu);
            }];
        }];
        [actionController addAction:downloadAction image:dict[@"icon"]];
    }
    
    [actionController presentFromController:self.rootViewController];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, url '%@', rootViewController %@>", [self class], self, self.url, self.rootViewController];
}

@end
