//
//  CourtesyGalleryDailyCardView.m
//  Courtesy
//
//  Created by Zheng on 4/30/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyGalleryDailyCardView.h"
//#import "LazyFadeInView.h"

@interface CourtesyGalleryDailyCardView ()
@property (nonatomic, strong) UIView *vLabelContainerView;
@property (nonatomic, strong) YYLabel *vLabel;
@property (nonatomic, strong) UILabel *hSmallLabel;
@property (nonatomic, strong) UIView *hLabelContainerView;
//@property (nonatomic, strong) LazyFadeInView *hLabel;
@property (nonatomic, strong) NSDictionary *hLabelAttributes;

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
    vLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightUltraLight];
    self.vLabel = vLabel;
    [vLabelContainerView addSubview:self.vLabel];
    
    UILabel *hSmallLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, vLabel.width, 16)];
    hSmallLabel.textAlignment = NSTextAlignmentCenter;
    hSmallLabel.text = @"礼记";
    hSmallLabel.textColor = vLabelColor;
    hSmallLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightUltraLight];
    self.hSmallLabel = hSmallLabel;
    [vLabelContainerView addSubview:hSmallLabel];
    
    UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 60, upHeight)];
    rightImageView.backgroundColor = [UIColor clearColor];
    rightImageView.contentMode = UIViewContentModeScaleAspectFill;
    rightImageView.alpha = .85f;
    rightImageView.clipsToBounds = YES;
    self.rightImageView = rightImageView;
    [self addSubview:rightImageView];
    
    UIView *hLabelContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - 16, self.frame.size.height - upHeight)];
    self.hLabelContainerView = hLabelContainerView;
    [self addSubview:hLabelContainerView];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    paragraph.minimumLineHeight = 20;
    paragraph.maximumLineHeight = 24;
    paragraph.lineSpacing = 8;
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *hLabelAttributes = @{
                                       NSFontAttributeName: [UIFont systemFontOfSize:16.0 weight:UIFontWeightUltraLight],
                                       NSParagraphStyleAttributeName: paragraph,
                                       NSForegroundColorAttributeName: [UIColor whiteColor]
                                       };
    self.hLabelAttributes = hLabelAttributes;
    
//    LazyFadeInView *hLabel = [[LazyFadeInView alloc] initWithFrame:hLabelContainerView.bounds];
//    hLabel.textColor = vLabelColor;
//    hLabel.textFont = [UIFont systemFontOfSize:16.0 weight:UIFontWeightUltraLight];
//    hLabel.attributes = hLabelAttributes;
//    self.hLabel = hLabel;
//    [hLabelContainerView addSubview:hLabel];
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
    
    [_hLabelContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).with.offset(standardMargin);
        make.right.equalTo(self.mas_right).with.offset(-standardMargin);
        make.bottom.equalTo(self.mas_bottom).with.offset(-standardMargin);
        make.height.equalTo(@(self.frame.size.height - upHeight - standardMargin * 3));
    }];
}

- (NSString *)digitUppercaseWithDigit:(NSInteger)digit needsScale:(BOOL)scale {
    NSMutableString *digitStr = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)digit]];
    NSArray *MyBase = @[@"〇", @"一", @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九"];
    
    NSMutableString *M = [[NSMutableString alloc] init];
    for (NSUInteger i = digitStr.length; i > 0; i--) {
        NSInteger MyData = [[digitStr substringWithRange:NSMakeRange(digitStr.length - i, 1)] integerValue];
        if (scale) {
            if (MyData == 1 && i == 2) {
                [M appendString:@"十"];
            } else if (MyData != 0) {
                [M appendString:MyBase[MyData]];
            }
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
    if (dailyCard == nil) {
        _rightImageView.imageURL = nil;
        return;
    }
    if (dailyCard.image)
    {
        [_rightImageView setImageWithURL:dailyCard.image.remoteUrl
                             placeholder:nil
                                 options:YYWebImageOptionShowNetworkActivity | YYWebImageOptionProgressive | YYWebImageOptionAllowBackgroundTask | YYWebImageOptionSetImageWithFadeAnimation
                              completion:nil];
    }
    if (dailyCard.string) {
//        [self setLabelText:dailyCard.string];
    }
}

//- (void)setLabelText:(NSString *)text {
//    if (text.length == 0) {
//        _hLabel.hidden = YES;
//    } else {
//        _hLabel.hidden = NO;
//        CGSize textSize = [text boundingRectWithSize:CGSizeMake(_hLabelContainerView.bounds.size.width, CGFLOAT_MAX)
//                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                          attributes:_hLabelAttributes
//                                             context:nil].size;
//        textSize = CGSizeMake(textSize.width + 16.f, textSize.height);
//        _hLabel.frame = CGRectMake((_hLabelContainerView.size.width - textSize.width) / 2, (_hLabelContainerView.size.height - textSize.height) / 2, textSize.width, textSize.height);
//        _hLabel.text = text;
//    }
//}

//- (void)setErrorMessage:(NSString *)errorMessage {
//    if (errorMessage == nil) {
//        errorMessage = @"无可用卡片数据";
//    }
//    [self setLabelText:[errorMessage stringByAppendingString:@"\n轻按以重新拉取"]];
//}

- (void)dealloc {
    CYLog(@"");
}

@end
