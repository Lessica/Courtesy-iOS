//
//  CourtesyGalleryLinkWebViewController.m
//  Courtesy
//
//  Created by Zheng on 5/13/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "CourtesyGalleryLinkWebViewController.h"

@interface CourtesyGalleryLinkWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;

@end

@implementation CourtesyGalleryLinkWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NJKWebViewProgress *progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
    progressProxy.webViewProxyDelegate = self;
    progressProxy.progressDelegate = self;
    self.progressProxy = progressProxy;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = progressProxy;
    self.webView = webView;
    [self.view addSubview:webView];
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    
    NJKWebViewProgressView *progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.progressView = progressView;
    
    NSString *urlString = self.cardUrl;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    [_progressView removeFromSuperview];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView == _webView && _progressView) {
        [_progressView setProgress:0.0 animated:YES];
    }
    NSString *currentTitle = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = currentTitle;
}

#pragma mark - NJKWebViewProgressDelegate
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    [_progressView setProgress:progress animated:YES];
}

@end
