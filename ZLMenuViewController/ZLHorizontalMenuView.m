//
//  ZLMenuView.m
//  BaseProject
//
//  Created by Zou on 10/28/14.
//  Copyright (c) 2014 Zou. All rights reserved.
//

#import "ZLHorizontalMenuView.h"

@interface ZLHorizontalMenuView()

@property (nonatomic, strong) NSMutableArray *menuButtons; //menu buttons
@property (nonatomic, strong) UIScrollView *horizontalScrollView; //used to hold menu buttons

@property CGFloat totalWidth; //all menu with

@end

@implementation ZLHorizontalMenuView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (_menuButtons == nil) {
            _menuButtons = [[NSMutableArray alloc] init];
        }
        if (_horizontalScrollView == nil) {
            _horizontalScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            _horizontalScrollView.showsHorizontalScrollIndicator = NO;
        }
    }
    return self;
}

-(void)createMenuViews{
    _menus = [[_delegate itemsForMenuView:self] mutableCopy];
    int visibleMenuCount = SCREEN_WIDTH/DEFAULT_MENU_WIDTH;
    int i = 0;
    float menuWidth = 0.0;
    NSArray *itemsArray = _menus;
    for (ZLMenu *menu in itemsArray) {
        NSString *normalImageName = menu.normalBackgroundImageName == nil ? @"normal.png":menu.normalBackgroundImageName;
        NSString *helightImageName = menu.selectedBackgroundImageName== nil ? @"helight.png":menu.selectedBackgroundImageName;
        NSString *title = menu.title;
        float buttonWidth = menu.width;
        if (visibleMenuCount >= [itemsArray count]) {
            buttonWidth = SCREEN_WIDTH/[itemsArray count];
        }
        UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [menuButton setBackgroundImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
        [menuButton setBackgroundImage:[UIImage imageNamed:helightImageName] forState:UIControlStateSelected];
        [menuButton setTitle:title forState:UIControlStateNormal];
        [menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [menuButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [menuButton setTag:i];
        [menuButton addTarget:self action:@selector(itemViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        [menuButton setFrame:CGRectMake(menuWidth, 0, buttonWidth, self.frame.size.height)];
        [_horizontalScrollView addSubview:menuButton];
        [_menuButtons addObject:menuButton];
        
        menuWidth += buttonWidth;
        i++;
        
        //used to scroll the button to visible rect when buttons' total width is wider than SCREEN_WIDTH
        menu.totalWidth = menuWidth;
    }
    
    //it decided by who(ZLMenuViewController here) implement the delegate
    int selectedIndex = [_delegate selectedIndexForMenuView:self];
    [_menuButtons enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        [obj setSelected:(selectedIndex == idx)];
    }];
    
    [_horizontalScrollView setContentSize:CGSizeMake(menuWidth, self.frame.size.height)];
    [self addSubview:_horizontalScrollView];
    // save the total width of the buttons, used to scroll the button to visibile rect when total is wider than SCREEN_WIDTH
    _totalWidth = menuWidth;
}

- (void)itemViewTapped:(UIButton*)button
{
    [self changeButtonStateAtIndex:button.tag];
    int index = (int)[_menuButtons indexOfObject:button];
    [_delegate menuView:self didSelectItemAtIndex:index];
}

-(void)changeButtonStateAtIndex:(NSInteger)aIndex{
    UIButton *vButton = [_menuButtons objectAtIndex:aIndex];
    [self changeButtonsToNormalState];
    vButton.selected = YES;
    [self moveScrolViewWithIndex:aIndex];
}

-(void)moveScrolViewWithIndex:(NSInteger)aIndex{
    if (_menus.count < aIndex) {
        return;
    }
    //no need to scroll when the width is smaller than SCREEN_WIDTH
    if (_totalWidth <= SCREEN_WIDTH) {
        return;
    }
    ZLMenu *menu = [_menus objectAtIndex:aIndex];
    float vButtonOrigin = menu.totalWidth;
    if (vButtonOrigin >= SCREEN_WIDTH) {
        if ((vButtonOrigin + 180) >= _horizontalScrollView.contentSize.width) {
            [_horizontalScrollView setContentOffset:CGPointMake(_horizontalScrollView.contentSize.width - SCREEN_WIDTH, _horizontalScrollView.contentOffset.y) animated:YES];
            return;
        }
        
        float vMoveToContentOffset = vButtonOrigin - 180;
        if (vMoveToContentOffset > 0) {
            [_horizontalScrollView setContentOffset:CGPointMake(vMoveToContentOffset, _horizontalScrollView.contentOffset.y) animated:YES];
        }
    }else{
        [_horizontalScrollView setContentOffset:CGPointMake(0, _horizontalScrollView.contentOffset.y) animated:YES];
        return;
    }
}

-(void)changeButtonsToNormalState{
    for (UIButton *vButton in _menuButtons) {
        vButton.selected = NO;
    }
}

@end
