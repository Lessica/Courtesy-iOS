//
//  CourtesyAboutViewController.m
//  Courtesy
//
//  Created by Zheng on 2/22/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyAboutViewController.h"
#import "UMSocial.h"

@interface CourtesyAboutViewController () <UIGestureRecognizerDelegate, UMSocialUIDelegate>

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *appLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;


@end

@implementation CourtesyAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 跳转到官方网站的手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailLabelClicked:)];
    tapGesture.delegate = self;
    [_detailLabel addGestureRecognizer:tapGesture];
    
    // 应用展示标签
    _appLabel.text = [NSString stringWithFormat:@"%@ V%@", APP_NAME_CN, VERSION_STRING];
}

- (void)detailLabelClicked:(UITapGestureRecognizer *)sender {
#if DEBUG
    // This could also live in a handler for a keyboard shortcut, debug menu item, etc.
    [self.navigationController.view makeToast:@"启动调试模式"
                                     duration:kStatusBarNotificationTime position:CSToastPositionCenter];
    [[FLEXManager sharedManager] showExplorer];
#else
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:SERVICE_INDEX]];
#endif
}

- (IBAction)shareButtonClicked:(id)sender {
    if (sender == _shareButton) {
        NSString *shareUrl = APP_DOWNLOAD_URL;
        [UMSocialData defaultData].extConfig.qqData.url = shareUrl;
        [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
        [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:UMENG_APP_KEY
                                          shareText:[NSString stringWithFormat:WEIBO_SHARE_CONTENT, kAccount.profile.nick ? kAccount.profile.nick : @"", APP_DOWNLOAD_URL]
                                         shareImage:[UIImage imageNamed:@"courtesy-share-qrcode"]
                                    shareToSnsNames:UMENG_SHARE_PLATFORMS
                                           delegate:self];
    }
}

#pragma mark - UMSocialUIDelegate

- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
    if (response.responseCode == UMSResponseCodeSuccess) {
        
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
