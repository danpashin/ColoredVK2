//
//  ColoredVKHelpController.m
//  ColoredVK2
//
//  Created by Даниил on 14.05.17.
//
//

#import "ColoredVKHelpController.h"
#import "PrefixHeader.h"

@implementation ColoredVKHelpController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupDefaultContentView];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.backgroundView.backgroundColor = [UIColor colorWithRed:90/255.0f green:130/255.0f blue:180/255.0f alpha:0.2];
    
    CGFloat contentViewWidth = CGRectGetWidth(self.contentView.frame);
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentViewWidth, 32)];
    self.nameLabel.text = CVKLocalizedString(@"HI");
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.font = [UIFont systemFontOfSize:25.0];
    [self.contentView addSubview:self.nameLabel];
    
    self.thanksLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.nameLabel.frame) + CGRectGetHeight(self.nameLabel.frame), contentViewWidth, 32)];
    self.thanksLabel.adjustsFontSizeToFitWidth = YES;
    self.thanksLabel.text = CVKLocalizedString(@"THANKS_FOR_PURCHASING");
    self.thanksLabel.textAlignment = NSTextAlignmentCenter;
    self.thanksLabel.font = [UIFont systemFontOfSize:18.0];
    [self.contentView addSubview:self.thanksLabel];
    
    self.messageTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.thanksLabel.frame) + CGRectGetHeight(self.thanksLabel.frame), contentViewWidth, CGRectGetHeight(self.contentView.frame) - (32 * 3))];
    self.messageTextView.text = CVKLocalizedString(@"RIGTHS_AGREEMENT");
    self.messageTextView.backgroundColor = [UIColor clearColor];
    self.messageTextView.editable = NO;
    [self.contentView addSubview:self.messageTextView];
    
    self.agreeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.messageTextView.frame) + CGRectGetHeight(self.messageTextView.frame),  contentViewWidth, 32)];
    [self.agreeButton setTitle:CVKLocalizedString(@"I_AGREE_WITH_RULES") forState:UIControlStateNormal];
    [self.agreeButton addTarget:self action:@selector(actionAgree) forControlEvents:UIControlEventTouchUpInside];
    self.agreeButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.agreeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.agreeButton addTarget:self action:@selector(actionAgree) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.agreeButton];
    
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view":self.nameLabel}]];
    
    self.thanksLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view":self.thanksLabel}]];
    
    self.agreeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view":self.agreeButton}]];
    
    self.messageTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[view]-|" options:0 metrics:nil views:@{@"view":self.messageTextView}]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[nameLabel(height)]-[thanksLabel(height)]-[messageTextView]-[agreeButton(height)]-|"
                                                                             options:0 metrics:@{@"height":@32} 
                                                                               views:@{@"nameLabel":self.nameLabel, @"thanksLabel":self.thanksLabel, 
                                                                                       @"messageTextView":self.messageTextView, @"agreeButton":self.agreeButton}]];
}

- (void)updateUsername
{
    NSString *url = [NSString stringWithFormat:@"https://api.vk.com/method/users.get?v=5.64&user_ids=%@", self.userID];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (!json[@"error"] && json[@"response"]) {
                NSDictionary *userInfo = ((NSArray *)json[@"response"]).firstObject;
                self.username = userInfo[@"first_name"];
            }
        }
    }];
}

- (void)actionAgree
{
    if (self.showInFirstTime) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:CVK_PREFS_PATH];
        dict[@"userAgreeWithCopyrights"] = @YES;
        [dict writeToFile:CVK_PREFS_PATH atomically:YES];
    }
    
    [self hide];
}



#pragma mark - Setters

- (void)setUserID:(NSNumber *)userID
{
    _userID = userID;
    
    [self updateUsername];
}

- (void)setUsername:(NSString *)username
{
    _username = username;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.nameLabel duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionAllowUserInteraction
                        animations:^{
                            if (self.showInFirstTime) self.nameLabel.text = [NSString stringWithFormat:CVKLocalizedString(@"HI_%@"), self.username];
                            else self.nameLabel.text = CVKLocalizedString(@"HI");
                        } completion:nil];
    });
}
@end
