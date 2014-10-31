//
//  ZLMenuView.h
//  BaseProject
//
//  Created by Zou on 10/28/14.
//  Copyright (c) 2014 Zou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLMenu.h"

@class ZLHorizontalMenuView;

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width

@protocol ZLHorizontalMenuViewDelegate <NSObject>

- (NSArray *)itemsForMenuView:(ZLHorizontalMenuView *)menuView;
- (int)selectedIndexForMenuView:(ZLHorizontalMenuView *)menuView;
- (void)menuView:(ZLHorizontalMenuView *)menuView didSelectItemAtIndex:(int)idx;

@end

@interface ZLHorizontalMenuView : UIControl

@property (nonatomic, weak) id <ZLHorizontalMenuViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *menus; // menu can dynamically add or remove

-(void)createMenuViews;
-(void)changeButtonStateAtIndex:(NSInteger)index;
@end
