//
//  CourtesyFontViewController.m
//  Courtesy
//
//  Created by Zheng on 3/10/16.
//  Copyright © 2016 82Flex. All rights reserved.
//

#import "CourtesyFontTableViewController.h"
#import "CourtesyFontTableViewCell.h"
#import "CourtesyFontManager.h"
#import "FCFileManager.h"

#define kMaxFontSize 22
#define kMinFontSize 14

@interface CourtesyFontTableViewController () <UITableViewDelegate, UITableViewDataSource, CourtesyFontManagerDelegate>
@property (nonatomic, strong) UITableView *fontTableView;
@property (nonatomic, strong) UIView *controlsBg;


@end

@implementation CourtesyFontTableViewController {
    NSUInteger fontCount;
    UIButton *fontSizeUpBtn;
    UIButton *fontSizeDownBtn;
}

- (instancetype)initWithMasterViewController:(UIViewController *)masterViewController {
    if (self = [super init]) {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        CourtesyFontManager *manager = [CourtesyFontManager sharedManager];
        manager.delegate = self;
        fontCount = [manager fontList].count;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGFloat height = 240.f;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // Control SG
    self.controlsBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    _controlsBg.frame = CGRectMake(0, self.view.frame.size.height - height, _controlsBg.frame.size.width, _controlsBg.frame.size.height);
    _controlsBg.center = CGPointMake(_controlsBg.center.x, _controlsBg.center.y + self.view.frame.size.height);
    [UIView animateWithDuration:0.5f animations:^{
        _controlsBg.center = CGPointMake(_controlsBg.center.x, _controlsBg.center.y - self.view.frame.size.height);
    }];
    [self.view addSubview:_controlsBg];
    
    // gray background for the controls
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _controlsBg.frame.size.width, height)];
    [bg setBackgroundColor:[UIColor blackColor]];
    [bg setAlpha:0.65];
    [_controlsBg addSubview:bg];
    
    // Font size
    fontSizeUpBtn = [UIButton new];
    fontSizeUpBtn.frame = CGRectMake(0, 0, 80, 62);
    fontSizeUpBtn.center = CGPointMake(self.controlsBg.frame.size.width / 4, self.controlsBg.frame.size.height / 4);
    fontSizeUpBtn.tintColor = [UIColor whiteColor];
    [fontSizeUpBtn setImage:[[UIImage imageNamed:@"font-size-up"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    fontSizeUpBtn.backgroundColor = [UIColor clearColor];
    [fontSizeUpBtn addTarget:self action:@selector(addFontSize:) forControlEvents:UIControlEventTouchUpInside];
    [_controlsBg addSubview:fontSizeUpBtn];
    
    fontSizeDownBtn = [UIButton new];
    fontSizeDownBtn.frame = CGRectMake(0, 0, 80, 62);
    fontSizeDownBtn.center = CGPointMake(self.controlsBg.frame.size.width / 4, self.controlsBg.frame.size.height / 4 * 3);
    fontSizeDownBtn.tintColor = [UIColor whiteColor];
    [fontSizeDownBtn setImage:[[UIImage imageNamed:@"font-size-down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    fontSizeDownBtn.backgroundColor = [UIColor clearColor];
    [fontSizeDownBtn addTarget:self action:@selector(cutFontSize:) forControlEvents:UIControlEventTouchUpInside];
    [_controlsBg addSubview:fontSizeDownBtn];
    
    // Font select
    UITableView *tableView = [UITableView new];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.frame = CGRectMake((self.controlsBg.frame.size.width / 2), 12, (self.controlsBg.frame.size.width / 2) - 12, self.controlsBg.frame.size.height - 24);
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_controlsBg addSubview:tableView];
    _fontTableView = tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *tapBg = [[UIView alloc] initWithFrame:self.view.bounds];
    tapBg.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel:)];
    [tapBg addGestureRecognizer:g];
    [self.view addSubview:tapBg];
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
            cell.tintColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            if (font.fileSize != 0.0 && !font.downloaded) {
                // cell.imageView.image = [font fontPreview];
                cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", [font fontName], [FCFileManager sizeFormatted:[NSNumber numberWithFloat:[font fileSize]]]];
            } else {
                cell.textLabel.text = [font fontName];
            }
            cell.textLabel.textColor = [UIColor whiteColor];
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
            if (self.delegate && [self.delegate respondsToSelector:@selector(fontViewControllerDidTapDone:withFont:)]) {
                [self done:nil withFont:fontModel.font];
            }
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
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        _controlsBg.center = CGPointMake(_controlsBg.center.x, _controlsBg.center.y + self.view.frame.size.height);
    } completion:^(BOOL finished) {
        if (!finished) return;
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(fontViewControllerDidCancel:)]) {
            [strongSelf.delegate fontViewControllerDidCancel:strongSelf];
        }
    }];
}

- (void)done:(UIButton *)sender withFont:(UIFont *)font {
    if (self.delegate && [self.delegate respondsToSelector:@selector(fontViewControllerDidTapDone:withFont:)]) {
        [self.delegate fontViewControllerDidTapDone:self withFont:font];
    }
}

- (void)addFontSize:(UIButton *)sender {
    if (_fitSize >= kMaxFontSize) {
        sender.enabled = NO;
    } else {
        fontSizeDownBtn.enabled = YES;
    }
    _fitSize += 0.5;
    if (_delegate && [_delegate respondsToSelector:@selector(fontViewController:changeFontSize:)]) {
        [_delegate fontViewController:self changeFontSize:_fitSize];
    }
}

- (void)cutFontSize:(UIButton *)sender {
    if (_fitSize <= kMinFontSize) {
        sender.enabled = NO;
    } else {
        fontSizeUpBtn.enabled = YES;
    }
    _fitSize -= 0.5;
    if (_delegate && [_delegate respondsToSelector:@selector(fontViewController:changeFontSize:)]) {
        [_delegate fontViewController:self changeFontSize:_fitSize];
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
