//
//  CourtesyOpenSourceProjectWebViewController.m
//  Courtesy
//
//  Created by Zheng on 5/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "CourtesyOpenSourceProjectWebViewController.h"

@interface CourtesyOpenSourceProjectWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *openWebView;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;

@end

@implementation CourtesyOpenSourceProjectWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
    _openWebView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    NSString *urlString = [[NSBundle mainBundle] pathForResource:@"open" ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_openWebView loadRequest:request];
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
    if (webView == _openWebView && _progressView) {
        [_progressView setProgress:0.0 animated:YES];
    }
}

#pragma mark - NJKWebViewProgressDelegate
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    [_progressView setProgress:progress animated:YES];
}

@end
