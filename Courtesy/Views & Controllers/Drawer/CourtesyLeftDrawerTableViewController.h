//
//  CourtesyLeftDrawerTableViewController.h
//  Courtesy
//
//  Created by i_82 on 2016-02-20.
//  Copyright (c) 2016 82Flex. All rights reserved.
//

@interface CourtesyLeftDrawerTableViewController : UITableViewController
- (BOOL)shortcutScan;
- (BOOL)shortcutCompose;
- (BOOL)shortcutShare;
- (BOOL)shortcutComposeWithQr:(NSString *)qr;
- (BOOL)shortcutViewWithToken:(NSString *)token;
- (void)shortcutMethod:(NSString *)method;
@end
