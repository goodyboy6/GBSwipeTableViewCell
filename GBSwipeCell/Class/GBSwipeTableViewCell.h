//
//  GBSwipeCell.h
//  GBSwipeCell
//
//  Created by yixiaoluo on 16/3/3.
//  Copyright © 2016年 yixiaoluo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    GBStatusClose,
    GBStatusOpen,
} GBStatus;

typedef enum : NSUInteger {
    GBSwipeDirectionToLeft,
    GBSwipeDirectionToRight,
    GBSwipeDirectionToBoth// Not available Now
} GBSwipeDirection;

@interface UIButton (GBBlock)
- (void)addControlEvent:(UIControlEvents)event callBack:(void(^)(UIButton *))callBack;
@end

/**
 * support add swipe to left or right, not both
 */
@interface GBSwipeTableViewCell : UITableViewCell

/**
 *  swipe to left or right
 *
 *  @param handler  return the view that will be autolayouted in the right side of the cell. the width of the view should be provided, and the height or origin will be ignored. NOTE: the subview of the view should be autolayouted for dynamic cell height.
 *  @param completion when open status changed, call back.
 */
- (void)addSwipeWithDirection:(GBSwipeDirection)direction configure:(UIView *(^)())handler completion:(void(^)(GBSwipeTableViewCell *cell, UIView *view, GBStatus status))completion;
- (void)removeSwipe;//remove the gesture and view added above

//manual action
- (void)openManual;
- (void)closeManual;

@end

@interface GBSwipeTableViewCell (NSDeprecated)

- (void)addSwipeLeftGestureConfigureHandler:(UIView *(^)())handler completion:(void(^)(GBSwipeTableViewCell *cell, UIView *rightView, GBStatus status))completion NS_DEPRECATED_IOS(2_0, 9_0);//use addSwipeWithDirection:configure:completion: instead
- (void)removeSwipeLeftGesture NS_DEPRECATED_IOS(2_0, 9_0);//use removeSwipe instead

@end


