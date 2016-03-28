//
//  CourtesyGithubWebViewController.m
//  Courtesy
//
//  Created by i_82 on 2016-02-20.
//  Copyright (c) 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "CourtesyGithubWebViewController.h"

static NSString * const kJVGithubProjectPage = @"https://github.com/Lessica";

@interface CourtesyGithubWebViewController () <JVFloatingDrawerCenterViewController>

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end

@implementation CourtesyGithubWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadWebpage];
}

- (void)loadWebpage {
    NSURL *webpageURL = [NSURL URLWithString:kJVGithubProjectPage];
    NSURLRequest *webpageRequest = [NSURLRequest requestWithURL:webpageURL];
    [self.webview loadRequest:webpageRequest];
}

#pragma mark - Actions

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}


#pragma mark - JVFloatingDrawerCenterViewController

- (BOOL)shouldOpenDrawerWithSide:(JVFloatingDrawerSide)drawerSide {
    if (drawerSide == JVFloatingDrawerSideLeft) return YES;
    return NO;
}

@end
