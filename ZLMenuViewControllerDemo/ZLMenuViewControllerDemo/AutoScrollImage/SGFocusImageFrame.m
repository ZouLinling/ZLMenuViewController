//
//  SGFocusImageFrame.m
//  ScrollViewLoop
//
//  Created by Vincent Tang on 13-7-18.
//  Copyright (c) 2013年 Vincent Tang. All rights reserved.
//

#import "SGFocusImageFrame.h"
#import <objc/runtime.h>
#define ITEM_WIDTH [UIScreen mainScreen].bounds.size.width

#define DEFAULT_TIME_INTERVAL 3.0f

@interface SGFocusImageFrame () {
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
}

- (void)setupViews;
- (void)switchFocusImageItems;
@end

@implementation SGFocusImageFrame
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame focusImageItems:(SGFocusImageItem *)firstItem, ...
{
    self = [super initWithFrame:frame];
    if (self) {
        _timeInterval = DEFAULT_TIME_INTERVAL;
        _itemsArray = [NSMutableArray array];
        SGFocusImageItem *eachItem;
        va_list argumentList;
        if (firstItem)
        {
            [_itemsArray addObject:firstItem];
            va_start(argumentList, firstItem);
            while((eachItem = va_arg(argumentList, SGFocusImageItem *)))
            {
                [_itemsArray addObject:eachItem];
            }
            va_end(argumentList);
        }
        _itemsArray = [[self addFirstAndLast:_itemsArray] mutableCopy];
        _isAutoPlay = YES;
        [self setupViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame imageItems:(NSArray *)items;
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _itemsArray = [NSMutableArray arrayWithArray:items];
        _itemsArray = [[self addFirstAndLast:_itemsArray] mutableCopy];
        _timeInterval = DEFAULT_TIME_INTERVAL;
        _isAutoPlay = YES;
        [self setupViews];
    }
    return self;
}


#pragma mark - private methods
- (void)setupViews
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.scrollsToTop = NO;

    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height -10-10, self.frame.size.width, 10)];
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_scrollView];
    [self addSubview:_pageControl];
    
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    
    // single tap gesture recognizer
    UITapGestureRecognizer *tapGestureRecognize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureRecognizer:)];
    tapGestureRecognize.delegate = self;
    tapGestureRecognize.numberOfTapsRequired = 1;
    [_scrollView addGestureRecognizer:tapGestureRecognize];

    [self addImageViews:_itemsArray];
}

#pragma mark 添加视图
-(void)addImageViews:(NSArray *)aImageItems{
    //移除子视图
    for (UIView *lView in _scrollView.subviews) {
        [lView removeFromSuperview];
    }
    
    float space = 0;
    CGSize size = CGSizeMake(320, 0);
    for (int i = 0; i < aImageItems.count; i++) {
        SGFocusImageItem *item = [aImageItems objectAtIndex:i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * _scrollView.frame.size.width+space, space, _scrollView.frame.size.width-space*2, _scrollView.frame.size.height-2*space-size.height)];
        //加载图片
        imageView.backgroundColor = i%2?[UIColor redColor]:[UIColor blueColor];
        imageView.image = [UIImage imageNamed:item.image];
        [_scrollView addSubview:imageView];
    }
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * aImageItems.count, _scrollView.frame.size.height);
    _pageControl.numberOfPages = aImageItems.count>1?aImageItems.count -2:aImageItems.count;
    _pageControl.currentPage = 0;
    
    if ([aImageItems count]>1)
    {
        [_scrollView setContentOffset:CGPointMake(ITEM_WIDTH, 0) animated:NO] ;
        if (_isAutoPlay)
        {
            [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:_timeInterval];
        }
        
    }
}

#pragma mark 改变添加视图内容
-(void)changeImageViewsContent:(NSArray *)aArray{
    NSArray *newImagesArray = [self addFirstAndLast:aArray];
    [_itemsArray removeAllObjects];
    _itemsArray = [NSMutableArray arrayWithArray:newImagesArray];
    [self addImageViews:_itemsArray];
}

/**
 *  把数组的最后一张图片插入到第一个，把原来的第一张图片插入到数组尾部以实现无缝滚动
 *
 *  @param orignalArray 原始数组
 *
 *  @return 修改后的数组
 */
-(NSArray*)addFirstAndLast:(NSArray*)orignalArray
{
    int length = [orignalArray count];
    if (length <= 1) {
        return orignalArray;
    }
    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:length + 2];
    //添加最后一张图 用于循环
    SGFocusImageItem *lastItem = [orignalArray objectAtIndex:length-1];
    lastItem.tag = -1;
    [itemArray addObject:lastItem];
    //把原来的image加入到新的Array中并重置tag
    for (int i = 0; i < length; i++)
    {
        SGFocusImageItem *item = [orignalArray objectAtIndex:i];
        item.tag = i;
        [itemArray addObject:item];
    }
    //添加第一张图 用于循环
    SGFocusImageItem *firstItem = [orignalArray objectAtIndex:0];
    firstItem.tag = length;
    [itemArray addObject:firstItem];
    return itemArray;
}

- (void)switchFocusImageItems
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(switchFocusImageItems) object:nil];
    
    CGFloat targetX = _scrollView.contentOffset.x + _scrollView.frame.size.width;
    targetX = (int)(targetX/ITEM_WIDTH) * ITEM_WIDTH;
    [self moveToTargetPosition:targetX];
    
    if ([_itemsArray count]>1 && _isAutoPlay)
    {
        [self performSelector:@selector(switchFocusImageItems) withObject:nil afterDelay:_timeInterval];
    }
}

- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%s", __FUNCTION__);
    int page = (int)(_scrollView.contentOffset.x / _scrollView.frame.size.width);
    if (page > -1 && page < _itemsArray.count) {
        SGFocusImageItem *item = [_itemsArray objectAtIndex:page];
        if ([self.delegate respondsToSelector:@selector(foucusImageFrame:didSelectItem:)]) {
            [self.delegate foucusImageFrame:self didSelectItem:item];
        }
    }
}

- (void)moveToTargetPosition:(CGFloat)targetX
{
    BOOL animated = YES;
    //    NSLog(@"moveToTargetPosition : %f" , targetX);
    [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:animated];
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float targetX = scrollView.contentOffset.x;
    if ([_itemsArray count]>=3)
    {
        if (targetX >= ITEM_WIDTH * ([_itemsArray count] -1)) {
            targetX = ITEM_WIDTH;
            [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
        }
        else if(targetX <= 0)
        {
            targetX = ITEM_WIDTH *([_itemsArray count]-2);
            [_scrollView setContentOffset:CGPointMake(targetX, 0) animated:NO];
        }
    }
    int page = (_scrollView.contentOffset.x+ITEM_WIDTH/2.0) / ITEM_WIDTH;
    //    NSLog(@"%f %d",_scrollView.contentOffset.x,page);
    if ([_itemsArray count] > 1)
    {
        page --;
        if (page >= _pageControl.numberOfPages)
        {
            page = 0;
        }else if(page <0)
        {
            page = _pageControl.numberOfPages -1;
        }
    }
    if (page!= _pageControl.currentPage)
    {
        if ([self.delegate respondsToSelector:@selector(foucusImageFrame:currentItem:)])
        {
            [self.delegate foucusImageFrame:self currentItem:page];
        }
    }
    _pageControl.currentPage = page;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        CGFloat targetX = _scrollView.contentOffset.x + _scrollView.frame.size.width;
        targetX = (int)(targetX/ITEM_WIDTH) * ITEM_WIDTH;
        [self moveToTargetPosition:targetX];
    }
}

- (void)scrollToIndex:(int)aIndex
{
    if ([_itemsArray count]>1)
    {
        if (aIndex >= ([_itemsArray count]-2))
        {
            aIndex = [_itemsArray count]-3;
        }
        [self moveToTargetPosition:ITEM_WIDTH*(aIndex+1)];
    }else
    {
        [self moveToTargetPosition:0];
    }
    [self scrollViewDidScroll:_scrollView];
}
@end