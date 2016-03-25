//
//  GBSwipeCell.h
//  GBSwipeCell
//
//  Created by yixiaoluo on 16/3/3.
//  Copyright © 2016年 yixiaoluo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    GBStatusClose,
    GBStatusOpen,
} GBStatus;

typedef enum : NSUInteger {
    GBSwipeDirectionToLeft,
    GBSwipeDirectionToRight,
    GBSwipeDirectionToBoth
} GBSwipeDirection;

//UIButton with touch event callback
@interface UIButton (GBBlock)
- (void)addControlEvent:(UIControlEvents)event callBack:(void(^)(UIButton *))callBack;
@end

//Support add swipe to left or/both right
@interface GBSwipeTableViewCell : UITableViewCell

@property (readonly, nonatomic)  GBStatus status NS_AVAILABLE_IOS(7_0);
@property (readonly, nonatomic)  GBSwipeDirection direction NS_AVAILABLE_IOS(7_0);

/**
 *  swipe to left or right. The method will change cell.selectionStyle and cell.contentView.backgroundColor which should 'opaque', if it unnecessary, change then after the method called.
 *
 *  @param handler  return the view that will be autolayouted in the right side of the cell. the width of the view should be provided, and the height or origin will be ignored. NOTE: the subview of the view should be autolayouted for dynamic cell height.
 *  @param completion when open status changed, call back.
 */
- (void)addSwipeWithDirection:(GBSwipeDirection)direction provideViewHandler:(UIView *(^)())handler statusDidChangedHandler:(void(^)(GBSwipeTableViewCell *cell, UIView *viewThatProvided))completion NS_AVAILABLE_IOS(7_0);
- (void)removeSwipe NS_AVAILABLE_IOS(7_0);//remove the gesture and view added above

//manual action
- (void)openManual NS_AVAILABLE_IOS(2_0);
- (void)closeManual NS_AVAILABLE_IOS(2_0);

@end

@interface GBSwipeTableViewCell (NSDeprecated)

- (void)addSwipeLeftGestureConfigureHandler:(UIView *(^)())handler completion:(void(^)(GBSwipeTableViewCell *cell, UIView *rightView, GBStatus status))completion NS_DEPRECATED_IOS(2_0, 7_0);//use addSwipeWithDirection:configure:completion: instead
- (void)removeSwipeLeftGesture NS_DEPRECATED_IOS(2_0, 7_0);//use removeSwipe instead

@end

NS_ASSUME_NONNULL_END


