//
//  ASHSearchListViewController.m
//  ASHEBShop
//
//  Created by xmfish on 2018/8/7.
//  Copyright © 2018年 ash. All rights reserved.
//

#import "ASHSearchListViewController.h"
#import "ASHSearchBar.h"
#import "ASHSearchRecommondVM.h"
#import "ASHTypeSearchView.h"
#import "ASHShopItem2Cell.h"
#import "ASHSearchContentVM.h"
#import "ASHSearchTagView.h"
@interface ASHSearchListViewController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>
@property (nonatomic, strong)ASHSearchBar *searchbar;
@property (nonatomic, strong)UITableView* tableView;
@property (nonatomic, strong)ASHSearchContentVM* viewModel;
@property (nonatomic, strong)ASHSearchRecommondVM* recommondVM;
@property (nonatomic, strong)UIView* headView;
@property (nonatomic, strong)ASHTypeSearchView* typeSelectView;
@property (nonatomic, strong)ASHSearchTagView* searchTagView;
@property (nonatomic, assign)NSInteger typeIndex;//排序
@property (nonatomic, assign)BOOL shouldScrollTop;
@end

@implementation ASHSearchListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [MobClick event:@"search"];
    _viewModel = [ASHSearchContentVM new];
    _viewModel.keyWord = self.searchKey;
    _viewModel.sortType = 7;
    _recommondVM = [ASHSearchRecommondVM new];
    _recommondVM.sortType = 7;
    _recommondVM.keyWord = self.searchKey;
    self.typeIndex = 0;
    self.shouldScrollTop = NO;
    [self bindViewModel];
    [self bindSpecialViewModel];
    
    [self requestData];
    [self initSearchBar];
    [self initTableView];
    [self setupCategoryTopView];
}
- (void)bindViewModel
{
    @weakify(self);
    [_viewModel.requestFinishedSignal subscribeNext:^(id x) {
        @strongify(self);
        [self setupCategoryTopView];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        [self.tableView.mj_footer removeFromSuperview];
        [self.tableView.mj_header endRefreshing];
        [UIView showToast:kASH_NETWORK_Error];
    }];
}
- (void)bindSpecialViewModel
{
    @weakify(self);
    [_recommondVM.requestFinishedSignal subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView.mj_header endRefreshing];
        [self setFooter];
        if(!self.recommondVM.hasMore){
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            
            [self.tableView.mj_footer resetNoMoreData];
        }
        
        [self.tableView reloadData];
        if (self.shouldScrollTop) {
            self.shouldScrollTop = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            });
            
        }
        
    } error:^(NSError *error) {
        @strongify(self);
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
        [self.tableView.mj_footer removeFromSuperview];
        [self.tableView.mj_header endRefreshing];
        [UIView showToast:kASH_NETWORK_Error];
    }];
}
- (void)setupCategoryTopView
{
//    if (!self.viewModel.model.zhekou_cate_minipic.count) {
//        return;
//    }
    if (_headView) {
        [_headView removeFromSuperview];
        _headView = nil;
    }
    _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ASHScreenWidth, 90)];
    [_headView addSubview:self.typeSelectView];
    [_headView addSubview:self.searchTagView];
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 90, ASHScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor lineColor];
    [_headView addSubview:lineView];
    
    self.tableView.tableHeaderView = _headView;
    
    
}
#pragma mark View
- (ASHSearchTagView*)searchTagView{
    if (!_searchTagView) {
        _searchTagView = [[ASHSearchTagView alloc] initWithFrame:CGRectMake(0, 41, ASHScreenWidth, 50) titleArray:@[@"绵薄",@"绵薄",@"绵薄zhili",@"绵薄",@"水淀粉绵薄",@"绵薄",@"绵薄",@"绵水淀粉薄",@"绵山薄",@"绵ss薄",@"绵sd薄",@"绵薄",@"绵薄"]];
    }
    return _searchTagView;
}
- (ASHTypeSearchView*)typeSelectView
{
    if (!_typeSelectView) {
        _typeSelectView = [[ASHTypeSearchView alloc] initWithFrame:CGRectMake(0, 0, ASHScreenWidth, 40.0)];
        [_typeSelectView addBottomLine:1.0];
        
        @weakify(self);
        [_typeSelectView setTypeSelectAction:^(NSInteger index) {
            @strongify(self);
            if (index == 0) {
                self.viewModel.sortType = 7;
            }
            if (index == 1) {
                self.viewModel.sortType = 6;
            }
            if (index == 2) {
                self.viewModel.sortType = 1;
            }
            self.shouldScrollTop = YES;
            [self.viewModel requestData];
        }];
    }
    return _typeSelectView;
}
- (void)initSearchBar
{
    _searchbar = [[ASHSearchBar alloc] init];
    
    [self.view addSubview:_searchbar];
    
    _searchbar.frame = CGRectMake(44.0, 20.0, (CGRectGetWidth(self.view.bounds) - 54), 30);
    _searchbar.barStyle = UIBarStyleDefault;
    _searchbar.placeholder = @"输入商品名或粘贴淘宝标题";
    _searchbar.translucent = YES;
    _searchbar.tintColor = [UIColor blueColor];
    
    _searchbar.barTintColor = [UIColor whiteColor];
    _searchbar.backgroundColor = [UIColor whiteColor];
    
    _searchbar.showsCancelButton = NO;
    _searchbar.searchBarStyle = UISearchBarStyleMinimal;
    _searchbar.delegate = self;
    UITextField *searchField=[_searchbar valueForKey:@"searchField"];
    searchField.backgroundColor = [UIColor lineColor];
    [searchField setValue:[UIColor grayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [searchField setValue:[UIFont systemFontOfSize:13] forKeyPath:@"_placeholderLabel.font"];
    [searchField becomeFirstResponder];
    
    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 15, 44, 44);
    [backButton setImage:[UIImage imageNamed:@"nav_back_arrow_icon"] forState:UIControlStateNormal];
    @weakify(self);
    [[[backButton rac_signalForControlEvents:UIControlEventTouchUpInside] deliverOnMainThread] subscribeNext:^(id x) {
        @strongify(self);
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
    [self.view addSubview:backButton];
    
    _searchbar.text = self.searchKey;
}

- (void)initTableView{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.ash_top = 60;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.cornerRadius = 5.0;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundView.backgroundColor = [UIColor lineColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    
    
    [_tableView registerNib:[UINib nibWithNibName:@"ASHShopItem2Cell" bundle:nil] forCellReuseIdentifier:@"ASHShopItem2Cell"];
}
- (void)setFooter
{
    if (self.tableView.mj_footer) {
        return;
    }
    @weakify(self);
    MJRefreshAutoNormalFooter* refreshfooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self loadMore];
    }];
    refreshfooter.stateLabel.textColor = [UIColor whiteColor];
    self.tableView.mj_footer = refreshfooter;
    
    
}
- (void)requestData
{
    [_viewModel requestData];
    [_recommondVM requestData];
}
- (void)loadMore
{
    [_recommondVM loadMore];
}
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
//    NSInteger count = self.viewModel.model.coupon_list.count;
//    count = count / 2 + count % 2;
//    return count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat height = ASHScreenWidth / 2 * 1.58;
    
    return height;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASHShopItem2Cell* cell;
//    cell = [tableView dequeueReusableCellWithIdentifier:@"ASHShopItem2Cell"];
//    if (!cell) {
//        cell = [[[NSBundle mainBundle]loadNibNamed:@"ASHShopItem2Cell" owner:nil options:nil] firstObject];
//    }
//    NSInteger index = indexPath.row*2;
//    if (index >= self.specialViewModel.model.coupon_list.count) {
//        return cell;
//    }
//    ASHCouponInfoModel* model1 = self.specialViewModel.model.coupon_list[index];
//    ASHCouponInfoModel* model2;
//    if (index + 1 < self.specialViewModel.model.coupon_list.count) {
//        model2 = self.specialViewModel.model.coupon_list[ index + 1];
//    }else{
//        NSLog(@"%ld",index);
//    }
//    [cell setModel:model1 secondModel:model2];
    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (self.specialViewModel.hasMore && (indexPath.item >= self.specialViewModel.model.coupon_list.count - 4) && (tableView.contentOffset.y > 0)) {
//        [self.tableView.mj_footer beginRefreshing];
//    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 0.0;
}
//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return _typeSelectView;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc]init];
}
@end
