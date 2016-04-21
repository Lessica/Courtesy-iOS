//
//  CourtesyCardModel.m
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardModel.h"
#import "AppStorage.h"

#define kCourtesyCardPrefix @"kCourtesyCardPrefix-%@"

@implementation CourtesyCardModel

+ (BOOL)propertyIsIgnored:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"delegate"]) {
        return YES;
    }
    return [super propertyIsIgnored:propertyName];
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

- (NSString *)saveToLocalDatabaseWithPublishFlag:(BOOL)willPublish {
    BOOL hasLocal = [self hasLocalRecord];
    NSDictionary *cardDict = [self toDictionary];
    [[self appStorage] setObject:cardDict forKey:[NSString stringWithFormat:kCourtesyCardPrefix, self.token]]; // Save Card Model
    // Save Attachments
    for (CourtesyCardAttachmentModel *a in self.local_template.attachments) {
        [a saveToLocalDatabase];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardDidFinishSaving:isNewRecord:willPublish:)]) {
        [self.delegate cardDidFinishSaving:self isNewRecord:!hasLocal willPublish:willPublish];
    }
    return self.token;
}

- (void)deleteInLocalDatabase {
    for (CourtesyCardAttachmentModel *a in self.local_template.attachments) {
        [a removeFromLocalDatabase];
    }
    [[self appStorage] removeObjectForKey:[NSString stringWithFormat:kCourtesyCardPrefix, self.token]];
}

@end
