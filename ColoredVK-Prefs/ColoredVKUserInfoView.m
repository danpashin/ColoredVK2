//
//  ColoredVKUserInfoView.m
//  ColoredVK2
//
//  Created by Даниил on 03/02/2018.
//

#import "ColoredVKUserInfoView.h"
#import "PrefixHeader.h"
#import "SDWebImageManager.h"
#import "ColoredVKNewInstaller.h"

@interface ColoredVKUserInfoView ()

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *emailLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *stackBottomConstraint;
@property (strong, nonatomic) IBOutlet UIStackView *stackView;

@property (strong, nonatomic) UIImage *defaultAvatar;

@end

@implementation ColoredVKUserInfoView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.avatarImageView.layer.cornerRadius = CGRectGetHeight(self.avatarImageView.frame) / 2.0f;
    self.avatarImageView.layer.masksToBounds = YES;
    
    self.defaultAvatar = [UIImage imageNamed:@"UserBigIcon" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH]
                           compatibleWithTraitCollection:nil];
    self.defaultAvatar = [self.defaultAvatar imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.avatarImageView.image = self.defaultAvatar;
    
    [self setupConstraints];
}

- (void)setUsername:(NSString *)username
{
    _username = username;
    self.nameLabel.text = username;
    
    [self setupConstraints];
}

- (void)setEmail:(NSString *)email
{
    _email = email;
    self.emailLabel.text = email;
    
    [self setupConstraints];
}

- (void)setAvatar:(UIImage *)avatar
{
    _avatar = avatar;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImage *imageToChange = avatar ? avatar : self.defaultAvatar;     
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"contents"];
        animation.fromValue = self.avatarImageView.image;
        animation.toValue = imageToChange;
        animation.duration = 0.3f;
        
        [self.avatarImageView.layer addAnimation:animation forKey:@"contents"];
        self.avatarImageView.image = imageToChange;
    });
}

- (void)setupConstraints
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat stackBottomConstant = 8.0f;
        
        if (self.nameLabel.text.length == 0 && self.emailLabel.text.length == 0) {
            stackBottomConstant = -CGRectGetHeight(self.stackView.frame) + 2.0f * stackBottomConstant;
        } else if (self.nameLabel.text.length > 0 && self.emailLabel.text.length == 0) {
            stackBottomConstant = -stackBottomConstant * 2.0f;
        }
        
        self.stackBottomConstraint.constant = stackBottomConstant;
        
        CGFloat bottomConstantForHeight = (stackBottomConstant > 0.0f) ? stackBottomConstant : 0.0f;
        CGFloat heightForLabels = (self.nameLabel.text.length > 0) ? 40.0f : 0.0f;
        
        _preferredHeight = bottomConstantForHeight + heightForLabels + 8.0f + CGRectGetHeight(self.avatarImageView.frame);
        
        if ([self.delegate respondsToSelector:@selector(infoView:didUpdateHeight:)])
            [self.delegate infoView:self didUpdateHeight:self.preferredHeight];
    });
}

- (void)loadVKAvatarForUserID:(NSNumber *)userID
{
    ColoredVKNewInstaller *newInstaller = [ColoredVKNewInstaller sharedInstaller];
    if (!newInstaller.user.authenticated) {
        self.avatar = nil;
        return;
    }
    
    SDWebImageManager *imageManager = [SDWebImageManager sharedManager];
    NSString *imageCacheKey = [NSString stringWithFormat:@"cvk_vk_user_%@", userID];
    UIImage *cachedAvatar = [imageManager.imageCache imageFromCacheForKey:imageCacheKey];
    if (cachedAvatar) {
        self.avatar = cachedAvatar;
        return;
    }
    NSString *jsonURL = @"https://api.vk.com/method/users.get";
    NSDictionary *params = @{@"user_ids":userID, @"fields":@"photo_100", @"v":@"5.71"};
    NSError *requestError = nil;
    NSMutableURLRequest *request = [newInstaller.networkController requestWithMethod:@"GET" URLString:jsonURL 
                                                                          parameters:params error:&requestError];
    if (!requestError) {
        [request setValue:@"VK" forHTTPHeaderField:@"User-Agent"];
        [newInstaller.networkController sendRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *rawData) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:rawData options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]) {
                NSArray *array = json[@"response"];
                if ([array isKindOfClass:[NSArray class]]) {
                    NSDictionary *responseDict = array.firstObject;
                    if ([responseDict isKindOfClass:[NSDictionary class]]) {
                        NSString *photoURL = responseDict[@"photo_100"];
                        if (photoURL) {
                            [imageManager loadImageWithURL:[NSURL URLWithString:photoURL] 
                                                   options:SDWebImageHighPriority|SDWebImageCacheMemoryOnly 
                                                  progress:nil 
                                                 completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                     [imageManager.imageCache storeImage:image forKey:imageCacheKey completion:nil];
                                                     self.avatar = image;
                                                 }];
                        }
                    }
                }
                
                
            }
        } failure:nil];
    }
}

@end
