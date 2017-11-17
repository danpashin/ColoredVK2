//
//  ColoredVKBarDownloadButton.m
//  ColoredVK
//
//  Created by Даниил on 02/12/16.
//
//

#import "ColoredVKBarDownloadButton.h"
#import "PrefixHeader.h"
#import "ColoredVKHUD.h"
#import "ColoredVKAlertController.h"
#import "ColoredVKImageProcessor.h"


@interface ColoredVKBarDownloadButton ()
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
    UIImage *downloadIcon = [UIImage imageNamed:@"downloadCloudIcon" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil];
    self = [super initWithImage:downloadIcon style:UIBarButtonItemStylePlain target:self action:@selector(actionDownloadImage)];
    if (self)  {
        _url = url;
        _rootViewController = controller;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            _downloadInfo = self.downloadInfo;
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
        NSString *identifier = dict[@"identifier"];
        UIAlertAction *action = [UIAlertAction actionWithTitle:CVKLocalizedStringFromTable(dict[@"title"], @"ColoredVK") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            ColoredVKHUD *hud = [ColoredVKHUD showHUD];
            
            ColoredVKImageProcessor *processor = [ColoredVKImageProcessor new];
            [processor processImageFromURL:[NSURL URLWithString:self.url] identifier:identifier 
                              andSaveToURL:[NSURL fileURLWithPath:[CVK_FOLDER_PATH stringByAppendingString:[NSString stringWithFormat:@"/%@.png", identifier]]] 
                           completionBlock:^(BOOL success, NSError *error) {
                               success ? [hud showSuccess] : [hud showFailureWithStatus:error.localizedDescription];
                               
                               [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.image.update" object:nil 
                                                                                 userInfo:@{@"identifier" : identifier}];
                               
                               if ([identifier isEqualToString:@"menuBackgroundImage"]) {
                                   CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.daniilpashin.coloredvk2.reload.menu"), NULL, NULL, YES);
                               }
                           }];
        }];
        [actionController addAction:action image:dict[@"icon"]];
    }
    
    [actionController presentFromController:self.rootViewController];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, url '%@', rootViewController %@>", [self class], self, self.url, self.rootViewController];
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
