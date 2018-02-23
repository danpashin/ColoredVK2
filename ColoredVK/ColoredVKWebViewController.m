//
//  ColoredVKWebViewController.m
//  ColoredVK 2
//
//  Created by Даниил on 22.07.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

#import "ColoredVKWebViewController.h"
#import <WebKit/WebKit.h>
#import "PrefixHeader.h"
#import "ColoredVKNewInstaller.h"
#import <sys/utsname.h>

@interface ColoredVKWebViewController () <WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;

@property (strong, nonatomic) UIProgressView *progressView;
@property (assign, nonatomic) BOOL pageLoaded;

@end

@implementation ColoredVKWebViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (!self.navigationController.navigationBar.barTintColor || IS_IPAD) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{};
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CVKLocalizedString(@"DISMISS")
                                                                              style:UIBarButtonItemStyleDone 
                                                                             target:self action:@selector(dismiss)];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:self.webView];
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:self.progressView];
    
    [self setupConstraints];
    
    ColoredVKNetworkController *networkController = [ColoredVKNewInstaller sharedInstaller].networkController;
    [networkController sendRequest:self.request 
                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *rawData) {
                               NSString *html = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [self.webView loadHTMLString:html baseURL:request.URL];
                               });
                           }
                           failure:nil];
}

- (void)setupConstraints
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat navBarHeight = -self.webView.scrollView.contentOffset.y;
        
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 
                                                                          metrics:@{@"navBarHeight":@(navBarHeight)} views:@{@"webView":self.webView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 
                                                                          metrics:nil views:@{@"webView":self.webView}]];
        
        self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[progressView]|" options:0
                                                                          metrics:nil views:@{@"progressView":self.progressView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-navBarHeight-[progressView(2)]" 
                                                                          options:0 metrics:@{@"navBarHeight":@(navBarHeight)}
                                                                            views:@{@"progressView":self.progressView}]];
    });
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.progressView setProgress:[change[NSKeyValueChangeNewKey] floatValue] animated:YES];
        });
    }
}

- (void)present
{
    [self presentFromController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (void)presentFromController:(UIViewController *)controller 
{    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [controller presentViewController:navigationController animated:YES completion:nil];
}

- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)setPageLoaded:(BOOL)pageLoaded
{
    _pageLoaded = pageLoaded;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.progressView.alpha = pageLoaded ? 0.0f : 1.0f;
        } completion:^(BOOL finished) {
            if (pageLoaded)
                self.progressView.progress = 0.0f;
        }];
    });
}


#pragma mark -
#pragma mark WKNavigationDelegate
#pragma mark -

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    self.pageLoaded = NO;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    self.pageLoaded = YES;
    self.navigationItem.title = webView.title;
}

@end
