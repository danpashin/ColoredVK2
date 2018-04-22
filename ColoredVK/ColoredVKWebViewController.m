//
//  ColoredVKWebViewController.m
//  ColoredVK 2
//
//  Created by Даниил on 22.07.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

#import "ColoredVKWebViewController.h"
#import <WebKit/WebKit.h>
#import "ColoredVKNavigationController.h"
#import "ColoredVKNetwork.h"

@interface ColoredVKWebViewController () <WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) NSString *requestHTML;

@property (strong, nonatomic) UIProgressView *progressView;
@property (assign, nonatomic) BOOL pageLoaded;
@end

@implementation ColoredVKWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CVKLocalizedString(@"DISMISS")
                                                                              style:UIBarButtonItemStyleDone 
                                                                             target:self action:@selector(dismiss)];
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.navigationDelegate = self;
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:self.webView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.requestHTML) {
            [self.webView loadHTMLString:self.requestHTML baseURL:self.request.URL];
            self.requestHTML = nil;
        }
    });
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressView.trackTintColor = [UIColor whiteColor];
    self.progressView.progressTintColor = [UIColor orangeColor];
    [self.view addSubview:self.progressView];
    
    
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 
                                                                      metrics:nil views:@{@"webView":self.webView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 
                                                                      metrics:nil views:@{@"webView":self.webView}]];
    
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[progressView]|" options:0
                                                                      metrics:nil views:@{@"progressView":self.progressView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-navBarHeight-[progressView(2)]" 
                                                                      options:0 metrics:@{@"navBarHeight":@(-self.webView.scrollView.contentOffset.y)}
                                                                        views:@{@"progressView":self.progressView}]];
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
    ColoredVKNavigationController *navigationController = [[ColoredVKNavigationController alloc] initWithRootViewController:self];
    navigationController.supportsAllOrientations = YES;
    navigationController.prefersLargeTitle = NO;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    [controller presentViewController:navigationController animated:YES completion:nil];
}

- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}


#pragma mark -
#pragma mark Setters
#pragma mark -

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

- (void)setRequest:(NSURLRequest *)request
{
    _request = request;
    
    [[ColoredVKNetwork sharedNetwork] sendRequest:request success:^(NSURLRequest *blockRequest, NSHTTPURLResponse *response, NSData *rawData) {
        NSString *html = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
        
        if (self.webView) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.webView loadHTMLString:html baseURL:blockRequest.URL];
            });
        } else {
            self.requestHTML = html;
        }
    } failure:nil];
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
