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
    
    void(^_swipeStatusHandler)(GBSwipeTableViewCell *cell, UIView *viewThatProvided);
    UIView *(^_provideViewHandler)(GBSwipeTableViewCell *cell);
    
    UIView *_viewThatProvided;
    
    TouchView *_touchView;
    
    GBSwipeDirection _direction;
}

@property (readwrite, nonatomic)  GBStatus status;
@property (readwrite, nonatomic)  GBSwipeDirection direction;

@end

@implementation GBSwipeTableViewCell
#pragma mark - life cycle

#pragma mark - open APIs
- (void)addSwipeWithDirection:(GBSwipeDirection)direction provideViewHandler:(UIView *(^)(GBSwipeTableViewCell *cell))handler statusDidChangedHandler:(void(^)(GBSwipeTableViewCell *cell, UIView *viewThatProvided))completion;
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor whiteColor];

    [self removeSwipe];

    _status = GBStatusClose;
    _direction = direction;
    _swipeStatusHandler = [completion copy];
    _provideViewHandler = [handler copy];

    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    _panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_panGestureRecognizer];
}

- (void)removeSwipe
{
    _status = GBStatusClose;
    _direction = GBSwipeDirectionToLeft;
    _swipeStatusHandler = NULL;
    _provideViewHandler = NULL;
    [self removeGestureRecognizer:_panGestureRecognizer];
    _panGestureRecognizer = nil;
    [_viewThatProvided removeFromSuperview];
    _viewThatProvided = nil;
}

- (void)openManual
{
    dispatch_block_t openAmianted = ^{
        [UIView animateWithDuration:.3 animations:^{
            self.contentView.frame = ({
                CGRect f = self.contentView.frame;
                f.origin.x = _viewThatProvided.frame.size.width *(f.origin.x == 0 ? -1 :  (f.origin.x/fabs(f.origin.x)));
                f;
            });
        } completion:^(BOOL finished) {
            self.status = GBStatusOpen;
        }];
    };
    if (![self willAddRevealingView]) {
        openAmianted();
    }else{
        [self showRevealingView];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            openAmianted();
        });
    }

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

#pragma mark - private
- (BOOL)willAddRevealingView
{
    if (!_provideViewHandler) {
        return NO;
    }
    
    if (_viewThatProvided && _viewThatProvided.superview) {
        return NO;
    }
    return YES;
}

- (void)showRevealingView
{
    if (![self willAddRevealingView]) {
        return;
    }
    
    _viewThatProvided = _provideViewHandler(self);
    [self insertSubview:_viewThatProvided belowSubview:self.contentView];
    
    //add subview constraints
    _viewThatProvided.translatesAutoresizingMaskIntoConstraints = NO;
    if (_direction != GBSwipeDirectionToBoth) {
        NSLayoutAttribute attribute = _direction == GBSwipeDirectionToRight ? NSLayoutAttributeLeading : NSLayoutAttributeTrailing;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_viewThatProvided attribute:attribute relatedBy:NSLayoutRelationEqual toItem:self attribute:attribute multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_viewThatProvided attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_viewThatProvided.frame.size.width]];
    }else{
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_viewThatProvided attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_viewThatProvided attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    }
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_viewThatProvided attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_viewThatProvided attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-1/[UIScreen mainScreen].scale]];
}

#pragma mark - setter && getter
- (void)setStatus:(GBStatus)status
{
    _status = status;
    if (_swipeStatusHandler) {
        _swipeStatusHandler(self, _viewThatProvided);
    }
    
    if (_status == GBStatusOpen) {
        [_touchView removeFromSuperview];
        
        UITableView *tableView = [self tableView];
        _touchView = [[TouchView alloc] initWithFrame:tableView.bounds];
        [tableView addSubview:_touchView];
        
        __weak typeof(self) weakSelf = self;
        _touchView.tappedCallBack = ^(UIView *view, CGPoint point, UIEvent *event){
            
            typeof(self) strongSelf = weakSelf;
            CGRect rect = [strongSelf->_viewThatProvided.superview convertRect:strongSelf->_viewThatProvided.frame toView:view];
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

#pragma mark - pan gesture handler
static inline BOOL shouldSwipe(CGPoint start, CGPoint end, GBSwipeDirection direction) {
    
    CGFloat xDistance = start.x - end.x;
    CGFloat yDistance = start.y - end.y;
    
    BOOL isValidDirection = (fabs(xDistance) > fabs(yDistance));
    
    BOOL isCorrectDirection = YES;
    switch (direction) {
        case GBSwipeDirectionToLeft:
            isCorrectDirection = (xDistance > 0);
            break;
        case GBSwipeDirectionToRight:
            isCorrectDirection = (xDistance < 0);
            break;
        default:
            isCorrectDirection = YES;
            break;
    }
    
    return isCorrectDirection && isValidDirection;
}

static inline CGFloat offsetBetween(CGPoint start, CGPoint end, GBSwipeDirection direction) {
    return end.x - start.x;
}

static inline CGFloat shouldOpen(UIView *contentView, UIView *viewThatProvided) {
    return fabs(contentView.frame.origin.x) >= MIN(contentView.frame.size.width/3, viewThatProvided.frame.size.width);
}

- (void)panHandler:(UIPanGestureRecognizer *)g
{
    switch (g.state) {
        case UIGestureRecognizerStateBegan:
            if (_status == GBStatusOpen) {
                return;
            }
            
            _panStartPoint = [g locationInView:self.window];
            [self showRevealingView];
        break;
        case UIGestureRecognizerStateChanged:
            if (_status == GBStatusOpen) {
                return;
            }
            
            if (shouldSwipe(_panStartPoint, [g locationInView:self.window], _direction)){
                self.contentView.frame = ({
                    CGRect f = self.contentView.frame;
                    f.origin.x = offsetBetween(_panStartPoint, [g locationInView:self.window], _direction);
                    f;
                });
            }
        break;
        case UIGestureRecognizerStateEnded:
            if (_status == GBStatusOpen) {
                return;
            }
            
            if (shouldOpen(self.contentView, _viewThatProvided)) {
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
    __weak typeof(self) weakSelf = self;
    [self addSwipeWithDirection:GBSwipeDirectionToLeft provideViewHandler:^UIView * _Nonnull(GBSwipeTableViewCell * _Nonnull cell) {
        return handler();
    } statusDidChangedHandler:^(GBSwipeTableViewCell *cell, UIView *viewThatProvided) {
        completion(cell, viewThatProvided, weakSelf.status);
    }];
}

@end
