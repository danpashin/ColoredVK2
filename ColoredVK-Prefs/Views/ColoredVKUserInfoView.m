//
//  ColoredVKUserInfoView.m
//  ColoredVK2
//
//  Created by Даниил on 03/02/2018.
//

#import "ColoredVKUserInfoView.h"
#import "SDWebImageManager.h"
#import "ColoredVKNewInstaller.h"
#import "ColoredVKNetwork.h"

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
    
    self.defaultAvatar = CVKImage(@"user/UserBigIcon");
    self.avatarImageView.image = self.defaultAvatar;
    
    [self setupConstraints];
}


#pragma mark -
#pragma mark Setters
#pragma mark -

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


#pragma mark -
#pragma mark Actions
#pragma mark -

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
        
        self->_preferredHeight = bottomConstantForHeight + heightForLabels + 8.0f + CGRectGetHeight(self.avatarImageView.frame);
        
        if ([self.delegate respondsToSelector:@selector(infoView:didUpdateHeight:)])
            [self.delegate infoView:self didUpdateHeight:self.preferredHeight];
    });
}

@end
