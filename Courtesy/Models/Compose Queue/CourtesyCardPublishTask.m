//
//  CourtesyCardPublishTask.m
//  Courtesy
//
//  Created by Zheng on 4/12/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardPublishTask.h"

@implementation CourtesyCardPublishTask

- (instancetype)initWithCard:(CourtesyCardModel *)card {
    if (self = [super init]) {
        _card = card;
        _hasObserver = NO;
    }
    return self;
}

- (void)addObserver:(NSObject *)observer
         forKeyPath:(NSString *)keyPath
            options:(NSKeyValueObservingOptions)options
            context:(void *)context {
    if (!_hasObserver) {
        [super addObserver:observer forKeyPath:keyPath options:options context:context];
        _hasObserver = YES;
    }
}

- (void)removeObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath {
    if (_hasObserver) {
        [super removeObserver:observer forKeyPath:keyPath];
        _hasObserver = NO;
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
