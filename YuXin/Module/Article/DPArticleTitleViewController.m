//
//  DPArticleTitleViewController.m
//  YuXin
//
//  Created by Dai Pei on 16/7/15.
//  Copyright © 2016年 Dai Pei. All rights reserved.
//

#import "DPArticleTitleViewController.h"
#import "DPArticleTitleCell.h"
#import "MJRefresh.h"
#import "DPArticleDetailViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "WSProgressHUD+DPExtension.h"
#import "DPPostArticleViewController.h"
#import "DPUserInfoViewController.h"
#import "DPTintView.h"
#import "YuXinSDK.h"

@interface DPArticleTitleViewController() <UITableViewDelegate, UITableViewDataSource, DPArticleTitleCellDelegate, DPPostArticleViewControllerDelegate, DPArticleDetailViewControllerDelegate, DPTintViewDelegate>

@property (nonatomic, strong) NSString *boardName;
@property (nonatomic, strong) NSMutableArray *titleArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) WSProgressHUD *hud;
@property (nonatomic, assign) NSUInteger articleStartNum;
@property (nonatomic, strong) DPTintView *tintView;

@end

@implementation DPArticleTitleViewController

#pragma mark - Init

- (instancetype)initWithBoardName:(NSString *)boardName {
    self = [super init];
    if (self) {
        self.boardName = boardName;
        self.title = boardName;
        self.titleArray = [NSMutableArray array];
        self.articleStartNum = 0;
    }
    return self;
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self initData];
    [self ConfigNavigationItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - ConfigViews

- (void)configUI {
    self.view.backgroundColor = DPBackgroundColor;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.hud];
    [self.view addSubview:self.tintView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.tintView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)ConfigNavigationItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"image_board_post"] style:UIBarButtonItemStylePlain target:self action:@selector(postButtonClicked)];
}

#pragma mark - Privite Method

- (void)refreshTitle {
    __weak typeof(self) weakSelf = self;
    [[YuXinSDK sharedInstance] fetchArticleTitleListWithBoard:self.boardName start:@(0) completion:^(NSString *error, NSArray *responseModels) {
        if (!error) {
            weakSelf.articleStartNum = [responseModels count];
            weakSelf.titleArray = [NSMutableArray arrayWithArray:responseModels];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        }
    }];
}

#pragma mark - Action Method

- (void)postButtonClicked {
    DPPostArticleViewController *viewController = [[DPPostArticleViewController alloc] initWithBoardName:self.boardName];
    viewController.delegate = self;
    viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)headerRefresh {
    __weak typeof(self) weakSelf = self;
    [[YuXinSDK sharedInstance] fetchArticleTitleListWithBoard:self.boardName start:@(0) completion:^(NSString *error, NSArray *responseModels) {
        if (!error) {
            weakSelf.articleStartNum = [responseModels count];
            weakSelf.titleArray = [NSMutableArray arrayWithArray:responseModels];
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [WSProgressHUD safeShowString:error];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
        });
    }];
}

- (void)footerRefresh {
    __weak typeof(self) weakSelf = self;
    [[YuXinSDK sharedInstance] fetchArticleTitleListWithBoard:self.boardName start:@(self.articleStartNum) completion:^(NSString *error, NSArray *responseModels) {
        if (!error) {
            weakSelf.articleStartNum += [responseModels count];
            [weakSelf.titleArray addObjectsFromArray:responseModels];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                [weakSelf.tableView.mj_footer endRefreshing];
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [WSProgressHUD safeShowString:error];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_footer endRefreshing];
        });
    }];
}

- (void)initData {
    self.tintView.hidden = YES;
    [self.hud show];
    [self.view setUserInteractionEnabled:NO];
    __weak typeof(self) weakSelf = self;
    [[YuXinSDK sharedInstance] fetchArticleTitleListWithBoard:self.boardName start:@(0) completion:^(NSString *error, NSArray *responseModels) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.hud dismiss];
            [weakSelf.view setUserInteractionEnabled:YES];
        });
        if (!error) {
            weakSelf.articleStartNum = [responseModels count];
            weakSelf.titleArray = [NSMutableArray arrayWithArray:responseModels];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.tableView.hidden = NO;
                [weakSelf.tableView reloadData];
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tintView setGuide:@"网络似乎有问题\n点击屏幕重新加载"];
                weakSelf.tintView.hidden = NO;
                [WSProgressHUD safeShowString:error];
            });
        }
    }];
}

#pragma mark - DPTintViewDelegate

- (void)tintViewDidClick {
    [self initData];
}

#pragma mark - DPArticleDetailViewControllerDelegate

- (void)deleteArticleAtIndex:(NSInteger)index {
    [self.titleArray removeObjectAtIndex:index];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:YES];
}

#pragma mark - DPPostArticleViewControllerDelegate

- (void)articleDidPost {
    [self refreshTitle];
}

#pragma mark - DPArticleTitleCellDelegate

- (void)userImageViewDidClick:(NSString *)userID {
    DPUserInfoViewController *viewController = [[DPUserInfoViewController alloc] initWithUserID:userID];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self) weakSelf = self;
    return [tableView fd_heightForCellWithIdentifier:DPArticleTitleCellReuseIdentifier cacheByIndexPath:indexPath configuration:^(id cell) {
        [cell fillDataWithModel:weakSelf.titleArray[indexPath.row]];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YuXinTitle *title = self.titleArray[indexPath.row];
    DPArticleDetailViewController *viewController = [[DPArticleDetailViewController alloc] initWithBoard:self.boardName file:title.fileName index:indexPath.row];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    DPArticleTitleCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setHighlighted:YES];
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    DPArticleTitleCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setHighlighted:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DPArticleTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:DPArticleTitleCellReuseIdentifier];
    [cell fillDataWithModel:self.titleArray[indexPath.row]];
    cell.delegate = self;
    return cell;
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = DPBackgroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.hidden = YES;
        [_tableView registerClass:[DPArticleTitleCell class] forCellReuseIdentifier:DPArticleTitleCellReuseIdentifier];
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
        header.automaticallyChangeAlpha = YES;
        _tableView.mj_header = header;
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefresh)];
        footer.automaticallyChangeAlpha = YES;
        _tableView.mj_footer = footer;
    }
    return _tableView;
}

- (WSProgressHUD *)hud {
    if (!_hud) {
        _hud = [[WSProgressHUD alloc] initWithView:self.view];
        [_hud setProgressHUDIndicatorStyle:WSProgressHUDIndicatorMMSpinner];
    }
    return _hud;
}

- (DPTintView *)tintView {
    if (!_tintView) {
        _tintView = [[DPTintView alloc] init];
        _tintView.delegate = self;
        _tintView.hidden = YES;
    }
    return _tintView;
}

@end
