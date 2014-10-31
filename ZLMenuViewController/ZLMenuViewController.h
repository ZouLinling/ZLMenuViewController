//
//  ZLMenuViewController.h
//  BaseProject
//
//  Created by Zou on 10/28/14.
//  Copyright (c) 2014 Zou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLHorizontalMenuView.h"

@class ZLMenuViewController;

@interface UIViewController (ZLMenuAdditions)
@property (nonatomic, readonly) ZLMenuViewController *menuController;
@property (nonatomic, retain) ZLMenu *menuItem;
@end

@interface ZLMenuViewController : UIViewController

@property (nonatomic) int selectedViewControllerIndex;
@property (nonatomic, copy) NSArray *viewControllers;

@property (nonatomic, weak, readonly) ZLHorizontalMenuView *menuView;

@end
