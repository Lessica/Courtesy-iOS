//
//  CourtesyThemeSettingsTableViewController.m
//  Courtesy
//
//  Created by Zheng on 5/6/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyThemeSettingsTableViewController.h"

@interface CourtesyThemeSettingsTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *markdownSupportSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *previewAvatarSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *previewShadowSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *previewSaveSwitch;

@end

@implementation CourtesyThemeSettingsTableViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    _markdownSupportSwitch.on = [sharedSettings switchMarkdown];
    _previewAvatarSwitch.on = [sharedSettings switchPreviewAvatar];
    _previewShadowSwitch.on = [sharedSettings switchPreviewNeedsShadows];
}

- (IBAction)switchTriggered:(id)sender {
    if (sender == _markdownSupportSwitch) {
        [sharedSettings setSwitchMarkdown:_markdownSupportSwitch.on];
    } else if (sender == _previewAvatarSwitch) {
        [sharedSettings setSwitchPreviewAvatar:_previewAvatarSwitch.on];
    } else if (sender == _previewShadowSwitch) {
        [sharedSettings setSwitchPreviewNeedsShadows:_previewShadowSwitch.on];
    }
}

@end
