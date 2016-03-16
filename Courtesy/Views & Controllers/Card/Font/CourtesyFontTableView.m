//
//  CourtesyFontViewController.m
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyFontTableView.h"
#import "CourtesyFontTableViewCell.h"
#import "CourtesyFontManager.h"
#import "FCFileManager.h"

#define kMaxFontSize 22
#define kMinFontSize 14

@interface CourtesyFontTableView () <UITableViewDelegate, UITableViewDataSource, CourtesyFontManagerDelegate>
@property (nonatomic, strong) UITableView *fontTableView;


@end

@implementation CourtesyFontTableView {
    NSUInteger fontCount;
    UIButton *fontSizeUpBtn;
    UIButton *fontSizeDownBtn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CourtesyFontManager *manager = [CourtesyFontManager sharedManager];
        manager.delegate = self;
        fontCount = [manager fontList].count;
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        self.layer.borderWidth = 0.5;
        
        UIView *sizeAdjustView = [UIView new];
        sizeAdjustView.frame = CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height / 2);
        sizeAdjustView.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        sizeAdjustView.layer.borderWidth = 0.5;
        [self addSubview:sizeAdjustView];
        
        UIView *styleAdjustView = [UIView new];
        styleAdjustView.frame = CGRectMake(0, self.frame.size.height / 2 - 0.5, self.frame.size.width / 2, self.frame.size.height / 2);
        styleAdjustView.layer.borderColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0].CGColor;
        styleAdjustView.layer.borderWidth = 0.5;
        [self addSubview:styleAdjustView];
        
        // Font size
        fontSizeUpBtn = [UIButton new];
        fontSizeUpBtn.frame = CGRectMake(0, 0, 40, 31);
        fontSizeUpBtn.center = CGPointMake(sizeAdjustView.frame.size.width / 4, sizeAdjustView.frame.size.height / 2);
        fontSizeUpBtn.tintColor = [UIColor darkGrayColor];
        [fontSizeUpBtn setImage:[[UIImage imageNamed:@"font-size-up"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        fontSizeUpBtn.backgroundColor = [UIColor clearColor];
        [fontSizeUpBtn addTarget:self action:@selector(addFontSize:) forControlEvents:UIControlEventTouchUpInside];
        [sizeAdjustView addSubview:fontSizeUpBtn];
        
        fontSizeDownBtn = [UIButton new];
        fontSizeDownBtn.frame = CGRectMake(0, 0, 40, 31);
        fontSizeDownBtn.center = CGPointMake(sizeAdjustView.frame.size.width / 4 * 3, sizeAdjustView.frame.size.height / 2);
        fontSizeDownBtn.tintColor = [UIColor darkGrayColor];
        [fontSizeDownBtn setImage:[[UIImage imageNamed:@"font-size-down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        fontSizeDownBtn.backgroundColor = [UIColor clearColor];
        [fontSizeDownBtn addTarget:self action:@selector(cutFontSize:) forControlEvents:UIControlEventTouchUpInside];
        [sizeAdjustView addSubview:fontSizeDownBtn];
        
        // Font select
        UITableView *tableView = [UITableView new];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.frame = CGRectMake((self.frame.size.width / 2) + 6, 24, (self.frame.size.width / 2) - 24, self.frame.size.height - 48);
        tableView.backgroundColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:tableView];
        _fontTableView = tableView;
    }
    return self;
}

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
            cell.tintColor = [UIColor darkGrayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            if (font.fileSize != 0.0 && !font.downloaded) {
                cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [font fontName], [FCFileManager sizeFormatted:[NSNumber numberWithFloat:[font fileSize]]]];
            } else {
                cell.textLabel.text = [font fontName];
                cell.textLabel.font = [font font];
            }
            cell.textLabel.textColor = [UIColor darkGrayColor];
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
        if (fontModel.downloaded) {
            CYLog(@"%@ has downloaded.", fontModel.fontName);
            self.card.card_data.fontType = fontModel.type;
            [self done:nil withFont:fontModel.font];
        } else {
            if (fontModel.downloading) {
                CYLog(@"Pause downloading: %@.", fontModel.fontName);
                [manager pauseDownloadFont:fontModel];
            } else {
                CYLog(@"Start downloading: %@.", fontModel.fontName);
                [manager downloadFont:fontModel];
            }
        }
    }
}

#pragma mark - actions

- (void)cancel:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fontViewDidCancel:)]) {
        [self.delegate fontViewDidCancel:self];
    }
}

- (void)done:(UIButton *)sender withFont:(UIFont *)font {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fontViewDidTapDone:withFont:)]) {
        [self.delegate fontViewDidTapDone:self withFont:font];
    }
}

- (void)addFontSize:(UIButton *)sender {
    if (_fitSize >= kMaxFontSize) {
        sender.enabled = NO;
    } else {
        fontSizeDownBtn.enabled = YES;
    }
    _fitSize += 0.5;
    if (_delegate && [_delegate respondsToSelector:@selector(fontView:changeFontSize:)]) {
        self.card.card_data.fontSize = _fitSize;
        [_delegate fontView:self changeFontSize:_fitSize];
    }
}

- (void)cutFontSize:(UIButton *)sender {
    if (_fitSize <= kMinFontSize) {
        sender.enabled = NO;
    } else {
        fontSizeUpBtn.enabled = YES;
    }
    _fitSize -= 0.5;
    if (_delegate && [_delegate respondsToSelector:@selector(fontView:changeFontSize:)]) {
        self.card.card_data.fontSize = _fitSize;
        [_delegate fontView:self changeFontSize:_fitSize];
    }
}

#pragma mark - CourtesyFontManagerDelegate

- (void)fontManager:(CourtesyFontManager *)fontManager
   shouldReloadData:(BOOL)reload {
    if (reload && _fontTableView) [_fontTableView reloadData];
}

- (void)dealloc {
    CYLog(@"");
}

@end
