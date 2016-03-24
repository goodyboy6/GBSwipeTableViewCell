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

/**
 * swipe left table view Cell
 */
@interface GBSwipeTableViewCell : UITableViewCell

/**
 *  add gesture to swipe to left
 *
 *  @param handler  return the view that will be autolayouted in the right side of the cell. the width of the view should be provided, and the height or origin will be ignored. NOTE: the subview of the view should be autolayouted for dynamic cell height.
 *  @param completion when open status changed, call back.
 */
- (void)addSwipeLeftGestureConfigureHandler:(UIView *(^)())handler completion:(void(^)(GBSwipeTableViewCell *cell, UIView *rightView, GBStatus status))completion;
- (void)removeSwipeLeftGesture;//remove the gesture and view added.

- (void)openManual;

- (void)closeManual;

@end

@interface UIButton (GBBlock)

- (void)addControlEvent:(UIControlEvents)event callBack:(void(^)(UIButton *))callBack;

@end

