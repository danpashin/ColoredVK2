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

NSString *const imageName = @"CoverImage";

@interface ColoredVKAudioCoverView ()
@property (strong, nonatomic) NSBundle *cvkBundle;
@property (strong, nonatomic) UIImageView *topImageView;
@property (strong, nonatomic) UIImageView *bottomImageView;
@property (strong, nonatomic) NSOperation *operation;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) NSString *key;
@end

@implementation ColoredVKAudioCoverView

- (instancetype)initWithFrame:(CGRect)frame andSeparationPoint:(CGPoint)point
{
    self = [super initWithFrame:frame];
    if (self) {
        self.defaultCover = YES;
        self.manager = [SDWebImageManager sharedManager];
        self.artist = @"";
        self.track = @"";
        
        self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        self.topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName inBundle:self.cvkBundle compatibleWithTraitCollection:nil]];
        self.topImageView.frame = CGRectMake(0, 0, self.frame.size.width, point.y);
        self.topImageView.backgroundColor = [UIColor blackColor];
        self.topImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.topImageView];
        
        self.bottomImageView = [UIImageView new];
        self.bottomImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.bottomImageView.backgroundColor = [UIColor blackColor];
        self.bottomImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        self.blurEffectView.frame = self.bottomImageView.bounds;
        [self.bottomImageView addSubview:self.blurEffectView];
        
        [self addSubview:self.bottomImageView];
        [self sendSubviewToBack:self.bottomImageView];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, self.frame.size.width, 79);
        gradient.colors = @[ (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, (id)[UIColor clearColor].CGColor ];
        gradient.locations = @[ @0, @0.95];
        [self.layer addSublayer:gradient];
    }
    return self;
}

- (void)updateCoverForAudioPlayer:(AudioPlayer *)player
{
    if (!self.operation.finished) [self.operation cancel];
    self.operation = [NSBlockOperation blockOperationWithBlock:^{        
        self.track = player.audio.title;
        self.artist = player.audio.performer;
        
        [self downloadCoverWithCompletionBlock:^(UIImage *image, BOOL wasDownloaded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.defaultCover = wasDownloaded?NO:YES;
                
                UIImage *coverImage = image;
                if (player.coverImage && (!wasDownloaded && ![player.coverImage.imageAsset.assetName containsString:@"placeholder"])) {
                    coverImage = player.coverImage;
                    self.defaultCover = NO;
                }
                
                [self changeImageViewImage:self.topImageView toImage:coverImage animated:YES];
                [self changeImageViewImage:self.bottomImageView toImage:self.defaultCover?nil:coverImage animated:YES];
                
                MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
                NSMutableDictionary *playingInfo = [NSMutableDictionary dictionaryWithDictionary:center.nowPlayingInfo];
                if (wasDownloaded) playingInfo[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:coverImage];
                else [playingInfo removeObjectForKey:MPMediaItemPropertyArtwork];
                center.nowPlayingInfo = [NSDictionary dictionaryWithDictionary:playingInfo];
                
                LEColorPicker *picker = [[LEColorPicker alloc] init];
                [picker pickColorsFromImage:coverImage onComplete:^(LEColorScheme *colorScheme) {
                    self.backColor = self.defaultCover?[UIColor clearColor]:[colorScheme.backgroundColor colorWithAlphaComponent:0.4];
                    self.tintColor = colorScheme.secondaryTextColor;
                    [UIView animateWithDuration:0.3 animations:^{ self.blurEffectView.backgroundColor = self.defaultCover?[UIColor clearColor]:self.backColor; } completion:nil];
                    [NSNotificationCenter.defaultCenter postNotificationName:@"com.daniilpashin.coloredvk.audio.image.changed" object:nil];
                }];
                    //                if (self.inBackground) [[UIApplication sharedApplication] _updateSnapshotForBackgroundApplication:YES];
            });
        }];
    }];
    [self.operation start];
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
        UIImage *noCover = [UIImage imageNamed:imageName inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
        __block NSString *query = [NSString stringWithFormat:@"%@+%@", self.artist, self.track];
        query = [query stringByReplacingOccurrencesOfString:@"|" withString:@" "];
        
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\(|\\[)+([\\s\\S])+(\\)|\\])" options:NSRegularExpressionCaseInsensitive error:&error];
        if (!error) {
            NSString *oldQuery = query.copy;
            [regex enumerateMatchesInString:query options:0 range:NSMakeRange(0, query.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                query = [query stringByReplacingOccurrencesOfString:[oldQuery substringWithRange:result.range] withString:@""];
            }];
        }
        
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
                                        } else if (block) block(noCover, NO);
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) { if (block) block(noCover, NO); }] start];
        }
    }
}
@end
