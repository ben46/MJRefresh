//
//  MJTableViewController.m
//  快速集成下拉刷新
//
//  Created by mj on 14-1-3.
//  Copyright (c) 2014年 itcast. All rights reserved.
//
/*
 具体用法：查看MJRefresh.h
 */
#import "MJTableViewController.h"
#import "MJTestViewController.h"
#import "MJRefresh.h"

NSString *const MJTableViewCellIdentifier = @"Cell";

/**
 *  随机数据
 */
#define MJRandomData [NSString stringWithFormat:@"随机数据---%d", arc4random_uniform(1000000)]

@interface MJTableViewController ()<UITableViewDelegate, UITableViewDataSource>
/**
 *  存放假数据
 */
@property (strong, nonatomic) NSMutableArray *fakeData;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIActivityIndicatorView       *loadMoreIndicator;

@end

@implementation MJTableViewController

#pragma mark - 初始化

- (void)loadView{
    
    [super loadView];
    
    CGRect fame = self.view.bounds;
    fame.size.height -= (44 + 44);
    
    self.tableView = [[UITableView alloc] initWithFrame:fame];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.tableView];

    // 1.注册cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MJTableViewCellIdentifier];
    
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    //#warning 自动刷新(一进入程序就下拉刷新)
    [self.tableView headerBeginRefreshing];
    [self headerRereshing];

    // 2.上拉加载更多(进入刷新状态就会调用self的footerRereshing)
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
}

#pragma mark - properties


- (UIActivityIndicatorView *)loadMoreIndicator
{
    if(!_loadMoreIndicator) {
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicator startAnimating];
        [indicator setHidesWhenStopped:YES];
        _loadMoreIndicator = indicator;
        
    }
    
    return _loadMoreIndicator;
    
}
/**
 *  数据的懒加载
 */
- (NSMutableArray *)fakeData
{
    if (!_fakeData) {
        self.fakeData = [NSMutableArray array];
        
        for (int i = 0; i<12; i++) {
            [self.fakeData addObject:MJRandomData];
        }
    }
    return _fakeData;
}


#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    // 1.添加假数据
    for (int i = 0; i<5; i++) {
        [self.fakeData insertObject:MJRandomData atIndex:0];
    }
    
    // 2.2秒后刷新表格UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [self.tableView reloadData];
        
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        [self.tableView headerEndRefreshing];
    });
}

- (void)footerRereshing
{
    // 1.添加假数据
    for (int i = 0; i<5; i++) {
        [self.fakeData addObject:MJRandomData];
    }
    
    // 2.2秒后刷新表格UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新表格
        [self.tableView reloadData];
        
        // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
        [self.tableView footerEndRefreshing];
    });
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fakeData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MJTableViewCellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.fakeData[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MJTestViewController *test = [[MJTestViewController alloc] init];
    [self.navigationController pushViewController:test animated:YES];
}

#pragma mark - Scroll delegate

// 判断是否药加载更多
- (BOOL)_scrollViewShouldLoadMore:(UIScrollView *)scrollView{
    int bottom = 70;
    return scrollView.contentOffset.y+(scrollView.frame.size.height) + bottom > scrollView.contentSize.height;
}







@end
