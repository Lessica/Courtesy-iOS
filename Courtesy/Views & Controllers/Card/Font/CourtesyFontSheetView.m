//
//  CourtesyFontViewController.m
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "FCFileManager.h"
#import "CourtesyFontSheetView.h"
#import "CourtesyFontTableViewCell.h"
#import "CourtesyFontModel.h"

#define kMaxFontSize 22
#define kMinFontSize 14

@interface CourtesyFontSheetView () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (nonatomic, strong) UITableView *fontTableView;


@end

@implementation CourtesyFontSheetView {
    NSUInteger fontCount;
    UIButton *fontSizeUpBtn;
    UIButton *fontSizeDownBtn;
    UIPageControl *pageControl;
}

- (CourtesyCardDataModel *)cdata {
    return self.delegate.card.local_template;
}

- (CourtesyCardStyleModel *)style {
    return self.delegate.card.local_template.style;
}

- (instancetype)initWithFrame:(CGRect)frame
                  andDelegate:(CourtesyCardComposeViewController<CourtesyFontSheetViewDelegate> *)viewController {
    if (self = [super initWithFrame:frame]) {
        self.delegate = viewController;
        
        CourtesyFontManager *manager = [CourtesyFontManager sharedManager];
        fontCount = [manager fontList].count;
        
        self.backgroundColor = self.style.toolbarColor;
        self.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        self.layer.borderWidth = 0.5;
        
        UIView *sizeAdjustView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 4, self.frame.size.height)];
        sizeAdjustView.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        sizeAdjustView.layer.borderWidth = 0.5;
        [self addSubview:sizeAdjustView];
        
        UIView *sizeAdjustUpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sizeAdjustView.frame.size.width, sizeAdjustView.frame.size.height / 2)];
        sizeAdjustUpView.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        sizeAdjustUpView.layer.borderWidth = 0.5;
        [sizeAdjustUpView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(addFontSize:)]];
        [sizeAdjustView addSubview:sizeAdjustUpView];
        
        UIView *sizeAdjustDownView = [[UIView alloc] initWithFrame:CGRectMake(0, sizeAdjustView.frame.size.height / 2 - 0.5, sizeAdjustView.frame.size.width, sizeAdjustView.frame.size.height / 2)];
        sizeAdjustDownView.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        sizeAdjustDownView.layer.borderWidth = 0.5;
        [sizeAdjustDownView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(cutFontSize:)]];
        [sizeAdjustView addSubview:sizeAdjustDownView];
        
//        UIView *styleAdjustView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height / 2 - 0.5, self.frame.size.width / 2, self.frame.size.height / 2)];
//        styleAdjustView.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
//        styleAdjustView.layer.borderWidth = 0.5;
//        [self addSubview:styleAdjustView];
        
        // Font size
        fontSizeUpBtn = [UIButton new];
        fontSizeUpBtn.frame = CGRectMake(0, 0, 40, 31);
        fontSizeUpBtn.center = CGPointMake(sizeAdjustUpView.frame.size.width / 2, sizeAdjustUpView.frame.size.height / 2);
        fontSizeUpBtn.tintColor = self.style.toolbarTintColor;
        [fontSizeUpBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [fontSizeUpBtn setImage:[[UIImage imageNamed:@"font-size-up"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        fontSizeUpBtn.backgroundColor = [UIColor clearColor];
        [fontSizeUpBtn addTarget:self action:@selector(addFontSize:) forControlEvents:UIControlEventTouchUpInside];
        [sizeAdjustUpView addSubview:fontSizeUpBtn];
        
        fontSizeDownBtn = [UIButton new];
        fontSizeDownBtn.frame = CGRectMake(0, 0, 40, 31);
        fontSizeDownBtn.center = CGPointMake(sizeAdjustDownView.frame.size.width / 2, sizeAdjustDownView.frame.size.height / 2);
        fontSizeDownBtn.tintColor = self.style.toolbarTintColor;
        [fontSizeDownBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [fontSizeDownBtn setImage:[[UIImage imageNamed:@"font-size-down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        fontSizeDownBtn.backgroundColor = [UIColor clearColor];
        [fontSizeDownBtn addTarget:self action:@selector(cutFontSize:) forControlEvents:UIControlEventTouchUpInside];
        [sizeAdjustDownView addSubview:fontSizeDownBtn];
        
        // Font select
        UITableView *tableView = [UITableView new];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.frame = CGRectMake((self.frame.size.width / 4) + 6, 24, (self.frame.size.width * 0.75) - 24, self.frame.size.height - 48);
        tableView.backgroundColor = [UIColor clearColor];
        tableView.showsVerticalScrollIndicator = NO;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:tableView];
        _fontTableView = tableView;
        
        /*
        // Style select
        UIScrollView *styleScrollView = [UIScrollView new];
        styleScrollView.frame = styleAdjustView.bounds;
        styleScrollView.delegate = self;
        styleScrollView.bounces = YES;
        styleScrollView.pagingEnabled = YES;
        styleScrollView.showsHorizontalScrollIndicator = NO;
        styleScrollView.showsVerticalScrollIndicator = NO;
        styleScrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
        styleScrollView.contentSize = CGSizeMake(styleScrollView.frame.size.width * 6, styleScrollView.frame.size.height);
        [styleAdjustView addSubview:styleScrollView];
        
        UIImageView *leftArrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 24)];
        leftArrow.center = CGPointMake(15, styleAdjustView.frame.size.height / 2);
        leftArrow.tintColor = self.style.toolbarTintColor;
        leftArrow.image = [[UIImage imageNamed:@"59-arrow-left"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [styleAdjustView addSubview:leftArrow];
        
        UIImageView *rightArrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 24)];
        rightArrow.center = CGPointMake(styleAdjustView.frame.size.width - 15, styleAdjustView.frame.size.height / 2);
        rightArrow.tintColor = self.style.toolbarTintColor;
        rightArrow.image = [[UIImage imageNamed:@"60-arrow-right"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [styleAdjustView addSubview:rightArrow];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, styleAdjustView.frame.size.width, 6)];
        pageControl.center = CGPointMake(styleAdjustView.frame.size.width / 2, styleAdjustView.frame.size.height - 8);
        pageControl.currentPageIndicatorTintColor = self.style.toolbarHighlightColor;
        pageControl.pageIndicatorTintColor = self.style.toolbarTintColor;
        pageControl.currentPage = 0;
        pageControl.numberOfPages = 6;
        [styleAdjustView addSubview:pageControl];
         */
    }
    return self;
}

#pragma mark - UIScrollViewDelegate
/*
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sView {
    NSInteger index = fabs(sView.contentOffset.x) / sView.frame.size.width;
    [pageControl setCurrentPage:index];
}
*/
#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return fontCount;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row < fontCount) {
            CourtesyFontModel *font = [[[CourtesyFontManager sharedManager] fontList] objectAtIndex:indexPath.row];
            CourtesyFontTableViewCell *cell = [CourtesyFontTableViewCell new];
            cell.backgroundColor = [UIColor clearColor];
            cell.tintColor = self.style.toolbarTintColor;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            if (font.fileSize != 0.0 && font.status != CourtesyFontDownloadingTaskStatusDone) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [font fontName], [FCFileManager sizeFormatted:[NSNumber numberWithFloat:[font fileSize]]]];
            } else {
                cell.textLabel.text = [font fontName];
                cell.textLabel.font = [font font];
            }
            cell.textLabel.textColor = self.style.toolbarTintColor;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.fontModel = font;
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        CourtesyFontManager *manager = [CourtesyFontManager sharedManager];
        CourtesyFontModel *fontModel = [[manager fontList] objectAtIndex:indexPath.row];
        if (fontModel.status == CourtesyFontDownloadingTaskStatusDone) {
            CYLog(@"%@ has downloaded.", fontModel.fontName);
            self.cdata.fontType = fontModel.type;
            [sharedSettings setPreferredFontType:fontModel.type];
            [self doneWithFont:fontModel.font];
        } else if (fontModel.status == CourtesyFontDownloadingTaskStatusDownload) {
            CYLog(@"Pause downloading: %@.", fontModel.fontName);
            [manager pauseDownloadFont:fontModel];
        } else if (fontModel.status == CourtesyFontDownloadingTaskStatusNone ||
                   fontModel.status == CourtesyFontDownloadingTaskStatusSuspend) {
            CYLog(@"Start downloading: %@.", fontModel.fontName);
            [manager downloadFont:fontModel];
        }
    }
}

#pragma mark - actions

- (void)cancel:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fontSheetViewDidCancel:)]) {
        [self.delegate fontSheetViewDidCancel:self];
    }
}

- (void)doneWithFont:(UIFont *)font {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fontSheetViewDidTapDone:withFont:)]) {
        [self.delegate fontSheetViewDidTapDone:self withFont:font];
    }
}

- (void)addFontSize:(UIButton *)sender {
    if (self.cdata.fontSize >= kMaxFontSize) {
        sender.enabled = NO;
    } else {
        fontSizeDownBtn.enabled = YES;
    }
    self.cdata.fontSize += 0.5;
    [sharedSettings setPreferredFontSize:self.cdata.fontSize];
    if (_delegate && [_delegate respondsToSelector:@selector(fontSheetView:changeFontSize:)]) {
        [_delegate fontSheetView:self changeFontSize:self.cdata.fontSize];
    }
}

- (void)cutFontSize:(UIButton *)sender {
    if (self.cdata.fontSize <= kMinFontSize) {
        sender.enabled = NO;
    } else {
        fontSizeUpBtn.enabled = YES;
    }
    self.cdata.fontSize -= 0.5;
    self.cdata.fontSize = self.cdata.fontSize;
    [sharedSettings setPreferredFontSize:self.cdata.fontSize];
    if (_delegate && [_delegate respondsToSelector:@selector(fontSheetView:changeFontSize:)]) {
        [_delegate fontSheetView:self changeFontSize:self.cdata.fontSize];
    }
}

- (void)dealloc {
    CYLog(@"");
}

@end
