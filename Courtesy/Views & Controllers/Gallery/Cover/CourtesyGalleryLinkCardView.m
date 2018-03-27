//
//  CourtesyGalleryLinkCardView.m
//  Courtesy
//
//  Created by Zheng on 5/13/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyGalleryLinkCardView.h"
//#import "LazyFadeInView.h"

@interface CourtesyGalleryLinkCardView ()
@property (nonatomic, strong) UIView *bodyContainerView;
@property (nonatomic, strong) UIView *topLabelContainerView;
@property (nonatomic, strong) UIView *middleContainerView;
@property (nonatomic, strong) UIView *bottomLabelContainerView;
@property (nonatomic, strong) UILabel *footerLabel;

@property (nonatomic, strong) YYLabel *topLabel;
//@property (nonatomic, strong) LazyFadeInView *bottomLabel;

@property (nonatomic, strong) NSDictionary *hLabelAttributes;
@property (nonatomic, strong) NSDictionary *vLabelAttributes;

@end

@implementation CourtesyGalleryLinkCardView

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
    CGFloat standardMargin = 8.f;
    CGFloat secondMargin = 12.f;
    UIColor *borderColor = [UIColor colorWithWhite:.4f alpha:.4f];
    UIColor *vLabelColor = [UIColor colorWithWhite:.75f alpha:1.f];
    
    /* Init of container view */
    UIView *bodyContainerView = [[UIView alloc] initWithFrame:CGRectMake(standardMargin, standardMargin, self.bounds.size.width - standardMargin * 2, self.bounds.size.height - standardMargin * 2)];
    bodyContainerView.layer.borderColor = borderColor.CGColor;
    bodyContainerView.layer.borderWidth = 2.f;
    self.bodyContainerView = bodyContainerView;
    [self addSubview:bodyContainerView];
    
    /* Init values */
    CGFloat containerHeight = bodyContainerView.size.height;
    CGFloat areaHeight = containerHeight / 6;
    CGFloat areaWidth = bodyContainerView.size.width - secondMargin * 2;
    CGFloat footerHeight = secondMargin + 16;
    
    /* Init of top container view */
    UIView *topLabelContainerView = [[UIView alloc] initWithFrame:CGRectMake(secondMargin, 0, areaWidth, areaHeight)];
    self.topLabelContainerView = topLabelContainerView;
    [bodyContainerView addSubview:topLabelContainerView];
    
    /* Init of top paragraph style */
    UIFont *vFont = [UIFont systemFontOfSize:20.0 weight:UIFontWeightLight];
    NSMutableParagraphStyle *vParagraph = [[NSMutableParagraphStyle alloc] init];
    vParagraph.alignment = NSTextAlignmentNatural;
    vParagraph.minimumLineHeight = 20;
    vParagraph.maximumLineHeight = 24;
    vParagraph.lineSpacing = 8;
    vParagraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *vLabelAttributes = @{
                                       NSFontAttributeName: vFont,
                                       NSParagraphStyleAttributeName: vParagraph,
                                       NSForegroundColorAttributeName: [UIColor whiteColor]
                                       };
    self.vLabelAttributes = vLabelAttributes;
    
    /* Init of top label */
    YYLabel *topLabel = [[YYLabel alloc] initWithFrame:topLabelContainerView.bounds];
    topLabel.textAlignment = NSTextAlignmentNatural;
    topLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    topLabel.textColor = vLabelColor;
    topLabel.font = vFont;
    self.topLabel = topLabel;
    [topLabelContainerView addSubview:topLabel];
    
    /* Init of middle container view */
    UIView *middleContainerView = [[UIView alloc] initWithFrame:CGRectMake(secondMargin, areaHeight, areaWidth, areaHeight * 3)];
    self.middleContainerView = middleContainerView;
    [bodyContainerView addSubview:middleContainerView];
    
    /* Init of middle image view */
    UIImageView *middleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, middleContainerView.width, middleContainerView.height)];
    middleImageView.backgroundColor = [UIColor clearColor];
    middleImageView.contentMode = UIViewContentModeScaleAspectFill;
    middleImageView.alpha = .85f;
    middleImageView.clipsToBounds = YES;
    self.middleImageView = middleImageView;
    [middleContainerView addSubview:middleImageView];
    
    /* Init of bottom label container view */
    UIView *bottomLabelContainerView = [[UIView alloc] initWithFrame:CGRectMake(secondMargin, areaHeight * 4, areaWidth, areaHeight * 2 - footerHeight)];
    self.bottomLabelContainerView = bottomLabelContainerView;
    [bodyContainerView addSubview:bottomLabelContainerView];
    
    /* Init of bottom paragraph style */
    UIFont *hFont = [UIFont systemFontOfSize:16.0 weight:UIFontWeightUltraLight];
    NSMutableParagraphStyle *hParagraph = [[NSMutableParagraphStyle alloc] init];
    hParagraph.alignment = NSTextAlignmentNatural;
    hParagraph.minimumLineHeight = 20;
    hParagraph.maximumLineHeight = 24;
    hParagraph.lineSpacing = 8;
    hParagraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *hLabelAttributes = @{
                                       NSFontAttributeName: hFont,
                                       NSParagraphStyleAttributeName: hParagraph,
                                       NSForegroundColorAttributeName: [UIColor whiteColor]
                                       };
    self.hLabelAttributes = hLabelAttributes;
    
    /* Init of bottom label */
//    LazyFadeInView *bottomLabel = [[LazyFadeInView alloc] initWithFrame:bottomLabelContainerView.bounds];
//    bottomLabel.textColor = vLabelColor;
//    bottomLabel.textFont = [UIFont systemFontOfSize:16.0 weight:UIFontWeightUltraLight];
//    bottomLabel.attributes = hLabelAttributes;
//    self.bottomLabel = bottomLabel;
//    [bottomLabelContainerView addSubview:bottomLabel];
    
    /* Init of footer label */
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(secondMargin, containerHeight - footerHeight, areaWidth, footerHeight)];
    footerLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightUltraLight];
    footerLabel.textAlignment = NSTextAlignmentRight;
    footerLabel.textColor = vLabelColor;
    footerLabel.text = @"来自 礼记 Courtesy";
    self.footerLabel = footerLabel;
    [bodyContainerView addSubview:footerLabel];
}

- (void)updateConstraints {
    [super updateConstraints];
    
    CGFloat firstMargin = 8.f;
    CGFloat secondMargin = 12.f;
    CGFloat areaHeight = (_bodyContainerView.size.height) / 6;
    CGFloat footerHeight = secondMargin + 16.f;
    
    [_bodyContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(firstMargin, firstMargin, firstMargin, firstMargin));
    }];
    
    [_topLabelContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bodyContainerView.mas_top).with.offset(0);
        make.left.equalTo(_bodyContainerView.mas_left).with.offset(secondMargin);
        make.right.equalTo(_bodyContainerView.mas_right).with.offset(-secondMargin);
        make.height.equalTo(@(areaHeight * 1));
    }];
    
    [_topLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_topLabelContainerView);
    }];
    
    [_middleContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_bodyContainerView.mas_top).with.offset(areaHeight * 1);
        make.left.equalTo(_bodyContainerView.mas_left).with.offset(secondMargin);
        make.right.equalTo(_bodyContainerView.mas_right).with.offset(-secondMargin);
        make.height.equalTo(@(areaHeight * 3));
    }];
    
    [_middleImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_middleContainerView);
    }];
    
    [_bottomLabelContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_bodyContainerView.mas_bottom).with.offset(-footerHeight);
        make.left.equalTo(_bodyContainerView.mas_left).with.offset(secondMargin);
        make.right.equalTo(_bodyContainerView.mas_right).with.offset(-secondMargin);
        make.height.equalTo(@(areaHeight * 2 - footerHeight));
    }];
    
    [_footerLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_bodyContainerView.mas_bottom);
        make.left.equalTo(_bodyContainerView.mas_left).with.offset(secondMargin);
        make.right.equalTo(_bodyContainerView.mas_right).with.offset(-secondMargin);
        make.height.equalTo(@(footerHeight));
    }];
}

- (void)setDailyCard:(CourtesyGalleryDailyCardModel *)dailyCard {
    _dailyCard = dailyCard;
    if (dailyCard == nil) {
        _middleImageView.imageURL = nil;
        return;
    }
    if (dailyCard.image) {
        [_middleImageView setImageWithURL:dailyCard.image.remoteUrl
                              placeholder:nil
                                  options:YYWebImageOptionShowNetworkActivity | YYWebImageOptionProgressive | YYWebImageOptionAllowBackgroundTask | YYWebImageOptionSetImageWithFadeAnimation
                               completion:nil];
    }
    if (dailyCard.type) {
        [self setTopText:dailyCard.type];
    }
    if (dailyCard.string) {
//        [self setBottomText:dailyCard.string];
    }
}

- (void)setTopText:(NSString *)topString {
    _topLabel.text = topString;
}

//- (void)setBottomText:(NSString *)bottomString {
//    if (bottomString.length == 0) {
//        _bottomLabel.hidden = YES;
//    } else {
//        _bottomLabel.hidden = NO;
//        CGSize bottomTextSize = [bottomString boundingRectWithSize:CGSizeMake(_bottomLabelContainerView.bounds.size.width, CGFLOAT_MAX)
//                                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                                        attributes:_hLabelAttributes
//                                                           context:nil].size;
//        _bottomLabel.frame = CGRectMake((_bottomLabelContainerView.size.width - bottomTextSize.width) / 2, (_bottomLabelContainerView.size.height - bottomTextSize.height) / 2, bottomTextSize.width, bottomTextSize.height);
//        _bottomLabel.text = bottomString;
//    }
//}

//- (void)setErrorMessage:(NSString *)errorMessage {
//    if (errorMessage == nil) {
//        errorMessage = @"无可用卡片数据";
//    }
//    [self setTopText:@""];
//    [self setBottomText:[errorMessage stringByAppendingString:@"\n轻按以重新拉取"]];
//}

- (void)dealloc {
    CYLog(@"");
}

@end
