//
//  ColoredVKNavigationBar.m
//  ColoredVK2
//
//  Created by Даниил on 29/01/2018.
//

#import "ColoredVKNavigationBar.h"
#import "PrefixHeader.h"

@interface ColoredVKNavigationBar()

@property (strong, nonatomic) UIImageView *statusBarBack;

@end

@implementation ColoredVKNavigationBar

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat anchorConstant = 16.0f;
    UILayoutGuide *screenGuide = self.superview.layoutMarginsGuide;
    if (@available(iOS 11, *)) {
        anchorConstant = 0.0f;
        screenGuide = self.superview.safeAreaLayoutGuide;
    }
    
    if ((!IS_IPAD && ![self.superview.subviews containsObject:self.statusBarBack]) || (IS_IPAD && CGRectGetWidth(rect) < 1024)) {
        [self.superview addSubview:self.statusBarBack];
        self.statusBarBack.translatesAutoresizingMaskIntoConstraints = NO;
        [self.statusBarBack.heightAnchor constraintEqualToConstant:CGRectGetMinY(self.frame)].active = YES;
        [self.statusBarBack.leadingAnchor constraintEqualToAnchor:screenGuide.leadingAnchor constant:-anchorConstant].active = YES;
        [self.statusBarBack.trailingAnchor constraintEqualToAnchor:screenGuide.trailingAnchor constant:anchorConstant].active = YES;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, rect, self.statusBarBack.image.CGImage);
}

- (UIImageView *)statusBarBack
{
    if (!_statusBarBack) {
        CGRect frame = CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 20);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = [UIImage imageNamed:@"NavigationBackground" inBundle:[NSBundle bundleWithPath:CVK_BUNDLE_PATH] compatibleWithTraitCollection:nil];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        _statusBarBack = imageView;
    }
    
    return _statusBarBack;
}

@end
