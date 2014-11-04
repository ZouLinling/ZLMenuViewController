//
//  NewsViewController.h
//  BaseProject
//
//  Created by Zou on 10/30/14.
//  Copyright (c) 2014 Zou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLMenuViewController.h"

typedef enum {
    NewsTypeRoot,
    NewsTypeSports,
    NewsTypeScience,
    NewsTypeGame,
    NewsTypeMovie,
    NewsTypeLocal,
    NewsTypeInternational
}NewsType;

@interface NewsViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NewsType newsType;

-(id)initWithNewsType:(NewsType)newsType;


@end
