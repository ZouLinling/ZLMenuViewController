//
//  ZLMenuViewController.m
//  BaseProject
//
//  Created by Zou on 10/28/14.
//  Copyright (c) 2014 Zou. All rights reserved.
//

#import "ZLMenuViewController.h"
#import <objc/runtime.h>

/**************
本类提供了三种切换动画实现的方案
方案一: USE_SWIPE_ANIMATION ＝ YES
 transitionView添加了对SwipeGesture的响应，当手势发生时，会把原来vc的view从transitionView删除并添加新的view进去
 然后根据swipe的方向，在指定时间之内完成frame的移动以实现动画，该动画开始后不能取消。
 transitionView从始至终只保留当前显示的ViewController的view对象，所需内存较少。
 
方案一: USE_SWIPE_ANIMATION ＝ NO and USE_THREE_VIEWS ＝ NO
 因第一种方案无法跟随手指移动，不是很满意，所以实现了这个方案。
 transitionView添加了PanGesture的响应，当手势开始时，根据手势的方向，添加左侧或者右侧的ViewController的view到transitionView的左侧和右侧。
 该方案使用了两种方法来实现frame控制
 第一种：view添加完成之后，根据view所在的位置，扩大transitionView的frame，然后根据手势移动transitionView，动画完成之后，缩小transitionView的frame到正常，因为缩小之后，子view相对父view的位置也需要相应的调整。
 第二种：view添加完成之后，设置_transitionView.clipsToBounds = NO 使得当子view超过父view时也能够显示（方案三也是基于此）。根据手势的方向移动_transitionView，当_transitionView到达指定位置之后，重新设置_transitionView的frame并删除不在显示区域内的子view
 这个方案有个bug，根据PanGesture的状态，在开始时，还是有可能无法得知方向，这个时候，无法完成VC的切换
 transitionView在手势开始到结束时，持有当前的VC的view以及目标VC的view，动画完成或者取消之后，不需要显示的那个会被删除
 
 方案三：
 因为第二种的bug，以及左右的view是在手势发生时加载，如果左右的VC有耗时操作，那么会有卡顿，所以最终默认使用了方案三
 在页面加载完成时，就会把左右VC的view加到transitionView的左右两侧，基于_transitionView.clipsToBounds = NO属性，采用
 和方案二中的第二种方法类似的逻辑，实现动画。
 transitionView从始至终会保留有左右两侧VC的view的对象，所需内存较多。
 **************/

#define  USE_SWIPE_ANIMATION NO //two types animation when change vc use gesture

#define USE_THREE_VIEWS YES

#define LEFT_VIEW_TAG -1

#define MIDDLE_VIEW_TAG 0

#define RIGHT_VIEW_TAG 1



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
        if (USE_THREE_VIEWS && !USE_SWIPE_ANIMATION) {
            [self addLeftAndRightView];
        }
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[_transitionView viewWithTag:LEFT_VIEW_TAG] removeFromSuperview];
}

/**
 *  方案一
 */
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
    if (USE_THREE_VIEWS) {
        /**************
         这里使用了和ELSE中不同的方案来实现动画：方案三
         每当选中一个VC之后，_transitionView中会添加当前VC的view以及左右两侧的view（最左/最右做额外处理）
         关键：_transitionView.clipsToBounds = NO 这边必须为NO，否则没有效果
         通过移动_transitionView的frame来实现左右view的切换
         要使用这个方案，需要 USE_SWIPE_ANIMATION ＝ NO 并且 USE_THREE_VIEWS = YES
         **************/
        
        if (_direction == ZLPanGestureSwipeDirectionNoneRight) {
            if (((CGFloat)(abs(_transitionView.frame.origin.x))/SCREEN_WIDTH - 1.0/3.0) >= 0.0) {
                [UIView animateWithDuration:0.5 animations:^{
                    //view's X dragged from ZERO to SCREEN_WIDTH
                    _transitionView.center = CGPointMake(SCREEN_WIDTH + SCREEN_WIDTH/2, _transitionView.center.y);
                } completion:^(BOOL finished) {
                    //change the frame to one screen
                    _transitionView.frame = CGRectMake(0, _transitionView.frame.origin.y, SCREEN_WIDTH, _transitionView.frame.size.height);
                    for (UIView *view in _transitionView.subviews) {
                        [view removeFromSuperview];
                    }
                    // set selected vc
                    [self setSelectedViewController:[_viewControllers objectAtIndex:[self selectedViewControllerIndex]-1]];
                    //change the menu
                    [_menuView changeButtonStateAtIndex:[self selectedViewControllerIndex]];
                }];
            }else {
                //cancel the drag, resume to before
                [UIView animateWithDuration:0.5 animations:^{
                    _transitionView.center = CGPointMake(SCREEN_WIDTH/2, _transitionView.center.y);
                } completion:^(BOOL finished) {
                }];
            }
        }
        
        if (_direction == ZLPanGestureSwipeDirectionNoneLeft) {
            if (((CGFloat)abs(_transitionView.frame.origin.x)/SCREEN_WIDTH - 1.0/3.0 ) >= 0.0) {
                [UIView animateWithDuration:0.5 animations:^{
                    //view's X dragged from ZERO to -SCREEN_WIDTH
                    _transitionView.center = CGPointMake(-SCREEN_WIDTH/2, _transitionView.center.y);
                } completion:^(BOOL finished) {
                    //change the frame to one screen
                    _transitionView.frame = CGRectMake(0, _transitionView.frame.origin.y, SCREEN_WIDTH, _transitionView.frame.size.height);
                    for (UIView *view in _transitionView.subviews) {
                        [view removeFromSuperview];
                    }
                    // set selected vc
                    [self setSelectedViewController:[_viewControllers objectAtIndex:[self selectedViewControllerIndex]+1]];
                    //change the menu
                    [_menuView changeButtonStateAtIndex:[self selectedViewControllerIndex]];
                }];
            } else {
                //cancel the drag, resume to before
                [UIView animateWithDuration:0.5 animations:^{
                    _transitionView.center = CGPointMake(SCREEN_WIDTH/2, _transitionView.center.y);
                } completion:^(BOOL finished) {
                }];
            }
        }
        
        if (_direction == ZLPanGestureSwipeDirectionNone) {
            [UIView animateWithDuration:0.5 animations:^{
                _transitionView.center = CGPointMake(SCREEN_WIDTH/2, _transitionView.center.y);
            } completion:^(BOOL finished) {
                
            }];
        }
    } else {
        /**************
         方案二
         注意，左滑和右滑分别使用了两种方法来控制frame的变化
         左滑是在屏幕的左侧添加了一个view，同时_transitionView的宽度从SCREEN_WIDTH扩大了一倍到2*SCREEN_WIDTH，然后依次往左滑动，最后中心点落在y轴上（x＝0），动画结束后把frame变回原样，同时删除了旧的view，新的view也设置到和_transitionView的frame一致
         右滑是在屏幕的左侧添加了一个view，但是这里并没有扩大_transitionView的frame来显示，而是利用了_transitionView.clipsToBounds = NO; 来显示超出_transitionView边界的view，最后_transitionView到了屏幕的右侧。动画结束后，调整_transitionView的frame为当前显示区域，同时删除了旧的view，这里可以不用重新设置新view的frame，因为动画结束后它的frame就已经是我们期望的。
         **************/
        
        
        
        //方案二 第二种实现
        if (_direction == ZLPanGestureSwipeDirectionNoneRight) {
            //如果往右滑动时_transitionView已经超过了屏幕的三分之一，则当作用户想往右滑动，自动完成
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
        //方案二 第一种实现
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
    
}

- (void)draggableViewBeganDragging:(DraggableView *)view gestureDirection:(ZLPanGestureSwipeDirection)direction
{
    _direction = direction;
    if (USE_THREE_VIEWS) {
        if ([self selectedViewControllerIndex] == 0 ) {
            if (direction == ZLPanGestureSwipeDirectionNoneRight) {
                _direction = ZLPanGestureSwipeDirectionNone;
                if (self.navigationController) {
                    [self.navigationController popViewControllerAnimated:YES];
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
        }
        
        if ([self selectedViewControllerIndex] == [_viewControllers count] -1) {
            if (direction == ZLPanGestureSwipeDirectionNoneLeft) {
                _direction = ZLPanGestureSwipeDirectionNone;
            }
        }
        
    } else {
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
    
}

-(void)addLeftAndRightView
{
    UIView *leftView;
    UIView *middleView;
    UIView *rightView;
    if ([self selectedViewControllerIndex] == 0 ) {
        leftView = nil;
    } else {
        leftView = [[_viewControllers objectAtIndex:([self selectedViewControllerIndex] - 1)] view];
        leftView.tag = LEFT_VIEW_TAG;
    }
    
    if ([self selectedViewControllerIndex] == [_viewControllers count] -1) {
        rightView = nil;
    } else {
        rightView = [[_viewControllers objectAtIndex:([self selectedViewControllerIndex] + 1)] view];
        rightView.tag = RIGHT_VIEW_TAG;
    }
    middleView = [_transitionView.subviews firstObject];
    middleView.tag = MIDDLE_VIEW_TAG;
    if (leftView) {
        [leftView setFrame:[[self transitionView] bounds]];
        [leftView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [_transitionView addSubview:leftView];
        [leftView setCenter:CGPointMake(-SCREEN_WIDTH/2, leftView.center.y)];
    }
    if (rightView) {
        [rightView setFrame:[[self transitionView] bounds]];
        [rightView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [_transitionView addSubview:rightView];
        if (rightView.center.x == 0 && rightView.center.y == 0) {
            [rightView setFrame:CGRectMake(SCREEN_WIDTH, 0, 0, 0)];
        } else {
            [rightView setCenter:CGPointMake(SCREEN_WIDTH + SCREEN_WIDTH/2, rightView.center.y)];
        }
        
    }
    _transitionView.clipsToBounds = NO; //must be no
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
