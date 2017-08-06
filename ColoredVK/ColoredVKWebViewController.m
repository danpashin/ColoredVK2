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

@interface ColoredVKWebViewController () <NSURLConnectionDataDelegate>

@property (strong, nonatomic) WKWebView *wkWebView;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSMutableData *mutableData;

@property (strong, nonatomic) NSURLConnection *connection;

@end

@implementation ColoredVKWebViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mutableData = [NSMutableData data];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (!self.navigationController.navigationBar.barTintColor || IS_IPAD) return UIStatusBarStyleLightContent;
    else return UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:UIKitLocalizedString(@"Dismiss") 
                                                                              style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    
    if (SYSTEM_VERSION_IS_MORE_THAN(@"9.0")) {
        self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
        self.wkWebView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.wkWebView];
        
        self.wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[wkWebView]|" options:0 metrics:nil views:@{@"wkWebView":self.wkWebView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[wkWebView]|" options:0 metrics:nil views:@{@"wkWebView":self.wkWebView}]];
    } else {
        self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        self.webView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:self.webView];
        
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 metrics:nil views:@{@"webView":self.webView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:@{@"webView":self.webView}]];
    }
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.mutableData appendData:data]; 
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *html = [[NSString alloc] initWithData:self.mutableData encoding:NSUTF8StringEncoding];
    
    if (SYSTEM_VERSION_IS_MORE_THAN(@"9.0")) {
        [self.wkWebView loadHTMLString:html baseURL:self.url];
    } else {
        [self.webView loadHTMLString:html baseURL:self.url];
    }
}

- (void)present
{
    [self presentFromController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (void)presentFromController:(UIViewController *)controller 
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
        [self.connection start];
    });
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [controller presentViewController:navigationController animated:YES completion:nil];
}

@end
