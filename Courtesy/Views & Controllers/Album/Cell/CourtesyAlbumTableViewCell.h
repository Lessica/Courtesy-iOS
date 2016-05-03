//
//  CourtesyAlbumTableViewCell.h
//  Courtesy
//
//  Created by Zheng on 3/24/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CourtesyCardModel.h"
#import "CourtesyCardPublishQueue.h"

@interface CourtesyAlbumTableViewCell : UITableViewCell
@property (nonatomic, strong) CourtesyCardModel *card;

- (void)notifyUpdateProgress;
- (void)notifyUpdateStatus;
@end
