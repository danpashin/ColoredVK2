//
//  ColoredVKPaymentController.m
//  ColoredVK 2
//
//  Created by Даниил on 22.07.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

#import "ColoredVKPaymentController.h"
#import <WebKit/WebKit.h>
#import "PrefixHeader.h"

@interface ColoredVKPaymentController () <NSURLConnectionDataDelegate>

@property (strong, nonatomic) WKWebView *wkWebView;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSMutableData *paymentPage;

@end

@implementation ColoredVKPaymentController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (!self.navigationController.navigationBar.barTintColor || IS_IPAD) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.paymentPage = [NSMutableData data];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.navigationController.navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                                                                                                       target:self action:@selector(dismiss)];
    
    if (SYSTEM_VERSION_IS_MORE_THAN(@"9.0")) {
        self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) configuration:[WKWebViewConfiguration new]];
        self.wkWebView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.wkWebView];
        
        self.wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[wkWebView]|" options:0 metrics:nil views:@{@"wkWebView":self.wkWebView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wkWebView]|" options:0 metrics:nil views:@{@"wkWebView":self.wkWebView}]];
    } else {
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.webView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.webView];
        
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 metrics:nil views:@{@"webView":self.webView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:@{@"webView":self.webView}]];
    }
}

- (void)setRequest:(NSURLRequest *)request
{
    _request = request;
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
    [connection start];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.paymentPage appendData:data]; 
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *html = [[NSString alloc] initWithData:self.paymentPage encoding:NSUTF8StringEncoding];
    
    if (SYSTEM_VERSION_IS_MORE_THAN(@"9.0")) {
        [self.wkWebView loadHTMLString:html baseURL:self.url];
    } else {
        [self.webView loadHTMLString:html baseURL:self.url];
    }
}

@end
