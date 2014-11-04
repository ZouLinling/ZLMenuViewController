//
//  SGFocusImageFrame.h
//  ScrollViewLoop
//
//  Created by Vincent Tang on 13-7-18.
//  Improved by ZouLinling on 14-10-30.
//  Copyright (c) 2013年 Vincent Tang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGFocusImageItem.h"
@class SGFocusImageFrame;

#pragma mark - SGFocusImageFrameDelegate
@protocol SGFocusImageFrameDelegate <NSObject>
@optional
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item;
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame currentItem:(int)index;

@end


@interface SGFocusImageFrame : UIView <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) id<SGFocusImageFrameDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableArray *itemsArray;
@property (nonatomic) BOOL isAutoPlay;
@property CGFloat timeInterval;

- (id)initWithFrame:(CGRect)frame focusImageItems:(SGFocusImageItem *)items, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initWithFrame:(CGRect)frame imageItems:(NSArray *)items;
- (void)scrollToIndex:(int)aIndex;

/**
 *  更新图片
 *
 *  @param aArray SGFocusImageItem数组
 */
-(void)changeImageViewsContent:(NSArray *)aArray;

@end
