//
// Created by Florian on 21/04/14.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

typedef enum :NSInteger {
    
    ZLPanGestureSwipeDirectionNone,
    
    ZLPanGestureSwipeDirectionNoneUp,
    
    ZLPanGestureSwipeDirectionNoneDown,
    
    ZLPanGestureSwipeDirectionNoneRight,
    
    ZLPanGestureSwipeDirectionNoneLeft
    
} ZLPanGestureSwipeDirection;


@class DraggableView;

@protocol DraggableViewDelegate

- (void)draggableView:(DraggableView *)view draggingEndedWithVelocity:(CGPoint)velocity;
- (void)draggableViewBeganDragging:(DraggableView *)view gestureDirection:(ZLPanGestureSwipeDirection)direction;

@end


@interface DraggableView : UIView

@property (nonatomic, weak) id <DraggableViewDelegate> delegate;

@end