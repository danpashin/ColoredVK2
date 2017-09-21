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
#import "ColoredVKCoreData.h"
#import "ColoredVKAudioEntity.h"
#import "ColoredVKNetworkController.h"


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
@property (strong, nonatomic) ColoredVKCoreData *coredata;

@property (assign, nonatomic) BOOL defaultCover;
@property (assign, nonatomic) BOOL customCover;

@end

@implementation ColoredVKAudioCover

void reloadPrefsNotify(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.daniilpashin.coloredvk2.audio.prefs.update" object:nil userInfo:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.coverView = [[UIView alloc] init];
        self.coverView.tag = 265;
        
        self.defaultCover = YES;
        self.manager = [SDWebImageManager sharedManager];
        self.coredata = [ColoredVKCoreData new];
        self.artist = @"";
        self.track = @"";
        _color = [UIColor whiteColor];
        self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        [self updatePrefs:nil];
        
        self.topImageView = [[UIImageView alloc] initWithImage:self.noCover];
        self.topImageView.backgroundColor = [UIColor blackColor];
        self.topImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.topImageView.layer.masksToBounds = YES;
        [self.coverView addSubview:self.topImageView];
        
        self.bottomImageView = [UIImageView new];
        self.bottomImageView.backgroundColor = [UIColor blackColor];
        self.bottomImageView.contentMode = UIViewContentModeScaleAspectFill;
        if (self.customCover) self.bottomImageView.image = self.noCover;
        
        self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        self.blurEffectView.frame = self.bottomImageView.bounds;
        [self.bottomImageView addSubview:self.blurEffectView];
        
        [self.coverView addSubview:self.bottomImageView];
        [self.coverView sendSubviewToBack:self.bottomImageView];
        
        self.audioLyricsView = [[ColoredVKAudioLyricsView alloc] init];
        [self.coverView addSubview:self.audioLyricsView];
        
        self.topCoverGradient = [CAGradientLayer layer];
        self.topCoverGradient.colors = @[ (id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, (id)[UIColor clearColor].CGColor ];
        self.topCoverGradient.locations = @[ @0, @0.95];
        [self.topImageView.layer addSublayer:self.topCoverGradient];
        
        [self updateColorSchemeForImage:self.noCover];
        
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updatePrefs:) name:@"com.daniilpashin.coloredvk2.audio.prefs.update" object:nil];
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, reloadPrefsNotify,  CFSTR("com.daniilpashin.coloredvk2.prefs.changed"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
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
}

- (void)addToView:(UIView *)view
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![view.subviews containsObject:[view viewWithTag:self.coverView.tag]]) {
            [view addSubview:self.coverView];
            [view sendSubviewToBack:self.coverView];
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
                if (!self.defaultCover) playingInfo[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:image];
                else [playingInfo removeObjectForKey:MPMediaItemPropertyArtwork];
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
    if (self.artist && self.track) {
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

        UIImage *image = [self.manager.imageCache imageFromCacheForKey:query];
        if (image) {
            if (block) 
                block(image, YES); 
        } else {
            ColoredVKNetworkController *networkController = [ColoredVKNetworkController controller];
            NSMutableURLRequest *urlRequest = [networkController requestWithMethod:@"GET" URLString:@"https://itunes.apple.com/search" 
                                                                        parameters:@{@"limit":@1, @"media":@"music", @"term":query} error:nil];
            urlRequest.accessibilityValue = query;
            [networkController sendRequest:urlRequest
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *rawData) {
                                       NSError *jsonError = nil;
                                       NSDictionary *json = [NSJSONSerialization JSONObjectWithData:rawData options:0 error:&jsonError];
                                       if (!jsonError) {
                                           NSArray *items = json[@"results"];
                                           if (items.count > 0) {
                                               NSString *url = [items[0][@"artworkUrl100"] stringByReplacingOccurrencesOfString:@"100x100bb" withString:@"1024x1024bb"];
                                               [self.manager loadImageWithURL:[NSURL URLWithString:url] options:SDWebImageHighPriority|SDWebImageCacheMemoryOnly progress:nil 
                                                                    completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                                        if (block) block(image, YES);
                                                                        NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
                                                                        BOOL cacheCovers = prefs[@"cacheAudioCovers"]?[prefs[@"cacheAudioCovers"] boolValue]:YES;
                                                                        if (cacheCovers) [self.manager.imageCache storeImage:image forKey:request.accessibilityValue completion:nil];
                                                                    }];
                                           } else if (block) block(self.noCover, NO);
                                       } else if (block) block(self.noCover, NO);
                                   } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       if (block) block(self.noCover, NO);
                                   }];
        }
    }
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
            _backColor = self.defaultCover?[UIColor clearColor]:[colorScheme.backgroundColor colorWithAlphaComponent:0.4];
            _color = colorScheme.secondaryTextColor;
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
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ColoredVKAudioEntity"];
    NSString *cdArtist = [artist stringByReplacingOccurrencesOfString:@"+" withString:@""];
    NSString *cdTitle = [title stringByReplacingOccurrencesOfString:@"+" withString:@""];
    request.predicate = [NSPredicate predicateWithFormat:@"artist == %@ && title == %@", cdArtist, cdTitle];
    
    NSError *requestError = nil;
    NSArray *resultArray = [self.coredata.managedContext executeFetchRequest:request error:&requestError];
    if (!requestError && resultArray.count > 0) {
        ColoredVKAudioEntity *entity = resultArray.firstObject;
        self.audioLyricsView.text = entity.lyrics;
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/lyrics.php",  kPackageAPIURL];
    
    ColoredVKNetworkController *networkController = [ColoredVKNetworkController controller];
    [networkController sendJSONRequestWithMethod:@"GET" stringURL:url parameters:@{@"artist":artist, @"title":title} 
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSDictionary *json) {
                                             if (json[@"response"]) {
                                                 NSData *data = [json[@"response"] dataUsingEncoding:NSUTF8StringEncoding];
                                                 NSDictionary *lyricsDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                 NSString *lyrics = lyricsDict[@"lyrics"];
                                                 
                                                 self.audioLyricsView.text = lyrics;
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     if (lyrics.length > 0) {
                                                         ColoredVKAudioEntity *audioEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ColoredVKAudioEntity" 
                                                                                                                           inManagedObjectContext:self.coredata.managedContext];
                                                         audioEntity.artist = cdArtist;
                                                         audioEntity.title = cdTitle;
                                                         audioEntity.lyrics = lyrics;
                                                         [self.coredata saveContext];
                                                     }
                                                 });
                                             } else {
                                                 [self.audioLyricsView resetState];
                                             }
                                         } 
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                             [self.audioLyricsView resetState];
                                         }];
}

- (NSString *)convertStringToURLSafe:(NSString *)string
{
    NSString *newString = [string stringByReplacingOccurrencesOfString:@"|" withString:@" "];
        
    NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@" /\\-|\""];
    newString = [[newString componentsSeparatedByCharactersInSet:charset] componentsJoinedByString:@"+"];
    while ([newString containsString:@"++"]) {
        newString = [newString stringByReplacingOccurrencesOfString:@"+++" withString:@"+"];
        newString = [newString stringByReplacingOccurrencesOfString:@"++" withString:@"+"];
    }
    if ([newString hasSuffix:@"+"]) newString = [newString stringByReplacingCharactersInRange:NSMakeRange(newString.length-1, 1) withString:@""];
    if ([newString hasPrefix:@"+"]) newString = [newString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    
    return newString;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@" %@; artist '%@'; track '%@'; frame %@; separationPoint %@; ", super.description, self.artist, self.track, 
            NSStringFromCGRect(self.coverView.frame), NSStringFromCGPoint(CGPointMake(0, CGRectGetMinY(self.bottomImageView.frame)))];
}

@end
