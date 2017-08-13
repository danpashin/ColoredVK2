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
#import "ColoredVKNetworkController.h"

@interface ColoredVKWebViewController () <UIWebViewDelegate, WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *wkWebView;
@property (strong, nonatomic) UIWebView *webView;

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
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.barTintColor = [UIColor whiteColor];
    navBar.tintColor = [UIColor darkGrayColor];
    navBar.titleTextAttributes = @{};
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CVKLocalizedString(@"Dismiss") 
                                                                              style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    
    if (SYSTEM_VERSION_IS_MORE_THAN(@"9.0")) {
        self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
        self.wkWebView.backgroundColor = [UIColor whiteColor];
        self.wkWebView.navigationDelegate = self;
        self.wkWebView.allowsBackForwardNavigationGestures = YES;
        [self.view addSubview:self.wkWebView];
        
        self.progressView = [[UIProgressView alloc] init];
        self.progressView.trackTintColor = [UIColor whiteColor];
        [self.view addSubview:self.progressView];
        
        [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:0];
    } else {
        self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        self.webView.backgroundColor = [UIColor whiteColor];
        self.webView.delegate = self;
        [self.view addSubview:self.webView];
    }
    
    
    ColoredVKNetworkController *networkController = [ColoredVKNetworkController controller];
    [networkController sendRequest:self.request 
                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSData *rawData) {
                               NSString *html = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
                               if (SYSTEM_VERSION_IS_MORE_THAN(@"9.0")) {
                                   [self.wkWebView loadHTMLString:html baseURL:request.URL];
                               } else {
                                   [self.webView loadHTMLString:html baseURL:request.URL];
                               }
                           }
                           failure:nil];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self setupConstraints];
}

- (void)setupConstraints
{
    [self.view removeConstraints:self.view.constraints];
    
    if (SYSTEM_VERSION_IS_MORE_THAN(@"9.0")) {
        CGFloat navBarHeight = (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) && !IS_IPAD) ? 64.0f : 32.0f;
        
        self.wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[wkWebView]|" options:0 
                                                                          metrics:@{@"navBarHeight":@(navBarHeight)} views:@{@"wkWebView":self.wkWebView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wkWebView]|" options:0 metrics:nil views:@{@"wkWebView":self.wkWebView}]];
        
        self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[progressView]|" options:0 metrics:nil views:@{@"progressView":self.progressView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-navBarHeight-[progressView(3)]" options:0 metrics:@{@"navBarHeight":@(navBarHeight)}
                                                                            views:@{@"progressView":self.progressView}]];
        
    } else {
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 metrics:nil views:@{@"webView":self.webView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:@{@"webView":self.webView}]];
    }
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
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)setPageLoaded:(BOOL)pageLoaded
{
    _pageLoaded = pageLoaded;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.progressView.alpha = pageLoaded ? 0.0f : 1.0f;
        } completion:^(BOOL finished) {
            if (pageLoaded)
                self.progressView.progress = 0.5f;
        }];
    });
}



#pragma mark -
#pragma mark UIWebViewDelegate
#pragma mark -

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.pageLoaded = NO;
//    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [indicatorView startAnimating];
//    indicatorView.color = [UIColor redColor];
//    self.navigationItem.titleView = indicatorView;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.pageLoaded = YES;
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
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
