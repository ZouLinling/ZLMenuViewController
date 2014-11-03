//
// Created by Florian on 21/04/14.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "DraggableView.h"


@implementation DraggableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self addGestureRecognizer:recognizer];
}

- (void)didPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer translationInView:self.superview];
    self.center = CGPointMake(self.center.x + point.x, self.center.y); //only draggable on X axis
    [recognizer setTranslation:CGPointZero inView:self.superview];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [recognizer velocityInView:self.superview];
        velocity.y = 0;
        [self.delegate draggableView:self draggingEndedWithVelocity:velocity];
    } else if (recognizer.state == UIGestureRecognizerStateBegan) {
        ZLPanGestureSwipeDirection direction = ZLPanGestureSwipeDirectionNone;
        if (point.x > 0) {
            direction = ZLPanGestureSwipeDirectionNoneRight;
        } else if (point.x < 0) {
            direction = ZLPanGestureSwipeDirectionNoneLeft;
        }
        [self.delegate draggableViewBeganDragging:self gestureDirection:direction];
    }
}

@end