//
//  CourtesyCardAttachmentModel.m
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardAttachmentModel.h"

@implementation CourtesyCardAttachmentModel

- (void)setUploaded_at_object:(NSDate<Optional> *)uploaded_at_object {
    _uploaded_at_object = uploaded_at_object;
    _uploaded_at = [_uploaded_at_object timeIntervalSince1970];
}

- (void)setCreated_at_object:(NSDate<Optional> *)created_at_object {
    _created_at_object = created_at_object;
    _created_at = [_created_at_object timeIntervalSince1970];
}

@end
