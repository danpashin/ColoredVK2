//
//  ColoredVKAudioCover.m
//  ColoredVK
//
//  Created by Даниил on 24/11/16.
//
//

#import "ColoredVKAudioCover.h"
#import "PrefixHeader.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LEColorPicker.h"
#import "ColoredVKAudioEntity.h"
#import "ColoredVKNetwork.h"
#import "SDWebImageManager.h"
#import "ColoredVKAudioLyricsView.h"


@interface ColoredVKAudioCover ()

@property (strong, nonatomic) NSString *track;
@property (strong, nonatomic) NSString *artist;

@property (strong, nonatomic) UIView *coverView;
@property (strong, nonatomic) UIImageView *topImageView;
@property (strong, nonatomic) UIImageView *bottomImageView;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) CAGradientLayer *topCoverGradient;
@property (strong, nonatomic) ColoredVKAudioLyricsView *audioLyricsView;

@property (strong, nonatomic) NSBundle *cvkBundle;
@property (strong, nonatomic, readonly) UIImage *noCover;
@property (strong, nonatomic) SDWebImageManager *manager;

@property (assign, nonatomic) BOOL defaultCover;
@property (assign, nonatomic) BOOL customCover;

@end

@implementation ColoredVKAudioCover

static NSString *const kCVKCoverInternalNotification = @"ru.danpashin.coloredvk2.audio.prefs.update";
void corePrefsNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    POST_NOTIFICATION(kCVKCoverInternalNotification);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _coverView = [[UIView alloc] init];
        _coverView.tag = 265;
        
        _defaultCover = YES;
        _manager = [SDWebImageManager sharedManager];
        _artist = @"";
        _track = @"";
        _color = [UIColor whiteColor];
        _cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        [self updatePrefs:nil];
        
        _topImageView = [[UIImageView alloc] initWithImage:self.noCover];
        _topImageView.backgroundColor = [UIColor blackColor];
        _topImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topImageView.layer.masksToBounds = YES;
        [_coverView addSubview:_topImageView];
        
        _bottomImageView = [UIImageView new];
        _bottomImageView.backgroundColor = [UIColor blackColor];
        _bottomImageView.contentMode = UIViewContentModeScaleAspectFill;
        if (_customCover)
            _bottomImageView.image = self.noCover;
        
        _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        _blurEffectView.frame = _bottomImageView.bounds;
        [_bottomImageView addSubview:_blurEffectView];
        
        [_coverView addSubview:_bottomImageView];
        [_coverView sendSubviewToBack:_bottomImageView];
        
        _audioLyricsView = [[ColoredVKAudioLyricsView alloc] init];
        [_coverView addSubview:_audioLyricsView];
        
        _topCoverGradient = [CAGradientLayer layer];
        _topCoverGradient.colors = @[ (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, (id)[UIColor clearColor].CGColor ];
        _topCoverGradient.locations = @[ @0, @0.95];
        [_topImageView.layer addSublayer:_topCoverGradient];
        
        [self updateColorSchemeForImage:self.noCover];
        
        
        REGISTER_CORE_OBSERVER(corePrefsNotify, kPackageNotificationReloadPrefs);
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updatePrefs:) 
                                                   name:kCVKCoverInternalNotification object:nil];
    }
    return self;
}

- (void)updateViewFrame:(CGRect)frame andSeparationPoint:(CGPoint)separationPoint
{
    self.coverView.frame = frame;
    self.topImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.coverView.frame), separationPoint.y);
    self.bottomImageView.frame = self.coverView.bounds;
    self.blurEffectView.frame = self.bottomImageView.bounds;
    self.audioLyricsView.frame = self.topImageView.bounds;
    self.topCoverGradient.frame = CGRectMake(0, 0, CGRectGetWidth(self.topImageView.frame), 79);
    
    self.topImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.coverView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topImageView(height)]|" options:0 
                                                                           metrics:@{@"height":@(separationPoint.y)} 
                                                                             views:@{@"topImageView":self.topImageView}]];
    [self.coverView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topImageView]|" options:0 
                                                                           metrics:nil views:@{@"topImageView":self.topImageView}]];
    
    
    self.bottomImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.coverView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[btmImageView]|" options:0 
                                                                           metrics:nil views:@{@"btmImageView":self.bottomImageView}]];
    [self.coverView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[btmImageView]|" options:0 
                                                                           metrics:nil views:@{@"btmImageView":self.bottomImageView}]];
    
    
    self.blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bottomImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurView]|" options:0 
                                                                                 metrics:nil views:@{@"blurView":self.blurEffectView}]];
    [self.bottomImageView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|" options:0 
                                                                                 metrics:nil views:@{@"blurView":self.blurEffectView}]];
}

- (void)addToView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![view.subviews containsObject:[view viewWithTag:self.coverView.tag]]) {
            [view addSubview:self.coverView];
            [view sendSubviewToBack:self.coverView];
            
            self.coverView.translatesAutoresizingMaskIntoConstraints = NO;
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[coverView]|" options:0 
                                                                         metrics:nil views:@{@"coverView":self.coverView}]];
            [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[coverView]|" options:0 
                                                                         metrics:nil views:@{@"coverView":self.coverView}]];
        }
    });
}

- (void)updateCoverForArtist:(NSString *)artist title:(NSString *)title
{
    if (![self.track isEqualToString:title] || ![self.artist isEqualToString:artist]) {
        self.track = title;
        self.artist = artist;
        
        [self downloadCoverWithCompletionBlock:^(UIImage *image, BOOL wasDownloaded) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.defaultCover = (wasDownloaded && image) ? NO : YES;
                
                [self changeImageViewImage:self.topImageView toImage:image animated:YES];
                if (self.defaultCover)
                    [self changeImageViewImage:self.bottomImageView toImage:self.customCover ? self.noCover : nil animated:YES];
                else
                    [self changeImageViewImage:self.bottomImageView toImage:image animated:YES];
                
                MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
                NSMutableDictionary *playingInfo = [center.nowPlayingInfo mutableCopy];
                if (!self.defaultCover)
                    playingInfo[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:image];
                else
                    [playingInfo removeObjectForKey:MPMediaItemPropertyArtwork];
                
                center.nowPlayingInfo = [playingInfo copy];
                
                [self updateColorSchemeForImage:image];
            });
        }];
    } else [self updateColorSchemeForImage:self.topImageView.image];
    
    [self updateLyrycsForArtist:artist title:title];
}
- (void)changeImageViewImage:(UIImageView *)imageView toImage:(UIImage *)image animated:(BOOL)animated
{
    if (animated) {
        [UIView transitionWithView:imageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionAllowUserInteraction
                        animations:^{
                            imageView.image = image;
                        } completion:nil];
    } else imageView.image = image;
}

- (void)downloadCoverWithCompletionBlock:( void(^)(UIImage *image, BOOL wasDownloaded) )block;
{
    if ((self.artist.length == 0) || (self.track.length == 0))
        return;
    
    dispatch_queue_t backgroundQueue = dispatch_queue_create("ru.danpashin.coloredvk2.audio.cover.background", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(backgroundQueue, ^{
        __block NSString *query = [NSString stringWithFormat:@"%@_%@", self.artist, self.track];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\(|\\[)+([\\s\\S])+(\\)|\\])" options:0 error:nil];
        NSString *oldQuery = query.copy;
        [regex enumerateMatchesInString:query options:0 range:NSMakeRange(0, query.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            query = [query stringByReplacingOccurrencesOfString:[oldQuery substringWithRange:result.range] withString:@""];
        }];
        
        
        NSArray *components = [query componentsSeparatedByString:@"_"];
        if (components.count == 2) [self updateLyrycsForArtist:components[0] title:components[1]];
        else [self.audioLyricsView resetState];
        
        query = [self convertStringToURLSafe:query];
        query = [query.lowercaseString stringByReplacingOccurrencesOfString:@"_" withString:@"+"];
        
        UIImage *cachedImage = [self.manager.imageCache imageFromCacheForKey:query];
        if (cachedImage) {
            if (block) 
                block(cachedImage, YES);
            return;
        }
        ColoredVKNetwork *network = [ColoredVKNetwork sharedNetwork];
        NSMutableURLRequest *urlRequest = [network requestWithMethod:@"GET" URLString:@"https://itunes.apple.com/search" 
                                                          parameters:@{@"limit":@1, @"media":@"music", @"term":query} error:nil];
        urlRequest.accessibilityValue = query;
        
        [network sendRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *rawData) {
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:rawData options:0 error:&jsonError];
            if (jsonError) {
                if (block)
                    block(self.noCover, NO);
                return;
            }
            
            NSArray *items = json[@"results"];
            if (items.count == 0) {
                if (block)
                    block(self.noCover, NO);
                return;
            }
            
            NSString *url = [items[0][@"artworkUrl100"] stringByReplacingOccurrencesOfString:@"100x100bb" withString:@"1024x1024bb"];
            [self.manager loadImageWithURL:[NSURL URLWithString:url] options:SDWebImageHighPriority|SDWebImageCacheMemoryOnly progress:nil completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (block)
                    block(image, YES);
                
                NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
                BOOL cacheCovers = prefs[@"cacheAudioCovers"]?[prefs[@"cacheAudioCovers"] boolValue]:YES;
                if (cacheCovers)
                    [self.manager.imageCache storeImage:image forKey:request.accessibilityValue completion:nil];
            }];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            if (block) block(self.noCover, NO);
        }];
    });
}

- (void)updateColorScheme
{
    [self updateColorSchemeForImage:self.topImageView.image];
}

- (void)updateColorSchemeForImage:(UIImage *)image
{
    dispatch_async(dispatch_get_main_queue(), ^{
        LEColorPicker *picker = [[LEColorPicker alloc] init];
        [picker pickColorsFromImage:image onComplete:^(LEColorScheme *colorScheme) {
            self->_backColor = self.defaultCover?[UIColor clearColor]:[colorScheme.backgroundColor colorWithAlphaComponent:0.4f];
            self->_color = colorScheme.secondaryTextColor;
            self.audioLyricsView.textColor = self.color;
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
                self.blurEffectView.backgroundColor = self.defaultCover?[UIColor clearColor]:self.backColor;
                self.audioLyricsView.blurView.backgroundColor = self.defaultCover?[UIColor clearColor]:self.backColor;
            } completion:nil];
            
            if (self.updateCompletionBlock)
                self.updateCompletionBlock(self);
        }];
    });
}

- (UIImage *)noCover
{
    if (self.customCover) return [UIImage imageWithContentsOfFile:[CVK_FOLDER_PATH stringByAppendingString:@"/audioCoverImage.png"]];
    else                  return [UIImage imageNamed:@"CoverImage" inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
}

- (void)updatePrefs:(NSNotification *)notification
{
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
    self.customCover = [prefs[@"enabledAudioCustomCover"] boolValue];
}

- (void)updateLyrycsForArtist:(NSString *)artist title:(NSString *)title
{
    if (artist.length == 0 || title.length == 0)
        return;
    
    if ([artist hasPrefix:@"+"]) artist = [artist substringFromIndex:1];
    if ([artist hasSuffix:@"+"]) artist = [artist substringToIndex:artist.length - 1];
    if ([title hasPrefix:@"+"]) title = [title substringFromIndex:1];
    if ([title hasSuffix:@"+"]) title = [title substringToIndex:title.length - 1];
    
    title = [self convertStringToURLSafe:title];
    artist = [self convertStringToURLSafe:artist];
    
    NSString *url = [NSString stringWithFormat:@"%@/lyrics.php",  kPackageAPIURL];
    NSDictionary *params = @{@"artist":artist, @"title":title};
    
    ColoredVKNetwork *network = [ColoredVKNetwork sharedNetwork];
    [network sendJSONRequestWithMethod:@"GET" stringURL:url parameters:params success:^(NSURLRequest *blockRequest, NSHTTPURLResponse *httpResponse, NSDictionary *json) {
        if (!json[@"response"]) {
            [self.audioLyricsView resetState];
            return;
        }
        self.audioLyricsView.text = json[@"response"][@"lyrics"];        
    }  failure:^(NSURLRequest *blockRequest, NSHTTPURLResponse *response, NSError *error) {
        [self.audioLyricsView resetState];
    }];
}

- (NSString *)convertStringToURLSafe:(NSString *)string
{
    NSString *newString = [string stringByReplacingOccurrencesOfString:@"|" withString:@" "];
        
    NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@" /\\-|\""];
    newString = [[newString componentsSeparatedByCharactersInSet:charset] componentsJoinedByString:@"+"];
    while ([newString containsString:@"++"]) {
        newString = [newString stringByReplacingOccurrencesOfString:@"++" withString:@"+"];
    }
    if ([newString hasSuffix:@"+"]) newString = [newString stringByReplacingCharactersInRange:NSMakeRange(newString.length-1, 1) withString:@""];
    if ([newString hasPrefix:@"+"]) newString = [newString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    
    return newString;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p artist '%@', track '%@', frame %@, separationPoint %@>", [self class], self, self.artist, self.track, 
            NSStringFromCGRect(self.coverView.frame), NSStringFromCGPoint(CGPointMake(0, CGRectGetMinY(self.bottomImageView.frame)))];
}

@end
