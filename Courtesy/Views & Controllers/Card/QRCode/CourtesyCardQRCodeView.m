//
//  CourtesyCardQRCodeView.m
//  Courtesy
//
//  Created by Zheng on 5/20/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyCardQRCodeView.h"
#import "ZXingWrapper.h"

@interface CourtesyCardQRCodeView ()
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIButton *changeStyleButton;
@property (nonatomic, strong) UIView *qrcodeImageContainerView;
@property (nonatomic, strong) UIImageView *qrcodeImageView;

@end

@implementation CourtesyCardQRCodeView

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)updateConstraints {
    [super updateConstraints];
    
    [self.qrcodeImageContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(300));
        make.height.equalTo(@(300));
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.qrcodeImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(280));
        make.height.equalTo(@(280));
        make.centerX.equalTo(self.qrcodeImageContainerView.mas_centerX);
        make.centerY.equalTo(self.qrcodeImageContainerView.mas_centerY);
    }];
    
    [self.tipsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(300));
        make.height.equalTo(@(48));
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.qrcodeImageContainerView.mas_top).with.offset(-24);
    }];
}

- (UIView *)qrcodeImageContainerView {
    if (!_qrcodeImageContainerView) {
        UIView *qrcodeImageContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        qrcodeImageContainerView.backgroundColor = [UIColor whiteColor];
        qrcodeImageContainerView.layer.masksToBounds = NO;
        qrcodeImageContainerView.layer.shadowOffset = CGSizeMake(0, 0);
        qrcodeImageContainerView.layer.shadowColor = [UIColor blackColor].CGColor;
        qrcodeImageContainerView.layer.shouldRasterize = YES;
        qrcodeImageContainerView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        qrcodeImageContainerView.layer.shadowOpacity = 0.4;
        qrcodeImageContainerView.layer.shadowRadius = 20.0;
        qrcodeImageContainerView.layer.cornerRadius = 6.0;
        _qrcodeImageContainerView = qrcodeImageContainerView;
    }
    return _qrcodeImageContainerView;
}

- (UIImageView *)qrcodeImageView {
    if (!_qrcodeImageView) {
        UIImageView *qrcodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 280)];
        qrcodeImageView.backgroundColor = [UIColor clearColor];
        _qrcodeImageView = qrcodeImageView;
    }
    return _qrcodeImageView;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 48)];
        tipsLabel.numberOfLines = 2;
        tipsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tipsLabel.font = [UIFont systemFontOfSize:16.0f];
        tipsLabel.textColor = [UIColor whiteColor];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.text = @"面对面分享卡片\n请使用「礼记」扫描二维码";
        _tipsLabel = tipsLabel;
    }
    return _tipsLabel;
}

- (void)setup {
    /* Init of self */
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.qrcodeImageContainerView];
    [self addSubview:self.tipsLabel];
    [self.qrcodeImageContainerView addSubview:self.qrcodeImageView];
}

- (void)setCard_token:(NSString *)card_token {
    _card_token = card_token;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize containerSize = self.qrcodeImageView.bounds.size;
    CGSize imageSize = CGSizeMake(containerSize.width * scale, containerSize.height * scale);
    [self.qrcodeImageView setImage:[ZXingWrapper createCodeWithString:[NSString stringWithFormat:@"courtesy://?action=card&token=%@", card_token] size:imageSize CodeFomart:kBarcodeFormatQRCode]];
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)dealloc {
    CYLog(@"");
}

@end
