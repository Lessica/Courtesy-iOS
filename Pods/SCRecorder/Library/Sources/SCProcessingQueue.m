//
//  SCProcessingQueue.m
//  SCRecorder
//
//  Created by Simon CORSIN on 02/07/15.
//  Copyright (c) 2015 rFlex. All rights reserved.
//

#import "SCProcessingQueue.h"
#import "SCIOPixelBuffers.h"

@interface SCProcessingQueue () {
    NSMutableArray *_queue;
    dispatch_semaphore_t _availableItemsToDequeue;
    dispatch_semaphore_t _availableItemsToEnqueue;
    dispatch_semaphore_t _accessQueue;
    BOOL _completed;
}

@end

@implementation SCProcessingQueue

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _queue = [NSMutableArray new];
        _completed = NO;
        _maxQueueSize = 1;
        _availableItemsToDequeue = dispatch_semaphore_create(0);
        _accessQueue = dispatch_semaphore_create(1);
        self.maxQueueSize = 1;
    }
    
    return self;
}

- (void)dealloc
{
    [self stopProcessing];
}

- (void)setMaxQueueSize:(NSUInteger)maxQueueSize {    
    _availableItemsToEnqueue = dispatch_semaphore_create(0);

    for (NSUInteger i = 0; i < maxQueueSize; i++) {
        dispatch_semaphore_signal(_availableItemsToEnqueue);
    }

    _maxQueueSize = maxQueueSize;
}

- (void)_process:(id (^)())processingBlock {
    @autoreleasepool {
        while (!_completed) {
            BOOL shouldProcess = NO;

            @autoreleasepool {
                dispatch_semaphore_wait(_availableItemsToEnqueue, DISPATCH_TIME_FOREVER);
                shouldProcess = !_completed;

                BOOL shouldStopProcessing = NO;
                if (shouldProcess) {
                    id data = processingBlock();

                    if (data != nil) {
                        dispatch_semaphore_wait(_accessQueue, DISPATCH_TIME_FOREVER);
                        [_queue addObject:data];
                        dispatch_semaphore_signal(_accessQueue);
                        dispatch_semaphore_signal(_availableItemsToDequeue);
                    } else {
                        shouldStopProcessing = YES;
                        dispatch_semaphore_signal(_availableItemsToEnqueue);
                    }
                } else {
                    dispatch_semaphore_signal(_availableItemsToEnqueue);
                }

                if (shouldStopProcessing) {
                    [self stopProcessing];
                }
            }
        }
    }
}

- (void)startProcessingWithBlock:(id (^)())processingBlock {
    [NSThread detachNewThreadSelector:@selector(_process:) toTarget:self withObject:processingBlock];
}

- (void)stopProcessing {
    dispatch_semaphore_wait(_accessQueue, DISPATCH_TIME_FOREVER);

    _completed = YES;

    [_queue removeAllObjects];
    
    while (dispatch_semaphore_signal(_availableItemsToDequeue) < 0) {

    }
    while (dispatch_semaphore_signal(_availableItemsToEnqueue) < 0) {
        
    }
    

    dispatch_semaphore_signal(_accessQueue);    
}

- (id)dequeue {
    id obj = nil;
    
    if (!_completed) {
        dispatch_semaphore_wait(_availableItemsToDequeue, DISPATCH_TIME_FOREVER);
        
        dispatch_semaphore_wait(_accessQueue, DISPATCH_TIME_FOREVER);
        if (_queue.count > 0) {
            obj = _queue.firstObject;
            [_queue removeObjectAtIndex:0];
            dispatch_semaphore_signal(_availableItemsToEnqueue);
        } else {
            dispatch_semaphore_signal(_availableItemsToDequeue);
        }

        dispatch_semaphore_signal(_accessQueue);
    }
    
    return obj;
}

@end
