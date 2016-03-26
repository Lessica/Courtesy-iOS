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

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err {
    if (self = [super initWithDictionary:dict error:err]) {
        // Parsing Ignored Properties
    }
    return self;
}

- (AppStorage *)appStorage {
    return [AppStorage sharedInstance];
}

- (void)setCreated_at_object:(NSDate<Ignore> *)created_at_object {
    _created_at_object = created_at_object;
    _created_at = [created_at_object timeIntervalSince1970];
}

- (void)setModified_at_object:(NSDate<Ignore> *)modified_at_object {
    _modified_at_object = modified_at_object;
    _modified_at = [modified_at_object timeIntervalSince1970];
}

- (void)setFirst_read_at_object:(NSDate<Ignore> *)first_read_at_object {
    _first_read_at_object = first_read_at_object;
    _first_read_at = [first_read_at_object timeIntervalSince1970];
}

- (BOOL)hasLocalRecord {
    if (!self.local_token) {
        return NO;
    }
    id obj = [[self appStorage] objectForKey:[NSString stringWithFormat:kCourtesyCardPrefix, self.local_token]];
    if (!obj) {
        return NO;
    }
    return YES;
}

- (NSString *)saveToLocalDatabase {
    BOOL hasLocal = [self hasLocalRecord];
    NSDictionary *cardDict = [self toDictionary];
    [[self appStorage] setObject:cardDict forKey:[NSString stringWithFormat:kCourtesyCardPrefix, self.local_token]]; // Save Card Model
    // Save Attachments
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardDidFinishSaving:newRecord:)]) {
        [self.delegate cardDidFinishSaving:self newRecord:!hasLocal];
    }
    return self.local_token;
}

- (void)deleteInLocalDatabase {
    [[self appStorage] removeObjectForKey:[NSString stringWithFormat:kCourtesyCardPrefix, self.local_token]];
}

- (void)dealloc {
    CYLog(@"");
}

@end
