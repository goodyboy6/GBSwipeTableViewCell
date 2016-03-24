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
    
    UIView *_rightView;
    
    TouchView *_touchView;
}

@property (readwrite, nonatomic)  GBStatus status;

@end

@implementation GBSwipeTableViewCell
#pragma mark - life cycle

#pragma mark - open api
- (void)removeSwipeLeftGesture
{
    _status = GBStatusClose;
    [_rightView removeFromSuperview];
    
    [self removeGestureRecognizer:_panGestureRecognizer];
    _panGestureRecognizer = nil;
}

- (void)addSwipeLeftGestureConfigureHandler:(UIView *(^)())handler completion:(void(^)(GBSwipeTableViewCell *cell, UIView *rightView, GBStatus status))completion
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    //reset status
    _status = GBStatusClose;
    _swipeStatusHandler = [completion copy];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    _panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_panGestureRecognizer];
    
    [_rightView removeFromSuperview];
    _rightView = handler();
    [self insertSubview:_rightView belowSubview:self.contentView];

    //add subview constraints
    _rightView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_rightView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_rightView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_rightView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_rightView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_rightView.frame.size.width]];
}

- (void)openManual
{
    [UIView animateWithDuration:.3 animations:^{
        self.contentView.frame = ({
            CGRect f = self.contentView.frame;
            f.origin.x = - _rightView.frame.size.width;
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
    _swipeStatusHandler(self, _rightView, _status);
    
    if (_status == GBStatusOpen) {
        [_touchView removeFromSuperview];
        
        UITableView *tableView = [self tableView];
        _touchView = [[TouchView alloc] initWithFrame:tableView.bounds];
        [tableView addSubview:_touchView];
        
        __weak typeof(self) weakSelf = self;
        _touchView.tappedCallBack = ^(UIView *view, CGPoint point, UIEvent *event){
            
            typeof(self) strongSelf = weakSelf;
            CGRect rect = [strongSelf->_rightView.superview convertRect:strongSelf->_rightView.frame toView:view];
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
BOOL shouldSwipe(CGPoint start, CGPoint end){
    BOOL should = start.x - end.x > 0 && (start.x - end.x > fabs(start.y - end.y));
    if (should) {
        NSLog(@"%@:%@, %f, %f", NSStringFromCGPoint(start), NSStringFromCGPoint(end), start.x - end.x, fabs(start.y - end.y));
    }
    return should;
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
            
            if (shouldSwipe(_panStartPoint, [g locationInView:self.window])){//_panStartPoint - [g locationInView:self].x > 20) {
                self.contentView.frame = ({
                    CGRect f = self.contentView.frame;
                    f.origin.x = [g locationInView:self].x - _panStartPoint.x;
                    f;
                });
            }
        break;
        case UIGestureRecognizerStateEnded:
            if (_status == GBStatusOpen) {
                return;
            }
            
            if (abs((int)self.contentView.frame.origin.x) > _rightView.frame.size.width/2) {
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
