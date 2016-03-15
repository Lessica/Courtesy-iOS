//
//  AFSoundItem.m
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 20/01/15.
//  Copyright (c) 2015 AlvaroFranco. All rights reserved.
//

#import "AFSoundItem.h"
#import "AFSoundManager.h"

@implementation AFSoundItem

-(id)initWithLocalResource:(NSString *)name atPath:(NSString *)path {
    
    if (self == [super init]) {
        
        _type = AFSoundItemTypeLocal;
        
        NSString *itemPath;
        
        if (!path) {
            
            NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
            itemPath = [resourcePath stringByAppendingPathComponent:name];
        } else {
            
            itemPath = [path stringByAppendingPathComponent:name];
        }
        
        _URL = [NSURL fileURLWithPath:itemPath];
        
        [self fetchMetadata];
    }
    
    return self;
}

-(id)initWithStreamingURL:(NSURL *)URL {
    
    if (self == [super init]) {
        
        _type = AFSoundItemTypeStreaming;
        
        _URL = URL;
        
        [self fetchMetadata];
    }
    
    return self;
}

-(void)fetchMetadata {
    
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:_URL];
    
    NSArray *metadata = [playerItem.asset commonMetadata];
    
    for (AVMetadataItem *metadataItem in metadata) {
        
        [metadataItem loadValuesAsynchronouslyForKeys:@[AVMetadataKeySpaceCommon] completionHandler:^{
            
            if ([metadataItem.commonKey isEqualToString:@"title"]) {
                
                _title = (NSString *)metadataItem.value;
            } else if ([metadataItem.commonKey isEqualToString:@"albumName"]) {
                
                _album = (NSString *)metadataItem.value;
            } else if ([metadataItem.commonKey isEqualToString:@"artist"]) {
                
                _artist = (NSString *)metadataItem.value;
            } else if ([metadataItem.commonKey isEqualToString:@"artwork"]) {
                
                if ([metadataItem.keySpace isEqualToString:AVMetadataKeySpaceID3]) {
                    if ([metadataItem.value respondsToSelector:@selector(objectForKey:)]) {
                        NSData *artworkData = [(NSDictionary *)metadataItem.value objectForKey:@"data"];
                        if (artworkData) _artwork = [UIImage imageWithData:artworkData];
                    }
                } else if ([metadataItem.keySpace isEqualToString:AVMetadataKeySpaceiTunes]) {
                    if ([metadataItem.value isMemberOfClass:[NSData class]]) {
                        NSData *artworkData = (NSData *)metadataItem.value;
                        if (artworkData) _artwork = [UIImage imageWithData:artworkData];
                    }
                }
            }
        }];
    }
}

-(void)setInfoFromItem:(AVPlayerItem *)item {
    
    _duration = CMTimeGetSeconds(item.duration);
    _timePlayed = CMTimeGetSeconds(item.currentTime);
}

@end
