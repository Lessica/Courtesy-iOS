//
//  NetworkUtils.m
//  Courtesy
//
//  Created by Zheng on 2/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "NetworkUtils.h"
#import "JSONHTTPClient.h"
#import <UIKit/UIKit.h>

@implementation NetworkUtils

+ (void)setNetworkConfig {
    [JSONHTTPClient setDefaultTextEncoding:NSUTF8StringEncoding];
    [JSONHTTPClient setRequestContentType:@"application/json"];
    [JSONHTTPClient setCachingPolicy:NSURLRequestReloadIgnoringCacheData];
    [JSONHTTPClient setTimeoutInSeconds:20];
}

+ (void)openURL:(NSString *)url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
