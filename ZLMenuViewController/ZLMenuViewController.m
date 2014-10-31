//
//  ZLMenuViewController.m
//  BaseProject
//
//  Created by Zou on 10/28/14.
//  Copyright (c) 2014 Zou. All rights reserved.
//

#import "ZLMenuViewController.h"
#import <objc/runtime.h>

@interface ZLMenuViewController ()<ZLHorizontalMenuViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *transitionView;
@property (nonatomic, weak) UIViewController *selectedViewController;

@end

@implementation ZLMenuViewController
@dynamic selectedViewControllerIndex;

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

#pragma mark ZLHorizontalMenuViewDelegate

- (int)selectedIndexForMenuView:(ZLHorizontalMenuView *)menuView
{
    return [self selectedViewControllerIndex];
}

- (void)menuView:(ZLHorizontalMenuView *)menuView didSelectItemAtIndex:(int)idx
{
    if(idx != [self selectedViewControllerIndex]) {
        [self setSelectedViewController:[_viewControllers objectAtIndex:idx]];
    }
}

- (NSArray *)itemsForMenuView:(ZLHorizontalMenuView *)menuView
{
    NSMutableArray *itemsArray = [[NSMutableArray alloc] initWithCapacity:[_viewControllers count]];
    //给没有设置菜单的VC添上菜单
    for (UIViewController *vc in _viewControllers) {
        ZLMenu *menu = vc.menuItem;
        if (menu) {
            [itemsArray addObject:menu];
        } else {
            [itemsArray addObject:[[ZLMenu alloc] initWithTitle:@"标题" background:nil selected:nil desiredWidth:DEFAULT_MENU_WIDTH]];
        }
    }
    return itemsArray;
}

#pragma mark methods

- (void)setViewControllers:(NSArray *)viewControllers
{
    for(UIViewController *vc in [self viewControllers]) {
        [vc willMoveToParentViewController:nil];
        if([vc isViewLoaded] && [[vc view] superview] == [self transitionView])
            [[vc view] removeFromSuperview];
        [vc removeFromParentViewController];
    }
    
    _viewControllers = viewControllers;
    
    for(UIViewController *vc in [self viewControllers]) {
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
    }
    
    if([_viewControllers count] > 0) {
        [self setSelectedViewController:[_viewControllers objectAtIndex:0]];
    } else {
        [self setSelectedViewController:nil];
    }
}

- (int)selectedViewControllerIndex
{
    return (int)[[self viewControllers] indexOfObject:[self selectedViewController]];
}

- (void)setSelectedViewControllerIndex:(int)selectedViewControllerIndex
{
    if(selectedViewControllerIndex < 0
       || selectedViewControllerIndex >= [[self viewControllers] count]
       || selectedViewControllerIndex == [self selectedViewControllerIndex])
        return;
    
    [self setSelectedViewController:[[self viewControllers] objectAtIndex:selectedViewControllerIndex]];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    if(![[self viewControllers] containsObject:selectedViewController]) {
        return;
    }
    
    UIViewController *previous = [self selectedViewController];
    
    _selectedViewController = selectedViewController;
    
    if([self isViewLoaded]) {
        [previous.view removeFromSuperview];
        
        UIView *newView = [[self selectedViewController] view];
        [newView setFrame:[[self transitionView] bounds]];
        [newView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [[self transitionView] addSubview:newView];
    }
}

/**
 *  根据手势滑动的方向添加不同的动画并显示新的VC
 *
 *  @param selectedViewController 需要显示的VC
 *  @param direction              滑动的方向
 */
- (void)swipeViewController:(UIViewController *)selectedViewController direction:(UISwipeGestureRecognizerDirection)direction
{
    if(![[self viewControllers] containsObject:selectedViewController]) {
        return;
    }
    
    UIViewController *previous = [self selectedViewController];
    
    _selectedViewController = selectedViewController;
    
    if([self isViewLoaded]) {
        if (previous == _selectedViewController) {
            //impossible to get here
            [previous.view removeFromSuperview];
        }
        UIView *newView = [[self selectedViewController] view];
        [newView setFrame:[[self transitionView] bounds]];
        [newView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [[self transitionView] addSubview:newView];
        
        if (previous != _selectedViewController)
        {
            if (direction == UISwipeGestureRecognizerDirectionLeft) {
                //swipe from right to left, the views move from right to left
                newView.center = CGPointMake(SCREEN_WIDTH + SCREEN_WIDTH/2, newView.center.y);
                [UIView animateWithDuration:0.5 animations:^{
                    previous.view.center = CGPointMake(-SCREEN_WIDTH/2, previous.view.center.y);
                } completion:^(BOOL finished) {
                    [previous.view removeFromSuperview];
                }];
                
                [UIView animateWithDuration:0.5 animations:^{
                    newView.center = CGPointMake(SCREEN_WIDTH/2, newView.center.y);
                } completion:^(BOOL finished) {
                    
                }];
            } else if (direction == UISwipeGestureRecognizerDirectionRight) {
                newView.center = CGPointMake(-SCREEN_WIDTH/2, newView.center.y);
                [UIView animateWithDuration:0.5 animations:^{
                    previous.view.center = CGPointMake(SCREEN_WIDTH + SCREEN_WIDTH/2, previous.view.center.y);
                } completion:^(BOOL finished) {
                    [previous.view removeFromSuperview];
                }];
                
                [UIView animateWithDuration:0.5 animations:^{
                    newView.center = CGPointMake(SCREEN_WIDTH/2, newView.center.y);
                } completion:^(BOOL finished) {
                    
                }];
            }
        }
    }
}

- (void)loadView
{
    UIView *layoutView = [[UIView alloc] init];
    ZLHorizontalMenuView *menuView;
    if (self.navigationController) {
        menuView = [[ZLHorizontalMenuView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, MENUHEIHT)];
    } else {
        menuView = [[ZLHorizontalMenuView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, MENUHEIHT)];
    }
    [menuView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [menuView setDelegate:self];
    [layoutView addSubview:menuView];
    
    UIView *transitionView = [[UIView alloc] initWithFrame:CGRectMake(layoutView.frame.origin.x, menuView.frame.origin.y + menuView.frame.size.height, layoutView.frame.size.width, layoutView.frame.size.height)];
    [transitionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleBottomMargin];
    
    //add left and right swipe gesture recognizer
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeVC:)];
    swipeRecognizer.delegate = self;
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [transitionView addGestureRecognizer:swipeRecognizer];

    swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeVC:)];
    swipeRecognizer.delegate = self;
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [transitionView addGestureRecognizer:swipeRecognizer];
    
    [layoutView addSubview:transitionView];
    
    [layoutView bringSubviewToFront:menuView];
    
    layoutView.userInteractionEnabled = YES;
    
    [self setView:layoutView];
    [self setTransitionView:transitionView];
    _menuView = menuView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSelectedViewController:[self selectedViewController]];
    [_menuView createMenuViews];
}

/**
 *  useless
 *
 *  @param panGesture
 */
-(void)handlePan:(UIPanGestureRecognizer*)panGesture
{
    CGPoint point = [panGesture translationInView:_transitionView];
    NSLog(@"%f,%f",point.x,point.y);
    panGesture.view.center = CGPointMake(panGesture.view.center.x + point.x, panGesture.view.center.y);
    [panGesture setTranslation:CGPointMake(0, 0) inView:_transitionView];
}

- (void)swipeVC:(UISwipeGestureRecognizer *)gestureRecognizer
{
    int index = [self selectedViewControllerIndex];
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (index == [_viewControllers count] -1 ) {
            //the right one， do nothing
        } else {
            [self swipeViewController:[_viewControllers objectAtIndex:index+1] direction:UISwipeGestureRecognizerDirectionLeft];
        }
    }
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        if (index == 0) {
            if (self.navigationController) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        } else {
            [self swipeViewController:[_viewControllers objectAtIndex:index - 1] direction:UISwipeGestureRecognizerDirectionRight];
        }
    }
    [_menuView changeButtonStateAtIndex:[self selectedViewControllerIndex]];
}


@end

@implementation UIViewController (ZLMenuAdditions)

static const void *Menu = &Menu;

@dynamic  menuItem;

-(ZLMenu*)menuItem
{
    return objc_getAssociatedObject(self, Menu);
}

-(void)setMenuItem:(ZLMenu *)menuItem
{
    objc_setAssociatedObject(self, Menu, menuItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ZLMenuViewController *)menuController
{
    UIViewController *parent = [self parentViewController];
    while(parent) {
        if([parent isKindOfClass:[ZLMenuViewController class]]) {
            return (ZLMenuViewController *)parent;
        }
        parent = [parent parentViewController];
    }
    return nil;
}
@end
