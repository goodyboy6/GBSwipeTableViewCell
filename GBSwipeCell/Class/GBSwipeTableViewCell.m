//
//  GBSwipeCell.m
//  GBSwipeCell
//
//  Created by yixiaoluo on 16/3/3.
//  Copyright © 2016年 yixiaoluo. All rights reserved.
//

#import "GBSwipeTableViewCell.h"
#import <objc/runtime.h>

@interface TouchView : UIView

@property (copy, nonatomic) BOOL (^tappedCallBack)(UIView *view, CGPoint point, UIEvent *event);

@end

@implementation TouchView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
     return self.tappedCallBack(self, point, event);
}

@end


static char kGBBlockKey;
@implementation UIButton (GBBlock)

- (void)addControlEvent:(UIControlEvents)event callBack:(void(^)(UIButton *))callBack;
{
    objc_setAssociatedObject(self, &kGBBlockKey, callBack, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
}

- (void)callActionBlock:(id)sender
{
    void(^block)(UIButton *) = objc_getAssociatedObject(self, &kGBBlockKey);
    block(self);
}

@end

@interface GBSwipeTableViewCell () <UIGestureRecognizerDelegate> {
    
    UIPanGestureRecognizer *_panGestureRecognizer;
    
    CGPoint _panStartPoint;
    
    void(^_swipeStatusHandler)(GBSwipeTableViewCell *cell, UIView *rightView, GBStatus status);
    
    UIView *_viewSwiped;
    
    TouchView *_touchView;
    
    GBSwipeDirection _direction;
}

@property (readwrite, nonatomic)  GBStatus status;

@end

@implementation GBSwipeTableViewCell
#pragma mark - life cycle

#pragma mark - open APIs
- (void)addSwipeWithDirection:(GBSwipeDirection)direction configure:(UIView *(^)())handler completion:(void(^)(GBSwipeTableViewCell *cell, UIView *view, GBStatus status))completion
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    
    _status = GBStatusClose;
    _direction = direction;
    _swipeStatusHandler = [completion copy];
    _viewSwiped = handler();

    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    _panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_panGestureRecognizer];
    
    [_viewSwiped removeFromSuperview];
    [self insertSubview:_viewSwiped belowSubview:self.contentView];
    
    //add subview constraints
    _viewSwiped.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutAttribute attribute = _direction == GBSwipeDirectionToRight ? NSLayoutAttributeLeading : NSLayoutAttributeTrailing;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_viewSwiped attribute:attribute relatedBy:NSLayoutRelationEqual toItem:self attribute:attribute multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_viewSwiped attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_viewSwiped attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-1/[UIScreen mainScreen].scale]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_viewSwiped attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_viewSwiped.frame.size.width]];
}

- (void)removeSwipe
{
    _status = GBStatusClose;
    _direction = GBSwipeDirectionToLeft;
    _swipeStatusHandler = nil;
    [self removeGestureRecognizer:_panGestureRecognizer];
    _panGestureRecognizer = nil;
}

- (void)openManual
{
    [UIView animateWithDuration:.3 animations:^{
        self.contentView.frame = ({
            CGRect f = self.contentView.frame;
            f.origin.x = _viewSwiped.frame.size.width * ((_direction == GBSwipeDirectionToLeft) ? -1 : 1);
            f;
        });
    } completion:^(BOOL finished) {
        self.status = GBStatusOpen;
    }];
}

- (void)closeManual
{
    [UIView animateWithDuration:.3 animations:^{
        self.contentView.frame = ({
            CGRect f = self.contentView.frame;
            f.origin.x = 0;
            f;
        });
    } completion:^(BOOL finished) {
        self.status = GBStatusClose;
    }];
}

#pragma mark - setter
- (void)setStatus:(GBStatus)status
{
    _status = status;
    _swipeStatusHandler(self, _viewSwiped, _status);
    
    if (_status == GBStatusOpen) {
        [_touchView removeFromSuperview];
        
        UITableView *tableView = [self tableView];
        _touchView = [[TouchView alloc] initWithFrame:tableView.bounds];
        [tableView addSubview:_touchView];
        
        __weak typeof(self) weakSelf = self;
        _touchView.tappedCallBack = ^(UIView *view, CGPoint point, UIEvent *event){
            
            typeof(self) strongSelf = weakSelf;
            CGRect rect = [strongSelf->_viewSwiped.superview convertRect:strongSelf->_viewSwiped.frame toView:view];
            if (CGRectContainsPoint(rect, point)) {
                return NO;
            }else{
                [view removeFromSuperview];
                [weakSelf closeManual];
                
                return YES;
            }
        };
    }else{
        [_touchView removeFromSuperview];
    }
}

- (UITableView *)tableView
{
    UIView *superView = self.superview;
    while (![superView isKindOfClass:[UITableView class]]) {
        superView = superView.superview;
    }
    if ([superView isKindOfClass:[UITableView class]]) {
        return (UITableView *)superView;
    }else{
        return nil;
    }
}

#pragma mark - event response
static inline BOOL shouldSwipe(CGPoint start, CGPoint end, GBSwipeDirection direction) {
    
    CGFloat xDistance = start.x - end.x;
    CGFloat yDistance = start.y - end.y;
    BOOL should = ((direction == GBSwipeDirectionToLeft) ?  xDistance > 0 : xDistance < 0) && (fabs(xDistance) > fabs(yDistance));
    return should;
}

static inline CGFloat distanceBetween(CGPoint start, CGPoint end, GBSwipeDirection direction) {
    return (direction == GBSwipeDirectionToLeft) ?  (end.x - start.x) : (end.x - start.x);
}

- (void)panHandler:(UIPanGestureRecognizer *)g
{
    switch (g.state) {
        case UIGestureRecognizerStateBegan:
            if (_status == GBStatusOpen) {
                [self closeManual];
            }else{
                _panStartPoint = [g locationInView:self.window];
            }
        break;
        case UIGestureRecognizerStateChanged:
            if (_status == GBStatusOpen) {
                return;
            }
            
            if (shouldSwipe(_panStartPoint, [g locationInView:self.window], _direction)){
                self.contentView.frame = ({
                    CGRect f = self.contentView.frame;
                    f.origin.x = distanceBetween(_panStartPoint, [g locationInView:self.window], _direction);
                    f;
                });
            }
        break;
        case UIGestureRecognizerStateEnded:
            if (_status == GBStatusOpen) {
                return;
            }
            
            if (abs((int)self.contentView.frame.origin.x) > _viewSwiped.frame.size.width/2) {
                [self openManual];
            }else{
                [self closeManual];
            }
        break;
        default:
            break;
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end

@implementation GBSwipeTableViewCell (NSDeprecated)

- (void)removeSwipeLeftGesture
{
    [self removeSwipe];
}

- (void)addSwipeLeftGestureConfigureHandler:(UIView *(^)())handler completion:(void(^)(GBSwipeTableViewCell *cell, UIView *rightView, GBStatus status))completion
{
    [self addSwipeWithDirection:GBSwipeDirectionToLeft configure:handler completion:completion];
}

@end
