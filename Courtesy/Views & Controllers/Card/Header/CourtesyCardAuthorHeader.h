//
//  CourtesyCardAuthorHeader.h
//  Courtesy
//
//  Created by Zheng on 4/25/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>

@interface CourtesyCardAuthorHeader : MJRefreshHeader
@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *nickLabel;
@property (strong, nonatomic) UILabel *viewCountLabel;

@end
