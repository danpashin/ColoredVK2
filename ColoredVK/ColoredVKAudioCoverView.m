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
@end

@implementation ColoredVKAudioCoverView

- (instancetype)initWithFrame:(CGRect)frame andSeparationPoint:(CGPoint)point
{
    self = [super initWithFrame:frame];
    if (self) {
        self.cvkBundle = [NSBundle bundleWithPath:CVK_BUNDLE_PATH];
        self.topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName inBundle:self.cvkBundle compatibleWithTraitCollection:nil]];
        self.topImageView.frame = CGRectMake(0, 0, frame.size.width, point.y);
        self.topImageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.topImageView];
        
        self.bottomImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName inBundle:self.cvkBundle compatibleWithTraitCollection:nil]];
        self.bottomImageView.frame = CGRectMake(0, point.y, frame.size.width, frame.size.height-point.y);
        self.bottomImageView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bottomImageView];
        [self sendSubviewToBack:self.bottomImageView];
        
        self.defaultCover = YES;
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
                self.defaultCover = !wasDownloaded;
                
                UIImage *coverImage = image;
                if (player.coverImage && (!wasDownloaded && ![player.coverImage.imageAsset.assetName containsString:@"placeholder"])) coverImage = player.coverImage;
                
                MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
                NSMutableDictionary *playingInfo = [NSMutableDictionary dictionaryWithDictionary:center.nowPlayingInfo];
                playingInfo[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:coverImage];
                center.nowPlayingInfo = [NSDictionary dictionaryWithDictionary:playingInfo];
                
                [self changeImageViewImage:self.topImageView toImage:coverImage animated:YES];
                [self changeImageViewImage:self.bottomImageView toImage:coverImage animated:YES];
                
                LEColorPicker *picker = [[LEColorPicker alloc] init];
                [picker pickColorsFromImage:image onComplete:^(LEColorScheme *colorScheme) {
                    self.backColor = [colorScheme.backgroundColor colorWithAlphaComponent:0.4];
                    self.tintColor = colorScheme.secondaryTextColor;
                    [NSNotificationCenter.defaultCenter postNotificationName:@"com.daniilpashin.coloredvk.audio.image.changed" object:nil];
                }];
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

- (void)setContentMode:(UIViewContentMode)contentMode
{
    super.contentMode = contentMode;
    self.topImageView.contentMode = contentMode;
    self.bottomImageView.contentMode = contentMode;
}

- (void)downloadCoverWithCompletionBlock:( void(^)(UIImage *image, BOOL wasDownloaded) )block;
{
    if (self.artist && self.track) {
        UIImage *noCover = [UIImage imageNamed:imageName inBundle:self.cvkBundle compatibleWithTraitCollection:nil];
        NSString *query = [NSString stringWithFormat:@"%@+%@", self.artist, self.track];
        query = [query stringByReplacingOccurrencesOfString:@"|" withString:@" "];
        
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(\\(|\\[)+(?:\\w|\\s)+(\\)|\\])" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *matches = [regex matchesInString:query options:0 range:NSMakeRange(0, query.length)];
        NSString *oldQuery = query.copy;
        for (NSTextCheckingResult *result in matches) query = [query stringByReplacingOccurrencesOfString:[oldQuery substringWithRange:result.range] withString:@""];
        
        NSCharacterSet *charset = [NSCharacterSet characterSetWithCharactersInString:@" &/-.()[]!&|'`+"];
        query = [[query componentsSeparatedByCharactersInSet:charset] componentsJoinedByString:@"+"];
        while ([query containsString:@"++"]) {
            query = [query stringByReplacingOccurrencesOfString:@"+++" withString:@"+"];
            query = [query stringByReplacingOccurrencesOfString:@"++" withString:@"+"];
        }
        
        NSString *iTunesURL = [NSString stringWithFormat:@"https://itunes.apple.com/search?limit=1&media=music&term=%@", query];
        [(AFJSONRequestOperation *)[NSClassFromString(@"AFJSONRequestOperation") 
                                    JSONRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:iTunesURL]]
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                        NSDictionary *responseDict = JSON;
                                        NSArray *items = responseDict[@"results"];
                                        if (items.count > 0) {
                                            NSString *imageURL = [items[0][@"artworkUrl100"] stringByReplacingOccurrencesOfString:@"100x100bb" withString:@"1024x1024bb"];
                                            [(AFImageRequestOperation *)[NSClassFromString(@"AFImageRequestOperation") 
                                                                         imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL]]
                                                                         imageProcessingBlock:^UIImage *(UIImage *image) { return image; }
                                                                         cacheName:@"com.daniilpashin.coloredvk2.covers.cache"
                                                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) { if (block) block(image, YES); } 
                                                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) { if (block) block(noCover, NO); }] start];
                                        } else if (block) block(noCover, NO);
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) { if (block) block(noCover, NO); }] start];
    }
}
@end
