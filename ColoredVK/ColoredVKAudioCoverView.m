//
//  ColoredVKAudioCoverView.m
//  ColoredVK
//
//  Created by Даниил on 24/11/16.
//
//

#import "ColoredVKAudioCoverView.h"
#import "PrefixHeader.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LEColorPicker.h"


@interface ColoredVKAudioCoverView ()
@property (strong, nonatomic) NSBundle *cvkBundle;
@property (strong, nonatomic) UIImageView *topImageView;
@property (strong, nonatomic) UIImageView *bottomImageView;
//@property (strong, nonatomic) NSOperation *operation;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic, readonly) UIImage *noCover;
@property (strong, nonatomic, readonly) NSDictionary *prefs;
@end

@implementation ColoredVKAudioCoverView

void reloadPrefsNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.image.update" object:nil userInfo:@{@"identifier":@"audioCoverImage"}];
}

- (instancetype)initWithFrame:(CGRect)frame andSeparationPoint:(CGPoint)point
{
    self = [super initWithFrame:frame];
    if (self) {
        self.defaultCover = YES;
        self.manager = [SDWebImageManager sharedManager];
        self.artist = @"";
        self.track = @"";
        self.color = [UIColor whiteColor];
        self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        [self updateCoverInfo];
        
        self.topImageView = [[UIImageView alloc] initWithImage:self.noCover];
        self.topImageView.frame = CGRectMake(0, 0, self.frame.size.width, point.y);
        self.topImageView.backgroundColor = [UIColor blackColor];
        self.topImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.topImageView.layer.masksToBounds = YES;
        [self addSubview:self.topImageView];
        
        self.bottomImageView = [UIImageView new];
        self.bottomImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.bottomImageView.backgroundColor = [UIColor blackColor];
        self.bottomImageView.contentMode = UIViewContentModeScaleAspectFill;
        if (self.customCover) self.bottomImageView.image = self.noCover;
        
        self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        self.blurEffectView.frame = self.bottomImageView.bounds;
        [self.bottomImageView addSubview:self.blurEffectView];
        
        [self addSubview:self.bottomImageView];
        [self sendSubviewToBack:self.bottomImageView];
        
        self.audioLyricsView = [[ColoredVKAudioLyricsView alloc] initWithFrame:self.topImageView.bounds];
        [self addSubview:self.audioLyricsView];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, self.frame.size.width, 79);
        gradient.colors = @[ (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, (id)[UIColor clearColor].CGColor ];
        gradient.locations = @[ @0, @0.95];
        [self.topImageView.layer addSublayer:gradient];
        
        [self updateColorSchemeForImage:self.noCover];
        
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateNoCover:) name:@"com.daniilpashin.coloredvk2.image.update" object:nil];
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadPrefsNotify,  CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    }
    return self;
}

- (void)addToView:(UIView *)view
{
    [view addSubview:self];
    [view sendSubviewToBack:self];
}

- (void)updateCoverForAudioPlayer:(AudioPlayer *)player
{
    @synchronized (self) {
        dispatch_async(dispatch_queue_create("com.daniilpashin.coloredvk2.download.queue", DISPATCH_QUEUE_SERIAL), ^{
            self.track = player.audio.title;
            self.artist = player.audio.performer;
            
            [self downloadCoverWithCompletionBlock:^(UIImage *image, BOOL wasDownloaded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.defaultCover = (wasDownloaded && image)?NO:YES;
                    
                    UIImage *coverImage = image;
                    if (player.coverImage && (!wasDownloaded && ![player.coverImage.imageAsset.assetName containsString:@"placeholder"])) {
                        coverImage = player.coverImage;
                        self.defaultCover = NO;
                    }
                    
                    [self changeImageViewImage:self.topImageView toImage:coverImage animated:YES];
                    if (self.defaultCover)
                        [self changeImageViewImage:self.bottomImageView toImage:self.customCover?self.noCover:nil animated:YES];
                    else
                        [self changeImageViewImage:self.bottomImageView toImage:coverImage animated:YES];
                    
                    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
                    NSMutableDictionary *playingInfo = [center.nowPlayingInfo mutableCopy];
                    if (!self.defaultCover) playingInfo[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:coverImage];
                    else [playingInfo removeObjectForKey:MPMediaItemPropertyArtwork];
                    center.nowPlayingInfo = [playingInfo copy];
                    
                    [self updateColorSchemeForImage:coverImage];
                        //                if (self.inBackground) [[UIApplication sharedApplication] _updateSnapshotForBackgroundApplication:YES];
                });
            }];
        });
    }
}
- (void)changeImageViewImage:(UIImageView *)imageView toImage:(UIImage *)image animated:(BOOL)animated
{
    if (animated) 
        [UIView transitionWithView:imageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionAllowUserInteraction animations:^{ imageView.image = image; } completion:nil];
    else imageView.image = image;
}

- (void)downloadCoverWithCompletionBlock:( void(^)(UIImage *image, BOOL wasDownloaded) )block;
{
    if (self.artist && self.track) {
        __block NSString *query = [NSString stringWithFormat:@"%@+%@", self.artist, self.track];
        query = [query stringByReplacingOccurrencesOfString:@"|" withString:@" "];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\(|\\[)+([\\s\\S])+(\\)|\\])" options:0 error:nil];
        NSString *oldQuery = query.copy;
        [regex enumerateMatchesInString:query options:0 range:NSMakeRange(0, query.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            query = [query stringByReplacingOccurrencesOfString:[oldQuery substringWithRange:result.range] withString:@""];
        }];
        
        NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@" &/-!|\""];
        query = [[query componentsSeparatedByCharactersInSet:charset] componentsJoinedByString:@"+"];
        while ([query containsString:@"++"]) {
            query = [query stringByReplacingOccurrencesOfString:@"+++" withString:@"+"];
            query = [query stringByReplacingOccurrencesOfString:@"++" withString:@"+"];
        }
        if ([query hasSuffix:@"+"]) query = [query stringByReplacingCharactersInRange:NSMakeRange(query.length-1, 1) withString:@""];
        
        self.key = query.lowercaseString;
        UIImage *image = [self.manager.imageCache imageFromCacheForKey:self.key];
        if (image) { if (block) block(image, YES); }
        else {
            NSString *iTunesURL = [NSString stringWithFormat:@"https://itunes.apple.com/search?limit=1&media=music&term=%@", query];
        [(AFJSONRequestOperation *)[NSClassFromString(@"AFJSONRequestOperation")
                                    JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:iTunesURL]]
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                        NSDictionary *responseDict = JSON;
                                        NSArray *items = responseDict[@"results"];
                                        if (items.count > 0) {
                                            NSString *url = [items[0][@"artworkUrl100"] stringByReplacingOccurrencesOfString:@"100x100bb" withString:@"1024x1024bb"];
                                            [self.manager loadImageWithURL:[NSURL URLWithString:url] options:SDWebImageHighPriority|SDWebImageCacheMemoryOnly progress:nil 
                                                                 completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                                     if (block) block(image, YES);
                                                                     NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
                                                                     BOOL cacheCovers = prefs[@"cacheAudioCovers"]?[prefs[@"cacheAudioCovers"] boolValue]:YES;
                                                                     if (cacheCovers) [self.manager.imageCache storeImage:image forKey:self.key completion:nil];
                                                                 }];
                                        } else if (block) block(self.noCover, NO);
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) { if (block) block(self.noCover, NO); }] start];
        }
    }
}

- (void)updateColorSchemeForImage:(UIImage *)image
{
    LEColorPicker *picker = [[LEColorPicker alloc] init];
    [picker pickColorsFromImage:image onComplete:^(LEColorScheme *colorScheme) {
        self.backColor = self.defaultCover?[UIColor clearColor]:[colorScheme.backgroundColor colorWithAlphaComponent:0.4];
        self.color = colorScheme.secondaryTextColor;
        self.audioLyricsView.textColor = self.color;
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.blurEffectView.backgroundColor = self.defaultCover?[UIColor clearColor]:self.backColor;
            self.audioLyricsView.blurView.backgroundColor = self.defaultCover?[UIColor clearColor]:self.backColor;
        } completion:nil];
        [NSNotificationCenter.defaultCenter postNotificationName:@"com.daniilpashin.coloredvk2.audio.image.changed" object:nil];
    }];
}

- (UIImage *)noCover
{
    if (self.customCover) return [UIImage imageWithContentsOfFile:[CVK_FOLDER_PATH stringByAppendingString:@"/audioCoverImage.png"]];
    else                  return [UIImage imageNamed:@"CoverImage" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
}

- (void)updateNoCover:(NSNotification *)notification
{
    if ([notification.userInfo[@"identifier"] isEqualToString:@"audioCoverImage"]) [self updateCoverInfo];
}

- (void)updateCoverInfo
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    self.customCover = [prefs[@"enabledAudioCustomCover"] boolValue];
}
@end
