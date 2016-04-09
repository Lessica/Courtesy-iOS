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
    if ((self.card_data = [[CourtesyCardDataModel alloc] initWithDictionary:self.card_dict andCardToken:token error:&err])) {
        CYLog(@"%@", [self toJSONString]);
    }
    NSAssert(err == nil, @"Error occured when parsing card data model with its hash!");
    return self;
}

- (void)dealloc {
    CYLog(@"");
}

#pragma mark - Getter / Setter

- (AppStorage *)appStorage {
    return [AppStorage sharedInstance];
}

- (void)setCreated_at:(NSUInteger)created_at {
    _created_at = created_at;
    _created_at_object = [NSDate dateWithTimeIntervalSince1970:created_at];
}

- (void)setModified_at:(NSUInteger)modified_at {
    _modified_at = modified_at;
    _modified_at_object = [NSDate dateWithTimeIntervalSince1970:modified_at];
}

- (void)setFirst_read_at:(NSUInteger)first_read_at {
    _first_read_at = first_read_at;
    _first_read_at_object = [NSDate dateWithTimeIntervalSince1970:first_read_at];
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
    for (CourtesyCardAttachmentModel *a in self.card_data.attachments) {
        [a saveToLocalDatabase];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardDidFinishSaving:newRecord:)]) {
        [self.delegate cardDidFinishSaving:self newRecord:!hasLocal];
    }
    return self.token;
}

- (void)deleteInLocalDatabase {
    for (CourtesyCardAttachmentModel *a in self.card_data.attachments) {
        [a deleteInLocalDatabase];
    }
    [[self appStorage] removeObjectForKey:[NSString stringWithFormat:kCourtesyCardPrefix, self.token]];
}

@end
