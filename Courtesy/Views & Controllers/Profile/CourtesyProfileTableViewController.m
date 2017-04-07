//
//  CourtesyProfileTableViewController.m
//  Courtesy
//
//  Created by Zheng on 2/26/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "AppDelegate.h"
#import "AppStorage.h"
#import "CourtesyProfileTableViewController.h"
#import "CourtesyAccountProfileModel.h"
#import "RSKImageCropper.h"
#import "JTSImageViewController.h"
#import "CourtesyParallaxHeaderView.h"
#import "CourtesyProfileCityTableViewController.h"
#import "UMSocial.h"

#define kCourtesyAvatarCachePrefix @"kCourtesyAvatarCache-%@"

#define kProfileAvatarReuseIdentifier @"kProfileAvatarReuseIdentifier"
#define kProfileNickReuseIdentifier @"kProfileNickReuseIdentifier"
#define kProfileGenderReuseIdentifier @"kProfileGenderReuseIdentifier"
#define kProfileBirthdayReuseIdentifier @"kProfileBirthdayReuseIdentifier"
#define kProfileMobileReuseIdentifier @"kProfileMobileReuseIdentifier"
#define kProfileFromWhereReuseIdentifier @"kProfileFromWhereReuseIdentifier"
#define kProfileConstellationReuseIdentifier @"kProfileConstellationReuseIdentifier"
#define kProfileIntroductionReuseIdentifier @"kProfileIntroductionReuseIdentifier"

enum {
    kAvatarSection = 0,
    kBasicSection,
    kReadonlySection
};

enum {
    kNickIndex = 0,
    kGenderIndex,
    kBirthdayIndex,
    kMobileIndex,
    kFromWhereIndex,
    kConstellationIndex,
    kIntroductionIndex
};

@interface CourtesyProfileTableViewController ()
<CourtesyEditProfileDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
CourtesyUploadAvatarDelegate,
RSKImageCropViewControllerDelegate,
JVFloatingDrawerCenterViewController,
JTSImageViewControllerInteractionsDelegate,
JTSImageViewControllerDismissalDelegate,
UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *avatarNickLabel;
@property (weak, nonatomic) IBOutlet UILabel *avatarDetailLabel;

@property (weak, nonatomic) IBOutlet UILabel *nickDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdayDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *fromWhereDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *constellationDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *registeredAtDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastLoginAtDetailLabel;

@property (strong, nonatomic) CourtesyParallaxHeaderView *headerView;

@end

@implementation CourtesyProfileTableViewController {
    id last_hash;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    last_hash = [[kProfile toDictionary] mutableCopy]; // 初始化备份
    
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout =  UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    
    self.avatarImageView.userInteractionEnabled = YES;
    [self.avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showOriginalAvatarImage:)]];
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToCopy:)];
    longPress.minimumPressDuration = 1.0;
    [self.tableView addGestureRecognizer:longPress];
    
    // Header View
    CourtesyParallaxHeaderView *headerView = [CourtesyParallaxHeaderView parallaxHeaderViewWithImage:[UIImage imageNamed:@"street"] forSize:CGSizeMake(self.tableView.frame.size.width, self.tableView.frame.size.width * 0.5625)];
    self.headerView = headerView;
    [self.tableView setTableHeaderView:headerView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        [(CourtesyParallaxHeaderView *)self.tableView.tableHeaderView layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_avatarImageView setImageWithURL:kProfile.avatar_url_medium
                              options:YYWebImageOptionShowNetworkActivity | YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation];
    _avatarNickLabel.text = kProfile.nick;
    _avatarDetailLabel.text = kAccount.email;
    _nickDetailLabel.text = kProfile.nick;
    if (kProfile.gender == 0) {
        _genderDetailLabel.text = @"男生";
    } else if (kProfile.gender == 1) {
        _genderDetailLabel.text = @"女生";
    } else if (kProfile.gender == 2) {
        _genderDetailLabel.text = @"保密";
    }
    _birthdayDetailLabel.text = kProfile.birthday;
    _mobileDetailLabel.text = kProfile.mobile;
    if (![[kProfile birthday] isEmpty]) {
        @try {
            _constellationDetailLabel.text = [[NSDate dateWithString:kProfile.birthday format:@"yyyy-MM-dd"] constellationString];
        }
        @catch (NSException *exception) {} @finally {}
    }
    @try {
        _fromWhereDetailLabel.text = [CourtesyProfileCityTableViewController generateCityStringWithState:kProfile.province andCity:kProfile.city andSubLocality:kProfile.area];
    } @catch (NSException *exception) {} @finally {}
    @try {
        _registeredAtDetailLabel.text = [[NSDate dateWithTimeIntervalSince1970:(float)kAccount.registered_at] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    } @catch (NSException *exception) {} @finally {}
    @try {
        _lastLoginAtDetailLabel.text = [[NSDate dateWithTimeIntervalSince1970:(float)kAccount.last_login_at] stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    } @catch (NSException *exception) {} @finally {}
    self.headerView.headerTitleLabel.text = kProfile.introduction;
    _emailDetailLabel.text = kAccount.email;
    [self.tableView reloadData];
    if (![[kProfile toDictionary] isEqual:last_hash]) { // 判断是否进行过修改
        last_hash = [[kProfile toDictionary] mutableCopy]; // 更新备份
        if (![kProfile isRequestingEditProfile]) {
            [JDStatusBarNotification showWithStatus:@"资料更新中"
                                          styleName:JDStatusBarStyleDefault];
            [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleGray];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
                [kProfile setDelegate:self]; // 设置请求代理
                [kProfile sendRequestEditProfile];
            });
        }
    }
}

#pragma mark - 个人资料导航栏按钮

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
}

- (IBAction)actionShareMyProfile:(id)sender {
    UIImage *shareImage = _avatarImageView.image ? _avatarImageView.image : [UIImage imageNamed:@"courtesy-share-qrcode"];
    NSString *shareUrl = APP_DOWNLOAD_URL;
    UmengSetShareType(shareUrl, shareImage)
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UMENG_APP_KEY
                                      shareText:[NSString stringWithFormat:WEIBO_SHARE_CONTENT, kAccount.profile.nick ? kAccount.profile.nick : @"", APP_DOWNLOAD_URL]
                                     shareImage:shareImage
                                shareToSnsNames:UMENG_SHARE_PLATFORMS
                                       delegate:nil];
}

#pragma mark - 自定义选择器

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == kAvatarSection && indexPath.row == 0) {
        [self openMenu];
    }
}

- (void)longPressToCopy:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:point];
        if (indexPath == nil) return;
        if (indexPath.section == kReadonlySection) {
            if (indexPath.row == 0) {
                [[UIPasteboard generalPasteboard] setString:_emailDetailLabel.text];
                [self.navigationController.view makeToast:@"注册邮箱已被复制到剪贴板"
                                                 duration:kStatusBarNotificationTime
                                                 position:CSToastPositionCenter];
            } else if (indexPath.row == 1) {
                [[UIPasteboard generalPasteboard] setString:_registeredAtDetailLabel.text];
                [self.navigationController.view makeToast:@"注册时间已被复制到剪贴板"
                                                 duration:kStatusBarNotificationTime
                                                 position:CSToastPositionCenter];
            } else if (indexPath.row == 2) {
                [[UIPasteboard generalPasteboard] setString:_lastLoginAtDetailLabel.text];
                [self.navigationController.view makeToast:@"最后登录已被复制到剪贴板"
                                                 duration:kStatusBarNotificationTime
                                                 position:CSToastPositionCenter];
            }
        }
    }
}

- (void)openMenu {
    LGAlertView *alertView = [[LGAlertView alloc] initWithTitle:@"上传头像"
                                                    message:@"请选择一种方式"
                                                      style:LGAlertViewStyleActionSheet buttonTitles:@[@"相机", @"本地相册"]
                                          cancelButtonTitle:@"取消"
                                     destructiveButtonTitle:nil
                                              actionHandler:^(LGAlertView *alertView, NSString *title, NSUInteger index) {
        if (index == 0) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.delegate = self;
            picker.allowsEditing = NO;
            [self presentViewController:picker animated:YES completion:nil];
        } else if (index == 1) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.delegate = self;
            picker.allowsEditing = NO;
            [self presentViewController:picker animated:YES completion:nil];
        } else {
            
        }
    } cancelHandler:nil destructiveHandler:nil];
    SetCourtesyAleryViewStyle(alertView)
    [alertView showAnimated:YES completionHandler:nil];
}

- (void)showOriginalAvatarImage:(id)sender {
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.referenceRect = self.avatarImageView.frame;
    imageInfo.referenceView = self.avatarImageView;
    NSString *avatar_cache_hash = [[kProfile.avatar_url_original path] md5String];
    NSString *avatar_cache_key = [NSString stringWithFormat:kCourtesyAvatarCachePrefix, avatar_cache_hash];
    if ([[AppStorage sharedInstance] objectForKey:avatar_cache_key]) {
        imageInfo.image = [UIImage imageWithData:[[AppStorage sharedInstance] objectForKey:avatar_cache_key]];
    } else {
        imageInfo.imageURL = kProfile.avatar_url_original;
    }
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc] initWithImageInfo:imageInfo
                                                                                       mode:JTSImageViewControllerMode_Image
                                                                            backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    imageViewer.interactionsDelegate = self;
    imageViewer.dismissalDelegate = self;
    [imageViewer showFromViewController:self
                             transition:JTSImageViewControllerTransition_FromOffscreen];
}

#pragma mark - JTSImageViewControllerInteractionsDelegate

- (void)imageViewerDidLongPress:(JTSImageViewController *)imageViewer
                         atRect:(CGRect)rect {
    [imageViewer.view makeToastActivity:CSToastPositionCenter];
    [[PHPhotoLibrary sharedPhotoLibrary] saveImage:imageViewer.image
                                           toAlbum:@"礼记"
                                        completion:^(BOOL success) {
                                            if (success) {
                                                dispatch_async_on_main_queue(^{
                                                    [imageViewer.view hideToastActivity];
                                                    [imageViewer.view makeToast:@"头像原图已保存到「礼记」相簿"
                                                                       duration:kStatusBarNotificationTime
                                                                       position:CSToastPositionCenter];
                                                });
                                            }
                                        } failure:^(NSError * _Nullable error) {
                                            dispatch_async_on_main_queue(^{
                                                [imageViewer.view hideToastActivity];
                                                [imageViewer.view makeToast:[NSString stringWithFormat:@"头像原图保存失败 - %@", [error localizedDescription]]
                                                                   duration:kStatusBarNotificationTime
                                                                   position:CSToastPositionCenter];
                                            });
                                        }];
}

#pragma mark - JTSImageViewControllerDismissalDelegate

- (void)imageViewerDidDismiss:(JTSImageViewController *)imageViewer {
    if (imageViewer.image && imageViewer.imageInfo.imageURL) {
        NSString *avatar_cache_hash = [[imageViewer.imageInfo.imageURL path] md5String];
        NSString *avatar_cache_key = [NSString stringWithFormat:kCourtesyAvatarCachePrefix, avatar_cache_hash];
        if (![[AppStorage sharedInstance] objectForKey:avatar_cache_key]) {
            [[AppStorage sharedInstance] setObject:[imageViewer.image imageDataRepresentation] forKey:avatar_cache_key];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __block UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    // 裁剪
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image];
    imageCropVC.delegate = self;
    [self.navigationController pushViewController:imageCropVC animated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - RSKImageCropViewControllerDelegate

// Crop image has been canceled.
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

// The original image has been cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
{
    // 上传
    if (![kProfile isRequestingUploadAvatar]) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            [JDStatusBarNotification showWithStatus:@"上传头像中"
                                          styleName:JDStatusBarStyleDefault];
            [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleGray];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^() {
            [kProfile setDelegate:self]; // 设置请求代理
            [kProfile sendRequestUploadAvatar:croppedImage];
        });
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - RSKImageCropViewControllerDataSource

// Returns a custom rect for the mask.
- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller
{
    CGSize maskSize;
    if ([controller isPortraitInterfaceOrientation]) {
        maskSize = CGSizeMake(250, 250);
    } else {
        maskSize = CGSizeMake(220, 220);
    }
    
    CGFloat viewWidth = CGRectGetWidth(controller.view.frame);
    CGFloat viewHeight = CGRectGetHeight(controller.view.frame);
    
    CGRect maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5f,
                                 (viewHeight - maskSize.height) * 0.5f,
                                 maskSize.width,
                                 maskSize.height);
    
    return maskRect;
}

// Returns a custom rect in which the image can be moved.
- (CGRect)imageCropViewControllerCustomMovementRect:(RSKImageCropViewController *)controller
{
    // If the image is not rotated, then the movement rect coincides with the mask rect.
    return controller.maskRect;
}

#pragma mark - 修改资料请求回调

- (void)editProfileSucceed:(CourtesyAccountProfileModel *)sender {
    [JDStatusBarNotification showWithStatus:@"资料更新成功" dismissAfter:kStatusBarNotificationTime
                                  styleName:JDStatusBarStyleSuccess];
    [NSNotificationCenter sendCTAction:kCourtesyActionProfileEdited message:nil];
}

- (void)editProfileFailed:(CourtesyAccountProfileModel *)sender
             errorMessage:(NSString *)message {
    [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"资料更新失败 - %@", message]
                               dismissAfter:kStatusBarNotificationTime
                                  styleName:JDStatusBarStyleError];
    [NSNotificationCenter sendCTAction:kCourtesyActionProfileEdited message:nil];
    [[GlobalSettings sharedInstance] reloadAccount];
}

#pragma mark - 上传头像请求回调

- (void)uploadAvatarSucceed:(CourtesyAccountProfileModel *)sender {
    [JDStatusBarNotification showWithStatus:@"头像上传成功"
                               dismissAfter:kStatusBarNotificationTime
                                  styleName:JDStatusBarStyleSuccess];
    _avatarImageView.imageURL = kProfile.avatar_url_medium;
    [NSNotificationCenter sendCTAction:kCourtesyActionProfileEdited message:nil];
    last_hash = [[kProfile toDictionary] mutableCopy]; // 头像更新以后需要更新备份
}

- (void)uploadAvatarFailed:(CourtesyAccountProfileModel *)sender
              errorMessage:(NSString *)message {
    [JDStatusBarNotification showWithStatus:[NSString stringWithFormat:@"头像上传失败 - %@", message]
                               dismissAfter:kStatusBarNotificationTime
                                  styleName:JDStatusBarStyleError];
    _avatarImageView.imageURL = kProfile.avatar_url_medium;
    [NSNotificationCenter sendCTAction:kCourtesyActionProfileEdited message:nil];
    last_hash = [[kProfile toDictionary] mutableCopy]; // 头像更新以后需要更新备份
    [[GlobalSettings sharedInstance] reloadAccount];
}

#pragma mark - JVFloatingDrawerCenterViewController

- (BOOL)shouldOpenDrawerWithSide:(JVFloatingDrawerSide)drawerSide {
    if (drawerSide == JVFloatingDrawerSideLeft) return YES;
    return NO;
}

@end
