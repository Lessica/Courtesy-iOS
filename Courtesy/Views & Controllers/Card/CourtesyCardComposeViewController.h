//
//  CourtesyCardComposeViewController.h
//  Courtesy
//
//  Created by Zheng on 3/1/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardStyleModel.h"
#import "CourtesyQRCodeModel.h"
#import "CourtesyCardAttachmentModel.h"

@interface CourtesyCardComposeViewController : UIViewController

// 传值
@property (nonatomic, copy) CourtesyQRCodeModel *qrcode;

@property (nonatomic, strong) CourtesyCardStyleModel *style;

// 属性
@property (nonatomic, assign, getter=isEditable) BOOL editable; // 卡片是否可修改
@property (nonatomic, assign, getter=isNewCard) BOOL newcard; // 卡片是否是首次创建
@property (nonatomic, strong) NSDate *cardCreateTime; // 卡片创建时间
@property (nonatomic, strong) NSDate *cardModifyTime; // 卡片修改时间
@property (nonatomic, copy)   NSMutableAttributedString *cardContent; // 卡片内容
@property (nonatomic, strong) NSMutableArray<CourtesyCardAttachmentModel *> *cardAttachments; // 卡片标准附件
@property (nonatomic, assign) BOOL shouldAutoPlayAudio; // 是否自动播放音频

- (instancetype)initWithCardStyle:(CourtesyCardStyleModel *)style;
@end
