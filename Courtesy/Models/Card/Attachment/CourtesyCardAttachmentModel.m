//
//  CourtesyCardAttachmentModel.m
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardAttachmentModel.h"
#import "AppStorage.h"
#import "FCFileManager.h"

#define kCourtesyAttachmentPrefix @"kCourtesyAttachmentPrefix-%@"

@implementation CourtesyCardAttachmentModel

- (instancetype)initWithSaltHash:(NSString *)salt {
    id obj = [[self appStorage] objectForKey:[NSString stringWithFormat:kCourtesyAttachmentPrefix, salt]];
    if (!obj) {
        return nil;
    }
    _salt_hash = salt;
    NSError *err = nil;
    NSDictionary *aDict = obj;
    if (self = [super initWithDictionary:aDict error:&err]) {

    }
    NSAssert(err == nil, @"Error occured when parsing attachment model with its hash!");
    return self;
}

#pragma mark - Getter / Setter

- (AppStorage *)appStorage {
    return [AppStorage sharedInstance];
}

- (void)setLocal_filename:(NSString<Optional> *)local_filename {
    _local_filename = local_filename;
    if (_local_filename) {
        NSString *targetPath = [[NSURL fileURLWithPath:[[[UIApplication sharedApplication] documentsPath] stringByAppendingPathComponent:@"SavedAttachments"]] path];
        _local_url = [NSURL fileURLWithPath:[targetPath stringByAppendingPathComponent:_local_filename]];
    }
}

- (void)setRemote_url_path:(NSString<Optional> *)remote_url_path {
    _remote_url_path = remote_url_path;
    if (_remote_url_path) {
        _remote_url = [NSURL URLWithString:_remote_url_path];
    }
}

- (void)setUploaded_at:(NSUInteger)uploaded_at {
    _uploaded_at = uploaded_at;
    _uploaded_at_object = [NSDate dateWithTimeIntervalSince1970:_uploaded_at];
}

- (void)setCreated_at:(NSUInteger)created_at {
    _created_at = created_at;
    _created_at_object = [NSDate dateWithTimeIntervalSince1970:_created_at];
}

#pragma mark - Card Storage

- (BOOL)hasLocalRecord {
    if (!self.salt_hash) {
        return NO;
    }
    id obj = [[self appStorage] objectForKey:[NSString stringWithFormat:kCourtesyAttachmentPrefix, self.salt_hash]];
    if (!obj) {
        return NO;
    }
    return YES;
}

- (NSString *)saveToLocalDatabase {
    NSDictionary *cardDict = [self toDictionary];
    NSAssert(cardDict != nil && self.salt_hash != nil, @"Attachment cannot be saved to the database!");
    [[self appStorage] setObject:cardDict forKey:[NSString stringWithFormat:kCourtesyAttachmentPrefix, self.salt_hash]];
    return self.salt_hash;
}

- (void)deleteInLocalDatabase {
    [FCFileManager removeItemAtPath:[_local_url path]];
    [[self appStorage] removeObjectForKey:[NSString stringWithFormat:kCourtesyAttachmentPrefix, self.salt_hash]];
}

@end
