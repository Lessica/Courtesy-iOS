//
//  CourtesyCardDataModel.h
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "JSONModel.h"
#import "CourtesyCardAttachmentModel.h"
#import "CourtesyCardStyleModel.h"

@interface CourtesyCardDataModel : JSONModel
@property (nonatomic, strong) NSAttributedString *content;
@property (nonatomic, strong) NSArray<CourtesyCardAttachmentModel *> *attachments;
@property (nonatomic, assign) CourtesyCardStyleType styleType;
@property (nonatomic, strong) CourtesyCardStyleModel<Ignore> *style;
@property (nonatomic, assign) BOOL shouldAutoPlayAudio;
@property (nonatomic, assign) BOOL newcard;

@end
