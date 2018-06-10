//
//  ColoredVKMusicPrefs.m
//  ColoredVK2
//
//  Created by Даниил on 10.06.18.
//

#import "ColoredVKMusicPrefs.h"

#import <SDImageCache.h>
#import "ColoredVKHUD.h"
#import "ColoredVKNewInstaller.h"

@interface ColoredVKMusicPrefs ()
@property (strong, nonatomic) NSString *cacheSize;
@end

@implementation ColoredVKMusicPrefs

- (void)viewDidLoad
{
    [self updateCacheSize];
    [super viewDidLoad];
}

- (void)updateCacheSize
{
    self.cacheSize = @"Calculating...";
    [[SDImageCache sharedImageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger totalSize) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cacheSize = [NSString stringWithFormat:@"%.1f MB", totalSize / 1024.0f / 1024.0f];
        });
    }];
}

- (void)setCacheSize:(NSString *)cacheSize
{
    _cacheSize = cacheSize;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadSpecifierID:@"cacheSize"];
    });
}

- (void)clearCoversCache
{
    ColoredVKHUD *hud = [ColoredVKHUD showHUD];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        [hud showSuccess];
        [[ColoredVKNewInstaller sharedInstaller] createFolders];
        [self updateCacheSize];
    }];
}

@end
