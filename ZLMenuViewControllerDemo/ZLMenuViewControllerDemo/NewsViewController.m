//
//  NewsViewController.m
//  BaseProject
//
//  Created by Zou on 10/30/14.
//  Copyright (c) 2014 Zou. All rights reserved.
//

#import "NewsViewController.h"
#import "SGFocusImageFrame.h"
#import "NewsTableViewCell.h"

@interface NewsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *dataArray;
}

@end

@implementation NewsViewController

-(id)initWithNewsType:(NewsType)newsType
{
    self = [self initWithNibName:@"NewsViewController" bundle:nil];
    if (self) {
        NSString *title;
        switch (newsType) {
            case NewsTypeRoot:
                title = @"首页";
                break;
            case NewsTypeSports:
                title = @"体育";
                break;
            case NewsTypeScience:
                title = @"科技";
                break;
            case NewsTypeGame:
                title = @"游戏";
                break;
            case NewsTypeMovie:
                title = @"电影";
                break;
            default:
                title = @"新闻";
                break;
        }
        self.menuItem = [[ZLMenu alloc] initWithTitle:title background:nil selected:nil desiredWidth:DEFAULT_MENU_WIDTH];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dataArray = [NSMutableArray array];
    //demo here use the same resource
    for (int i = 0; i<3; i++) {
        NSDictionary *item = @{@"title":@"四中全会召开",@"image":[NSString stringWithFormat:@"image%d",(i + 1)],@"subTitle":@"四中全会胜利闭幕"};
        [dataArray addObject:item];
    }
    
    NSMutableArray *tempArray = [NSMutableArray array];
    int length = 3;
    for (int i = 0 ; i < length; i++)
    {
        SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:[NSString stringWithFormat:@"title%d",i] image:[NSString stringWithFormat:@"image%d",(i + 1)] tag:0];
        [tempArray addObject:item];
    }
    
    SGFocusImageFrame *adFrame = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 120) imageItems:tempArray];    
    _tableView.tableHeaderView = adFrame;
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *vCellIdentify = @"NewsTableViewCell";
    NewsTableViewCell *vCell = [tableView dequeueReusableCellWithIdentifier:vCellIdentify];
    if (vCell == nil) {
        vCell = [[[NSBundle mainBundle] loadNibNamed:@"NewsTableViewCell" owner:self options:nil] lastObject];
    }
    
    NSDictionary *item = [dataArray objectAtIndex:indexPath.row];
    vCell.titleLabel.text = [item objectForKey:@"title"];
    vCell.subTitleLabel.text = [item objectForKey:@"subTitle"];
    vCell.image.image = [UIImage imageNamed:[item objectForKey:@"image"]];
    return vCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}



@end
