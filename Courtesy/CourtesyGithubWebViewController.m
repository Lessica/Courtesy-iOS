//
//  CourtesyGithubWebViewController.m
//  Courtesy
//
//  Created by i_82 on 2016-02-20.
//  Copyright (c) 2016 82Flex. All rights reserved.
//

#import "CourtesyGithubWebViewController.h"
#import "AppDelegate.h"

static NSString * const kJVGithubProjectPage = @"https://github.com/Lessica/Courtesy-iOS";

@interface CourtesyGithubWebViewController ()

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

- (IBAction)actionToggleRightDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleRightDrawer:self animated:YES];
}

@end
