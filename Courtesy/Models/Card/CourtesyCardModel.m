//
//  CourtesyCardModel.m
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardModel.h"
#import "FCFileManager.h"
#import "AppStorage.h"

#define kCourtesyCardPrefix @"kCourtesyCardPrefix-%@"

@implementation CourtesyCardModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if (
        [propertyName isEqualToString:@"first_read_at"] ||
        [propertyName isEqualToString:@"read_by"] ||
        [propertyName isEqualToString:@"isNewCard"] ||
        [propertyName isEqualToString:@"hasPublished"]
        ) {
        return YES;
    }
    return NO;
}

+ (BOOL)propertyIsIgnored:(NSString *)propertyName {
    if (
        [propertyName isEqualToString:@"isNewRecord"] ||
        [propertyName isEqualToString:@"willPublish"] ||
        [propertyName isEqualToString:@"shouldNotify"] ||
        [propertyName isEqualToString:@"shouldRemove"]
        ) {
        return YES;
    }
    return NO;
}

- (instancetype)initWithCardToken:(NSString *)token {
    id obj = [[self appStorage] objectForKey:[NSString stringWithFormat:kCourtesyCardPrefix, token]];
    if (!obj) {
        return nil;
    }
    _token = token;
    NSError *err = nil;
    NSDictionary *cDict = obj;
    if (self = [super initWithDictionary:cDict error:&err]) {
        
    }
    CYLog(@"%@", err);
    NSAssert(err == nil, @"Error occured when parsing card model with its hash!");
    return self;
}

- (void)dealloc {
    CYLog(@"");
}

#pragma mark - Getter / Setter

- (AppStorage *)appStorage {
    return [AppStorage sharedInstance];
}

- (void)setQr_id:(NSString<Optional> *)qr_id {
    _qr_id = qr_id;
    if (_local_template) {
        _local_template.qrcode = qr_id;
    }
}

#pragma mark - Card Storage

- (BOOL)hasLocalRecord {
    if (!self.token) {
        return NO;
    }
    id obj = [[self appStorage] objectForKey:[NSString stringWithFormat:kCourtesyCardPrefix, self.token]];
    if (!obj) {
        return NO;
    }
    return YES;
}

- (NSString *)saveToLocalDatabase {
    BOOL hasLocal = [self hasLocalRecord];
    NSDictionary *cardDict = [self toDictionary];
    [[self appStorage] setObject:cardDict forKey:[NSString stringWithFormat:kCourtesyCardPrefix, self.token]]; // Save Card Model
    // Save Attachments
    for (CourtesyCardAttachmentModel *a in self.local_template.attachments) {
        [a saveToLocalDatabase];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardDidFinishSaving:)]) {
        if (hasLocal) {
            _isNewRecord = NO;
        } else {
            _isNewRecord = YES;
        }
        [self.delegate cardDidFinishSaving:self];
    }
    return self.token;
}

- (void)deleteInLocalDatabase {
    for (CourtesyCardAttachmentModel *a in self.local_template.attachments) {
        [a removeFromLocalDatabase];
    }
    [[self appStorage] removeObjectForKey:[NSString stringWithFormat:kCourtesyCardPrefix, self.token]];
}

#pragma mark - Card Cache

- (BOOL)isCardCached {
    for (CourtesyCardAttachmentModel *attr in self.local_template.attachments) {
        NSString *localPath = [attr attachmentPath];
        if (![FCFileManager isReadableItemAtPath:localPath]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - card owner

- (BOOL)isMyCard {
    if (
        (self.author) &&
        (self.author.user_id == kAccount.user_id)
        ) {
        return YES;
    }
    return NO;
}

- (BOOL)isReadByMe {
    if (
        (self.read_by) &&
        (self.read_by.user_id == kAccount.user_id)
        ) {
        return YES;
    }
    return NO;
}

@end
