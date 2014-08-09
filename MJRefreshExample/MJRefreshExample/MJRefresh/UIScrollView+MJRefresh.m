//
//  UIScrollView+MJRefresh.m
//  MJRefreshExample
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "UIScrollView+MJRefresh.h"
#import "MJRefreshFooterView.h"
#import <objc/runtime.h>

@interface UIScrollView()

@property (weak, nonatomic) MJRefreshFooterView *footer;
@property (nonatomic, copy) void (^beginRefreshingCallback)();

@end


@implementation UIScrollView (MJRefresh)

#pragma mark - 运行时相关

static void *MJRefreshHeaderViewKey = &MJRefreshHeaderViewKey;
static void *MJRefreshFooterViewKey = &MJRefreshFooterViewKey;
static void *MJRefreshBeginCallBackKey = &MJRefreshBeginCallBackKey;

- (void)setHeader:(UIRefreshControl *)header {
    [self willChangeValueForKey:@"MJRefreshHeaderViewKey"];
    objc_setAssociatedObject(self, &MJRefreshHeaderViewKey,
                             header,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"MJRefreshHeaderViewKey"];
}

- (UIRefreshControl *)header {
    return objc_getAssociatedObject(self, &MJRefreshHeaderViewKey);
}


- (void)setFooter:(MJRefreshFooterView *)footer {
    [self willChangeValueForKey:@"MJRefreshFooterViewKey"];
    objc_setAssociatedObject(self, &MJRefreshFooterViewKey,
                             footer,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"MJRefreshFooterViewKey"];
}

- (MJRefreshFooterView *)footer {
    return objc_getAssociatedObject(self, &MJRefreshFooterViewKey);
}

#pragma mark -

- (void)setBeginRefreshingCallback:(void (^)())beginRefreshingCallback
{
    objc_setAssociatedObject(self, &MJRefreshBeginCallBackKey,
                             beginRefreshingCallback,
                             OBJC_ASSOCIATION_COPY);
}

- (void (^)())beginRefreshingCallback{
    return objc_getAssociatedObject(self, &MJRefreshBeginCallBackKey);
}

#pragma mark - 

- (void)setShouldLoadMoreBlock:(BOOL (^)())shouldLoadMoreBlock{
    self.footer.shouldLoadMoreBlock = shouldLoadMoreBlock;
}

- (BOOL (^)())shouldLoadMoreBlock{
    return self.footer.shouldLoadMoreBlock;
}

#pragma mark - 下拉刷新
/**
 *  添加一个下拉刷新头部控件
 *
 *  @param callback 回调
 */
- (void)addHeaderWithCallback:(void (^)())callback
{
    // 1.创建新的header
    if (!self.header) {
        UIRefreshControl *header = [[UIRefreshControl alloc] init];
        [header addTarget:self action:nil forControlEvents:UIControlEventValueChanged];
        [self addSubview:header];
        self.header = header;
    }
    
    // 2.设置block回调
    self.beginRefreshingCallback = callback;
    [self.header addTarget:self action:@selector(beginRefreshingCallded) forControlEvents:UIControlEventValueChanged];
}

- (void)beginRefreshingCallded
{
    if(self.beginRefreshingCallback){
        self.beginRefreshingCallback();
    }
    [self.footer setHidden:NO];

}

/**
 *  添加一个下拉刷新头部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addHeaderWithTarget:(id)target action:(SEL)action
{
    
    // 1.创建新的header
    if (!self.header) {
        UIRefreshControl *header = [[UIRefreshControl alloc] init];
        [self addSubview:header];
        self.header = header;
    }
    
    [self.header addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    [self.header addTarget:self action:@selector(beginRefreshingCallded) forControlEvents:UIControlEventValueChanged];
    
}

/**
 *  移除下拉刷新头部控件
 */
- (void)removeHeader
{
    [self.header removeFromSuperview];
    self.header = nil;
}

/**
 *  主动让下拉刷新头部控件进入刷新状态
 */
- (void)headerBeginRefreshing
{
    [self setContentOffset:CGPointMake(0, - 1.0f) animated:NO];
    [self setContentOffset:CGPointMake(0, - self.header.frame.size.height) animated:YES];
    [self.header beginRefreshing];
    [self.footer setHidden:NO];
}

/**
 *  让下拉刷新头部控件停止刷新状态
 */
- (void)headerEndRefreshing
{
    [self.header endRefreshing];
}

/**
 *  下拉刷新头部控件的可见性
 */
- (void)setHeaderHidden:(BOOL)hidden
{
    self.header.hidden = hidden;
}

- (BOOL)isHeaderHidden
{
    return self.header.isHidden;
}

#pragma mark - 上拉刷新
/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param callback 回调
 */
- (void)addFooterWithCallback:(void (^)())callback
{
//    // 1.创建新的footer
    if (!self.footer) {
        MJRefreshFooterView *footer = [MJRefreshFooterView footer];
        [self addSubview:footer];
        self.footer = footer;
    }

    // 2.设置block回调
    self.footer.beginRefreshingCallback = callback;
}

/**
 *  添加一个上拉刷新尾部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addFooterWithTarget:(id)target action:(SEL)action
{
    // 1.创建新的footer
    if (!self.footer) {
        MJRefreshFooterView *footer = [MJRefreshFooterView footer];
        [self addSubview:footer];
        self.footer = footer;
    }
    
    // 2.设置目标和回调方法
    self.footer.beginRefreshingTaget = target;
    self.footer.beginRefreshingAction = action;
}

/**
 *  移除上拉刷新尾部控件
 */
- (void)removeFooter
{
    [self.footer removeFromSuperview];
    self.footer = nil;
}

/**
 *  主动让上拉刷新尾部控件进入刷新状态
 */
- (void)footerBeginRefreshing
{
    [self.footer beginRefreshing];
}

/**
 *  让上拉刷新尾部控件停止刷新状态
 */
- (void)footerEndRefreshing
{
    [self.footer endRefreshing];
}

/**
 *  下拉刷新头部控件的可见性
 */
- (void)setFooterHidden:(BOOL)hidden
{
    self.footer.hidden = hidden;
}

- (BOOL)isFooterHidden
{
    return self.footer.isHidden;
}
@end
