//
//  CourtesyGalleryDailyCardView.m
//  Courtesy
//
//  Created by Zheng on 4/30/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyGalleryDailyCardView.h"

@interface CourtesyGalleryDailyCardView ()
@property (nonatomic, strong) UIView *vLabelContainerView;
@property (nonatomic, strong) YYLabel *vLabel;
@property (nonatomic, strong) UILabel *hSmallLabel;
@property (nonatomic, strong) UIImageView *rightImageView;
@property (nonatomic, strong) UIView *hLabelContainerView;
@property (nonatomic, strong) YYLabel *hLabel;

@end

@implementation CourtesyGalleryDailyCardView

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

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)setup
{
    CGFloat upHeight = self.frame.size.height * 0.75;
    UIColor *vLabelColor = [UIColor colorWithWhite:.75f alpha:1.f];
    
    UIView *vLabelContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 36, upHeight)];
    vLabelContainerView.backgroundColor = [UIColor colorWithWhite:.4f alpha:.4f];
    self.vLabelContainerView = vLabelContainerView;
    [self addSubview:vLabelContainerView];
    
    YYLabel *vLabel = [[YYLabel alloc] initWithFrame:vLabelContainerView.bounds];
    vLabel.verticalForm = YES;
    vLabel.textAlignment = NSTextAlignmentCenter;
    vLabel.text = @"礼记之谊，记礼之情。";
    vLabel.textColor = vLabelColor;
    vLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightLight];
    self.vLabel = vLabel;
    [vLabelContainerView addSubview:self.vLabel];
    
    UILabel *hSmallLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, vLabel.width, 16)];
    hSmallLabel.textAlignment = NSTextAlignmentCenter;
    hSmallLabel.text = @"礼记";
    hSmallLabel.textColor = vLabelColor;
    hSmallLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightLight];
    self.hSmallLabel = hSmallLabel;
    [vLabelContainerView addSubview:hSmallLabel];
    
    UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 60, upHeight)];
    rightImageView.backgroundColor = [UIColor clearColor];
    rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    rightImageView.alpha = .85f;
    rightImageView.clipsToBounds = YES;
    self.rightImageView = rightImageView;
    [self addSubview:rightImageView];
    
    YYLabel *hLabel = [[YYLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 16, self.frame.size.height - upHeight)];
    hLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    hLabel.textAlignment = NSTextAlignmentCenter;
    hLabel.textColor = vLabelColor;
    hLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightLight];
    hLabel.lineBreakMode = NSLineBreakByWordWrapping;
    hLabel.numberOfLines = 0;
    YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
    modifier.fixedLineHeight = 22.0f;
    hLabel.linePositionModifier = modifier;
    self.hLabel = hLabel;
    [self addSubview:hLabel];
}

- (void)updateConstraints {
    [super updateConstraints];
    CGFloat upHeight = self.frame.size.height * 0.75;
    CGFloat standardMargin = 8.0f;
    
    [_vLabelContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@36);
        make.height.equalTo(@(upHeight));
        make.top.equalTo(self.mas_top).with.offset(standardMargin);
        make.left.equalTo(self.mas_left).with.offset(standardMargin);
    }];
    
    [_vLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_vLabelContainerView.mas_width);
        make.centerX.equalTo(_vLabelContainerView.mas_centerX);
        make.centerY.equalTo(_vLabelContainerView.mas_centerY);
    }];
    
    [_hSmallLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(_vLabelContainerView.mas_width);
        make.centerX.equalTo(_vLabelContainerView.mas_centerX);
        make.bottom.equalTo(_vLabelContainerView.mas_bottom).with.offset(-standardMargin);
    }];
    
    [_rightImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(upHeight));
        make.top.equalTo(self.mas_top).with.offset(standardMargin);
        make.left.equalTo(_vLabelContainerView.mas_right).with.offset(standardMargin);
        make.right.equalTo(self.mas_right).with.offset(-standardMargin);
    }];
    
    [_hLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(standardMargin);
        make.right.equalTo(self.mas_right).with.offset(-standardMargin);
        make.bottom.equalTo(self.mas_bottom).with.offset(-standardMargin);
        make.height.equalTo(@(self.frame.size.height - upHeight - standardMargin * 3));
    }];
}

- (NSString *)digitUppercaseWithDigit:(NSInteger)digit needsScale:(BOOL)scale {
    NSMutableString *digitStr = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%ld", digit]];
    NSArray *MyBase = @[@"〇", @"一", @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九"];
    
    NSMutableString *M = [[NSMutableString alloc] init];
    for (NSUInteger i = digitStr.length; i > 0; i--) {
        NSInteger MyData = [[digitStr substringWithRange:NSMakeRange(digitStr.length - i, 1)] integerValue];
        if (scale && MyData == 1 && i == 2) {
            [M appendString:@"十"];
        } else {
            [M appendString:MyBase[MyData]];
        }
        if (scale && MyData > 1 && i == 2) {
            [M appendString:@"十"];
        }
    }
    return M;
}

- (NSString *)dateString {
    NSDate *date = self.targetDate;
    
    NSInteger year = [date year];
    NSInteger month = [date month];
    NSInteger day = [date day];
    
    NSString *yearStr = [self digitUppercaseWithDigit:year needsScale:NO];
    NSString *monthStr = [self digitUppercaseWithDigit:month needsScale:YES];
    NSString *dayStr = [self digitUppercaseWithDigit:day needsScale:YES];
    
    return [NSString stringWithFormat:@"%@年%@月%@日", yearStr, monthStr, dayStr];
}

- (void)setTargetDate:(NSDate *)targetDate {
    _targetDate = targetDate;
    _vLabel.text = [self dateString];
}

- (void)setDailyCard:(CourtesyGalleryDailyCardModel *)dailyCard {
    _dailyCard = dailyCard;
    if (dailyCard.image)
    {
        _rightImageView.imageURL = dailyCard.image.remoteUrl;
    }
    if (dailyCard.string) {
        _hLabel.text = dailyCard.string;
    }
}

@end
