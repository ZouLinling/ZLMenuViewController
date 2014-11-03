//
//  ZLMenuViewController.m
//  BaseProject
//
//  Created by Zou on 10/28/14.
//  Copyright (c) 2014 Zou. All rights reserved.
//

#import "ZLMenuViewController.h"
#import <objc/runtime.h>

#define  USE_SWIPE_ANIMATION NO //two types animation when change vc use gesture

@interface ZLMenuViewController ()<ZLHorizontalMenuViewDelegate, UIGestureRecognizerDelegate,DraggableViewDelegate>

@property (nonatomic, weak) UIView *transitionView;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property ZLPanGestureSwipeDirection direction;

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
    //add the default menu for the ViewController not set menuItem
    for (UIViewController *vc in _viewControllers) {
        ZLMenu *menu = vc.menuItem;
        if (menu) {
            [itemsArray addObject:menu];
        } else {
            [itemsArray addObject:[[ZLMenu alloc] initWithTitle:@"Menu" background:nil selected:nil desiredWidth:DEFAULT_MENU_WIDTH]];
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
 *  add animation when swipe to change VC. The code here is similar with above
 *  -(void)setSelectedViewController:(UIViewController *)selectedViewController
 *
 *  @param selectedViewController
 *  @param direction              swipe direction
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
    if (USE_SWIPE_ANIMATION) {
         UIView *transitionView = [[UIView alloc] initWithFrame:CGRectMake(layoutView.frame.origin.x, menuView.frame.origin.y + menuView.frame.size.height, layoutView.frame.size.width, layoutView.frame.size.height)];
        [transitionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleBottomMargin];
        //add left and right swipe gesture recognizer
        UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeRecognizer.delegate = self;
        swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [transitionView addGestureRecognizer:swipeRecognizer];
        
        swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        swipeRecognizer.delegate = self;
        swipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [transitionView addGestureRecognizer:swipeRecognizer];
        [layoutView addSubview:transitionView];
        [self setTransitionView:transitionView];
    } else {
        DraggableView *transitionView = [[DraggableView alloc] initWithFrame:CGRectMake(layoutView.frame.origin.x, menuView.frame.origin.y + menuView.frame.size.height, layoutView.frame.size.width, layoutView.frame.size.height)];
        [transitionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleBottomMargin];
        transitionView.delegate = self;
        [layoutView addSubview:transitionView];
        [self setTransitionView:transitionView];
    }
    [layoutView bringSubviewToFront:menuView];
    
    layoutView.userInteractionEnabled = YES;
    
    [self setView:layoutView];
    
    _menuView = menuView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSelectedViewController:[self selectedViewController]];
    [_menuView createMenuViews];
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)gestureRecognizer
{
    int index = [self selectedViewControllerIndex];
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (index == [_viewControllers count] -1 ) {
            //the right most one， do nothing here
            // you can add animation or toast to remind the user that there is no more vc on the right
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

#pragma mark DraggableViewDelegate

- (void)draggableView:(DraggableView *)view draggingEndedWithVelocity:(CGPoint)velocity
{
    /**************注意，左滑和右滑分别使用了两种方法来控制frame的变化
    左滑是在屏幕的左侧添加了一个view，同时_transitionView的宽度从SCREEN_WIDTH扩大了一倍到2*SCREEN_WIDTH，然后依次往左滑动，最后中心点落在y轴上（x＝0），动画结束后把frame变回原样，同时删除了旧的view，新的view也设置到和_transitionView的frame一致
    右滑是在屏幕的左侧添加了一个view，但是这里并没有扩大_transitionView的frame来显示，而是利用了_transitionView.clipsToBounds = NO; 来显示超出_transitionView边界的view，最后_transitionView到了屏幕的右侧。动画结束后，调整_transitionView的frame为当前显示区域，同时删除了旧的view，这里可以不用重新设置新view的frame，因为动画结束后它的frame就已经是我们期望的。**************/
    
    
        //如果往右滑动时_transitionView已经超过了屏幕的三分之一，则当作用户想往右滑动，自动完成
    if (_direction == ZLPanGestureSwipeDirectionNoneRight) {
        if (((CGFloat)_transitionView.frame.origin.x/SCREEN_WIDTH - 1.0/3.0) >= 0.0) {
            [UIView animateWithDuration:0.5 animations:^{
                //view's X dragged from ZERO to SCREEN_WIDTH,the view's center finally to SCREEN_WIDTH*1.5
                _transitionView.center = CGPointMake(SCREEN_WIDTH + SCREEN_WIDTH/2, _transitionView.center.y);
            } completion:^(BOOL finished) {
                //change the frame to one screen
                _transitionView.frame = CGRectMake(0, _transitionView.frame.origin.y, SCREEN_WIDTH, _transitionView.frame.size.height);
                // remove the older vc's view
                [[[_transitionView subviews] objectAtIndex:0] removeFromSuperview];
                // change the new vc's view's frame and show
                [[[_transitionView subviews] objectAtIndex:0] setFrame:CGRectMake(0, 0, _transitionView.frame.size.width, _transitionView.frame.size.height)];
                // set selected vc
                [self setSelectedViewController:[_viewControllers objectAtIndex:[self selectedViewControllerIndex]-1]];
                //change the menu
                [_menuView changeButtonStateAtIndex:[self selectedViewControllerIndex]];
            }];
        }else {
            //cancel the drag, resume to before
            [UIView animateWithDuration:0.5 animations:^{
                //view's X dragged from ZERO to SCREEN_WIDTH,the view's center finally to SCREEN_WIDTH*1.5
                _transitionView.center = CGPointMake(SCREEN_WIDTH/2, _transitionView.center.y);
            } completion:^(BOOL finished) {
                // remove the new vc's view
                [[[_transitionView subviews] objectAtIndex:1] removeFromSuperview];
                // resume the old vc's view's frame and show
                [[[_transitionView subviews] objectAtIndex:0] setFrame:CGRectMake(0, 0, _transitionView.frame.size.width, _transitionView.frame.size.height)];
            }];
        }
    }
    
    if (_direction == ZLPanGestureSwipeDirectionNoneLeft) {
        if (((CGFloat)abs(_transitionView.frame.origin.x)/SCREEN_WIDTH - 1.0/3.0 ) >= 0.0) {
            [UIView animateWithDuration:0.5 animations:^{
                //view's X dragged from ZERO to -SCREEN_WIDTH,the view's center finally to ZERO
                _transitionView.center = CGPointMake(0, _transitionView.center.y);
            } completion:^(BOOL finished) {
                //change the frame to one screen
                _transitionView.frame = CGRectMake(0, _transitionView.frame.origin.y, SCREEN_WIDTH, _transitionView.frame.size.height);
                // remove the older vc's view
                [[[_transitionView subviews] objectAtIndex:0] removeFromSuperview];
                // change the new vc's view's frame and show
                [[[_transitionView subviews] objectAtIndex:0] setFrame:CGRectMake(0, 0, _transitionView.frame.size.width, _transitionView.frame.size.height)];
                // set selected vc
                [self setSelectedViewController:[_viewControllers objectAtIndex:[self selectedViewControllerIndex]+1]];
                //change the menu
                [_menuView changeButtonStateAtIndex:[self selectedViewControllerIndex]];
            }];
        } else {
            //cancel the drag, resume to before
            [UIView animateWithDuration:0.5 animations:^{
                _transitionView.center = CGPointMake(SCREEN_WIDTH, _transitionView.center.y);
            } completion:^(BOOL finished) {
                //change the frame to one screen
                _transitionView.frame = CGRectMake(0, _transitionView.frame.origin.y, SCREEN_WIDTH, _transitionView.frame.size.height);
                // remove the new vc's view
                [[[_transitionView subviews] objectAtIndex:1] removeFromSuperview];
                // resume the old vc's view's frame and show
                [[[_transitionView subviews] objectAtIndex:0] setFrame:CGRectMake(0, 0, _transitionView.frame.size.width, _transitionView.frame.size.height)];
            }];
        }
    }
    
    
    if (_direction == ZLPanGestureSwipeDirectionNone) {
        [UIView animateWithDuration:0.5 animations:^{
            _transitionView.center = CGPointMake(SCREEN_WIDTH/2, _transitionView.center.y);
        } completion:^(BOOL finished) {
            
        }];
    }
    
}

- (void)draggableViewBeganDragging:(DraggableView *)view gestureDirection:(ZLPanGestureSwipeDirection)direction
{
    _direction = direction;
    switch (direction) {
        case ZLPanGestureSwipeDirectionNoneLeft:
            if ([self selectedViewControllerIndex] == [_viewControllers count] -1 ) {
                _direction = ZLPanGestureSwipeDirectionNone;
                //the right most one， do nothing here
                // you can add animation or toast to remind the user that there is no more vc on the right
            } else {
                UIView *rightView = [[_viewControllers objectAtIndex:([self selectedViewControllerIndex] +1)] view];
                [rightView setFrame:[[self transitionView] bounds]];
                [rightView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
                rightView.center = CGPointMake(SCREEN_WIDTH + SCREEN_WIDTH/2, rightView.center.y);
                [[self transitionView] addSubview:rightView];
                //now transitionView has two view, one is the current vc's view, the other is above right view
                // right view will be dragged from right to replace the position of current view
                [[self transitionView] setFrame:CGRectMake(_transitionView.frame.origin.x, _transitionView.frame.origin.y, SCREEN_WIDTH*2, _transitionView.frame.size.height)];
            }
            break;
            
        case ZLPanGestureSwipeDirectionNoneRight:
            if ([self selectedViewControllerIndex] == 0) {
                _direction = ZLPanGestureSwipeDirectionNone;
                if (self.navigationController) {
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            } else {
                _transitionView.clipsToBounds = NO;
                UIView *leftView = [[_viewControllers objectAtIndex:([self selectedViewControllerIndex] -1)] view];
                [leftView setFrame:[[self transitionView] bounds]];
                [leftView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
                [[self transitionView] addSubview:leftView];
                leftView.center = CGPointMake(-SCREEN_WIDTH/2, leftView.center.y);
            }
            break;
            
        default:
            //do nothing here
            break;
    }
    
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
